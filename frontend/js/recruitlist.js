(() => {
  const { API_BASE, BASE_PATH = '/alpa', thumb } = window.LIVEE_CONFIG || {};
  const $  = (s) => document.querySelector(s);
  const $$ = (s) => Array.from(document.querySelectorAll(s));

  const listEl  = $('#rlList');
  const emptyEl = $('#rlEmpty');

  // 안전 썸네일 변환
  function toThumb(url) {
    if (!url) return '';
    try {
      const [h,t] = url.split('/upload/');
      return `${h}/upload/${thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto'}/${t}`;
    } catch { return url; }
  }
  const FALL = (seed) => `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/360`;

  // 카드 템플릿
  function card(it) {
    const img = toThumb(it.thumbnailUrl || it.imageUrl) || FALL(`r${it._id||''}`);
    const when = it.date ? new Date(it.date).toLocaleDateString('ko-KR') : '';
    const brand = it.brand || '브랜드 미정';
    const pay   = (it.description||'').match(/［출연료］\s*([^\n]+)/)?.[1] || '';

    return `
      <article class="rl-card">
        <img class="rl-thumb" src="${img}" alt="" onerror="this.onerror=null;this.src='${FALL('livee')}'" />
        <div class="rl-body">
          <h3 class="rl-title-sm">${escapeHtml(it.title || '무제')}</h3>
          <div class="rl-meta">
            ${when ? `<span>📅 ${when}</span>` : ''}
            <span>🏷️ ${escapeHtml(brand)}</span>
            ${pay ? `<span>💸 ${escapeHtml(pay)}</span>` : ''}
          </div>
          <div class="rl-badges">
            ${it.category ? `<span class="rl-badge">${escapeHtml(it.category)}</span>` : ''}
          </div>
          <p class="rl-desc">${escapeHtml((it.description || '').replace(/\n/g,' ').trim())}</p>
        </div>
      </article>
    `;
  }
  function escapeHtml(s){return String(s).replace(/[&<>"']/g,m=>({ '&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;' }[m]))}

  // API 호출 (한 번 넉넉히 받아서 클라이언트 필터)
  async function fetchAll() {
    const res = await fetch(`${API_BASE}/recruits?limit=100`);
    const json = await res.json().catch(()=>({}));
    const items = json.items || json.data?.items || json.data || [];
    return items;
  }

  // 필터 로직
  function applyFilter(items, filterKey) {
    const now = new Date();
    const inFuture = (d) => d && new Date(d).getTime() >= now.getTime();

    if (filterKey === 'deadline') {
      return items
        .filter(r => inFuture(r.date))
        .sort((a,b) => new Date(a.date) - new Date(b.date));
    }
    if (filterKey === 'mukbang') {
      return items.filter(r => /먹방|food|mukbang/i.test([r.title, r.description, r.category].join(' ')));
    }
    if (filterKey === 'beauty') {
      return items.filter(r => /뷰티|beauty|메이크업|코스메틱/i.test([r.title, r.description, r.category].join(' ')));
    }
    if (filterKey === 'pay') {
      // 숫자 추출해서 높은 순
      const toNum = (s) => {
        const m = String(s||'').match(/(\d[\d,\.]*)\s*(만원|원|KRW)?/);
        if (!m) return 0;
        const n = parseFloat(m[1].replace(/[,\s]/g,''));
        return /만원/.test(m[2]||'') ? n * 10000 : n;
      };
      return items
        .map(r => ({ r, pay: toNum((r.description||'').match(/［출연료］\s*([^\n]+)/)?.[1]) }))
        .sort((a,b) => b.pay - a.pay)
        .map(x => x.r);
    }
    return items;
  }

  async function render(filterKey='deadline') {
    // 탭 활성화
    $$('.rl-tab').forEach(btn => btn.classList.toggle('is-active', btn.dataset.filter === filterKey));

    // 스켈레톤 표시
    emptyEl.hidden = true;
    listEl.innerHTML = `<div class="rl-skeleton"></div><div class="rl-skeleton"></div><div class="rl-skeleton"></div><div class="rl-skeleton"></div>`;

    try {
      const all = await fetchAll();
      const filtered = applyFilter(all, filterKey);

      if (!filtered.length) {
        listEl.innerHTML = '';
        emptyEl.hidden = false;
        return;
      }
      listEl.innerHTML = filtered.map(card).join('');
    } catch (e) {
      console.debug('[recruitlist] fetch error', e);
      listEl.innerHTML = '';
      emptyEl.hidden = false;
    }
  }

  // 탭 이벤트
  document.addEventListener('click', (e)=>{
    const btn = e.target.closest('.rl-tab');
    if (!btn) return;
    render(btn.dataset.filter);
  });

  // 하단탭 활성화
  function setBottomActive(){
    const nav = document.getElementById('bottom-tab-container');
    if (!nav) return;
    const a = nav.querySelector('[data-tab="recruits"]');
    if (a) a.classList.add('active');
  }

  // 초기 실행
  render('deadline');
  setBottomActive();
})();