// campaign.js — 상세 페이지 전용
(function () {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const $ = (s) => document.querySelector(s);

  /* ------------- helpers ------------- */
  const qs = new URLSearchParams(location.search);
  const ID = qs.get("id");

  const authHeaders = () => {
    const t = localStorage.getItem("liveeToken");
    return t ? { Authorization: `Bearer ${t}` } : {};
  };

  async function getJsonAbs(url, opts = {}) {
    const res = await fetch(url, {
      ...opts,
      headers: { "Content-Type": "application/json", ...(opts.headers || {}), ...authHeaders() },
    });
    const json = await res.json().catch(() => ({}));
    return { ok: res.ok && json.ok !== false, json, status: res.status };
  }

  const pickThumb = (it) =>
    it?.thumbnailUrl || it?.imageUrl || it?.coverImageUrl ||
    `https://picsum.photos/seed/${encodeURIComponent(it?._id||it?.id||"lv")}/1280/720`;

  const fmtDate = (s) => (s ? new Date(s).toLocaleDateString("ko-KR") : "");
  const money  = (n) => (n!=null && n!=="") ? `${Number(n).toLocaleString()}원` : "";

  function show(el, v){
    if(!el) return;
    el.hidden = !v;
  }
  function set(el, txt){
    if(!el) return;
    el.textContent = txt || "-";
  }

  /* ------------- render ------------- */
  function renderCommon(it){
    $("#cdThumb").src = pickThumb(it);
    $("#cdBrand").textContent = it.brand || it.recruit?.brand || "브랜드 미정";
    $("#cdTitle").textContent = it.title || it.recruit?.title || "무제";
  }

  function renderRecruit(it){
    const r = it.recruit || {};
    $("#cdMeta").hidden = false;

    // 메타 출력(있을 때만 보이기)
    const hasDate     = !!r.date;
    const hasTime     = !!(r.timeStart || r.timeEnd || r.time);
    const hasLoc      = !!r.location;
    const hasPay      = !!(r.pay || r.payNegotiable);
    const hasDeadline = !!(r.deadline || r.date);
    const hasCat      = !!(r.category || it.category);

    show($("#cdItemDate"), hasDate);
    show($("#cdItemTime"), hasTime);
    show($("#cdItemLoc"),  hasLoc);
    show($("#cdItemPay"),  hasPay);
    show($("#cdItemDeadline"), hasDeadline);
    show($("#cdItemCat"),  hasCat);

    if (hasDate) set($("#mDate"), fmtDate(r.date));
    if (hasTime) {
      const t = (r.timeStart || "") + (r.timeEnd ? (" ~ " + r.timeEnd) : (r.time ? (" ~ " + r.time) : ""));
      set($("#mTime"), t || "-");
    }
    if (hasLoc) set($("#mLoc"), r.location);
    if (hasPay) set($("#mPay"), r.pay ? money(r.pay) : "협의 가능");
    if (hasDeadline) set($("#mDeadline"), fmtDate(r.deadline || r.date));
    if (hasCat) set($("#mCat"), r.category || it.category || "-");

    // 하단 요약
    $("#cdPayText").textContent = r.pay ? ("출연료 " + money(r.pay)) : (r.payNegotiable ? "출연료 협의 가능" : "");
    $("#cdPrimaryBtn").textContent = "지원자 현황";
    $("#cdPrimaryBtn").onclick = () => {
      location.href = `/alpa/blank/blank.html?p=applications&cid=${encodeURIComponent(it.id || it._id)}`;
    };

    // 상세 설명
    $("#cdDesc").innerHTML = it.descriptionHTML || it.descriptionHtml || r.description || "상세 설명이 없습니다.";
  }

  function renderProduct(it){
    $("#cdMeta").hidden = false;

    // 라이브 일정/가격/카테고리
    const liveDate = it.live?.date;
    const liveTime = it.live?.time;
    const price    = it.sale?.price ?? it.products?.[0]?.price ?? null;
    const cat      = it.category;

    show($("#cdItemDate"), !!liveDate);
    show($("#cdItemTime"), !!liveTime);
    show($("#cdItemLoc"),  false);
    show($("#cdItemPay"),  price!=null);
    show($("#cdItemDeadline"), false);
    show($("#cdItemCat"),  !!cat);

    if (liveDate) set($("#mDate"), fmtDate(liveDate));
    if (liveTime) set($("#mTime"), liveTime);
    if (price!=null) set($("#mPay"), money(price));
    if (cat) set($("#mCat"), cat);

    // 상품 리스트
    const list = Array.isArray(it.products) ? it.products : [];
    if (list.length) {
      $("#cdProducts").hidden = false;
      $("#cdProdList").innerHTML = list.map(p => `
        <div class="cd-prod">
          <img src="${p.thumbnail || `https://picsum.photos/seed/${encodeURIComponent(p.url || p.title || Math.random())}/128/128`}" alt="">
          <div class="t">${p.title || "상품"}</div>
          <div class="p">${p.price!=null ? money(p.price) : ""}</div>
        </div>
      `).join("");
    } else {
      $("#cdProducts").hidden = true;
    }

    // 하단 요약/버튼
    $("#cdPayText").textContent = price!=null ? ("판매가 " + money(price)) : "";
    $("#cdPrimaryBtn").textContent = "지원자 현황";
    $("#cdPrimaryBtn").onclick = () => {
      location.href = `/alpa/blank/blank.html?p=applications&cid=${encodeURIComponent(it.id || it._id)}`;
    };

    // 상세 설명
    $("#cdDesc").innerHTML = it.descriptionHTML || it.descriptionHtml || "상세 설명이 없습니다.";
  }

  /* ------------- init ------------- */
  async function init(){
    if (!ID) {
      $("#cdDesc").innerHTML = `<div class="cd-error">잘못된 접근입니다. (id 누락)</div>`;
      return;
    }

    const url = `${API_BASE}/campaigns/${encodeURIComponent(ID)}`;
    const { ok, json, status } = await getJsonAbs(url);
    if (status === 401) {
      alert("로그인이 필요합니다.");
      location.href = `/alpa/login.html?redirect=${encodeURIComponent(location.pathname + location.search)}`;
      return;
    }
    if (!ok) {
      $("#cdDesc").innerHTML = `<div class="cd-error">${json?.message || "캠페인을 불러오지 못했습니다."}</div>`;
      return;
    }

    const it = json.data || json;
    renderCommon(it);

    if (it.type === "recruit") renderRecruit(it);
    else renderProduct(it);
  }

  init();
})();