(function(){
  const mount = document.getElementById('top-tab-container');
  if(!mount) return;

  // 필요 시 activeKey로 활성 탭 지정 가능 (지금은 홈이므로 전부 비활성)
  const tabs = [
    { key:'clip',  label:'숏클립',     href:'/blank/blank.html?p=clip' },
    { key:'live',  label:'쇼핑라이브', href:'/blank/blank.html?p=live' },
    { key:'rank',  label:'랭킹',       href:'/blank/blank.html?p=ranking' },
    { key:'news',  label:'뉴스',       href:'/blank/blank.html?p=news' },
    { key:'recmd', label:'추천',       href:'/blank/blank.html?p=recommend' },
    { key:'svc',   label:'서비스',     href:'/blank/blank.html?p=agency' },
    { key:'influ', label:'인플루언서', href:'/blank/blank.html?p=influencer' },
  ];

  mount.innerHTML = tabs.map(t => (
    `<a class="lv-tab" href="${t.href}" data-key="${t.key}">${t.label}</a>`
  )).join('');
})();
