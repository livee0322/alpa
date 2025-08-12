<script>
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

  // 간단 api 래퍼
  const api = window.api || (async function api(path, opts={}){
    const headers = {'Content-Type':'application/json', ...(opts.headers||{})};
    const t = localStorage.getItem('liveeToken');
    if (t) headers.Authorization = `Bearer ${t}`;
    const res = await fetch(`${API_BASE}${path}`, {...opts, headers});
    // JSON 파싱 실패 대비
    const data = await res.json().catch(()=>({ ok:false, message:'INVALID_JSON' }));

    if (res.status === 401) {
      ['liveeToken','liveeName','liveeTokenExp'].forEach(k=>localStorage.removeItem(k));
      location.href = '/alpa/login.html';
      return;
    }
    if (!res.ok || data.ok === false) {
      throw new Error(data.message || `HTTP_${res.status}`);
    }
    return data;
  });

  // 권한 확인(브랜드만 접근) - 응답 구조 유연화
  async function guardRole(){
    try{
      const me = await api('/users/me');
      // me 형태가 {ok:true, data:{...}} 또는 {...} 둘 다 대응
      const user = me?.data ?? me;
      if (!user || (user.role !== 'brand' && user.role !== 'admin')) {
        throw new Error('브랜드 계정만 공고를 등록할 수 있습니다.');
      }
    }catch(err){
      showNotice('접근 권한이 없습니다. 브랜드 계정으로 로그인해 주세요.', true);
      disableForm(true);
      throw err;
    }
  }

  function disableForm(disabled){
    document.querySelectorAll('#recruitForm input, #recruitForm textarea, #recruitForm button, #recruitForm select')
      .forEach(el => el.disabled = !!disabled);
  }

  // ✅ Cloudinary 업로드 (에러메시지 친절히, 폴더 고정)
  async function uploadToCloudinary(file){
    if(!CLOUDINARY || !CLOUDINARY.uploadApi) throw new Error('Cloudinary 설정 누락');
    const fd = new FormData();
    fd.append('file', file);
    fd.append('upload_preset', CLOUDINARY.uploadPreset);
    fd.append('folder', 'livee'); // 운영 폴더 고정 (대시보드 폴더와 맞춤)

    const prog = document.getElementById('rfUploadProg');
    if (prog) { prog.hidden = false; prog.value = 0; }

    const url = CLOUDINARY.uploadApi;

    // fetch로도 가능하지만, 진행률을 위해 XHR 유지
    const xhr = new XMLHttpRequest();
    const p = new Promise((resolve, reject)=>{
      if (xhr.upload && prog) {
        xhr.upload.addEventListener('progress', (e)=>{
          if(e.lengthComputable){ prog.value = Math.round(e.loaded / e.total * 100); }
        });
      }
      xhr.onreadystatechange = ()=>{
        if(xhr.readyState === 4){
          if (prog) prog.hidden = true;
          try{
            const json = JSON.parse(xhr.responseText || '{}');
            if (xhr.status >= 200 && xhr.status < 300) {
              if (!json.secure_url) {
                // Cloudinary가 에러를 json.error로 줄 때가 많음
                const em = json.error?.message || '이미지 URL이 응답되지 않았습니다.';
                return reject(new Error(em));
              }
              return resolve(json.secure_url);
            } else {
              const em = json.error?.message || `Cloudinary 업로드 실패 (HTTP_${xhr.status})`;
              return reject(new Error(em));
            }
          }catch(e){
            return reject(new Error('이미지 업로드 응답 파싱 오류'));
          }
        }
      };
      xhr.onerror = ()=> reject(new Error('네트워크 오류'));
      xhr.open('POST', url, true);
      xhr.send(fd);
    });
    return p;
  }

  // 파일 선택 시 업로드
  const inputFile = document.getElementById('rfThumb');
  const imgPreview = document.getElementById('rfThumbPreview');
  const imageUrlHidden = document.getElementById('rfImageUrl');

  if (inputFile) {
    inputFile.addEventListener('change', async (e)=>{
      const f = e.target.files && e.target.files[0];
      if(!f) return;
      // 간단한 타입/용량 가드(선택)
      if (!/^image\//.test(f.type)) { showNotice('이미지 파일만 업로드할 수 있습니다.'); return; }
      if (f.size > 8 * 1024 * 1024) { showNotice('파일 용량은 8MB 이하로 제한합니다.'); return; }

      try{
        disableForm(true);
        showNotice('이미지 업로드 중...', false);
        const url = await uploadToCloudinary(f);

        // 보기용 썸네일 변환 파라미터 삽입
        const viewUrl = (()=> {
          try{
            const parts = url.split('/upload/');
            const trans = (thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto');
            return parts[0] + '/upload/' + trans + '/' + parts[1];
          }catch{ return url; }
        })();

        imageUrlHidden.value = url;
        if (imgPreview) imgPreview.src = viewUrl;
        showNotice('이미지 업로드 완료', false);
      }catch(err){
        console.error(err);
        showNotice(`이미지 업로드에 실패했습니다. ${err.message || ''}`.trim());
      }finally{
        disableForm(false);
      }
    });
  }

  // 제출
  const form = document.getElementById('recruitForm');
  const submitBtn = document.getElementById('rfSubmitBtn');
  const cancelBtn = document.getElementById('rfCancelBtn');

  if (cancelBtn){
    // ✅ 경로 오타 수정: recruitslist → recruits
    cancelBtn.addEventListener('click', ()=>{
      history.length > 1 ? history.back() : location.href = '/alpa/recruits.html';
    });
  }

  if (form) {
    form.addEventListener('submit', async (e)=>{
      e.preventDefault();
      if (submitBtn) submitBtn.disabled = true;
      showNotice('저장 중...', false);

      const title = document.getElementById('rfTitleInput').value.trim();
      const brand = document.getElementById('rfBrand').value.trim();
      const date = document.getElementById('rfDate').value;   // YYYY-MM-DD
      const time = document.getElementById('rfTime').value;   // HH:mm
      const locationText = document.getElementById('rfLocation').value.trim();
      const pay = document.getElementById('rfPay').value.trim();
      const payNeg = document.getElementById('rfPayNeg').checked;
      const category = document.getElementById('rfCategory').value.trim();
      const desc = document.getElementById('rfDesc').value.trim();
      const imageUrl = imageUrlHidden.value;

      if(!title || !desc || !date || !imageUrl){
        if (submitBtn) submitBtn.disabled = false;
        showNotice('필수 항목(제목, 촬영일, 제품설명, 썸네일)을 확인해 주세요.');
        return;
      }

      const descWithMeta = [
        brand ? `［브랜드］ ${brand}` : '',
        category ? `［상품군］ ${category}` : '',
        pay ? `［출연료］ ${pay}${payNeg ? ' (협의 가능)' : ''}` : '',
        desc
      ].filter(Boolean).join('\n');

      const payload = {
        title,
        description: descWithMeta,
        date,                         // 서버에서 Date로 변환
        time: time || undefined,
        location: locationText || undefined,
        imageUrl
      };

      try{
        await guardRole(); // 브랜드 확인
        await api('/recruits', { method:'POST', body: JSON.stringify(payload) });
        showNotice('공고가 등록되었습니다.', false);
        setTimeout(()=> location.href = '/alpa/recruits.html', 600);
      }catch(err){
        console.error(err);
        if (submitBtn) submitBtn.disabled = false;
        showNotice(err?.message || '저장 중 오류가 발생했습니다.');
      }
    });
  }

  // 초기화
  (async function init(){
    if(!localStorage.getItem('liveeToken')){
      showNotice('로그인이 필요합니다.');
      disableForm(true);
      return;
    }
    try{ await guardRole(); }catch{}
  })();
})();
</script>