// 공통 fetch 래퍼
async function api(path, opts={}) {
  const { API_BASE } = window.LIVEE_CONFIG;
  const headers = { 'Content-Type': 'application/json', ...(opts.headers||{}) };
  const t = localStorage.getItem('liveeToken');
  if (t) headers.Authorization = `Bearer ${t}`;
  const res = await fetch(`${API_BASE}${path}`, { ...opts, headers });
  const data = await res.json().catch(()=>({ ok:false, message:'INVALID_JSON' }));
  if (res.status === 401) { ['liveeToken','liveeName','liveeTokenExp'].forEach(k=>localStorage.removeItem(k)); location.href='/alpa/login.html'; }
  if (!res.ok || data.ok===false) throw new Error(data.message||`HTTP_${res.status}`);
  return data;
}

document.addEventListener('DOMContentLoaded', () => {
  // 홈 섹션 로딩 (필요 시 주석 해제)
  loadRecruits();
  loadPortfolios();
  // loadSchedule(); // 서버 준비되면 사용
});

async function loadRecruits(){
  const mount = document.getElementById('recruits');
  if(!mount) return;
  try{
    const r = await api('/recruits?limit=4');
    if(!r.items || r.items.length===0){ mount.innerHTML = `<div class="lv-empty">등록된 공고가 없습니다</div>`; return; }
    mount.innerHTML = r.items.map(it => card(it.title, it.imageUrl, `${it.date||''} ${it.location||''}`)).join('');
  }catch(e){
    mount.innerHTML = `<div class="lv-empty">공고를 불러오지 못했습니다</div>`;
  }
}

async function loadPortfolios(){
  const mount = document.getElementById('portfolios');
  if(!mount) return;
  try{
    const r = await api('/portfolios?limit=4');
    if(!r.items || r.items.length===0){ mount.innerHTML = `<div class="lv-empty">등록된 포트폴리오가 없습니다</div>`; return; }
    mount.innerHTML = r.items.map(it => card(it.title||it.name, it.imageUrl, (it.skills||[]).join(' · '))).join('');
  }catch(e){
    mount.innerHTML = `<div class="lv-empty">포트폴리오를 불러오지 못했습니다</div>`;
  }
}

function card(title, img, meta){
  const src = img || 'https://dummyimage.com/600x400/eeeeee/aaaaaa.png&text=Livee';
  return `
    <article class="lv-card" onclick="location.href='/alpa/blank/blank.html?p=detail'">
      <img class="lv-thumb" src="${src}" alt="">
      <div class="lv-title">${escapeHtml(title||'무제')}</div>
      <div class="lv-meta">${escapeHtml(meta||'')}</div>
    </article>
  `;
}
function escapeHtml(s=''){return s.replace(/[&<>"']/g,m=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));}