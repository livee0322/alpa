// /alpa/frontend/js/main.js
(function () {
  // ===== CONFIG =====
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const FALLBACK = {
    card: (seed) => `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/360`,
    avatar: (seed) => `https://picsum.photos/seed/${encodeURIComponent(seed)}/96/96`,
    square: (seed) => `https://picsum.photos/seed/${encodeURIComponent(seed)}/320/320`,
  };

  const $ = (sel) => document.querySelector(sel);

  // 통합 fetch + 응답 언래핑 (items | docs | result 전부 대응)
  async function getJson(path, opts = {}) {
    const url = `${API_BASE}${path}`;
    const res = await fetch(url, opts);
    const json = await res.json().catch(() => ({}));

    const ok = res.ok && json.ok !== false;

    // 후보들 중 '배열'을 첫 번째로 발견하는 값을 items로 사용
    const candidates = [
      json,
      json.items, json.data?.items,
      json.docs, json.data?.docs,
      json.result, json.data?.result,
    ];
    const arr = candidates.find(v => Array.isArray(v)) || [];

    return { ok, res, json, items: arr };
  }

  // 안전한 이미지 선택
  function pickThumb(it, seedPrefix) {
    const src = it?.thumbnailUrl || it?.imageUrl || '';
    return src || FALLBACK.card(`${seedPrefix}${it?._id || ''}`);
  }

  // 날짜 렌더
  function fmtDate(val) {
    try { return new Date(val).toLocaleString('ko-KR'); }
    catch { return ''; }
  }

  // ===== 위젯 1) 오늘의 라이브 라인업 =====
  async function loadSchedule() {
    const box = $('#schedule');
    if (!box) return;

    try {
      const { ok, items } = await getJson('/recruits/schedule');
      if (!ok || !items.length) {
        box.innerHTML = `<div class="lv-empty">예정된 일정이 없습니다.</div>`;
        return;
      }
      box.innerHTML = items.map(it => `
        <div class="lv-s-item">
          <img class="lv-s-thumb"
               src="${pickThumb(it, 's')}"
               onerror="this.onerror=null;this.src='${FALLBACK.avatar('livee')}'" />
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

  // ===== 위젯 2) 추천 공고 4 =====
  async function loadRecruits() {
    const box = $('#recruits');
    if (!box) return;

    try {
      const { ok, items } = await getJson('/recruits?limit=4');
      if (!ok || !items.length) {
        box.innerHTML = `<div class="lv-empty">등록된 공고가 없습니다</div>`;
        return;
      }
      box.innerHTML = items.map(it => `
        <a class="lv-card" href="/alpa/blank/blank.html?p=recruits">
          <img class="lv-thumb"
               src="${pickThumb(it, 'r')}"
               onerror="this.onerror=null;this.src='${FALLBACK.card(`r${it._id||''}`)}'" />
          <div class="lv-title">${it.title || '무제'}</div>
          <div class="lv-meta">${it.brand || '브랜드 미정'}</div>
        </a>
      `).join('');
    } catch (e) {
      console.debug('[recruits] error', e);
      box.innerHTML = `<div class="lv-empty">공고 로딩 실패</div>`;
    }
  }

  // ===== 위젯 3) 인기 쇼호스트 4 =====
  async function loadPortfolios() {
    const box = $('#portfolios');
    if (!box) return;

    try {
      const { ok, items } = await getJson('/portfolios?limit=4');
      if (!ok || !items.length) {
        box.innerHTML = `<div class="lv-empty">등록된 포트폴리오가 없습니다</div>`;
        return;
      }
      box.innerHTML = items.map(it => `
        <a class="lv-card" href="/alpa/portfolio.html">
          <img class="lv-thumb"
               src="${it.profileImage || ''}"
               onerror="this.onerror=null;this.src='${FALLBACK.square(`p${it._id||''}`)}'" />
          <div class="lv-title">${it.name || '이름 미정'}</div>
          <div class="lv-meta">${[it.jobTag, it.region].filter(Boolean).join(' · ')}</div>
        </a>
      `).join('');
    } catch (e) {
      console.debug('[portfolios] error', e);
      box.innerHTML = `<div class="lv-empty">포트폴리오 로딩 실패</div>`;
    }
  }

  // 초기 실행
  loadSchedule();
  loadRecruits();
  loadPortfolios();

  // 디버깅 도움
  if (!API_BASE || !/\/api\//.test(API_BASE)) {
    console.warn('[main.js] LIVEE_CONFIG.API_BASE 확인 필요:', API_BASE);
  }
})();