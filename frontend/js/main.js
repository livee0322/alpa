<script>
(async function () {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const $ = (sel) => document.querySelector(sel);

  // -------- 공통 헬퍼 --------
  const PLACE = {
    s: (id) => `https://picsum.photos/seed/s${id||'livee'}/96/96`,
    r: (id) => `https://picsum.photos/seed/r${id||'livee'}/640/360`,
    p: (id) => `https://picsum.photos/seed/p${id||'livee'}/320/320`,
  };

  function pickImage(item, kind) {
    // kind: 's'|'r'|'p' (schedule/recruit/portfolio)
    return item?.thumbnailUrl || item?.imageUrl || item?.profileImage || PLACE[kind](item?._id);
  }

  async function getJSON(url) {
    const res = await fetch(url);
    const json = await res.json().catch(() => ({}));
    // API가 {ok:true, items:[]} 또는 {ok:true, data:{items:[]}} 등 다양하게 올 수 있으니 유연 처리
    const items = json?.items || json?.data?.items || [];
    return { ok: res.ok && json?.ok !== false, items, raw: json };
  }

  function fmtDate(d) {
    try {
      return new Date(d).toLocaleString('ko-KR', { hour12: false });
    } catch { return ''; }
  }

  // -------- 섹션 1: 일정 (today ~ +3) --------
  async function loadSchedule() {
    const box = $('#schedule');
    if (!box) return;
    try {
      const { ok, items } = await getJSON(`${API_BASE}/recruits/schedule`);
      if (!ok || !items.length) {
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
    } catch (e) {
      console.debug('[schedule] error', e);
      box.innerHTML = `<div class="lv-empty">일정 로딩 실패</div>`;
    }
  }

  // -------- 섹션 2: 추천 공고 4 --------
  async function loadRecruits() {
    const box = $('#recruits');
    if (!box) return;
    try {
      const { ok, items } = await getJSON(`${API_BASE}/recruits?limit=4`);
      if (!ok || !items.length) {
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
    } catch (e) {
      console.debug('[recruits] error', e);
      box.innerHTML = `<div class="lv-empty">공고 로딩 실패</div>`;
    }
  }

  // -------- 섹션 3: 쇼호스트 4 --------
  async function loadPortfolios() {
    const box = $('#portfolios');
    if (!box) return;
    try {
      const { ok, items } = await getJSON(`${API_BASE}/portfolios?limit=4`);
      if (!ok || !items.length) {
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
          <div class="lv-meta">${it.jobTag || ''}${it.region ? ' · ' + it.region : ''}</div>
        </a>
      `).join('');
    } catch (e) {
      console.debug('[portfolios] error', e);
      box.innerHTML = `<div class="lv-empty">포트폴리오 로딩 실패</div>`;
    }
  }

  // kick
  loadSchedule();
  loadRecruits();
  loadPortfolios();
})();
</script>