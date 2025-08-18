// /frontend/js/modules/top-tab.js
(function(){
  const mount = document.getElementById('top-tab-container');
  if(!mount) return;

  const tabs = [
    { key:'clip',   label:'숏클립',     href:'/alpa/blank/blank.html?p=clip' },
    { key:'live',   label:'쇼핑라이브', href:'/alpa/blank/blank.html?p=live' },
    { key:'news',   label:'뉴스',       href:'/alpa/blank/blank.html?p=news' },
    { key:'event',  label:'이벤트',     href:'/alpa/blank/blank.html?p=event' },
    { key:'svc',    label:'서비스',     href:'/alpa/blank/blank.html?p=service' }
  ];

  const path = location.pathname + location.search;
  mount.innerHTML = `
    <nav class="lv-top-tabs">
      <ul>
        ${tabs.map(t=>{
          const active = path.includes(t.href) ? 'active' : '';
          return `<li><a class="lv-chip ${active}" href="${t.href}">${t.label}</a></li>`;
        }).join('')}
      </ul>
    </nav>
  `;
})();