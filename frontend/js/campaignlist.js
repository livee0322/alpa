(function(){
  const { API_BASE, thumb } = window.LIVEE_CONFIG || {};
  const list = document.getElementById('clList');
  const empty = document.getElementById('clEmpty');

  function toThumb(url){
    try{
      const [h,t] = (url||'').split('/upload/');
      if(!t) return url;
      return `${h}/upload/${thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto'}/${t}`;
    }catch{return url;}
  }
  function authHeaders(){
    const t = localStorage.getItem('liveeToken');
    return t ? { Authorization:`Bearer ${t}` } : {};
  }

  async function load(){
    try{
      const res = await fetch(`${API_BASE}/campaigns/mine`, { headers: authHeaders() });
      const json = await res.json();
      const items = json.items || json.data || [];
      list.innerHTML = '';
      if(!items.length){ empty.hidden = false; return; }
      empty.hidden = true;
      items.forEach((it)=>{
        const card = document.createElement('article');
        card.className = 'cl-card';
        const img = document.createElement('img');
        img.className = 'cl-thumb';
        img.src = toThumb(it.imageUrl || it.thumbnailUrl || '');
        const body = document.createElement('div');
        body.className = 'cl-body';
        const title = document.createElement('div'); title.className='cl-title'; title.textContent = it.title || '(제목 없음)';
        const meta = document.createElement('div'); meta.className='cl-meta';
        meta.textContent = it.type === 'recruit' ? '쇼호스트 모집' : '상품 캠페인';
        const acts = document.createElement('div'); acts.className='cl-act';
        const edit = document.createElement('a'); edit.href = `/alpa/campaign-new.html?edit=${encodeURIComponent(it._id || it.id)}`; edit.textContent='수정';
        const del = document.createElement('button'); del.textContent='삭제';
        del.addEventListener('click', async ()=>{
          if(!confirm('삭제하시겠어요?')) return;
          const resDel = await fetch(`${API_BASE}/campaigns/${encodeURIComponent(it._id || it.id)}`, {
            method:'DELETE', headers:{ 'Content-Type':'application/json', ...authHeaders() }
          });
          if(resDel.ok) load();
        });
        acts.append(edit, del);
        body.append(title, meta);
        card.append(img, body, acts);
        list.appendChild(card);
      });
    }catch(e){
      list.innerHTML = '<p>목록을 불러오지 못했습니다.</p>';
    }
  }

  load();
})();