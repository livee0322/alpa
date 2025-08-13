/* /alpa/frontend/js/recruitform.js (edit 모드 지원) */
(function () {
  const CONFIG = { USE_SIGNED_FOLDER: false, MAX_FILE_SIZE: 8 * 1024 * 1024 };
  const { API_BASE, thumb } = (window.LIVEE_CONFIG || {});
  const notice = document.getElementById('rfNotice');

  function showNotice(msg, isError = true) {
    if (!notice) return;
    notice.textContent = msg;
    notice.hidden = false;
    notice.style.background = isError ? '#fff4f4' : '#f5fff5';
    notice.style.color = isError ? '#a32020' : '#0f6b2b';
    notice.style.borderColor = isError ? '#ffd6d6' : '#b9efc9';
  }
  function disableForm(disabled) {
    document.querySelectorAll('#recruitForm input, #recruitForm textarea, #recruitForm button, #recruitForm select')
      .forEach((el) => (el.disabled = !!disabled));
  }

  const api = async (path, opts = {}) => {
    const headers = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
    const t = localStorage.getItem('liveeToken');
    if (t) headers.Authorization = `Bearer ${t}`;
    const res = await fetch(`${API_BASE}${path}`, { ...opts, headers });
    const data = await res.json().catch(() => ({ ok:false, message:'INVALID_JSON' }));
    if (res.status === 401) {
      ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k=>localStorage.removeItem(k));
      location.href = '/alpa/login.html';
      return;
    }
    if (!res.ok || data.ok === false) throw new Error(data.message || `HTTP_${res.status}`);
    return data;
  };

  async function guardRole() {
    const me = await api('/users/me');
    const user = me?.data ?? me;
    if (!user || (user.role !== 'brand' && user.role !== 'admin')) {
      throw new Error('브랜드 계정만 공고를 등록할 수 있습니다.');
    }
    return user;
  }

  async function getUploadSignature() {
    const headers = {};
    const t = localStorage.getItem('liveeToken');
    if (t) headers.Authorization = `Bearer ${t}`;
    const res = await fetch(`${API_BASE}/uploads/signature`, { headers });
    if (!res.ok) throw new Error(`서명 발급 실패(HTTP_${res.status})`);
    const json = await res.json().catch(() => ({}));
    const sig = json?.data ?? json;
    const { cloudName, apiKey, timestamp, signature, folder } = sig || {};
    if (!cloudName || !apiKey || !timestamp || !signature) throw new Error('서명 응답 형식 오류');
    return { cloudName, apiKey, timestamp, signature, folder };
  }

  async function uploadToCloudinary(file) {
    const { cloudName, apiKey, timestamp, signature, folder } = await getUploadSignature();
    const fd = new FormData();
    fd.append('file', file);
    fd.append('api_key', apiKey);
    fd.append('timestamp', timestamp);
    if (CONFIG.USE_SIGNED_FOLDER && folder) fd.append('folder', folder);
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
          } catch { return reject(new Error('이미지 업로드 응답 파싱 실패')); }
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
    } catch { return originalUrl; }
  }

  // DOM
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

  // 파일 업로드 핸들러
  if (inputFile) {
    inputFile.addEventListener('change', async (e) => {
      const f = e.target.files && e.target.files[0];
      if (!f) return;
      if (!/^image\//.test(f.type)) { showNotice('이미지 파일만 업로드할 수 있습니다.'); inputFile.value=''; return; }
      if (f.size > CONFIG.MAX_FILE_SIZE) { showNotice('파일 용량은 8MB 이하로 제한합니다.'); inputFile.value=''; return; }

      try {
        disableForm(true);
        showNotice('이미지 업로드 중...', false);
        const url = await uploadToCloudinary(f);
        const trans = thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto';
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

  // ====== EDIT MODE ======
  const params = new URLSearchParams(location.search);
  const editId = params.get('edit');  // ?edit=<id>
  let isEdit = !!editId;

  async function loadExistingForEdit(id) {
    // 백엔드에 GET /recruits/:id 가 없다면 mine에서 찾아오는 방식
    const mine = await api('/recruits/mine');
    const items = mine.items || mine.data || [];
    const found = items.find(it => (it._id || it.id) === id);
    if (!found) throw new Error('해당 공고를 찾을 수 없습니다.');

    // 프리필
    titleEl.value = found.title || '';
    brandEl.value = found.brand || '';
    if (found.date) dateEl.value = String(found.date).slice(0,10);
    timeEl.value = found.time || '';
    locationEl.value = found.location || '';
    // description 는 메타 포함되어 있을 수 있으니 그대로
    descEl.value = (found.description || '').trim();

    const src = found.imageUrl || found.thumbnailUrl || '';
    if (src) {
      imageUrlHidden.value = src;
      const viewUrl = toTransformedUrl(src, thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto');
      if (imgPreview) imgPreview.src = viewUrl;
    }

    // 버튼 라벨
    if (submitBtn) submitBtn.textContent = '수정 완료';
  }

  if (form) {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      if (submitBtn) submitBtn.disabled = true;
      showNotice(isEdit ? '수정 중...' : '저장 중...', false);

      try {
        if (!localStorage.getItem('liveeToken')) { showNotice('로그인이 필요합니다.'); disableForm(true); return; }
        await guardRole();

        const payload = {
          title: titleEl.value.trim(),
          description: [
            (brandEl.value.trim() ? `［브랜드］ ${brandEl.value.trim()}` : ''),
            (categoryEl.value.trim() ? `［상품군］ ${categoryEl.value.trim()}` : ''),
            (payEl.value.trim() ? `［출연료］ ${payEl.value.trim()}${payNegEl.checked ? ' (협의 가능)' : ''}` : ''),
            (descEl.value.trim())
          ].filter(Boolean).join('\n'),
          date: dateEl.value,
          time: timeEl.value || undefined,
          location: locationEl.value.trim() || undefined,
          imageUrl: imageUrlHidden.value
        };

        if (!payload.title || !payload.description || !payload.date || !payload.imageUrl) {
          if (submitBtn) submitBtn.disabled = false;
          showNotice('필수 항목(제목, 촬영일, 제품설명, 썸네일)을 확인해 주세요.');
          return;
        }

        if (isEdit) {
          await api(`/recruits/${encodeURIComponent(editId)}`, {
            method: 'PUT',
            body: JSON.stringify(payload)
          });
          showNotice('수정되었습니다.', false);
        } else {
          await api('/recruits', { method: 'POST', body: JSON.stringify(payload) });
          showNotice('공고가 등록되었습니다.', false);
        }
        setTimeout(() => (location.href = '/alpa/recruits.html'), 600);
      } catch (err) {
        console.error('submit error:', err);
        if (submitBtn) submitBtn.disabled = false;
        showNotice(err?.message || (isEdit ? '수정 중 오류가 발생했습니다.' : '저장 중 오류가 발생했습니다.'));
      }
    });
  }

  (async function init() {
    if (!localStorage.getItem('liveeToken')) { showNotice('로그인이 필요합니다.'); disableForm(true); return; }
    try {
      await guardRole();
      if (isEdit) await loadExistingForEdit(editId);
    } catch {/* 안내는 각각의 함수에서 처리 */}
  })();
})();