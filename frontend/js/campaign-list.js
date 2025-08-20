/* /alpa/frontend/js/campaign-list.js */
(() => {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const list  = document.getElementById('clList');
  const empty = document.getElementById('clEmpty');
  if (!list) return;

  /* ---------------- Helpers ---------------- */
  const authHeaders = () => {
    const t = localStorage.getItem('liveeToken');
    return t ? { Authorization: `Bearer ${t}` } : {};
  };

  // Cloudinary 16:9 변환 (서버 기본과 동일한 프리셋)
  const toThumb = (url = '') => {
    try {
      if (!url) return '';
      const [h, t] = String(url).split('/upload/');
      const TR = 'c_fill,g_auto,w_640,h_360,f_auto,q_auto';
      return t ? `${h}/upload/${TR}/${t}` : url;
    } catch {
      return url || '';
    }
  };

  const pickImage = (it) =>
    it?.thumbnailUrl || toThumb(it?.imageUrl) || toThumb(it?.coverImageUrl) || '';

  const handleUnauthorized = () => {
    ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k => localStorage.removeItem(k));
    location.href = '/alpa/login.html';
  };

  /* ---------------- Data ---------------- */
  async function loadMine() {
    // skeleton
    list.innerHTML = `
      <div class="cl-skeleton"></div>
      <div class="cl-skeleton"></div>
      <div class="cl-skeleton"></div>
    `;
    empty.hidden = true;

    try {
      const res = await fetch(`${API_BASE}/campaigns/mine`, { headers: authHeaders() });
      const json = await res.json().catch(() => ({}));

      if (res.status === 401) return handleUnauthorized();
      if (!res.ok || json.ok === false) throw new Error(json.message || `HTTP_${res.status}`);

      const items = Array.isArray(json.items) ? json.items : (json.data || []);
      render(Array.isArray(items) ? items : []);
    } catch (e) {
      list.innerHTML = `<p class="cl-error">목록을 불러오지 못했습니다. ${e.message || ''}</p>`;
      empty.hidden = true;
    }
  }

  /* ---------------- Render ---------------- */
  function render(items = []) {
    list.innerHTML = '';
    if (!items.length) {
      empty.hidden = false;
      return;
    }
    empty.hidden = true;

    items.forEach((it) => {
      const id = it.id || it._id || '';

      const card = document.createElement('article');
      card.className = 'cl-card';

      // 썸네일
      const img = document.createElement('img');
      img.className = 'cl-thumb';
      img.src = pickImage(it);
      img.alt = it.title || '캠페인 썸네일';
      img.onerror = () => {
        img.onerror = null;
        img.src = `https://picsum.photos/seed/${encodeURIComponent(id)}/640/360`;
      };

      // 본문
      const body = document.createElement('div');
      body.className = 'cl-body';

      // 1행: 유형 배지
      const row1 = document.createElement('div');
      row1.className = 'cl-row1';
      const isRecruit = it.type === 'recruit';

      const badge = document.createElement('span');
      badge.className = `cl-badge ${isRecruit ? 'cl-badge--recruit' : 'cl-badge--product'}`;
      badge.textContent = isRecruit ? '쇼호스트 모집' : '상품 캠페인';
      row1.appendChild(badge);
      body.appendChild(row1);

      // 브랜드
      const brand = document.createElement('div');
      brand.className = 'cl-brand';
      brand.textContent = it.brand || it.recruit?.brand || '브랜드 미정';
      body.appendChild(brand);

      // 제목
      const title = document.createElement('div');
      title.className = 'cl-title';
      title.textContent = it.title || it.recruit?.title || '(제목 없음)';
      body.appendChild(title);

      // 하단 액션
      const act = document.createElement('div');
      act.className = 'cl-act';

      const btnEdit = document.createElement('a');
      btnEdit.className = 'cl-btn';
      btnEdit.textContent = '수정';
      btnEdit.href = `/alpa/campaign-new.html?edit=${encodeURIComponent(id)}`;

      const btnDel = document.createElement('button');
      btnDel.className = 'cl-btn cl-btn--danger';
      btnDel.textContent = '삭제';
      btnDel.addEventListener('click', async () => {
        if (!confirm('삭제하시겠어요?')) return;
        try {
          const res = await fetch(`${API_BASE}/campaigns/${encodeURIComponent(id)}`, {
            method: 'DELETE',
            headers: { 'Content-Type': 'application/json', ...authHeaders() },
          });
          const js = await res.json().catch(() => ({}));
          if (res.status === 401) return handleUnauthorized();
          if (!res.ok || js.ok === false) throw new Error(js.message || `HTTP_${res.status}`);
          loadMine();
        } catch (err) {
          alert(`삭제 실패: ${err.message || err}`);
        }
      });

      act.appendChild(btnEdit);
      act.appendChild(btnDel);

      // 조립
      card.appendChild(img);
      card.appendChild(body);
      card.appendChild(act);
      list.appendChild(card);
    });
  }

  /* ---------------- Init ---------------- */
  loadMine();
})();