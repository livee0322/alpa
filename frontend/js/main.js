<script>
/* /alpa/frontend/js/main.js (debug & robust) */
(async function () {
  const RAW_BASE = (window.LIVEE_CONFIG && window.LIVEE_CONFIG.API_BASE) || '';
  const API_BASE = RAW_BASE.replace(/\/+$/,'');   
  const $ = (sel) => document.querySelector(sel);

  const PLACE = {
    s: (id) => `https://picsum.photos/seed/s${id||'livee'}/96/96`,
    r: (id) => `https://picsum.photos/seed/r${id||'livee'}/640/360`,
    p: (id) => `https://picsum.photos/seed/p${id||'livee'}/320/320`,
  };

  const pickImage = (it, k) => it?.thumbnailUrl || it?.imageUrl || it?.profileImage || PLACE[k](it?._id);

  async function getJSON(url) {
    try {
      const res  = await fetch(url, { headers: { 'Accept':'application/json' }});
      const text = await res.text();
      let json   = {};
      try { json = text ? JSON.parse(text) : {}; } catch { /* 파싱 실패도 로깅 */ }

      // 다양한 응답 형태 대응: {items}, {data:{items}}, Array, {data:Array}
      const items =
        Array.isArray(json) ? json :
        json?.items ||
        (Array.isArray(json?.data) ? json.data : (json?.data?.items || []));
      const ok = res.ok && json?.ok !== false;

      console.log('[GET]', url, { status: res.status, ok, length: (items||[]).length, json });

      return { ok, items, status: res.status, json };
    } catch (e) {
      console.error('[GET:ERR]', url, e);
      return { ok:false, items:[], status:0, json:{} };
    }
  }

  const fmtDate = (d) => {
    try { return new Date(d).toLocaleString('ko-KR', { hour12:false }); }
    catch { return ''; }
  };

  async function loadSchedule() {
    const box = $('#schedule');
    if (!box) return;
    const { ok, items, status } = await getJSON(`${API_BASE}/recruits/schedule`);
    if (!ok) {
      box.innerHTML = `<div class="lv-empty">일정 로딩 실패 (HTTP ${status})</div>`;
      return;
    }
    if (!items.length) {
      box.innerHTML = `<div class="lv-empty">예정된 일정이 없습니다.</div>`;
      return;
    }
    box.innerHTML = items.map(it => `
      <div class="lv-s-item">
        <img class="lv-s-thumb"
             src="${pickImage(it,'s')}"
             onerror="this.onerror=null;this.src='${PLACE.s(it._id)}'">
        <div class="lv-s-body">
          <div class="lv-s-title">${it.title || '무제'}</div>
          <div class="lv-s-meta">${fmtDate(it.date)}</div>
        </div>
      </div>
    `).join('');
  }

  async function loadRecruits() {
    const box = $('#recruits');
    if (!box) return;
    const { ok, items, status } = await getJSON(`${API_BASE}/recruits?limit=4`);
    if (!ok) {
      box.innerHTML = `<div class="lv-empty">공고 로딩 실패 (HTTP ${status})</div>`;
      return;
    }
    if (!items.length) {
      box.innerHTML = `<div class="lv-empty">등록된 공고가 없습니다</div>`;
      return;
    }
    box.innerHTML = items.map(it => `
      <a class="lv-card" href="/alpa/blank/blank.html?p=recruits">
        <img class="lv-thumb"
             src="${pickImage(it,'r')}"
             loading="lazy"
             onerror="this.onerror=null;this.src='${PLACE.r(it._id)}'">
        <div class="lv-title">${it.title || '무제'}</div>
        <div class="lv-meta">${it.brand || '브랜드 미정'}</div>
      </a>
    `).join('');
  }

  async function loadPortfolios() {
    const box = $('#portfolios');
    if (!box) return;
    const { ok, items, status } = await getJSON(`${API_BASE}/portfolios?limit=4`);
    if (!ok) {
      box.innerHTML = `<div class="lv-empty">포트폴리오 로딩 실패 (HTTP ${status})</div>`;
      return;
    }
    if (!items.length) {
      box.innerHTML = `<div class="lv-empty">등록된 포트폴리오가 없습니다</div>`;
      return;
    }
    box.innerHTML = items.map(it => `
      <a class="lv-card" href="/alpa/portfolio.html">
        <img class="lv-thumb"
             src="${pickImage(it,'p')}"
             loading="lazy"
             onerror="this.onerror=null;this.src='${PLACE.p(it._id)}'">
        <div class="lv-title">${it.name || '이름 미정'}</div>
        <div class="lv-meta">${(it.jobTag || '')}${it.region ? ' · ' + it.region : ''}</div>
      </a>
    `).join('');
  }

  // kick
  console.log('[MAIN] API_BASE =', API_BASE);
  loadSchedule();
  loadRecruits();
  loadPortfolios();
})();
</script>