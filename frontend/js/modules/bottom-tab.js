(function(){
  const mount = document.getElementById('bottom-tab-container');
  if(!mount) return;

  const loggedIn = !!localStorage.getItem('liveeToken');
  const myHref = loggedIn ? '/alpa/mypage.html' : '/alpa/login.html';
  const myLabel = loggedIn ? '마이' : '로그인';

  const icons = {
    home:`<svg viewBox="0 0 24 24"><path d="M3.5 10.5 12 3l8.5 7.5"/><path d="M6 10v8a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2v-8"/><path d="M10 20v-5h4v5"/></svg>`,
    calendar:`<svg viewBox="0 0 24 24"><path d="M16 3v3M8 3v3"/><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18"/></svg>`,
    bookmark:`<svg viewBox="0 0 24 24"><path d="M6.5 4h11a1 1 0 0 1 1 1v15l-6.5-3.8L5.5 20V5a1 1 0 0 1 1-1Z"/></svg>`,
    user:`<svg viewBox="0 0 24 24"><path d="M12 13.5a5 5 0 1 0-5-5 5 5 0 0 0 5 5Z"/><path d="M4 21a8 8 0 0 1 16 0"/></svg>`
  };

  const items = [
    { key:'home',       label:'홈',    href:'/alpa/index.html',         icon:icons.home },
    { key:'recruits',   label:'공고',  href:'/alpa/recruitslist.html',  icon:icons.calendar },
    { key:'library',    label:'라이브러리', href:'/alpa/blank/blank.html?p=showhost', icon:icons.bookmark },
    { key:'influencer', label:'인플루언서', href:'/alpa/blank/blank.html?p=influencer', icon:icons.bookmark },
    { key:'my',         label:myLabel, href: myHref,                   icon:icons.user }
  ];

  const pageKey = (document.body.dataset.page || '').toLowerCase();
  mount.innerHTML = `
    ${items.map(i => `
      <a href="${i.href}" data-key="${i.key}" class="${(i.key===pageKey)?'active':''}">
        <span class="ico">${i.icon}</span><span>${i.label}</span>
      </a>
    `).join('')}
  `;

  if(!pageKey){
    const path = location.pathname + location.search;
    mount.querySelectorAll('a[data-key]').forEach(a=>{
      if(path.includes(a.getAttribute('href'))) a.classList.add('active');
    });
  }
})();