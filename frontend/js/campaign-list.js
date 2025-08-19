/* /alpa/frontend/js/campaign-list.js */
(function(){
  const { API_BASE, thumb } = window.LIVEE_CONFIG || {};
  const list = document.getElementById('clList');
  const empty = document.getElementById('clEmpty');

  const toThumb = (url) => {
    try{
      const [h,t] = (url || '').split('/upload/');
      if(!t) return url || '';
      const tr = (thumb && thumb.card169) || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto';
      return `${h}/upload/${tr}/${t}`;
    }catch{ return url || ''; }
  };

  const authHeaders = () => {
    const t = localStorage.getItem('liveeToken');
    return t ? { Authorization:`Bearer ${t}` } : {};
  };

  async function load(){
    try{
      const res = await fetch(`${API_BASE}/campaigns/mine`, { headers: authHeaders() });
      const json = await res.json().catch(()=>({}));
      const items = json.items || json.data || [];
      list.innerHTML = '';
      if(!items.length){ empty.hidden = false; return; }
      empty.hidden = true;

      items.forEach((it)=>{
        const id = it._id || it.id;
        const type = it.type === 'recruit' ? 'recruit' : 'product';

        const card = document.createElement('article');
        card.className = 'cl-card';

        const img = document.createElement('img');
        img.className = 'cl-thumb';
        img.loading = 'lazy';
        img.src = toThumb(it.imageUrl || it.thumbnailUrl || '');

        const body = document.createElement('div');
        body.className = 'cl-body';

        const row1 = document.createElement('div');
        row1.className = 'cl-row1';

        const badge = document.createElement('span');
        badge.className = `cl-badge cl-badge--${type}`;
        badge.textContent = type === 'recruit' ? '쇼호스트 모집' : '상품 캠페인';

        const title = document.createElement('div');
        title.className = 'cl-title';
        title.textContent = it.title || '(제목 없음)';

        row1.append(badge);
        body.append(row1, title);

        const acts = document.createElement('div');
        acts.className = 'cl-act';

        const edit = document.createElement('a');
        edit.href = `/alpa/campaign-new.html?edit=${encodeURIComponent(id)}`;
        edit.className = 'cl-btn';
        edit.textContent = '수정';

        const del = document.createElement('button');
        del.type = 'button';
        del.className = 'cl-btn cl-btn--danger';
        del.textContent = '삭제';
        del.addEventListener('click', async ()=>{
          if(!confirm('삭제하시겠어요?')) return;
          const r = await fetch(`${API_BASE}/campaigns/${encodeURIComponent(id)}`, {
            method:'DELETE',
            headers:{ 'Content-Type':'application/json', ...authHeaders() }
          });
          if(r.ok) load();
        });

        acts.append(edit, del);

        card.append(img, body, acts);
        list.appendChild(card);
      });
    }catch(e){
      list.innerHTML = '<p class="cl-error">목록을 불러오지 못했습니다.</p>';
      empty.hidden = true;
    }
  }

  load();
})();
