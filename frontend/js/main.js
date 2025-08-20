// /// /alpa/frontend/js/main.js
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
  function pickThumb(it, mode = "card") {
    const src =
      it?.thumbnailUrl ||
      it?.imageUrl ||
      it?.coverImageUrl ||
      it?.thumbnail ||
      "";
    if (src) return src;
    const seed = it?._id || it?.id || Math.random().toString(36).slice(2);
    if (mode === "square") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/640`;
    if (mode === "avatar") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/96/96`;
    return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/360`;
  }

  // 날짜/시간 유틸
  const toYMD = (d) =>
    `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
  const fmtDate = (v) => {
    try {
      const d = new Date(v);
      const today = toYMD(new Date());
      return toYMD(d) === today ? "오늘" : d.toLocaleDateString("ko-KR");
    } catch {
      return "";
    }
  };
  const fmtHM = (hhmm) => {
    if (!hhmm) return "";
    try {
      // "09:30" -> 09:30 (로케일 포맷 안쓰고 고정 출력)
      const [h, m] = String(hhmm).split(":");
      return `${h?.padStart(2, "0")}:${m?.padStart(2, "0")}`;
    } catch {
      return hhmm;
    }
  };
  const fmtRange = (start, end, single) => {
    if (start && end) return `${fmtHM(start)} – ${fmtHM(end)}`;
    if (single) return fmtHM(single);
    return "";
  };
  const n2 = (v) => (isFinite(v) ? Number(v).toLocaleString() : "");

  /* ---------------------------------------
     1) 오늘의 라이브 라인업 (#schedule)
     - "등록된 모집 공고"를 일정처럼 노출
     - 썸네일 / 제목 / 시간(시작~종료 또는 단일 시간)
  ----------------------------------------*/
  async function loadSchedule() {
    const box = $("#schedule");
    if (!box) return;

    try {
      // 모집 캠페인에서 오늘/이후만 추출
      const { ok, items: all } = await getJson("/campaigns?type=recruit&limit=100");
      let items = [];
      if (ok) {
        const todayYMD = toYMD(new Date());
        items = (all || [])
          .filter((it) => it?.recruit?.date) // 날짜 있는 것만
          .filter((it) => String(it.recruit.date) >= todayYMD) // 오늘 이후
          .sort((a, b) => {
            // 날짜 → 시작시간 기준 정렬
            const ad = String(a.recruit.date);
            const bd = String(b.recruit.date);
            if (ad !== bd) return ad.localeCompare(bd);
            const at = a.recruit.timeStart || a.recruit.time || "";
            const bt = b.recruit.timeStart || b.recruit.time || "";
            return String(at).localeCompare(String(bt));
          })
          .slice(0, 5);
      }

      if (!items.length) {
        box.innerHTML = `<div class="lv-empty">예정된 일정이 없습니다.</div>`;
        return;
      }

      box.innerHTML = items
        .map((it) => {
          const r = it.recruit || {};
          const dateLabel = fmtDate(r.date);
          const timeLabel = fmtRange(r.timeStart, r.timeEnd, r.time);
          const when = [dateLabel, timeLabel].filter(Boolean).join(" · ");
          const href = `/alpa/blank/blank.html?p=recruit&id=${encodeURIComponent(it.id || it._id || "")}`;

          return `
          <a class="lv-s-item" href="${href}">
            <img class="lv-s-thumb"
                 src="${pickThumb(it, "avatar")}"
                 alt=""
                 onerror="this.onerror=null;this.src='${pickThumb({}, "avatar")}'" />
            <div class="lv-s-body">
              <div class="lv-s-title">${it.title || r.title || "무제"}</div>
              <div class="lv-s-meta">${when}</div>
            </div>
          </a>`;
        })
        .join("");
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

      box.innerHTML = items
        .map((it) => {
          const r = it.recruit || {};
          const when = [fmtDate(r.date), fmtHM(r.timeStart || r.time)]
            .filter(Boolean)
            .join(" · ");
          return `
          <a class="lv-s-item" href="/alpa/blank/blank.html?p=recruit&id=${encodeURIComponent(it.id || it._id || "")}">
            <img class="lv-s-thumb" src="${pickThumb(it, "avatar")}"
                 onerror="this.onerror=null;this.src='${pickThumb({}, "avatar")}'" />
            <div class="lv-s-body">
              <div class="lv-s-title">${it.title || r.title || "무제"}</div>
              <div class="lv-s-meta">${when}</div>
            </div>
          </a>`;
        })
        .join("");
    } catch (e) {
      console.debug("[recruitList] error", e);
      box.innerHTML = `<div class="lv-empty">모집 로딩 실패</div>`;
    }
  }

  /* ----------------------------------------------------
     3) 라이브 상품: 2열 그리드 (#productGrid) 최대 10개
  -----------------------------------------------------*/
  async function loadProductGrid() {
    const grid = $("#productGrid");
    if (!grid) return;

    try {
      const { ok, items } = await getJson("/campaigns?type=product&limit=10");
      if (!ok || !items.length) {
        grid.innerHTML = `<div class="lv-empty">등록된 상품 캠페인이 없습니다</div>`;
        return;
      }

      grid.innerHTML = items
        .map((it) => {
          const price = it?.sale?.price ?? it?.products?.[0]?.price ?? null;
          return `
          <a class="lv-g-card" href="/alpa/blank/blank.html?p=product&id=${encodeURIComponent(it.id || it._id || "")}">
            <img class="lv-g-thumb"
                 src="${pickThumb(it, "square")}"
                 alt="${(it.title || "상품")}"
                 onerror="this.onerror=null;this.src='https://picsum.photos/seed/${encodeURIComponent(
                   "p" + (it._id || "")
                 )}/640/640'"/>
            <div class="lv-g-body">
              <div class="lv-g-brand">${it.brand || "브랜드 미정"}</div>
              <div class="lv-g-title">${it.title || "상품명 미정"}</div>
              <div class="lv-g-price">${price != null ? n2(price) + "원" : ""}</div>
            </div>
          </a>`;
        })
        .join("");
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