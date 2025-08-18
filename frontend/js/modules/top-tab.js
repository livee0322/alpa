(function () {
  const mount = document.getElementById('top-tab-container');
  if (!mount) return;

  const tabs = [
    { key: 'clip',  label: '숏클립',     href: '/alpa/blank/blank.html?p=clip' },
    { key: 'live',  label: '쇼핑라이브', href: '/alpa/blank/blank.html?p=live' },
    { key: 'news',  label: '뉴스',       href: '/alpa/blank/blank.html?p=news' },
    { key: 'event', label: '이벤트',     href: '/alpa/blank/blank.html?p=event' },
    { key: 'svc',   label: '서비스',     href: '/alpa/blank/blank.html?p=service' },
  ];

  // 현재 탭 판단 (URL 어디에 있든 query p=값 기준)
  const params = new URLSearchParams(location.search);
  const currentKey = params.get('p'); // 없으면 null

  mount.innerHTML = `
    <ul>
      ${tabs.map(t => {
        const active = currentKey ? (t.key === currentKey ? 'active' : '') 
                                  : (location.pathname + location.search).includes(t.href) ? 'active' : '';
        return `<li><a class="${active}" href="${t.href}">${t.label}</a></li>`;
      }).join('')}
    </ul>
  `;
})();