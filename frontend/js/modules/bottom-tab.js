(function(){
  const mount = document.getElementById('bottom-tab-container');
  if(!mount) return;

  const pageKey = (document.body.dataset.page || '').toLowerCase();
  const loggedIn = !!localStorage.getItem('liveeToken');
  const myHref = loggedIn ? '/alpa/blank/blank.html?p=mypage' : '/alpa/blank/blank.html?p=login';
  const myLabel = loggedIn ? '마이' : '로그인';

  // 라인 아이콘(SVG) (hourplace 느낌)
  const icons = {
    home: `<svg viewBox="0 0 24 24"><path d="M3 10.5 12 3l9 7.5"></path><path d="M5 10v9a2 2 0 0 0 2 2h10a2 2 0 0 0 2-2v-9"></path><path d="M9 21v-6h6v6"></path></svg>`,
    calendar: `<svg viewBox="0 0 24 24"><path d="M16 2v3M8 2v3"></path><rect x="3" y="5" width="18" height="16" rx="2"></rect><path d="M3 10h18"></path></svg>`,
    bookmark: `<svg viewBox="0 0 24 24"><path d="M6 3h12a1 1 0 0 1 1 1v17l-7-4-7 4V4a1 1 0 0 1 1-1z"></path></svg>`,
    user: `<svg viewBox="0 0 24 24"><path d="M16 7a4 4 0 1 1-8 0 4 4 0 0 1 8 0z"></path><path d="M4 21a8 8 0 0 1 16 0"></path></svg>`
  };

  const items = [
    { key:'home',      label:'홈',       href:'/alpa/index.html',                 icon:icons.home },
    { key:'recruits',  label:'공고',     href:'/alpa/blank/blank.html?p=recruits',icon:icons.calendar },
    { key:'showhost',  label:'라이브러리',href:'/alpa/blank/blank.html?p=showhost',icon:icons.bookmark },
    { key:'influencer',label:'인플루언서',href:'/alpa/blank/blank.html?p=influencer', icon:icons.bookmark },
    { key:'my',        label:myLabel,    href: myHref,                            icon:icons.user }
  ];

  mount.innerHTML = `
    <div class="lv-bottom" role="navigation" aria-label="하단탭">
      ${items.map(i => `
        <a href="${i.href}" data-key="${i.key}" class="${(i.key===pageKey)?'active':''}">
          <span class="ico">${i.icon}</span>
          <span>${i.label}</span>
        </a>
      `).join('')}
    </div>
  `;

  // URL 기준으로 자동 활성화 보정(빈페이지 등에서 body data-page가 없을 때)
  if(!pageKey){
    const path = location.pathname + location.search;
    const anchors = mount.querySelectorAll('a[data-key]');
    anchors.forEach(a=>{
      if(path.includes(a.getAttribute('href'))) a.classList.add('active');
    });
  }
})();