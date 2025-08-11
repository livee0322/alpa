(function(){
  const mount = document.getElementById('top-tab-container');
  if(!mount) return;

  const tabs = [
    { key:'clip',   label:'숏클립',     href:'/alpa/blank/blank.html?p=clip' },
    { key:'live',   label:'쇼핑라이브', href:'/alpa/blank/blank.html?p=live' },
    { key:'rank',   label:'랭킹',       href:'/alpa/blank/blank.html?p=ranking' },
    { key:'news',   label:'뉴스',       href:'/alpa/blank/blank.html?p=news' },
    { key:'reco',   label:'추천',       href:'/alpa/blank/blank.html?p=reco' },
    { key:'svc',    label:'서비스',     href:'/alpa/blank/blank.html?p=service' }
  ];

  const path = location.pathname + location.search;
  mount.innerHTML = `
    <ul>
      ${tabs.map(t=>{
        const active = path.includes(t.href) ? 'active' : '';
        return `<li><a class="lv-chip ${active}" href="${t.href}">${t.label}</a></li>`;
      }).join('')}
    </ul>
  `;
})();