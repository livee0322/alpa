/* /alpa/frontend/js/campaign-form.js */
(function () {
  const { API_BASE, thumb } = window.LIVEE_CONFIG || {};
  const notice = document.getElementById('cfNotice');

  const ui = {
    form: document.getElementById('campaignForm'),
    submit: document.getElementById('cfSubmitBtn'),
    cancel: document.getElementById('cfCancelBtn'),
    // thumb
    file: document.getElementById('cfThumb'),
    img: document.getElementById('cfThumbPreview'),
    hiddenUrl: document.getElementById('cfImageUrl'),
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
    time: document.getElementById('cfTime'),
    location: document.getElementById('cfLocation'),
    pay: document.getElementById('cfPay'),
    payNeg: document.getElementById('cfPayNeg'),
    categoryRecruit: document.getElementById('cfCategoryRecruit'),
    descRecruit: document.getElementById('cfDescRecruit'),
  };

  const state = {
    products: [], // {url,title,price,thumbnail,salePrice?}
  };

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
  function authHeaders() {
    const t = localStorage.getItem('liveeToken');
    return t ? { Authorization: `Bearer ${t}` } : {};
  }
  async function api(path, opts = {}) {
    const res = await fetch(`${API_BASE}${path}`, {
      ...opts,
      headers: {
        'Content-Type': 'application/json',
        ...authHeaders(),
        ...(opts.headers || {}),
      },
    });
    const data = await res.json().catch(() => ({}));
    if (res.status === 401) {
      ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k=>localStorage.removeItem(k));
      location.href = '/alpa/login.html';
      return Promise.reject(new Error('UNAUTH'));
    }
    if (!res.ok || data.ok === false) throw new Error(data.message || `HTTP_${res.status}`);
    return data;
  }

  /* ===== Upload (Cloudinary signed) ===== */
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
        ui.hiddenUrl.value = url;
        ui.img.src = toTransformedUrl(url, thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto');
        showNotice('이미지 업로드 완료', 'ok');
      } catch (err) {
        ui.hiddenUrl.value = '';
        ui.img.removeAttribute('src');
        showNotice(`이미지 업로드 실패: ${err.message}`);
      }
    });
  }

  /* ===== 상품 메타 불러오기 ===== */
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
      const url = ui.prodUrl.value.trim();
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
        showNotice(`상품 불러오기 실패: ${e.message}`);
      }
    });
  }

  /* ===== 제출 ===== */
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
        if (!['brand','admin'].includes(role)) throw new Error('브랜드/관리자만 등록 가능');

        const type = document.querySelector('input[name="cfType"]:checked')?.value || 'product';
        const common = {
          title: ui.title.value.trim(),
          imageUrl: ui.hiddenUrl.value || undefined,
        };
        if (!common.title) throw new Error('캠페인 제목은 필수입니다.');

        let payload;
        if (type === 'product') {
          if (!state.products.length) throw new Error('상품을 한 개 이상 추가하세요.');
          payload = {
            ...common,
            type: 'product',
            products: state.products,
            sale: {
              price: ui.salePrice.value ? Number(ui.salePrice.value) : undefined,
              durationSec: ui.saleDuration.value ? Number(ui.saleDuration.value) : undefined,
            },
            live: {
              date: ui.liveDate.value || undefined,
              time: ui.liveTime.value || undefined,
            },
            brand: ui.brand.value || undefined,
            category: ui.category.value || undefined,
            descriptionHtml: ui.desc.value || undefined,
          };
        } else {
          payload = {
            ...common,
            type: 'recruit',
            recruit: {
              title: ui.titleRecruit.value.trim() || common.title,
              date: ui.date.value || undefined,
              time: ui.time.value || undefined,
              location: ui.location.value || undefined,
              pay: ui.pay.value || undefined,
              payNegotiable: !!ui.payNeg.checked,
              category: ui.categoryRecruit.value || undefined,
              description: ui.descRecruit.value || undefined,
            }
          };
        }

        ui.submit.disabled = true;
        showNotice('저장 중...', 'ok');
        await api('/campaigns', { method: 'POST', body: JSON.stringify(payload) });
        showNotice('캠페인이 등록되었습니다.', 'ok');
        setTimeout(()=> location.href = '/alpa/campaigns.html', 500);
      } catch (err) {
        showNotice(err.message || '저장 실패');
      } finally {
        ui.submit.disabled = false;
      }
    });
  }

  // 초기 렌더
  renderProducts();
})();