(function(){
  const mount = document.getElementById('bottom-tab-container');
  if(!mount) return;

  const pageKey = (document.body.dataset.page || '').toLowerCase();
  const loggedIn = !!localStorage.getItem('liveeToken');
  const myHref = loggedIn ? '/alpa/blank/blank.html?p=mypage' : '/alpa/blank/blank.html?p=login';
  const myLabel = loggedIn ? '마이' : '로그인';

  // 라운드 라인(2px) – hourplace 톤
  const icons = {
    home: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M3.5 10.5 12 3l8.5 7.5" />
        <path d="M6 10v8a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2v-8" />
        <path d="M10 20v-5h4v5" />
      </svg>`,
    calendar: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M16 3v3M8 3v3" />
        <rect x="3" y="5" width="18" height="16" rx="2" />
        <path d="M3 10h18" />
      </svg>`,
    bookmark: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M6.5 4h11a1 1 0 0 1 1 1v15l-6.5-3.8L5.5 20V5a1 1 0 0 1 1-1Z" />
      </svg>`,
    user: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <path d="M12 13.5a5 5 0 1 0-5-5 5 5 0 0 0 5 5Z" />
        <path d="M4 21a8 8 0 0 1 16 0" />
      </svg>`,
    search: `
      <svg viewBox="0 0 24 24" aria-hidden="true">
        <circle cx="11" cy="11" r="7" />
        <path d="M21 21l-3.5-3.5" />
      </svg>`
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

const loggedIn = !!localStorage.getItem('liveeToken');
const myHref = loggedIn ? '/alpa/blank/blank.html?p=mypage' : '/alpa/login.html';