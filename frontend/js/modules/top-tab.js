(() => {
  const el = document.getElementById('top-tab-container');
  if (!el) return;
  const tabs = [
    { key:'clip',  label:'숏클립',     href:'/alpa/blank/blank.html?p=clip' },
    { key:'live',  label:'쇼핑라이브', href:'/alpa/blank/blank.html?p=live' },
    { key:'rank',  label:'랭킹',       href:'/alpa/blank/blank.html?p=ranking' },
    { key:'news',  label:'뉴스',       href:'/alpa/blank/blank.html?p=news' },
    { key:'svc',   label:'서비스',     href:'/alpa/blank/blank.html?p=agency' },
  ];
  el.innerHTML = tabs.map(t=>`<a class="lv-tab" href="${t.href}" data-key="${t.key}">${t.label}</a>`).join('');
})();