/* /alpa/frontend/js/recruitform.js  (2025-08-13 최신본)
 * - Cloudinary Signed Upload 적용 (preset 미사용)
 * - 파일 선택 시 미리보기/진행률
 * - 권한 가드(brand/admin)
 * - 실패 시 UI 초기화/명확한 에러 표시
 */

(function () {
  const { API_BASE } = (window.LIVEE_CONFIG || {});
  const notice = document.getElementById('rfNotice');

  // ---------------- UI helpers ----------------
  function showNotice(msg, isError = true) {
    if (!notice) return;
    notice.textContent = msg;
    notice.hidden = false;
    notice.style.background = isError ? '#fff4f4' : '#f5fff5';
    notice.style.color = isError ? '#a32020' : '#0f6b2b';
    notice.style.borderColor = isError ? '#ffd6d6' : '#b9efc9';
  }

  function disableForm(disabled) {
    document
      .querySelectorAll('#recruitForm input, #recruitForm textarea, #recruitForm button, #recruitForm select')
      .forEach((el) => (el.disabled = !!disabled));
  }

  // ---------------- API wrapper ----------------
  const api = window.api || (async function api(path, opts = {}) {
    const headers = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
    const t = localStorage.getItem('liveeToken');
    if (t) headers.Authorization = `Bearer ${t}`;

    const res = await fetch(`${API_BASE}${path}`, { ...opts, headers });

    if (res.status === 401) {
      ['liveeToken', 'liveeName', 'liveeTokenExp'].forEach((k) => localStorage.removeItem(k));
      location.href = '/alpa/login.html';
      return;
    }
    const data = await res.json().catch(() => ({ ok: false, message: 'INVALID_JSON' }));
    if (!res.ok || data.ok === false) {
      throw new Error(data.message || `HTTP_${res.status}`);
    }
    return data;
  });

  // ---------------- Role guard ----------------
  async function guardRole() {
    const me = await api('/users/me');
    const user = me?.data ?? me;
    if (!user || (user.role !== 'brand' && user.role !== 'admin')) {
      throw new Error('브랜드 계정만 공고를 등록할 수 있습니다.');
    }
    return user;
  }

  // ---------------- Signed Upload ----------------
  async function getUploadSignature() {
    const headers = {};
    const t = localStorage.getItem('liveeToken');
    if (t) headers.Authorization = `Bearer ${t}`;
    const res = await fetch(`${API_BASE}/uploads/signature`, { headers });
    if (!res.ok) throw new Error(`서명 발급 실패(HTTP_${res.status})`);
    const json = await res.json().catch(() => ({}));
    const sig = json?.data ?? json;
    const { cloudName, apiKey, timestamp, folder, signature } = sig || {};
    if (!cloudName || !apiKey || !timestamp || !signature) throw new Error('서명 응답 형식 오류');
    return { cloudName, apiKey, timestamp, folder, signature };
  }

  async function uploadToCloudinary(file) {
    const { cloudName, apiKey, timestamp, folder, signature } = await getUploadSignature();

    const fd = new FormData();
    fd.append('file', file);
    fd.append('api_key', apiKey);
    fd.append('timestamp', timestamp);
    if (folder) fd.append('folder', folder);
    fd.append('signature', signature);

    const uploadUrl = `https://api.cloudinary.com/v1_1/${cloudName}/image/upload`;
    const prog = document.getElementById('rfUploadProg');
    if (prog) { prog.hidden = false; prog.value = 0; }

    return new Promise((resolve, reject) => {
      const xhr = new XMLHttpRequest();
      if (xhr.upload && prog) {
        xhr.upload.addEventListener('progress', (e) => {
          if (e.lengthComputable) prog.value = Math.round((e.loaded / e.total) * 100);
        });
      }
      xhr.onreadystatechange = () => {
        if (xhr.readyState === 4) {
          if (prog) prog.hidden = true;
          try {
            const json = JSON.parse(xhr.responseText || '{}');
            if (xhr.status >= 200 && xhr.status < 300) {
              if (!json.secure_url) return reject(new Error(json.error?.message || '이미지 URL 없음'));
              return resolve(json.secure_url);
            }
            return reject(new Error(json.error?.message || `Cloudinary 업로드 실패(HTTP_${xhr.status})`));
          } catch {
            return reject(new Error('이미지 업로드 응답 파싱 실패'));
          }
        }
      };
      xhr.onerror = () => reject(new Error('네트워크 오류'));
      xhr.open('POST', uploadUrl, true);
      xhr.send(fd);
    });
  }

  function toTransformedUrl(originalUrl, transform) {
    try {
      const [head, tail] = originalUrl.split('/upload/');
      return `${head}/upload/${transform}/${tail}`;
    } catch {
      return originalUrl;
    }
  }

  // ---------------- DOM refs ----------------
  const form = document.getElementById('recruitForm');
  const submitBtn = document.getElementById('rfSubmitBtn');
  const cancelBtn = document.getElementById('rfCancelBtn');

  const inputFile = document.getElementById('rfThumb');
  const imgPreview = document.getElementById('rfThumbPreview');
  const imageUrlHidden = document.getElementById('rfImageUrl');

  const titleEl = document.getElementById('rfTitleInput');
  const brandEl = document.getElementById('rfBrand');
  const dateEl = document.getElementById('rfDate');
  const timeEl = document.getElementById('rfTime');
  const locationEl = document.getElementById('rfLocation');
  const payEl = document.getElementById('rfPay');
  const payNegEl = document.getElementById('rfPayNeg');
  const categoryEl = document.getElementById('rfCategory');
  const descEl = document.getElementById('rfDesc');

  // ---------------- Handlers ----------------
  if (inputFile) {
    inputFile.addEventListener('change', async (e) => {
      const f = e.target.files && e.target.files[0];
      if (!f) return;

      if (!/^image\//.test(f.type)) {
        showNotice('이미지 파일만 업로드할 수 있습니다.');
        inputFile.value = '';
        return;
      }
      if (f.size > 8 * 1024 * 1024) {
        showNotice('파일 용량은 8MB 이하로 제한합니다.');
        inputFile.value = '';
        return;
      }

      try {
        disableForm(true);
        showNotice('이미지 업로드 중...', false);
        const url = await uploadToCloudinary(f);

        const trans = (window.LIVEE_CONFIG?.thumb?.card169) || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto';
        const viewUrl = toTransformedUrl(url, trans);

        imageUrlHidden.value = url;
        if (imgPreview) imgPreview.src = viewUrl;

        showNotice('이미지 업로드 완료', false);
      } catch (err) {
        console.error('upload error:', err);
        imageUrlHidden.value = '';
        if (imgPreview) imgPreview.removeAttribute('src');
        showNotice(`이미지 업로드에 실패했습니다. ${err?.message || ''}`.trim());
      } finally {
        disableForm(false);
      }
    });
  }

  if (cancelBtn) {
    cancelBtn.addEventListener('click', () => {
      history.length > 1 ? history.back() : (location.href = '/alpa/recruits.html');
    });
  }

  if (form) {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      if (submitBtn) submitBtn.disabled = true;
      showNotice('저장 중...', false);

      try {
        // 로그인/권한 확인
        if (!localStorage.getItem('liveeToken')) {
          showNotice('로그인이 필요합니다.');
          disableForm(true);
          return;
        }
        await guardRole();

        const title = titleEl.value.trim();
        const brand = brandEl.value.trim();
        const date = dateEl.value; // YYYY-MM-DD
        const time = timeEl.value; // HH:mm
        const locationText = locationEl.value.trim();
        const pay = payEl.value.trim();
        const payNeg = !!payNegEl.checked;
        const category = categoryEl.value.trim();
        const desc = descEl.value.trim();
        const imageUrl = imageUrlHidden.value;

        if (!title || !desc || !date || !imageUrl) {
          if (submitBtn) submitBtn.disabled = false;
          showNotice('필수 항목(제목, 촬영일, 제품설명, 썸네일)을 확인해 주세요.');
          return;
        }

        const descWithMeta = [
          brand ? `［브랜드］ ${brand}` : '',
          category ? `［상품군］ ${category}` : '',
          pay ? `［출연료］ ${pay}${payNeg ? ' (협의 가능)' : ''}` : '',
          desc,
        ].filter(Boolean).join('\n');

        const payload = {
          title,
          description: descWithMeta,
          date,                         // 서버에서 Date 변환
          time: time || undefined,
          location: locationText || undefined,
          imageUrl,
        };

        await api('/recruits', { method: 'POST', body: JSON.stringify(payload) });
        showNotice('공고가 등록되었습니다.', false);
        setTimeout(() => (location.href = '/alpa/recruits.html'), 600);
      } catch (err) {
        console.error('submit error:', err);
        if (submitBtn) submitBtn.disabled = false;
        showNotice(err?.message || '저장 중 오류가 발생했습니다.');
      }
    });
  }

  // ---------------- Init ----------------
  (async function init() {
    if (!localStorage.getItem('liveeToken')) {
      showNotice('로그인이 필요합니다.');
      disableForm(true);
      return;
    }
    try { await guardRole(); } catch { /* guardRole 안에서 안내됨 */ }
  })();
})();