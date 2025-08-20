// /alpa/frontend/js/campaign-detail.js
(function () {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const $ = (s) => document.querySelector(s);

  // ------------ helpers ------------
  const qs = (k) => new URLSearchParams(location.search).get(k);
  const CID = qs('id');         // 캠페인 id
  if (!CID) console.warn('[detail] id 파라미터가 없습니다');

  const authHeaders = () => {
    const t = localStorage.getItem('liveeToken');
    return t ? { Authorization: `Bearer ${t}` } : {};
  };
  const api = async (path, opts = {}) => {
    const res = await fetch(`${API_BASE}${path}`, {
      ...opts, headers: { 'Content-Type': 'application/json', ...authHeaders(), ...(opts.headers||{}) }
    });
    let data = {};
    try { data = await res.json(); } catch {}
    return { res, ok: res.ok && data.ok !== false, data };
  };

  const n2 = (v) => (isFinite(v) ? Number(v).toLocaleString() : '');
  const pickThumb = (it) =>
    it?.thumbnailUrl || it?.imageUrl || it?.coverImageUrl ||
    `https://picsum.photos/seed/${encodeURIComponent(it?.id||it?._id||'thumb')}/640/360`;

  const setNotice = (msg, ok=false) => {
    const n = $('#cdNotice'); if (!n) return;
    if (!msg){ n.hidden = true; return; }
    n.textContent = msg; n.hidden = false; n.classList.toggle('ok', !!ok);
  };

  // D-day 계산 (deadline > date > null)
  const ddayOf = (deadline, date) => {
    const toDate = (s) => {
      if (!s) return null;
      const [y,m,d] = String(s).split('-').map(Number);
      if (!y||!m||!d) return null;
      return new Date(y,m-1,d);
    };
    const base = toDate(deadline) || toDate(date);
    if (!base) return { label:'', ended:false };
    const now = new Date(); const t0 = new Date(now.getFullYear(), now.getMonth(), now.getDate());
    const diff = Math.round((base - t0)/86400000);
    if (diff < 0) return { label:'마감', ended:true };
    if (diff === 0) return { label:'D‑DAY', ended:false };
    return { label:`D‑${diff}`, ended:false };
  };

  // ------------ state ------------
  const state = {
    me: null,            // /users/me 결과
    detail: null,        // /campaigns/:id
    myApp: null,         // /applications/mine?campaignId=...
    isOwner: false,
  };

  async function loadMe() {
    const { ok, data } = await api('/users/me');
    if (ok) state.me = data?.data || data;
  }

  async function loadDetail() {
    const { ok, res, data } = await api(`/campaigns/${encodeURIComponent(CID)}`);
    if (!ok) {
      if (res.status === 401) {
        setNotice('로그인이 필요합니다. 로그인 후 다시 시도해주세요.');
      } else if (res.status === 403) {
        $('#cdGuard').hidden = false;
        $('#cdGuard').textContent = '비공개이거나 접근 권한이 없습니다.';
      } else if (res.status === 404) {
        $('#cdGuard').hidden = false;
        $('#cdGuard').textContent = '삭제되었거나 존재하지 않는 캠페인입니다.';
      } else {
        setNotice(`상세 정보를 불러오지 못했습니다. (${res.status})`);
      }
      return;
    }
    state.detail = data?.data || data;

    // 오너 여부
    if (state.me && state.detail?.createdBy) {
      state.isOwner = String(state.detail.createdBy) === String(state.me.id || state.me._id);
    }

    renderDetail();
    await loadMyApplication();  // 버튼 상태 반영
    renderActionbar();
  }

  async function loadMyApplication() {
    // 로그인 안했으면 패스
    if (!localStorage.getItem('liveeToken')) return;
    const { ok, data } = await api(`/applications/mine?campaignId=${encodeURIComponent(CID)}`);
    if (ok) state.myApp = data?.data || data || null;
  }

  // ------------ render ------------
  function renderDetail() {
    const it = state.detail || {};
    // hero
    const thumb = pickThumb(it);
    $('#cdThumb').src = thumb;
    $('#cdThumb').onerror = function(){ this.onerror = null; this.src = `https://picsum.photos/seed/${encodeURIComponent('c'+(it.id||it._id||''))}/640/360`; };

    // badge
    if (it.type === 'recruit') {
      const r = it.recruit || {};
      const { label, ended } = ddayOf(r.deadline, r.date);
      if (label) {
        const b = $('#cdBadge');
        b.textContent = label; b.hidden = false;
        b.classList.toggle('end', !!ended);
      }
    }

    // head
    $('#cdBrand').textContent = it.brand || it.recruit?.brand || '브랜드 미정';
    $('#cdTitle').textContent = it.title || it.recruit?.title || '무제';

    // meta chips
    const meta = [];
    if (it.type === 'recruit') {
      const r = it.recruit || {};
      if (r.category) meta.push(`<span class="cd-chip">${r.category}</span>`);
      if (r.date) meta.push(`<span class="cd-chip">${new Date(r.date).toLocaleDateString('ko-KR')}</span>`);
      if (r.timeStart) meta.push(`<span class="cd-chip">${r.timeStart}${r.timeEnd ? ' ~ ' + r.timeEnd : ''}</span>`);
      if (r.location) meta.push(`<span class="cd-chip">${r.location}</span>`);
    } else {
      if (it.category) meta.push(`<span class="cd-chip">${it.category}</span>`);
      if (it.live?.date) meta.push(`<span class="cd-chip">${new Date(it.live.date).toLocaleDateString('ko-KR')}${it.live.time ? ' · ' + it.live.time : ''}</span>`);
    }
    $('#cdMeta').innerHTML = meta.join('');

    // desc
    const descEl = $('#cdDesc');
    if (it.type === 'recruit') {
      const text = it.recruit?.description || '';
      descEl.textContent = text; // 서버에서 plain-text로 저장한 기준
    } else {
      const html = it.descriptionHTML || it.descriptionHtml || '';
      // 서버에서 sanitize 됨 (campaigns.js 참고)
      descEl.innerHTML = html || '<p>상세 설명이 없습니다.</p>';
    }

    // products
    if (it.type === 'product') {
      const box = $('#cdProducts');
      const grid = $('#cdProdGrid');
      const list = Array.isArray(it.products) ? it.products : [];
      if (list.length) {
        grid.innerHTML = list.map(p => `
          <article class="cd-prod">
            <img src="${p.thumbnail || ''}" alt="" onerror="this.onerror=null;this.src='https://picsum.photos/seed/${encodeURIComponent(p.url||p.title||'p')}/320/320'"/>
            <div class="cd-prod-b">
              <div class="cd-prod-t">${p.title || '(상품명 없음)'}</div>
              <div class="cd-prod-m">
                ${p.price ? `${n2(p.price)}원` : ''} ${p.salePrice ? ` → <b>${n2(p.salePrice)}원</b>` : ''}
              </div>
            </div>
          </article>
        `).join('');
        box.hidden = false;
      } else box.hidden = true;
    }
  }

  function renderActionbar() {
    const d = state.detail; if (!d) return;

    // 좌측 정보 (출연료/마감 or 가격/라이브)
    const left1 = $('#cdPrimaryInfo');
    const left2 = $('#cdSubInfo');
    if (d.type === 'recruit') {
      const r = d.recruit || {};
      const pay = (typeof r.payWan === 'number') ? `${n2(r.payWan)}만원` : (r.pay || '협의');
      left1.textContent = `출연료 ${pay}`;
      left2.textContent = r.deadline ? `마감 ${new Date(r.deadline).toLocaleDateString('ko-KR')}` : (r.date ? `촬영 ${new Date(r.date).toLocaleDateString('ko-KR')}` : '');
    } else {
      const price = d?.sale?.price ?? d?.products?.[0]?.price ?? null;
      left1.textContent = price != null ? `가격 ${n2(price)}원` : '';
      left2.textContent = d.live?.date ? `라이브 ${new Date(d.live.date).toLocaleDateString('ko-KR')}${d.live.time ? ' · '+d.live.time : ''}` : '';
    }

    // 버튼 상태
    const btnLogin = $('#cdBtnLogin');
    const btnApply = $('#cdBtnApply');
    const btnApplied = $('#cdBtnApplied');
    const btnApplicants = $('#cdBtnApplicants');
    const btnClosed = $('#cdBtnClosed');

    // 모두 숨기고 필요한 것만 열기
    [btnLogin, btnApply, btnApplied, btnApplicants, btnClosed].forEach(b => b.hidden = true);

    // 오너는 현황
    if (state.isOwner) {
      btnApplicants.hidden = false;
      btnApplicants.href = `/alpa/blank/blank.html?p=applicants&campaignId=${encodeURIComponent(d.id || d._id || '')}`;
      return;
    }

    // 모집이 아니면 버튼(지원/마감) 노출 X (필요 시 장바구니/알림 등 확장)
    if (d.type !== 'recruit') return;

    // 마감 여부
    const r = d.recruit || {};
    const { ended } = ddayOf(r.deadline, r.date);
    if (ended) { btnClosed.hidden = false; return; }

    // 로그인 여부
    const isAuthed = !!localStorage.getItem('liveeToken');
    if (!isAuthed) { btnLogin.hidden = false; return; }

    // 내 지원 여부
    if (state.myApp) { btnApplied.hidden = false; return; }

    // 기본: 지원 가능
    btnApply.hidden = false;
  }

  // ------------ events ------------
  // 로그인 유도
  $('#cdBtnLogin')?.addEventListener('click', () => {
    location.href = '/alpa/login.html?next=' + encodeURIComponent(location.pathname + location.search);
  });

  // 지원하기 모달 토글
  const modal = $('#cdApplyModal');
  const openApply = () => { if (modal) modal.hidden = false; $('#cdApplyNotice').hidden = true; };
  const closeApply = () => { if (modal) modal.hidden = true; };
  $('#cdBtnApply')?.addEventListener('click', openApply);
  modal?.addEventListener('click', (e) => {
    if (e.target && e.target.getAttribute('data-close')) closeApply();
  });

  // 지원 제출
  $('#cdApplySubmit')?.addEventListener('click', async () => {
    const portfolio = $('#cdApplyPortfolio').value.trim();
    const message = $('#cdApplyMsg').value.trim();
    const agree = $('#cdApplyAgree').checked;
    const note = $('#cdApplyNotice');

    if (!agree) {
      note.textContent = '개인정보 동의가 필요합니다.'; note.hidden = false; return;
    }
    const body = { campaignId: CID, profileRef: portfolio || undefined, message: message || undefined };
    const { ok, res, data } = await api('/applications', { method:'POST', body: JSON.stringify(body) });
    if (ok) {
      closeApply();
      setNotice('지원이 접수되었습니다.', true);
      state.myApp = data?.data || data || { status:'submitted' };
      renderActionbar();
    } else {
      note.textContent = data?.message || `제출에 실패했습니다. (${res.status})`; note.hidden = false;
    }
  });

  // ------------ run ------------
  (async function init(){
    if (!API_BASE) console.warn('[detail] LIVEE_CONFIG.API_BASE 미설정');
    await loadMe().catch(()=>{});
    await loadDetail();
  })();
})();