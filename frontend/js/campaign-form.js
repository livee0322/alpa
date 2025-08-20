/* /alpa/frontend/js/campaign-form.js */
(function () {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const notice = document.getElementById('cfNotice');

  /* ---------- helpers ---------- */
  const qs = (k) => new URLSearchParams(location.search).get(k);
  const EDIT_ID = qs('edit');        // 있으면 수정 모드
  const val = (el) => (el && typeof el.value === 'string' ? el.value : '');
  const safeVal = (el) => String(val(el) || '').trim();
  const num = (el) => (safeVal(el) ? Number(safeVal(el)) : undefined);
  const txtOrUndef = (el) => (safeVal(el) ? safeVal(el) : undefined);

  function showNotice(msg, type = 'error') {
    if (!notice) return;
    notice.textContent = msg;
    notice.hidden = false;
    if (type === 'ok') {
      notice.style.background = '#f5fff5';
      notice.style.color = '#0f6b2b';
      notice.style.borderColor = '#b9efc9';
    } else {
      notice.style.background = '#fff4f4';
      notice.style.color = '#a32020';
      notice.style.borderColor = '#ffd6d6';
    }
  }
  const authHeaders = () => {
    const t = localStorage.getItem('liveeToken');
    return t ? { Authorization: `Bearer ${t}` } : {};
  };
  async function api(path, opts = {}) {
    const res = await fetch(`${API_BASE}${path}`, {
      ...opts,
      headers: { 'Content-Type': 'application/json', ...authHeaders(), ...(opts.headers || {}) },
    });
    const data = await res.json().catch(() => ({}));
    if (res.status === 401) {
      ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k=>localStorage.removeItem(k));
      location.href = '/alpa/login.html';
      throw new Error('UNAUTH');
    }
    if (!res.ok || data.ok === false) throw new Error(data.message || `HTTP_${res.status}`);
    return data;
  }

  /* ---------- UI refs ---------- */
  const ui = {
    form: document.getElementById('campaignForm'),
    submit: document.getElementById('cfSubmitBtn'),
    cancel: document.getElementById('cfCancelBtn'),
    // thumb
    file: document.getElementById('cfThumb'),
    img: document.getElementById('cfThumbPreview'),
    hiddenUrl: document.getElementById('cfImageUrl'), // coverImageUrl 저장
    prog: document.getElementById('cfUploadProg'),
    // common
    title: document.getElementById('cfTitle'),
    // product section
    prodUrl: document.getElementById('cfProdUrl'),
    fetchBtn: document.getElementById('cfProdFetchBtn'),
    prodList: document.getElementById('cfProdList'),
    salePrice: document.getElementById('cfSalePrice'),
    saleDuration: document.getElementById('cfSaleDuration'),
    liveDate: document.getElementById('cfLiveDate'),
    liveTime: document.getElementById('cfLiveTime'),
    brand: document.getElementById('cfBrand'),
    category: document.getElementById('cfCategory'),
    desc: document.getElementById('cfDesc'),
    // recruit section
    titleRecruit: document.getElementById('cfTitleRecruit'),
    date: document.getElementById('cfDate'),
    timeStart: document.getElementById('cfTimeStart'),
    timeEnd: document.getElementById('cfTimeEnd'),
    duration: document.getElementById('cfDuration'),
    location: document.getElementById('cfLocation'),
    pay: document.getElementById('cfPay'),
    payNeg: document.getElementById('cfPayNeg'),
    categoryRecruit: document.getElementById('cfCategoryRecruit'),
    descRecruit: document.getElementById('cfDescRecruit'),
  };

  const state = { products: [] }; // {url,title,price,thumbnail,salePrice?}

  /* ---------- Cloudinary Upload ---------- */
  async function getUploadSignature() {
    const res = await fetch(`${API_BASE}/uploads/signature`, { headers: authHeaders() });
    const json = await res.json();
    const sig = json.data || json;
    const { cloudName, apiKey, timestamp, signature, folder } = sig || {};
    if (!cloudName || !apiKey || !timestamp || !signature) throw new Error('서명 오류');
    return { cloudName, apiKey, timestamp, signature, folder };
  }
  function toTransformedUrl(originalUrl, transform) {
    try {
      const [head, tail] = originalUrl.split('/upload/');
      return `${head}/upload/${transform}/${tail}`;
    } catch { return originalUrl; }
  }
  async function uploadToCloudinary(file) {
    const { cloudName, apiKey, timestamp, signature, folder } = await getUploadSignature();
    const fd = new FormData();
    fd.append('file', file);
    fd.append('api_key', apiKey);
    fd.append('timestamp', timestamp);
    if (folder) fd.append('folder', folder);
    fd.append('signature', signature);

    const url = `https://api.cloudinary.com/v1_1/${cloudName}/image/upload`;
    const prog = ui.prog;
    if (prog) { prog.hidden = false; prog.value = 0; }

    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      xhr.upload?.addEventListener('progress', (e) => {
        if (e.lengthComputable && prog) prog.value = Math.round((e.loaded / e.total) * 100);
      });
      xhr.onreadystatechange = () => {
        if (xhr.readyState === 4) {
          if (prog) prog.hidden = true;
          try {
            const json = JSON.parse(xhr.responseText || '{}');
            if (xhr.status >= 200 && xhr.status < 300) {
              if (!json.secure_url) return reject(new Error('URL 없음'));
              resolve(json.secure_url);
            } else reject(new Error(json.error?.message || `Cloudinary HTTP_${xhr.status}`));
          } catch { reject(new Error('응답 파싱 실패')); }
        }
      };
      xhr.onerror = () => reject(new Error('네트워크 오류'));
      xhr.open('POST', url, true);
      xhr.send(fd);
    });
  }

  if (ui.file) {
    ui.file.addEventListener('change', async (e) => {
      const f = e.target.files?.[0];
      if (!f) return;
      if (!/^image\//.test(f.type)) { showNotice('이미지 파일만 업로드 가능합니다.'); ui.file.value=''; return; }
      if (f.size > 8 * 1024 * 1024) { showNotice('파일 용량은 8MB 이하'); ui.file.value=''; return; }
      try {
        showNotice('이미지 업로드 중...', 'ok');
        const url = await uploadToCloudinary(f);
        ui.hiddenUrl.value = url; // coverImageUrl
        ui.img.src = toTransformedUrl(
          url,
          (window.LIVEE_CONFIG?.thumb && window.LIVEE_CONFIG.thumb.card169) ||
          'c_fill,g_auto,w_640,h_360,f_auto,q_auto'
        );
        showNotice('이미지 업로드 완료', 'ok');
      } catch (err) {
        ui.hiddenUrl.value = '';
        ui.img.removeAttribute('src');
        showNotice(`이미지 업로드 실패: ${err.message}`);
      }
    });
  }

  /* ---------- 상품 스크래핑 & 렌더 ---------- */
  function renderProducts() {
    const box = ui.prodList;
    box.innerHTML = '';
    if (!state.products.length) {
      const div = document.createElement('div');
      div.className = 'cf-empty';
      div.textContent = '아직 등록된 상품이 없습니다.';
      box.appendChild(div);
      return;
    }
    const tpl = document.getElementById('cfProdItemTpl');
    state.products.forEach((p, idx) => {
      const node = tpl.content.cloneNode(true);
      node.querySelector('.cf-prod-thumb').src = p.thumbnail || '';
      node.querySelector('.cf-prod-title').textContent = p.title || '(제목 없음)';
      node.querySelector('.price').textContent = p.price ? `${Number(p.price).toLocaleString()}원` : '';
      node.querySelector('.sale').textContent = p.salePrice ? `→ ${Number(p.salePrice).toLocaleString()}원` : '';
      node.querySelector('[data-act="edit"]').addEventListener('click', () => {
        const v = prompt('할인가(원 단위, 빈칸이면 해제):', p.salePrice || '');
        if (v === null) return;
        p.salePrice = v ? Number(v) : undefined;
        renderProducts();
      });
      node.querySelector('[data-act="remove"]').addEventListener('click', () => {
        state.products.splice(idx, 1);
        renderProducts();
      });
      box.appendChild(node);
    });
  }

  if (ui.fetchBtn) {
    ui.fetchBtn.addEventListener('click', async () => {
      const url = safeVal(ui.prodUrl);
      if (!url) return showNotice('상품 URL을 입력하세요.');
      try {
        const res = await api(`/scrape/product?url=${encodeURIComponent(url)}`);
        const meta = res.data || res; // {title,price,thumbnail,url}
        state.products.push({
          url: meta.url || url,
          title: meta.title || '',
          price: meta.price || 0,
          thumbnail: meta.thumbnail || '',
        });
        renderProducts();
        ui.prodUrl.value = '';
        showNotice('상품을 추가했습니다.', 'ok');
      } catch (e) {
        showNotice(`상품 불러오기 실패: ${e.message}`, 'error');
        const goManual = confirm('메타를 불러오지 못했습니다. 수동으로 추가하시겠어요?');
        if (!goManual) return;
        const title = prompt('상품명(선택):', '');
        const price = prompt('가격(숫자, 선택):', '');
        state.products.push({ url, title: title || '', price: price ? Number(price) : 0, thumbnail: '' });
        renderProducts();
        ui.prodUrl.value = '';
        showNotice('수동으로 상품을 추가했습니다.', 'ok');
      }
    });
  }

  /* ---------- 촬영시간 계산(모집) ---------- */
  function parseHHMM(str){ if(!str) return null; const [h,m]=str.split(':').map(Number); if(Number.isNaN(h)||Number.isNaN(m)) return null; return h*60+m; }
  function updateDuration(){
    const s = parseHHMM(safeVal(ui.timeStart));
    const e = parseHHMM(safeVal(ui.timeEnd));
    if (s==null || e==null){
      if (ui.duration) ui.duration.textContent = '촬영시간: -';
      if (ui.timeEnd) ui.timeEnd.min = safeVal(ui.timeStart) || '';
      return;
    }
    if (e <= s){
      if (ui.duration) ui.duration.textContent = '촬영시간: 종료시간은 시작시간 이후여야 합니다.';
      return;
    }
    if (ui.duration) ui.duration.textContent = `촬영시간: ${e - s}분`;
  }
  ['change','input'].forEach(ev=>{
    ui.timeStart?.addEventListener(ev, ()=>{
      if (ui.timeEnd) ui.timeEnd.min = safeVal(ui.timeStart) || '';
      updateDuration();
    });
    ui.timeEnd?.addEventListener(ev, updateDuration);
  });

  /* ---------- 수정 모드: 기존 데이터 채우기 ---------- */
  async function loadForEdit() {
    if (!EDIT_ID) return;
    try {
      showNotice('기존 데이터를 불러오는 중...', 'ok');
      const res = await fetch(`${API_BASE}/campaigns/${encodeURIComponent(EDIT_ID)}`, { headers: authHeaders() });
      const json = await res.json().catch(()=>({}));
      if (!res.ok) throw new Error(json.message || `HTTP_${res.status}`);

      const it = json.data || json;
      // 타입 라디오 & 섹션 토글
      const type = it.type === 'recruit' ? 'recruit' : 'product';
      const radio = document.querySelector(`input[name="cfType"][value="${type}"]`);
      if (radio) { radio.checked = true; }
      // 섹션 show/hide (페이지 하단의 토글 스크립트가 있을 수 있으니 강제 적용)
      const secP = document.getElementById('cfSectionProduct');
      const secR = document.getElementById('cfSectionRecruit');
      if (secP && secR) {
        secP.hidden = type !== 'product';
        secR.hidden = type !== 'recruit';
      }

      // 공통
      ui.title.value = it.title || '';
      ui.hiddenUrl.value = it.coverImageUrl || it.imageUrl || '';
      if (ui.hiddenUrl.value) {
        ui.img.src = toTransformedUrl(
          ui.hiddenUrl.value,
          (window.LIVEE_CONFIG?.thumb && window.LIVEE_CONFIG.thumb.card169) ||
          'c_fill,g_auto,w_640,h_360,f_auto,q_auto'
        );
      }

      if (type === 'product') {
        // 상품들
        state.products = Array.isArray(it.products) ? it.products.slice() : [];
        renderProducts();
        // 세일/라이브/메타
        ui.salePrice.value   = it.sale?.price ?? '';
        ui.saleDuration.value= it.sale?.durationSec ?? '';
        ui.liveDate.value    = it.live?.date || '';
        ui.liveTime.value    = it.live?.time || '';
        ui.brand.value       = it.brand || '';
        ui.category.value    = it.category || '';
        ui.desc.value        = it.descriptionHTML || it.descriptionHtml || '';
      } else {
        // 모집
        ui.titleRecruit.value   = (it.recruit?.title || it.title || '');
        ui.date.value           = it.recruit?.date || '';
        ui.timeStart.value      = it.recruit?.timeStart || '';
        ui.timeEnd.value        = it.recruit?.timeEnd || it.recruit?.time || '';
        ui.location.value       = it.recruit?.location || '';
        ui.pay.value            = it.recruit?.pay || '';
        if (ui.payNeg) ui.payNeg.checked = !!it.recruit?.payNegotiable;
        ui.categoryRecruit.value= it.recruit?.category || '';
        ui.descRecruit.value    = it.recruit?.description || '';
        updateDuration();
      }

      ui.submit.textContent = '수정 저장';
      showNotice('불러오기 완료', 'ok');
    } catch (e) {
      showNotice(`불러오기 실패: ${e.message || e}`, 'error');
    }
  }

  /* ---------- 제출 ---------- */
  if (ui.cancel) {
    ui.cancel.addEventListener('click', () => {
      history.length > 1 ? history.back() : (location.href = '/alpa/campaigns.html');
    });
  }

  if (ui.form) {
    ui.form.addEventListener('submit', async (e) => {
      e.preventDefault();
      try {
        const me = await api('/users/me');
        const role = me?.data?.role || me.role;
        if (!['brand', 'admin'].includes(role)) throw new Error('브랜드/관리자만 등록 가능');

        const type = document.querySelector('input[name="cfType"]:checked')?.value || 'product';
        const computedTitle =
          type === 'recruit'
            ? (safeVal(ui.titleRecruit) || safeVal(ui.title))
            : (safeVal(ui.title) || safeVal(ui.titleRecruit));

        const common = {
          title: computedTitle,
          coverImageUrl: txtOrUndef(ui.hiddenUrl),
        };
        if (!common.title) throw new Error('캠페인 제목은 필수입니다.');

        let payload;
        if (type === 'product') {
          if (!state.products.length) throw new Error('상품을 한 개 이상 추가하세요.');
          payload = {
            ...common,
            type: 'product',
            products: state.products,
            sale: { price: num(ui.salePrice), durationSec: num(ui.saleDuration) },
            live: { date: txtOrUndef(ui.liveDate), time: txtOrUndef(ui.liveTime) },
            brand: txtOrUndef(ui.brand),
            category: txtOrUndef(ui.category),
            descriptionHTML: txtOrUndef(ui.desc),
          };
        } else {
          // 시간 순서 체크
          const s = parseHHMM(safeVal(ui.timeStart));
          const eM = parseHHMM(safeVal(ui.timeEnd));
          if (s!=null && eM!=null && eM<=s) throw new Error('종료시간은 시작시간 이후여야 합니다.');

          payload = {
            ...common,
            type: 'recruit',
            recruit: {
              title: computedTitle,
              date: txtOrUndef(ui.date),
              timeStart: txtOrUndef(ui.timeStart),
              timeEnd: txtOrUndef(ui.timeEnd),
              location: txtOrUndef(ui.location),
              pay: txtOrUndef(ui.pay),
              payNegotiable: !!(ui.payNeg && ui.payNeg.checked),
              category: txtOrUndef(ui.categoryRecruit),
              description: txtOrUndef(ui.descRecruit),
            },
          };
        }

        ui.submit.disabled = true;
        showNotice(EDIT_ID ? '수정 중...' : '저장 중...', 'ok');

        if (EDIT_ID) {
          await api(`/campaigns/${encodeURIComponent(EDIT_ID)}`, { method: 'PUT', body: JSON.stringify(payload) });
          showNotice('캠페인이 수정되었습니다.', 'ok');
        } else {
          await api('/campaigns', { method: 'POST', body: JSON.stringify(payload) });
          showNotice('캠페인이 등록되었습니다.', 'ok');
        }

        setTimeout(() => (location.href = '/alpa/campaigns.html'), 500);
      } catch (err) {
        showNotice(err.message || '저장 실패');
      } finally {
        ui.submit.disabled = false;
      }
    });
  }

  // 초기 렌더 & 수정 모드 로딩
  renderProducts();
  loadForEdit();
})();