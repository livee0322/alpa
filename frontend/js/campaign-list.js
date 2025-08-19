(() => {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const list  = document.getElementById('clList');   // ✅ id 일치
  const empty = document.getElementById('clEmpty');

  if (!list) return;

  const authHeaders = () => {
    const t = localStorage.getItem('liveeToken');
    return t ? { Authorization: `Bearer ${t}` } : {};
  };

  const toThumb = (url = '') => {
    try {
      if (!url) return '';
      const [h, t] = String(url).split('/upload/');
      return t ? `${h}/upload/c_fill,g_auto,w_320,h_180,f_auto,q_auto/${t}` : url;
    } catch { return url || ''; }
  };

  async function loadMine() {
    list.innerHTML = `
      <div class="cl-skeleton"></div>
      <div class="cl-skeleton"></div>
      <div class="cl-skeleton"></div>
    `;
    empty.hidden = true;

    try {
      const res  = await fetch(`${API_BASE}/campaigns/mine`, { headers: authHeaders() });
      const json = await res.json().catch(() => ({}));
      if (!res.ok) throw new Error(json.message || `HTTP_${res.status}`);

      const items = json.items || json.data || [];
      render(items);
    } catch (e) {
      list.innerHTML = `<p class="cl-error">목록을 불러오지 못했습니다. ${e.message || ''}</p>`;
      empty.hidden = true;
    }
  }

  function render(items = []) {
    list.innerHTML = '';
    if (!items.length) {
      empty.hidden = false;
      return;
    }
    empty.hidden = true;

    items.forEach((it) => {
      const card = document.createElement('article');
      card.className = 'cl-card';

      // 썸네일
      const img = document.createElement('img');
      img.className = 'cl-thumb';
      img.src = it.thumbnailUrl || toThumb(it.imageUrl) || toThumb(it.coverImageUrl) || '';
      img.alt = '';

      // 본문
      const body = document.createElement('div');
      body.className = 'cl-body';

      const row1 = document.createElement('div');
      row1.className = 'cl-row1';

      const badge = document.createElement('span');
      badge.className = `cl-badge ${it.type === 'recruit' ? 'cl-badge--recruit' : 'cl-badge--product'}`;
      badge.textContent = it.type === 'recruit' ? '쇼호스트 모집' : '상품 캠페인';

      const title = document.createElement('div');
      title.className = 'cl-title';
      title.textContent = it.title || '(제목 없음)';

      row1.appendChild(badge);
      row1.appendChild(title);

      body.appendChild(row1);

      // 액션
      const act = document.createElement('div');
      act.className = 'cl-act';

      const btnEdit = document.createElement('a');
      btnEdit.className = 'cl-btn';
      btnEdit.textContent = '수정';
      btnEdit.href = `/alpa/campaign-new.html?edit=${encodeURIComponent(it.id || it._id || '')}`;

      const btnDel = document.createElement('button');
      btnDel.className = 'cl-btn cl-btn--danger';
      btnDel.textContent = '삭제';
      btnDel.addEventListener('click', async () => {
        if (!confirm('삭제하시겠어요?')) return;
        const res = await fetch(`${API_BASE}/campaigns/${encodeURIComponent(it.id || it._id)}`, {
          method: 'DELETE',
          headers: { 'Content-Type': 'application/json', ...authHeaders() },
        });
        if (res.ok) loadMine();
      });

      act.appendChild(btnEdit);
      act.appendChild(btnDel);

      card.appendChild(img);
      card.appendChild(body);
      card.appendChild(act);
      list.appendChild(card);
    });
  }

  loadMine();
})();