// /alpa/frontend/js/main.js
(function () {
  const { API_BASE } = window.LIVEE_CONFIG || {};

  const $ = (s) => document.querySelector(s);

  // 공통 fetch (items/ data.items / docs 등 안전 언래핑)
  async function getJson(path, opts = {}) {
    const url = `${API_BASE}${path}`;
    const res = await fetch(url, opts);
    const json = await res.json().catch(() => ({}));
    const ok = res.ok && json.ok !== false;

    // 배열 후보 중 첫 번째를 items로 사용
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

    // picsum 폴백
    const seed = it?._id || it?.id || Math.random().toString(36).slice(2);
    if (ratio === "square") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/320/320`;
    if (ratio === "avatar") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/96/96`;
    return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/360`;
  }

  // 날짜/시간 표시
  const fmtDate = (v) => {
    try { return new Date(v).toLocaleDateString("ko-KR"); } catch { return ""; }
  };
  const fmtTime = (v) => {
    try { return new Date(`1970-01-01T${v}`).toLocaleTimeString("ko-KR", { hour: "2-digit", minute: "2-digit" }); }
    catch { return v || ""; }
  };

  /* -----------------------------
     1) 오늘의 라이브 라인업
  ------------------------------*/
  async function loadSchedule() {
    const box = $("#schedule");
    if (!box) return;

    try {
      // 이 엔드포인트가 없다면 빈 상태로
      const { ok, items } = await getJson("/recruits/schedule");
      if (!ok || !items.length) {
        box.innerHTML = `<div class="lv-empty">예정된 일정이 없습니다.</div>`;
        return;
      }

      box.innerHTML = items.map((it) => `
        <div class="lv-s-item">
          <img class="lv-s-thumb" src="${pickThumb(it, "avatar")}"
               onerror="this.onerror=null;this.src='${pickThumb({}, "avatar")}'" />
          <div class="lv-s-body">
            <div class="lv-s-title">${it.title || "무제"}</div>
            <div class="lv-s-meta">${fmtDate(it.date)} ${it.time ? "· " + fmtTime(it.time) : ""}</div>
          </div>
        </div>
      `).join("");
    } catch (e) {
      console.debug("[schedule] error", e);
      box.innerHTML = `<div class="lv-empty">일정 로딩 실패</div>`;
    }
  }

  /* -------------------------------------------
     2) 쇼호스트 모집: 리스트형 3개 (id=recruits)
     /campaigns?type=recruit&limit=3
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

      // 리스트형은 .lv-s-item 스타일 재사용
      box.innerHTML = items.map((it) => {
        const r = it.recruit || {};
        return `
          <a class="lv-s-item" href="/alpa/blank/blank.html?p=recruit&id=${encodeURIComponent(it.id || it._id || "")}">
            <img class="lv-s-thumb" src="${pickThumb(it, "avatar")}"
                 onerror="this.onerror=null;this.src='${pickThumb({}, "avatar")}'" />
            <div class="lv-s-body">
              <div class="lv-s-title">${it.title || r.title || "무제"}</div>
              <div class="lv-s-meta">
                ${r.date ? fmtDate(r.date) : ""}${r.time ? " · " + fmtTime(r.time) : ""}${r.location ? " · " + r.location : ""}
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
     3) 라이브 상품: 2열 그리드 (새 컨테이너 #productGrid)
     /campaigns?type=product&limit=8
     ※ 메인 CSS에 그리드가 없더라도, 최소한의 인라인 스타일로 2열 보장
  -----------------------------------------------------*/
  async function loadProductGrid() {
    const grid = document.querySelector("#productGrid");
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

  // config 확인
  if (!API_BASE) console.warn("[main.js] LIVEE_CONFIG.API_BASE 미설정");
})();