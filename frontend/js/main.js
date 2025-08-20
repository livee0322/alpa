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
      json.items || json.data?.items ||
      json.docs  || json.data?.docs  ||
      json.result|| json.data?.result|| [];
    return { ok, items: Array.isArray(arr) ? arr : [], json, res };
  }

  // 썸네일 우선순위 + 폴백
  function pickThumb(it, ratio = "card") {
    const src = it?.thumbnailUrl || it?.imageUrl || it?.coverImageUrl || it?.thumbnail || "";
    if (src) return src;
    const seed = it?._id || it?.id || Math.random().toString(36).slice(2);
    if (ratio === "square") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/640`;
    if (ratio === "avatar") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/96/96`;
    return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/360`;
  }

  // 날짜/시간
  const toYMD = (d) =>
    `${d.getFullYear()}-${String(d.getMonth()+1).padStart(2,'0')}-${String(d.getDate()).padStart(2,'0')}`;
  const fmtDate = (v) => { try { return new Date(v).toLocaleDateString("ko-KR"); } catch { return ""; } };
  const fmtTime = (v) => v || "";
  const n2 = (v) => (isFinite(v) ? Number(v).toLocaleString() : "");

  /* ---------------------------------------
     1) 오늘의 라이브 라인업 (#schedule)
  ----------------------------------------*/
  async function loadSchedule() {
    const box = $("#schedule");
    if (!box) return;
    try {
      let items = [];
      const trial1 = await getJson("/recruits/schedule");
      if (trial1.ok && trial1.items.length) {
        items = trial1.items;
      } else {
        const { ok, items: all } = await getJson("/campaigns?type=recruit&limit=50");
        if (ok) {
          const todayYMD = toYMD(new Date());
          items = (all || [])
            .filter(it => it?.recruit?.date)
            .filter(it => String(it.recruit.date) >= todayYMD)
            .sort((a,b) => String(a.recruit.date).localeCompare(String(b.recruit.date)))
            .slice(0, 5);
        }
      }
      if (!items.length) {
        box.innerHTML = `<div class="lv-empty">예정된 일정이 없습니다.</div>`;
        return;
      }
      box.innerHTML = items.map((it) => {
        const r = it.recruit || it;
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
     2) 추천 공고: 카드 리스트 (브랜드/제목/썸네일/D‑day/출연료/지원자)
  --------------------------------------------*/
  async function loadRecruitList() {
    const box = $("#recruits");
    if (!box) return;

    const toDateOnly = (s) => {
      if (!s) return null;
      const [y,m,d] = String(s).split("-").map(Number);
      if (!y || !m || !d) return null;
      return new Date(y, m - 1, d);
    };
    const dday = (dateStr) => {
      const d = toDateOnly(dateStr);
      if (!d) return { label: "", ended: false };
      const today = new Date();
      const t0 = new Date(today.getFullYear(), today.getMonth(), today.getDate());
      const diff = Math.round((d - t0) / 86400000);
      if (diff < 0)  return { label: "마감", ended: true };
      if (diff === 0) return { label: "D‑DAY", ended: false };
      return { label: `D‑${diff}`, ended: false };
    };

    try {
      const { ok, items } = await getJson("/campaigns?type=recruit&limit=10");
      if (!ok || !items.length) {
        box.innerHTML = `<div class="lv-empty">등록된 공고가 없습니다</div>`;
        return;
      }
      box.innerHTML = items.map((it) => {
        const r = it.recruit || {};
        const { label, ended } = dday(r.date);
        const pay = r.pay ? `${String(r.pay).replace(/\B(?=(\d{3})+(?!\d))/g, ",")}원` : "협의";
        const applicants =
          (typeof r.applicantsCount === "number" && r.applicantsCount) ??
          (Array.isArray(r.applicants) ? r.applicants.length : 0);
        const href = `/alpa/blank/blank.html?p=recruit&id=${encodeURIComponent(it.id || it._id || "")}`;
        return `
          <a class="lv-job" href="${href}">
            <div class="lv-job-body">
              <div class="lv-job-brand">${it.brand || r.brand || "브랜드 미정"}</div>
              <div class="lv-job-title">${it.title || r.title || "무제"}</div>
              <div class="lv-job-meta">
                ${label ? `<span class="lv-job-dday ${ended ? "lv-end" : ""}">${label}</span>` : ""}
                <span class="lv-job-sep">|</span>
                <span>출연료 ${pay}</span>
                <span class="lv-job-sep">|</span>
                <span>지원자 ${applicants}명</span>
              </div>
            </div>
            <img class="lv-job-thumb"
                 src="${pickThumb(it, "square")}"
                 alt=""
                 onerror="this.onerror=null;this.src='https://picsum.photos/seed/${encodeURIComponent("recruit"+(it._id||""))}/112/112'"/>
          </a>
        `;
      }).join("");
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
      grid.innerHTML = items.map((it) => {
        const price = it?.sale?.price ?? it?.products?.[0]?.price ?? null;
        return `
          <a class="lv-g-card" href="/alpa/blank/blank.html?p=product&id=${encodeURIComponent(it.id || it._id || "")}">
            <img class="lv-g-thumb"
                 src="${pickThumb(it, "square")}"
                 alt="${(it.title || '상품')}"
                 onerror="this.onerror=null;this.src='https://picsum.photos/seed/${encodeURIComponent('p'+(it._id||''))}/640/640'"/>
            <div class="lv-g-body">
              <div class="lv-g-brand">${it.brand || "브랜드 미정"}</div>
              <div class="lv-g-title">${it.title || "상품명 미정"}</div>
              <div class="lv-g-price">${price!=null ? n2(price)+'원' : ''}</div>
            </div>
          </a>
        `;
      }).join("");
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