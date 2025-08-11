(async function(){
  const { API_BASE } = window.LIVEE_CONFIG;

  const $ = (sel)=>document.querySelector(sel);
  const imgFallback = (el)=>{ el.onerror=null; el.src='https://picsum.photos/seed/livee/640/360'; };

  // 일정: today ~ +3
  async function loadSchedule(){
    const box = $('#schedule');
    try{
      const res = await fetch(`${API_BASE}/recruits/schedule`);
      const json = await res.json();
      if(!res.ok || json.ok===false || !json.items?.length){
        box.innerHTML = `<div class="lv-empty">예정된 일정이 없습니다.</div>`;
        return;
      }
      box.innerHTML = json.items.map(it=>`
        <div class="lv-s-item">
          <img class="lv-s-thumb" src="${it.thumbnailUrl||''}" onerror="this.onerror=null;this.src='https://picsum.photos/seed/s${it._id}/96/96';">
          <div class="lv-s-body">
            <div class="lv-s-title">${it.title||'무제'}</div>
            <div class="lv-s-meta">${new Date(it.date).toLocaleString('ko-KR')}</div>
          </div>
        </div>
      `).join('');
    }catch(e){
      box.innerHTML = `<div class="lv-empty">일정 로딩 실패</div>`;
      console.debug('[schedule] error', e);
    }
  }

  // 추천 공고 4
  async function loadRecruits(){
    const box = $('#recruits');
    try{
      const res = await fetch(`${API_BASE}/recruits?limit=4`);
      const json = await res.json();
      if(!res.ok || json.ok===false || !json.items?.length){
        box.innerHTML = `<div class="lv-empty">등록된 공고가 없습니다</div>`;
        return;
      }
      box.innerHTML = json.items.map(it=>`
        <a class="lv-card" href="/alpa/blank/blank.html?p=recruits">
          <img class="lv-thumb" src="${it.thumbnailUrl||''}" onerror="this.onerror=null;this.src='https://picsum.photos/seed/r${it._id}/640/360';">
          <div class="lv-title">${it.title||'무제'}</div>
          <div class="lv-meta">${(it.brand||'브랜드 미정')}</div>
        </a>
      `).join('');
    }catch(e){
      box.innerHTML = `<div class="lv-empty">공고 로딩 실패</div>`;
      console.debug('[recruits] error', e);
    }
  }

  // 쇼호스트 4
  async function loadPortfolios(){
    const box = $('#portfolios');
    try{
      const res = await fetch(`${API_BASE}/portfolios?limit=4`);
      const json = await res.json();
      if(!res.ok || json.ok===false || !json.items?.length){
        box.innerHTML = `<div class="lv-empty">등록된 포트폴리오가 없습니다</div>`;
        return;
      }
      box.innerHTML = json.items.map(it=>`
        <a class="lv-card" href="/alpa/portfolio.html">
          <img class="lv-thumb" src="${it.profileImage||''}" onerror="this.onerror=null;this.src='https://picsum.photos/seed/p${it._id}/320/320';">
          <div class="lv-title">${it.name||'이름 미정'}</div>
          <div class="lv-meta">${it.jobTag||''} ${(it.region? '· '+it.region:'')}</div>
        </a>
      `).join('');
    }catch(e){
      box.innerHTML = `<div class="lv-empty">포트폴리오 로딩 실패</div>`;
      console.debug('[portfolios] error', e);
    }
  }

  loadSchedule();
  loadRecruits();
  loadPortfolios();
})();