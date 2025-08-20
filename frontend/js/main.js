// /alpa/frontend/js/main.js
(function () {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const $ = (s) => document.querySelector(s);

  // 공통 fetch (items / data.items / docs 등 안전 언래핑)
  async function getJson(path, opts = {}) {
    const url = `${API_BASE}${path}`;
    const res = await fetch(url, opts);
    const json = await res.json().catch(() => ({}));
    const ok = res.ok && json.ok !== false;
    const arr =
      (Array.isArray(json) && json) ||
      json.items ||
      json.data?.items ||
      json.docs ||
      json.data?.docs ||
      json.result ||
      json.data?.result ||
      [];
    return { ok, items: Array.isArray(arr) ? arr : [], json, res };
  }

  // 썸네일 우선순위 + 폴백
  function pickThumb(it, ratio = "card") {
    const src =
      it?.thumbnailUrl ||
      it?.imageUrl ||
      it?.coverImageUrl ||
      it?.thumbnail ||
      "";
    if (src) return src;
    const seed = it?._id || it?.id || Math.random().toString(36).slice(2);
    if (ratio === "square") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/320/320`;
    if (ratio === "avatar") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/96/96`;
    return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/360`;
  }

  // 날짜/시간 유틸
  const toYMD = (d) => `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
  const fmtDate = (v) => { try { return new Date(v).toLocaleDateString("ko-KR"); } catch { return ""; } };
  const fmtTime = (v) => v || "";

  /* ---------------------------------------
     1) 오늘의 라이브 라인업 (#schedule)
     - 서버에 전용 스케줄 API가 없어도 동작
     - recruit.date가 오늘 이후인 모집 캠페인에서 상위 5개
  ----------------------------------------*/
  async function loadSchedule() {
    const box = $("#schedule");
    if (!box) return;

    try {
      // 1) 기본: 전용 API가 있으면 먼저 사용
      let items = [];
      const trial1 = await getJson("/recruits/schedule");
      if (trial1.ok && trial1.items.length) {
        items = trial1.items;
      } else {
        // 2) 대안: 캠페인에서 recruit만 가져와 클라이언트에서 필터/정렬
        const { ok, items: all } = await getJson("/campaigns?type=recruit&limit=50");
        if (ok) {
          const today = new Date();
          const todayYMD = toYMD(today);
          items = (all || [])
            .filter(it => it?.recruit?.date)                      // 날짜가 있는 것
            .filter(it => String(it.recruit.date) >= todayYMD)    // 오늘 이후
            .sort((a, b) => String(a.recruit.date).localeCompare(String(b.recruit.date)))
            .slice(0, 5);
        }
      }

      if (!items.length) {
        box.innerHTML = `<div class="lv-empty">예정된 일정이 없습니다.</div>`;
        return;
      }

      box.innerHTML = items.map((it) => {
        const r = it.recruit || it; // 전용 API면 평면 구조일 수 있음
        const date = r.date || it.date;
        const time = r.timeStart || r.time || it.time;
        return `
          <div class="lv-s-item">
            <img class="lv-s-thumb" src="${pickThumb(it, "avatar")}"
                 onerror="this.onerror=null;this.src='${pickThumb({}, "avatar")}'" />
            <div class="lv-s-body">
              <div class="lv-s-title">${it.title || r.title || "무제"}</div>
              <div class="lv-s-meta">${date ? fmtDate(date) : ""}${time ? " · " + fmtTime(time) : ""}</div>
            </div>
          </div>
        `;
      }).join("");
    } catch (e) {
      console.debug("[schedule] error", e);
      box.innerHTML = `<div class="lv-empty">일정 로딩 실패</div>`;
    }
  }

  /* -------------------------------------------
     2) 쇼호스트 모집: 리스트형 3개 (#recruits)
  --------------------------------------------*/
  async function loadRecruitList() {
    const box = $("#recruits");
    if (!box) return;

    try {
      const { ok, items } = await getJson("/campaigns?type=recruit&limit=3");
      if (!ok || !items.length) {
        box.innerHTML = `<div class="lv-empty">등록된 모집 캠페인이 없습니다</div>`;
        return;
      }

      box.innerHTML = items.map((it) => {
        const r = it.recruit || {};
        return `
          <a class="lv-s-item" href="/alpa/blank/blank.html?p=recruit&id=${encodeURIComponent(it.id || it._id || "")}">
            <img class="lv-s-thumb" src="${pickThumb(it, "avatar")}"
                 onerror="this.onerror=null;this.src='${pickThumb({}, "avatar")}'" />
            <div class="lv-s-body">
              <div class="lv-s-title">${it.title || r.title || "무제"}</div>
              <div class="lv-s-meta">
                ${r.date ? fmtDate(r.date) : ""}${r.timeStart ? " · " + fmtTime(r.timeStart) : ""}${r.location ? " · " + r.location : ""}
              </div>
            </div>
          </a>
        `;
      }).join("");
    } catch (e) {
      console.debug("[recruitList] error", e);
      box.innerHTML = `<div class="lv-empty">모집 로딩 실패</div>`;
    }
  }

  /* ----------------------------------------------------
     3) 라이브 상품: 2열 그리드 (#productGrid)
  -----------------------------------------------------*/
  async function loadProductGrid() {
    const grid = $("#productGrid");
    if (!grid) return;

    try {
      const { ok, items } = await getJson("/campaigns?type=product&limit=8");
      if (!ok || !items.length) {
        grid.innerHTML = `<div class="lv-empty">등록된 상품 캠페인이 없습니다</div>`;
        return;
      }

      grid.innerHTML = items.map((it) => `
        <a class="lv-card"
           href="/alpa/blank/blank.html?p=product&id=${encodeURIComponent(it.id || it._id || "")}"
           style="display:inline-block; width:calc(50% - 8px); vertical-align:top; margin:4px;">
          <img class="lv-thumb"
               src="${pickThumb(it, "card")}"
               onerror="this.onerror=null;this.src='${pickThumb({}, "card")}'" />
          <div class="lv-title">${it.title || "무제"}</div>
          <div class="lv-meta">${it.brand || "브랜드 미정"}</div>
        </a>
      `).join("");
    } catch (e) {
      console.debug("[productGrid] error", e);
      grid.innerHTML = `<div class="lv-empty">상품 로딩 실패</div>`;
    }
  }

  // 실행
  loadSchedule();
  loadRecruitList();
  loadProductGrid();

  if (!API_BASE) console.warn("[main.js] LIVEE_CONFIG.API_BASE 미설정");
})();