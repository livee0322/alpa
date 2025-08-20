// /alpa/frontend/js/main.js
(function () {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const $ = (s) => document.querySelector(s);

  // ---------- fetch helper ----------
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

  // ---------- utils ----------
  function pickThumb(it, ratio = "card") {
    const src = it?.thumbnailUrl || it?.imageUrl || it?.coverImageUrl || it?.thumbnail || "";
    if (src) return src;
    const seed = it?._id || it?.id || Math.random().toString(36).slice(2);
    if (ratio === "square") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/640`;
    if (ratio === "avatar") return `https://picsum.photos/seed/${encodeURIComponent(seed)}/96/96`;
    return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/360`;
  }
  const n2 = (v) => (isFinite(v) ? Number(v).toLocaleString() : "");

  // YYYY-MM-DD → Date(로컬 00:00)
  const toDateOnly = (s) => {
    if (!s) return null;
    const [y,m,d] = String(s).split("-").map(Number);
    if (!y||!m||!d) return null;
    return new Date(y, m-1, d);
  };

  /* ---------------------------------------
   * 1) 오늘의 라이브 라인업 (#schedule)
   *    - 서버가 today/sort 미지원시 클라이언트 폴백
   *    - 항목 클릭 시 상세(/alpa/campaign.html?id=...)
   * -------------------------------------*/
  async function loadSchedule() {
    const box = $("#schedule");
    if (!box) return;

    const today = new Date();
    const t0 = new Date(today.getFullYear(), today.getMonth(), today.getDate());

    try {
      // 1차: 서버가 정렬/필터를 지원하는 경우
      let { ok, items } = await getJson("/campaigns?type=recruit&today=1&sort=schedule&limit=6");

      // 2차: 폴백(전체에서 오늘만 필터 + timeStart/시간 오름차순)
      if (!ok || !items.length) {
        const fallback = await getJson("/campaigns?type=recruit&limit=50");
        if (fallback.ok) {
          items = (fallback.items || [])
            .filter(it => {
              const r = it.recruit || {};
              const d = toDateOnly(r.date);
              return d && d.getTime() === t0.getTime();
            })
            .sort((a,b) => {
              const ra = a.recruit || {}, rb = b.recruit || {};
              return String(ra.timeStart || ra.time || '').localeCompare(String(rb.timeStart || rb.time || ''));
            })
            .slice(0, 6);
          ok = true;
        }
      }

      if (!ok || !items.length) {
        box.innerHTML = `<div class="lv-empty">예정된 일정이 없습니다.</div>`;
        return;
      }

      box.innerHTML = `
        <div class="lv-mini">
          ${items.map((it) => {
            const r = it.recruit || {};
            const id = encodeURIComponent(it.id || it._id || "");
            const brand = it.brand || r.brand || "브랜드 미정";
            const time  = r.timeStart || r.time || "";
            const timeHtml = time ? `<span class="lv-mini-time">${time} 예정</span>` : "";
            const dot      = time ? `<span class="lv-mini-dot">·</span>` : "";
            return `
              <a class="lv-mini-item" href="/alpa/campaign.html?id=${id}">
                <img class="lv-mini-thumb"
                     src="${pickThumb(it, "avatar")}"
                     alt=""
                     onerror="this.onerror=null;this.src='${pickThumb({}, "avatar")}'" />
                <div class="lv-mini-body">
                  <div class="lv-mini-title">${it.title || r.title || "무제"}</div>
                  <div class="lv-mini-sub">
                    ${timeHtml}
                    ${dot}
                    <span class="lv-mini-brand">${brand}</span>
                  </div>
                </div>
              </a>
            `;
          }).join("")}
        </div>
      `;
    } catch (e) {
      console.debug("[schedule] error", e);
      box.innerHTML = `<div class="lv-empty">일정 로딩 실패</div>`;
    }
  }

  /* -------------------------------------------
   * 2) 추천 공고: 클릭 → 상세로 이동
   * -----------------------------------------*/
  async function loadRecruitList() {
    const box = $("#recruits");
    if (!box) return;

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
        const href = `/alpa/campaign.html?id=${encodeURIComponent(it.id || it._id || "")}`;
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
   * 3) 라이브 상품: 클릭 → 상세로 이동
   * ---------------------------------------------------*/
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
        const href = `/alpa/campaign.html?id=${encodeURIComponent(it.id || it._id || "")}`;
        return `
          <a class="lv-g-card" href="${href}">
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