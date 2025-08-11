(function(){
  const { API_BASE, CLOUDINARY, thumb } = window.LIVEE_CONFIG || {};
  const notice = document.getElementById('rfNotice');

  function showNotice(msg, isError=true){
    notice.textContent = msg;
    notice.hidden = false;
    notice.style.background = isError ? '#fff4f4' : '#f5fff5';
    notice.style.color = isError ? '#a32020' : '#0f6b2b';
    notice.style.borderColor = isError ? '#ffd6d6' : '#b9efc9';
  }

  // 간단 api 래퍼 (전역 api 있으면 사용)
  const api = window.api || (async function api(path, opts={}){
    const headers = {'Content-Type':'application/json', ...(opts.headers||{})};
    const t = localStorage.getItem('liveeToken');
    if (t) headers.Authorization = `Bearer ${t}`;
    const res = await fetch(`${API_BASE}${path}`, {...opts, headers});
    const data = await res.json().catch(()=>({ok:false,message:'INVALID_JSON'}));
    if (res.status === 401) {
      ['liveeToken','liveeName','liveeTokenExp'].forEach(k=>localStorage.removeItem(k));
      location.href = '/alpa/login.html';
      return;
    }
    if (!res.ok || data.ok===false) throw new Error(data.message||`HTTP_${res.status}`);
    return data;
  });

  // 권한 확인(브랜드만 접근)
  async function guardRole(){
    try{
      const me = await api('/users/me');
      if (!me || me.role !== 'brand') {
        throw new Error('브랜드 계정만 공고를 등록할 수 있습니다.');
      }
    }catch(err){
      showNotice('접근 권한이 없습니다. 브랜드 계정으로 로그인해 주세요.', true);
      disableForm(true);
      throw err;
    }
  }

  function disableForm(disabled){
    document.querySelectorAll('#recruitForm input, #recruitForm textarea, #recruitForm button')
      .forEach(el => el.disabled = !!disabled);
  }

  // Cloudinary 업로드
  async function uploadToCloudinary(file){
    if(!CLOUDINARY || !CLOUDINARY.uploadApi) throw new Error('Cloudinary 설정 누락');
    const fd = new FormData();
    fd.append('file', file);
    fd.append('upload_preset', CLOUDINARY.uploadPreset);

    const prog = document.getElementById('rfUploadProg');
    prog.hidden = false; prog.value = 0;

    // XMLHttpRequest로 진행률 표시
    const url = CLOUDINARY.uploadApi;
    const headers = {}; // FormData라 Content-Type 자동
    const xhr = new XMLHttpRequest();
    const p = new Promise((resolve, reject)=>{
      xhr.upload.addEventListener('progress', (e)=>{
        if(e.lengthComputable){ prog.value = Math.round(e.loaded / e.total * 100); }
      });
      xhr.onreadystatechange = ()=>{
        if(xhr.readyState === 4){
          prog.hidden = true;
          try{
            if(xhr.status >= 200 && xhr.status < 300){
              const data = JSON.parse(xhr.responseText);
              resolve(data.secure_url);
            }else{
              reject(new Error('이미지 업로드 실패'));
            }
          }catch(e){ reject(new Error('이미지 업로드 응답 오류')); }
        }
      };
      xhr.onerror = ()=> reject(new Error('네트워크 오류'));
      xhr.open('POST', url, true);
      xhr.send(fd);
    });
    return p;
  }

  // 썸네일 선택 시
  const inputFile = document.getElementById('rfThumb');
  const imgPreview = document.getElementById('rfThumbPreview');
  const imageUrlHidden = document.getElementById('rfImageUrl');

  inputFile.addEventListener('change', async (e)=>{
    const f = e.target.files && e.target.files[0];
    if(!f) return;
    try{
      disableForm(true);
      showNotice('이미지 업로드 중...', false);
      const url = await uploadToCloudinary(f);
      const viewUrl = (function(u){
        // 보기용 썸네일 변환 파라미터 삽입(옵션)
        try{
          const parts = u.split('/upload/');
          return parts[0] + '/upload/' + (thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto') + '/' + parts[1];
        }catch{ return u; }
      })(url);
      imageUrlHidden.value = url;
      imgPreview.src = viewUrl;
      showNotice('이미지 업로드 완료', false);
    }catch(err){
      console.error(err);
      showNotice('이미지 업로드에 실패했습니다. 다시 시도해 주세요.');
    }finally{
      disableForm(false);
    }
  });

  // 제출
  const form = document.getElementById('recruitForm');
  const submitBtn = document.getElementById('rfSubmitBtn');
  const cancelBtn = document.getElementById('rfCancelBtn');

  cancelBtn.addEventListener('click', ()=>{
    history.length > 1 ? history.back() : location.href = '/alpa/recruitslist.html';
  });

  form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    submitBtn.disabled = true; showNotice('저장 중...', false);

    const title = document.getElementById('rfTitleInput').value.trim();
    const brand = document.getElementById('rfBrand').value.trim();
    const date = document.getElementById('rfDate').value;
    const time = document.getElementById('rfTime').value;
    const locationText = document.getElementById('rfLocation').value.trim();
    const pay = document.getElementById('rfPay').value.trim();
    const payNeg = document.getElementById('rfPayNeg').checked;
    const category = document.getElementById('rfCategory').value.trim();
    const desc = document.getElementById('rfDesc').value.trim();
    const imageUrl = imageUrlHidden.value;

    // 필수값 체크 (API 스펙 기준: title, description, date, imageUrl 필요)
    if(!title || !desc || !date || !imageUrl){
      submitBtn.disabled = false;
      showNotice('필수 항목(제목, 촬영일, 제품설명, 썸네일)을 확인해 주세요.');
      return;
    }

    // 백엔드 스키마에 맞춰 description에 부가 정보 깔끔히 병합
    const descWithMeta = [
      brand ? `［브랜드］ ${brand}` : '',
      category ? `［상품군］ ${category}` : '',
      pay ? `［출연료］ ${pay}${payNeg ? ' (협의 가능)' : ''}` : '',
      desc
    ].filter(Boolean).join('\n');

    const payload = {
      title,
      description: descWithMeta,
      date,                         // YYYY-MM-DD
      time: time || undefined,      // optional
      location: locationText || undefined,
      imageUrl
    };

    try{
      await guardRole(); // 브랜드 확인
      await api('/recruits', {
        method:'POST',
        body: JSON.stringify(payload)
      });
      showNotice('공고가 등록되었습니다.', false);
      // 리스트로 이동
      setTimeout(()=> location.href = '/alpa/recruits.html', 600);
    }catch(err){
      console.error(err);
      submitBtn.disabled = false;
      showNotice(err?.message || '저장 중 오류가 발생했습니다.');
    }
  });

  // 초기화
  (async function init(){
    // 로그인 여부
    if(!localStorage.getItem('liveeToken')){
      showNotice('로그인이 필요합니다.');
      disableForm(true);
      return;
    }
    // 권한 미리 체크(에러 시 위에서 막힘)
    try{ await guardRole(); }catch{}
  })();
})();