(function(){
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const $  = (s) => document.querySelector(s);
  const $$ = (s) => Array.from(document.querySelectorAll(s));

  /* ---------------- Utils ---------------- */
  const qs = (k) => new URLSearchParams(location.search).get(k);
  const CID = qs('id') || '';   // ?id=...
  const token = localStorage.getItem('liveeToken') || '';
  const authHeaders = () => token ? { Authorization: `Bearer ${token}` } : {};

  const weekday = ['일','월','화','수','목','금','토'];
  const z2 = (n) => String(n).padStart(2,'0');

  function pickThumb(it, ratio='card'){
    const src = it?.thumbnailUrl || it?.imageUrl || it?.coverImageUrl || it?.thumbnail || '';
    if (src) return src;
    const seed = it?._id || it?.id || Math.random().toString(36).slice(2);
    if (ratio === 'square') return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/640`;
    if (ratio === 'avatar') return `https://picsum.photos/seed/${encodeURIComponent(seed)}/96/96`;
    return `https://picsum.photos/seed/${encodeURIComponent(seed)}/640/360`;
  }

  function fmtDateYMDK(s){
    if (!s) return '';
    const d = new Date(s);
    if (isNaN(d)) return s;
    return `${d.getFullYear()}.${z2(d.getMonth()+1)}.${z2(d.getDate())}(${weekday[d.getDay()]})`;
  }
  function fmtTimeRange(s, e){
    if (!s && !e) return '';
    if (s && e) return `${s}~${e}`;
    return s || e || '';
  }
  function fmtPayWan(pay, negotiable){
    if (typeof pay === 'number' && !isNaN(pay)) return `${pay.toLocaleString()}만원`;
    if (typeof pay === 'string' && /^\d+$/.test(pay)) return `${Number(pay).toLocaleString()}만원`;
    return negotiable ? '협의' : '';
  }
  function calcDday(deadline){
    if(!deadline) return null;
    const [y,m,d] = String(deadline).split('-').map(Number);
    if(!y||!m||!d) return null;
    const today = new Date();
    const t0 = new Date(today.getFullYear(), today.getMonth(), today.getDate());
    const dd = new Date(y, m-1, d);
    const diff = Math.round((dd - t0)/86400000);
    if (diff < 0)  return '마감';
    if (diff === 0) return 'D-DAY';
    return `D-${diff}`;
  }

  async function getJson(path, opts = {}){
    const url = `${API_BASE}${path}`;
    const res = await fetch(url, { ...opts, headers: { 'Content-Type':'application/json', ...(opts.headers||{}), ...authHeaders() }});
    const json = await res.json().catch(()=>({}));
    const ok = res.ok && json.ok !== false;
    const item = json.data || json.item || json;
    return { ok, json, item, res };
  }

  function showNotice(msg, ok=false){
    const n = $('#rdNotice');
    if(!n) return;
    n.textContent = msg;
    n.hidden = false;
    n.style.background = ok ? '#f5fff5' : '#fff4f4';
    n.style.color      = ok ? '#0f6b2b' : '#a32020';
    n.style.border     = `1px solid ${ok ? '#b9efc9' : '#ffd6d6'}`;
  }

  /* ---------------- Render ---------------- */
  function renderHero(it){
    $('#rdHero').hidden = false;

    const r = it.recruit || {};
    $('#rdThumb').src   = pickThumb(it);
    $('#rdBrand').textContent = it.brand || r.brand || '브랜드 미정';
    $('#rdTitle').textContent = it.title || r.title || '무제';

    const dday = calcDday(r.deadline);
    if (dday){
      const el = $('#rdDday');
      el.hidden = false;
      el.textContent = dday;
    }

    // brief 4개
    const brief = $('#rdBrief');
    brief.innerHTML = '';
    const rows = [
      { ico: timeIco(), txt: [fmtDateYMDK(r.date), fmtTimeRange(r.timeStart, r.timeEnd)].filter(Boolean).join(' ') },
      { ico: locIco(),  txt: r.location || '장소 미정' },
      { ico: payIco(),  txt: fmtPayWan(r.pay, r.payNegotiable) || '협의' },
      { ico: tagIco(),  txt: r.category || '카테고리' },
    ];
    rows.forEach(({ico,txt})=>{
      const li = document.createElement('li');
      li.innerHTML = `<span class="ico">${ico}</span><span class="txt">${escapeHtml(txt)}</span>`;
      brief.appendChild(li);
    });

    // CTA
    $('#rdCTA').hidden = false;
    $('#rdPayLabel').textContent = `출연료 ${fmtPayWan(r.pay, r.payNegotiable) || '협의'}`;
  }

  function renderOutline(it){
    $('#desc').hidden = false;
    const r = it.recruit || {};
    const box = $('#rdOutline');
    const cells = [
      ['촬영일', fmtDateYMDK(r.date)],
      ['촬영시간', fmtTimeRange(r.timeStart, r.timeEnd)],
      ['촬영장소', r.location || '-'],
      ['카테고리', r.category || '-'],
      ['마감일', r.deadline ? fmtDateYMDK(r.deadline) : '-'],
      ['출연료', fmtPayWan(r.pay, r.payNegotiable) || '-'],
    ];
    box.innerHTML = cells.map(([k,v])=>(
      `<div class="row"><div class="key">${k}</div><div class="val">${escapeHtml(v)}</div></div>`
    )).join('');

    // 상세 설명
    const descBox = $('#rdDesc');
    const html = it.descriptionHTML || it.descriptionHtml || r.description || '';
    if (html) {
      descBox.innerHTML = `<div class="html">${html}</div>`;
    } else {
      descBox.innerHTML = `<div class="rd-empty">상세요강이 준비중입니다.</div>`;
    }
  }

  function renderApplicantsList(list, total){
    $('#applicants').hidden = false;
    const box = $('#rdApplicants');
    if (!Array.isArray(list) || !list.length){
      box.innerHTML = `<div class="rd-empty">아직 지원자가 없습니다.</div>`;
      return;
    }
    const html = `
      <div class="rd-app-list">
        ${list.map(a=>`
          <div class="rd-app">
            <img class="avt" src="${a.user?.avatar || `https://picsum.photos/seed/${encodeURIComponent(a.user?._id||'u')}/80/80`}" alt="">
            <div>
              <div class="name">${escapeHtml(a.user?.name || '지원자')}</div>
              <div class="note">${escapeHtml(a.message || '')}</div>
            </div>
            <div style="margin-left:auto; color:#9aa3af; font-size:.86rem;">${new Date(a.createdAt||Date.now()).toLocaleDateString('ko-KR')}</div>
          </div>
        `).join('')}
      </div>
      <div style="margin-top:8px; color:#6b7280; font-weight:800;">총 ${total||list.length}명 지원</div>
    `;
    box.innerHTML = html;
  }

  function renderBrandInfo(it){
    $('#brand').hidden = false;
    const b = it.brand || it.recruit?.brand || '';
    const box = $('#rdBrandInfo');
    if (!b){
      box.innerHTML = `<div class="rd-empty">브랜드 정보가 준비중입니다.</div>`;
    } else {
      box.innerHTML = `
        <div style="padding:12px; border:1px solid #f1f3f5; border-radius:12px; background:#fff">
          <div style="font-weight:900; font-size:1.05rem">${escapeHtml(b)}</div>
          <div style="margin-top:6px; color:#6b7280">브랜드 소개가 곧 제공됩니다.</div>
        </div>
      `;
    }
  }

  function renderRelated(items){
    $('#related').hidden = false;
    const box = $('#rdRelated');
    if (!items.length){
      box.innerHTML = `<div class="rd-empty">추천 공고가 없습니다.</div>`;
      return;
    }
    box.innerHTML = items.map((it)=> {
      const r = it.recruit || {};
      const dday = calcDday(r.deadline);
      const href = `/alpa/recruit-detail.html?id=${encodeURIComponent(it.id || it._id || '')}`;
      const pay  = fmtPayWan(r.pay, r.payNegotiable) || '협의';
      return `
        <a class="lv-job" href="${href}">
          <div class="lv-job-body">
            <div class="lv-job-brand">${escapeHtml(it.brand || r.brand || '브랜드 미정')}</div>
            <div class="lv-job-title">${escapeHtml(it.title || r.title || '무제')}</div>
            <div class="lv-job-meta">
              ${dday ? `<span class="lv-job-dday ${dday==='마감'?'lv-end':''}">${dday}</span>` : ''}
              <span class="lv-job-sep">|</span>
              <span>출연료 ${escapeHtml(pay)}</span>
            </div>
          </div>
          <img class="lv-job-thumb" src="${pickThumb(it,'square')}" alt="">
        </a>
      `;
    }).join('');
  }

  function bindTabs(){
    const tabs = $('#rdTabs');
    if (!tabs) return;
    tabs.hidden = false;
    const links = $$('#rdTabs a');
    const map = links.map(a => ({ a, id:a.getAttribute('href').slice(1) }));
    const io = new IntersectionObserver((entries)=>{
      entries.forEach(e=>{
        if(e.isIntersecting){
          const id = e.target.id;
          links.forEach(l=>l.classList.toggle('active', l.getAttribute('href')==='#'+id));
        }
      });
    },{ rootMargin:'-40% 0px -55% 0px', threshold:0 });

    ['desc','applicants','brand','related'].forEach(id=>{
      const el = document.getElementById(id);
      if (el) io.observe(el);
    });
  }

  function bindCTA(cid){
    $('#rdApplicantsBtn')?.addEventListener('click', ()=> {
      document.getElementById('applicants')?.scrollIntoView({behavior:'smooth'});
    });
    $('#rdApplyBtn')?.addEventListener('click', async ()=>{
      if (!localStorage.getItem('liveeToken')){
        const go = confirm('로그인이 필요합니다. 로그인 페이지로 이동할까요?');
        if (go) location.href = '/alpa/login.html';
        return;
      }
      const message = prompt('한 줄 자기소개/메시지를 입력하세요 (선택):','');
      const contact = prompt('연락처(이메일/휴대폰) 입력 (필수):','');
      if (!contact) return alert('연락처는 필수입니다.');

      try{
        const res = await fetch(`${API_BASE}/campaigns/${encodeURIComponent(cid)}/applications`, {
          method:'POST',
          headers: { 'Content-Type':'application/json', ...authHeaders() },
          body: JSON.stringify({ message, contact })
        });
        const json = await res.json().catch(()=>({}));
        if (!res.ok || json.ok===false) throw new Error(json.message || `HTTP_${res.status}`);
        showNotice('지원이 접수되었습니다.', true);
        $('#rdApplyBtn').disabled = true;
        $('#rdApplyBtn').textContent = '지원 완료';
      }catch(e){
        showNotice(e.message || '지원 실패');
      }
    });

    // 공유
    $('#rdShare')?.addEventListener('click', async ()=>{
      const url = location.href;
      try{
        if (navigator.share) await navigator.share({ title: document.title, url });
        else {
          await navigator.clipboard.writeText(url);
          showNotice('링크가 복사되었습니다.', true);
        }
      }catch{}
    });
  }

  /* ---------------- Icons ---------------- */
  function timeIco(){ return `<svg viewBox="0 0 24 24"><circle cx="12" cy="12" r="9" fill="none" stroke="currentColor" stroke-width="2"/><path d="M12 7v5l3 3" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round"/></svg>`; }
  function locIco(){  return `<svg viewBox="0 0 24 24"><path d="M12 21s-7-6.1-7-11a7 7 0 1 1 14 0c0 4.9-7 11-7 11z" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="12" cy="10" r="2" fill="currentColor"/></svg>`; }
  function payIco(){  return `<svg viewBox="0 0 24 24"><rect x="3" y="6" width="18" height="12" rx="2" ry="2" fill="none" stroke="currentColor" stroke-width="2"/><path d="M3 10h18" stroke="currentColor" stroke-width="2"/><circle cx="8" cy="14" r="1.2" fill="currentColor"/><circle cx="12" cy="14" r="1.2" fill="currentColor"/><circle cx="16" cy="14" r="1.2" fill="currentColor"/></svg>`; }
  function tagIco(){  return `<svg viewBox="0 0 24 24"><path d="M20.59 13.41l-7.17 7.17a2 2 0 0 1-2.83 0L3 13V3h10l7.59 7.59a2 2 0 0 1 0 2.82z" fill="none" stroke="currentColor" stroke-width="2"/><circle cx="7.5" cy="7.5" r="1.5" fill="currentColor"/></svg>`; }

  const escapeHtml = (s='') => String(s)
    .replaceAll('&','&amp;').replaceAll('<','&lt;').replaceAll('>','&gt;');

  /* ---------------- Boot ---------------- */
  async function boot(){
    if (!CID){
      showNotice('잘못된 접근입니다.');
      return;
    }

    try{
      // 상세
      const { ok, item, res, json } = await getJson(`/campaigns/${encodeURIComponent(CID)}`);
      if (!ok){
        if (res && res.status === 401){
          showNotice('로그인이 필요하거나 비공개 공고입니다.');
        } else {
          showNotice(json?.message || '불러오기 실패');
        }
        return;
      }
      const it = item.data || item;
      document.title = `${(it.brand || it.recruit?.brand || '')} — ${(it.title || it.recruit?.title || '공고 상세')} | Livee`;

      renderHero(it);
      renderOutline(it);
      renderBrandInfo(it);
      bindTabs();
      bindCTA(it.id || it._id);

      // 지원자 요약 (로그인/권한 없으면 graceful fail)
      try{
        const r1 = await getJson(`/campaigns/${encodeURIComponent(CID)}/applications?limit=5`);
        const list = r1.item?.items || r1.item?.data || r1.item?.applications || r1.item || [];
        const total = r1.item?.total || r1.item?.count || list.length;
        renderApplicantsList(Array.isArray(list)?list:[], total);
      }catch{ /* 무시 */ }

      // 추천 공고
      const cat = it.recruit?.category ? `&category=${encodeURIComponent(it.recruit.category)}` : '';
      const ex  = `&exclude=${encodeURIComponent(it.id || it._id || '')}`;
      const r2 = await getJson(`/campaigns?type=recruit&limit=8${cat}${ex}`);
      const rel = Array.isArray(r2.item?.items) ? r2.item.items : (r2.item?.items || r2.item?.docs || r2.json?.items || []);
      renderRelated(Array.isArray(rel)?rel:[]);
    }catch(e){
      showNotice(e.message || '로딩 실패');
    }
  }

  boot();
})();
