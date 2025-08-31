// /alpa/frontend/js/main.js  (v2.5 API 호환 + 안전 폴백)
(function () {
  // ---- Config & helpers ----
  const { API_BASE: _API_BASE } = (window.LIVEE_CONFIG || {});
  const API_BASE = (_API_BASE || "/api/v1").replace(/\/$/, "");
  const $ = (s) => document.querySelector(s);
  const DEFAULT_IMG = "default.jpg";

  // 공통 fetch(JSON) — 다양한 응답 포맷을 items로 정규화
  async function getJson(path, opts = {}) {
    const url = `${API_BASE}${path.startsWith("/") ? path : `/${path}`}`;
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

  // ---- utils ----
  function pickThumb(it, ratio = "card") {
    const src = it?.thumbnailUrl || it?.imageUrl || it?.coverImageUrl || it?.thumbnail;
    if (src) return src;
    // 기본 이미지(로컬에 default.jpg 있어야 함)
    return DEFAULT_IMG;
  }
  const n2 = (v) => (isFinite(v) ? Number(v).toLocaleString("ko-KR") : "");

  // YYYY-MM-DD → Date(로컬 00:00)
  const toDateOnly = (s) => {
    if (!s) return null;
    const [y, m, d] = String(s).split("-").map(Number);
    if (!y || !m || !d) return null;
    return new Date(y, m - 1, d);
  };

  // 서버(v2.5) → 프런트(구 코드) 필드 정규화
  function normalizeCampaign(c) {
    const r = c?.recruit || {};

    // shootTime: "HH:MM~HH:MM" → 시작만
    const startHM = (r.shootTime || "").split("~")[0] || "";

    // shootDate(Date) → YYYY-MM-DD
    let date = "";
    if (r.shootDate) {
      const d = new Date(r.shootDate);
      if (!isNaN(d)) {
        const mm = String(d.getMonth() + 1).padStart(2, "0");
        const dd = String(d.getDate()).padStart(2, "0");
        date = `${d.getFullYear()}-${mm}-${dd}`;
      }
    }

    return {
      ...c,
      brand: c.brand || r.brand || "브랜드 미정",
      thumbnailUrl: c.thumbnailUrl || c.coverImageUrl,
      _id: c.id || c._id,
      recruit: {
        ...r,
        date,              // 기존 코드가 쓰는 필드명
        timeStart: startHM // 기존 코드가 쓰는 필드명
      }
    };
  }

  /* ---------------------------------------
   * 1) 오늘의 라이브 라인업 (#schedule)
   * -------------------------------------*/
  async function loadSchedule() {
    const box = $("#schedule");
    if (!box) return;

    const today = new Date();
    const t0 = new Date(today.getFullYear(), today.getMonth(), today.getDate());

    try {
      // 서버가 today/sort 지원한다고 가정 + status=published 필터 추가
      let { ok, items } = await getJson("/campaigns?type=recruit&status=published&today=1&sort=schedule&limit=6");

      if (!ok || !items.length) {
        // 폴백: 전체에서 오늘자만 필터, 시작시간 오름차순
        const fb = await getJson("/campaigns?type=recruit&status=published&limit=50");
        if (fb.ok) {
          items = (fb.items || [])
            .map(normalizeCampaign)
            .filter((it) => {
              const d = toDateOnly(it.recruit?.date);
              return d && d.getTime() === t0.getTime();
            })
            .sort((a, b) => String(a.recruit?.timeStart || "").localeCompare(String(b.recruit?.timeStart || "")))
            .slice(0, 6);
          ok = true;
        }
      } else {
        items = items.map(normalizeCampaign);
      }

      if (!ok || !items.length) {
        box.innerHTML = `<div class="lv-empty">예정된 일정이 없습니다.</div>`;
        return;
      }

      box.innerHTML = `
        <div class="lv-mini">
          ${items
            .map((it) => {
              const r = it.recruit || {};
              const id = encodeURIComponent(it._id || it.id || "");
              const time = r.timeStart || "";
              const timeHtml = time ? `<span class="lv-mini-time">${time} 예정</span>` : "";
              const dot = time ? `<span class="lv-mini-dot">·</span>` : "";
              return `
                <a class="lv-mini-item" href="/alpa/campaign.html?id=${id}">
                  <img class="lv-mini-thumb"
                       src="${pickThumb(it, "avatar")}"
                       alt="" onerror="this.onerror=null;this.src='${DEFAULT_IMG}'" />
                  <div class="lv-mini-body">
                    <div class="lv-mini-title">${it.title || r.title || "무제"}</div>
                    <div class="lv-mini-sub">
                      ${timeHtml}
                      ${dot}
                      <span class="lv-mini-brand">${it.brand}</span>
                    </div>
                  </div>
                </a>
              `;
            })
            .join("")}
        </div>
      `;
    } catch (e) {
      console.debug("[schedule] error", e);
      box.innerHTML = `<div class="lv-empty">일정 로딩 실패</div>`;
    }
  }

  /* -------------------------------------------
   * 2) 추천 공고 리스트 (#recruits)
   * -----------------------------------------*/
  async function loadRecruitList() {
    const box = $("#recruits");
    if (!box) return;

    // D-DAY: closeAt 우선, 없으면 촬영일 기준
    const dday = (closeAt, dateStr) => {
      const d = closeAt ? toDateOnly(String(closeAt).slice(0, 10)) : toDateOnly(dateStr);
      if (!d) return { label: "", ended: false };
      const today = new Date();
      const t0 = new Date(today.getFullYear(), today.getMonth(), today.getDate());
      const diff = Math.round((d - t0) / 86400000);
      if (diff < 0) return { label: "마감", ended: true };
      if (diff === 0) return { label: "D-DAY", ended: false };
      return { label: `D-${diff}`, ended: false };
    };

    try {
      const { ok, items } = await getJson("/campaigns?type=recruit&status=published&limit=10");
      if (!ok || !items.length) {
        box.innerHTML = `<div class="lv-empty">등록된 공고가 없습니다</div>`;
        return;
      }
      const list = items.map(normalizeCampaign);

      box.innerHTML = list
        .map((it) => {
          const r = it.recruit || {};
          const { label, ended } = dday(it.closeAt, r.date);
          const pay = r.pay ? `${n2(Number(r.pay))}원` : r.payNegotiable ? "협의" : "미정";
          const href = `/alpa/campaign.html?id=${encodeURIComponent(it._id || it.id || "")}`;
          return `
            <a class="lv-job" href="${href}">
              <div class="lv-job-body">
                <div class="lv-job-brand">${it.brand}</div>
                <div class="lv-job-title">${it.title || r.title || "무제"}</div>
                <div class="lv-job-meta">
                  ${label ? `<span class="lv-job-dday ${ended ? "lv-end" : ""}">${label}</span>` : ""}
                  <span class="lv-job-sep">|</span>
                  <span>출연료 ${pay}</span>
                </div>
              </div>
              <img class="lv-job-thumb"
                   src="${pickThumb(it, "square")}"
                   alt="" onerror="this.onerror=null;this.src='${DEFAULT_IMG}'"/>
            </a>
          `;
        })
        .join("");
    } catch (e) {
      console.debug("[recruitList] error", e);
      box.innerHTML = `<div class="lv-empty">모집 로딩 실패</div>`;
    }
  }

  /* ----------------------------------------------------
   * 3) 라이브 상품 그리드 (#productGrid)
   * ---------------------------------------------------*/
  async function loadProductGrid() {
    const grid = $("#productGrid");
    if (!grid) return;
    try {
      const { ok, items } = await getJson("/campaigns?type=product&status=published&limit=10");
      if (!ok || !items.length) {
        grid.innerHTML = `<div class="lv-empty">등록된 상품 캠페인이 없습니다</div>`;
        return;
      }
      grid.innerHTML = items
        .map((raw) => {
          const it = normalizeCampaign(raw); // 썸네일/브랜드 정규화 재사용
          const price = it?.sale?.price ?? it?.products?.[0]?.price ?? null;
          const href = `/alpa/campaign.html?id=${encodeURIComponent(it._id || it.id || "")}`;
          return `
            <a class="lv-g-card" href="${href}">
              <img class="lv-g-thumb"
                   src="${pickThumb(it, "square")}"
                   alt="${it.title || "상품"}"
                   onerror="this.onerror=null;this.src='${DEFAULT_IMG}'"/>
              <div class="lv-g-body">
                <div class="lv-g-brand">${it.brand}</div>
                <div class="lv-g-title">${it.title || "상품명 미정"}</div>
                <div class="lv-g-price">${price != null ? n2(price) + "원" : ""}</div>
              </div>
            </a>
          `;
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

  if (!_API_BASE) console.warn("[main.js] LIVEE_CONFIG.API_BASE 미설정 → /api/v1 사용 중");
})();