/* /alpa/frontend/js/recruitform.js  — refactored, edit-mode + signed upload */
(function () {
  // ========= Config =========
  const CFG = {
    MAX_FILE_SIZE: 8 * 1024 * 1024, // 8MB
    USE_SIGNED_FOLDER: false
  };
  const { API_BASE, thumb } = window.LIVEE_CONFIG || {};
  const THUMB_TRANS = thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto';

  // ========= Utilities =========
  const qs  = (s, p=document) => p.querySelector(s);
  const qsa = (s, p=document) => [...p.querySelectorAll(s)];

  const notice = qs('#rfNotice');
  const noticeUI = {
    show(msg, isError = true) {
      if (!notice) return;
      notice.textContent = msg;
      notice.hidden = false;
      notice.style.background  = isError ? '#fff4f4' : '#f5fff5';
      notice.style.color       = isError ? '#a32020' : '#0f6b2b';
      notice.style.borderColor = isError ? '#ffd6d6' : '#b9efc9';
    },
    ok(msg){ this.show(msg, false); },
    hide(){ if (notice) notice.hidden = true; }
  };

  function disableForm(disabled) {
    qsa('#recruitForm input, #recruitForm textarea, #recruitForm button, #recruitForm select')
      .forEach((el) => (el.disabled = !!disabled));
  }

  async function fetchJSON(path, opts = {}) {
    const headers = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
    const t = localStorage.getItem('liveeToken');
    if (t) headers.Authorization = `Bearer ${t}`;
    const res = await fetch(`${API_BASE}${path}`, { ...opts, headers });
    const data = await res.json().catch(() => ({ ok:false, message:'INVALID_JSON' }));

    if (res.status === 401) {
      ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k => localStorage.removeItem(k));
      location.href = '/alpa/login.html';
      return Promise.reject(new Error('UNAUTHORIZED'));
    }
    if (!res.ok || data.ok === false) {
      throw new Error(data.message || `HTTP_${res.status}`);
    }
    return data;
  }

  async function guardRole() {
    const me = await fetchJSON('/users/me');
    const user = me?.data ?? me;
    if (!user || (user.role !== 'brand' && user.role !== 'admin')) {
      throw new Error('브랜드 계정만 공고를 등록할 수 있습니다.');
    }
    return user;
  }

  function toTransformedUrl(originalUrl, transform = THUMB_TRANS) {
    try {
      const [head, tail] = String(originalUrl).split('/upload/');
      return tail ? `${head}/upload/${transform}/${tail}` : originalUrl;
    } catch { return originalUrl; }
  }

  // ========= Uploader =========
  const uploader = {
    prog: qs('#rfUploadProg'),
    previewEl: qs('#rfThumbPreview'),
    hiddenEl:  qs('#rfImageUrl'),

    async getSignature() {
      const headers = {};
      const t = localStorage.getItem('liveeToken');
      if (t) headers.Authorization = `Bearer ${t}`;
      const res = await fetch(`${API_BASE}/uploads/signature`, { headers });
      if (!res.ok) throw new Error(`서명 발급 실패(HTTP_${res.status})`);
      const json = await res.json().catch(() => ({}));
      const sig = json?.data ?? json;
      const { cloudName, apiKey, timestamp, signature, folder } = sig || {};
      if (!cloudName || !apiKey || !timestamp || !signature) {
        throw new Error('서명 응답 형식 오류');
      }
      return { cloudName, apiKey, timestamp, signature, folder };
    },

    async upload(file) {
      const { cloudName, apiKey, timestamp, signature, folder } = await this.getSignature();

      const fd = new FormData();
      fd.append('file', file);
      fd.append('api_key', apiKey);
      fd.append('timestamp', timestamp);
      if (CFG.USE_SIGNED_FOLDER && folder) fd.append('folder', folder);
      fd.append('signature', signature);

      const url = `https://api.cloudinary.com/v1_1/${cloudName}/image/upload`;
      if (this.prog) { this.prog.hidden = false; this.prog.value = 0; }

      return new Promise((resolve, reject) => {
        const xhr = new XMLHttpRequest();
        if (xhr.upload && this.prog) {
          xhr.upload.addEventListener('progress', (e) => {
            if (e.lengthComputable) this.prog.value = Math.round((e.loaded / e.total) * 100);
          });
        }
        xhr.onreadystatechange = () => {
          if (xhr.readyState !== 4) return;
          if (this.prog) this.prog.hidden = true;
          try {
            const json = JSON.parse(xhr.responseText || '{}');
            if (xhr.status >= 200 && xhr.status < 300) {
              if (!json.secure_url) return reject(new Error(json.error?.message || '이미지 URL 없음'));
              return resolve(json.secure_url);
            }
            reject(new Error(json.error?.message || `Cloudinary 업로드 실패(HTTP_${xhr.status})`));
          } catch {
            reject(new Error('이미지 업로드 응답 파싱 실패'));
          }
        };
        xhr.onerror = () => reject(new Error('네트워크 오류'));
        xhr.open('POST', url, true);
        xhr.send(fd);
      });
    },

    apply(url) {
      this.hiddenEl.value = url;
      if (this.previewEl) this.previewEl.src = toTransformedUrl(url);
    }
  };

  // ========= DOM =========
  const form       = qs('#recruitForm');
  const submitBtn  = qs('#rfSubmitBtn');
  const cancelBtn  = qs('#rfCancelBtn');
  const inputFile  = qs('#rfThumb');

  const titleEl     = qs('#rfTitleInput');
  const brandEl     = qs('#rfBrand');
  const dateEl      = qs('#rfDate');
  const timeEl      = qs('#rfTime');
  const locationEl  = qs('#rfLocation');
  const payEl       = qs('#rfPay');
  const payNegEl    = qs('#rfPayNeg');
  const categoryEl  = qs('#rfCategory');
  const descEl      = qs('#rfDesc');
  const imgHiddenEl = qs('#rfImageUrl');

  // ========= File change =========
  if (inputFile) {
    inputFile.addEventListener('change', async (e) => {
      const f = e.target.files?.[0];
      if (!f) return;
      if (!/^image\//.test(f.type)) { noticeUI.show('이미지 파일만 업로드할 수 있습니다.'); inputFile.value=''; return; }
      if (f.size > CFG.MAX_FILE_SIZE) { noticeUI.show('파일 용량은 8MB 이하로 제한합니다.'); inputFile.value=''; return; }

      try {
        disableForm(true);
        noticeUI.ok('이미지 업로드 중...');
        const url = await uploader.upload(f);
        uploader.apply(url);
        noticeUI.ok('이미지 업로드 완료');
      } catch (err) {
        console.error('upload error:', err);
        imgHiddenEl.value = '';
        if (uploader.previewEl) uploader.previewEl.removeAttribute('src');
        noticeUI.show(`이미지 업로드에 실패했습니다. ${err?.message || ''}`.trim());
      } finally {
        disableForm(false);
      }
    });
  }

  // ========= Edit mode =========
  const params = new URLSearchParams(location.search);
  const editId = params.get('edit');
  const isEdit = !!editId;

  async function loadExisting(editId) {
    // 빠르고 간단: /recruits/:id 있으면 그걸 사용하고, 없으면 /recruits/mine에서 찾기
    try {
      const byId = await fetchJSON(`/recruits/${encodeURIComponent(editId)}`).catch(()=>null);
      const rec = byId?.data;
      if (rec) return rec;
    } catch {}
    const mine = await fetchJSON('/recruits/mine');
    const items = mine.items || mine.data || [];
    return items.find(it => (it._id || it.id) === editId);
  }

  function prefill(rec) {
    if (!rec) return;
    titleEl.value     = rec.title || '';
    brandEl.value     = rec.brand || '';
    dateEl.value      = rec.date ? String(rec.date).slice(0,10) : '';
    timeEl.value      = rec.time || '';
    locationEl.value  = rec.location || '';
    descEl.value      = (rec.description || '').trim();

    const src = rec.imageUrl || rec.thumbnailUrl || '';
    if (src) uploader.apply(src);

    if (submitBtn) submitBtn.textContent = '수정 완료';
  }

  // ========= Validate & Build payload =========
  function validate() {
    const errors = [];
    if (!localStorage.getItem('liveeToken')) errors.push('로그인이 필요합니다.');
    if (!titleEl.value.trim()) errors.push('제목을 입력해 주세요.');
    if (!descEl.value.trim()) errors.push('제품설명을 입력해 주세요.');
    if (!dateEl.value) errors.push('촬영일을 선택해 주세요.');
    if (!imgHiddenEl.value) errors.push('썸네일 이미지를 업로드해 주세요.');
    return errors;
  }

  function buildPayload() {
    const descWithMeta = [
      brandEl.value.trim()    && `［브랜드］ ${brandEl.value.trim()}`,
      categoryEl.value.trim() && `［상품군］ ${categoryEl.value.trim()}`,
      payEl.value.trim()      && `［출연료］ ${payEl.value.trim()}${payNegEl.checked ? ' (협의 가능)' : ''}`,
      descEl.value.trim(),
    ].filter(Boolean).join('\n');

    return {
      title: titleEl.value.trim(),
      description: descWithMeta,
      date: dateEl.value,
      time: timeEl.value || undefined,
      location: locationEl.value.trim() || undefined,
      imageUrl: imgHiddenEl.value
    };
  }

  // ========= Submit =========
  if (form) {
    form.addEventListener('submit', async (e) => {
      e.preventDefault();
      if (submitBtn) submitBtn.disabled = true;

      try {
        const errs = validate();
        if (errs.length) throw new Error(errs[0]);

        await guardRole();
        const payload = buildPayload();

        if (isEdit) {
          noticeUI.ok('수정 중...');
          await fetchJSON(`/recruits/${encodeURIComponent(editId)}`, {
            method: 'PUT',
            body: JSON.stringify(payload)
          });
          noticeUI.ok('수정되었습니다.');
        } else {
          noticeUI.ok('저장 중...');
          await fetchJSON('/recruits', { method: 'POST', body: JSON.stringify(payload) });
          noticeUI.ok('공고가 등록되었습니다.');
        }
        setTimeout(() => (location.href = '/alpa/recruits.html'), 600);
      } catch (err) {
        console.error('submit error:', err);
        noticeUI.show(err?.message || (isEdit ? '수정 중 오류가 발생했습니다.' : '저장 중 오류가 발생했습니다.'));
        if (submitBtn) submitBtn.disabled = false;
      }
    });
  }

  // ========= Init =========
  (async function init() {
    if (!localStorage.getItem('liveeToken')) { noticeUI.show('로그인이 필요합니다.'); disableForm(true); return; }
    try {
      await guardRole();
      if (isEdit) {
        const rec = await loadExisting(editId);
        if (!rec) throw new Error('해당 공고를 찾을 수 없습니다.');
        prefill(rec);
      }
    } catch (e) {
      console.warn('[init]', e);
      // guardRole / prefill이 자체적으로 메시지를 띄웠다면 조용히 패스
    }
  })();
})();