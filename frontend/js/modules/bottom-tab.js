(() => {
  const BASE = '/alpa';
  const el = document.getElementById('bottom-tab-container');
  if (!el) return;

  const isLoggedIn = () => !!localStorage.getItem('liveeToken');
  const pageKey = (document.body.dataset.page || '').toLowerCase();

  const icons = {
    home: `<svg viewBox="0 0 24 24"><path d="M3.5 10.5 12 3l8.5 7.5"/><path d="M6 10v8a2 2 0 0 0 2 2h8a2 2 0 0 0 2-2v-8"/><path d="M10 20v-5h4v5"/></svg>`,
    calendar: `<svg viewBox="0 0 24 24"><path d="M16 3v3M8 3v3"/><rect x="3" y="5" width="18" height="16" rx="2"/><path d="M3 10h18"/></svg>`,
    bookmark: `<svg viewBox="0 0 24 24"><path d="M6.5 4h11a1 1 0 0 1 1 1v15l-6.5-3.8L5.5 20V5a1 1 0 0 1 1-1Z"/></svg>`,
    user: `<svg viewBox="0 0 24 24"><path d="M12 13.5a5 5 0 1 0-5-5 5 5 0 0 0 5 5Z"/><path d="M4 21a8 8 0 0 1 16 0"/></svg>`
  };

  const routes = {
    home:        `${BASE}/index.html`,
    recruits:    `${BASE}/recruits.html`,
    showhost:    `${BASE}/portfolio.html`,
    influencer:  `${BASE}/influencer.html`,
    login:       `${BASE}/login.html`,
    mypage:      `${BASE}/mypage.html`
  };

  const items = [
    { key:'home', label:'홈', icon:icons.home, href:routes.home },
    { key:'recruits', label:'공고', icon:icons.calendar, href:routes.recruits },
    { key:'showhost', label:'라이브러리', icon:icons.bookmark, href:routes.showhost },
    { key:'influencer', label:'인플루언서', icon:icons.bookmark, href:routes.influencer },
    { key:'my', label: isLoggedIn() ? '마이' : '로그인', icon:icons.user, href: isLoggedIn()? routes.mypage : routes.login }
  ];

  el.innerHTML = `
    <div class="lv-bottom" role="navigation" aria-label="하단탭">
      ${items.map(i=>{
        const active = i.key === pageKey;
        return `<a href="${i.href}" data-key="${i.key}" class="${active?'active':''}" ${active?'aria-current="page"':''}>
          <span class="ico">${i.icon}</span><span>${i.label}</span></a>`;
      }).join('')}
    </div>
  `;

  // 다른 탭에서 로그인 상태가 바뀌면 자동 반영
  window.addEventListener('storage', (e) => {
    if (e.key === 'liveeToken') location.reload();
  });
})();