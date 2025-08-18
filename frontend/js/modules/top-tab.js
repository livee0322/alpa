<script>
(function(){
  const mount = document.getElementById('top-tab-container');
  if (!mount) return;

  const tabs = [
    { key:'clip',   label:'숏클립',     href:'/alpa/blank/blank.html?p=clip' },
    { key:'live',   label:'쇼핑라이브', href:'/alpa/blank/blank.html?p=live' },
    { key:'news',   label:'뉴스',       href:'/alpa/blank/blank.html?p=news' },
    { key:'event',  label:'이벤트',     href:'/alpa/blank/blank.html?p=event' },
    { key:'svc',    label:'서비스',     href:'/alpa/blank/blank.html?p=service' }
  ];

  const url = new URL(location.href);
  const activeKey = url.searchParams.get('p') || '';  // 정확 매칭
  const SCROLL_KEY = 'lv-top-scrollX';

  mount.innerHTML = `
    <nav class="lv-top-tabs" aria-label="상단 탭">
      <ul role="tablist">
        ${tabs.map(t => {
          const isActive = activeKey === t.key;
          return `
            <li role="presentation">
              <a role="tab"
                 aria-selected="${isActive ? 'true' : 'false'}"
                 class="lv-chip ${isActive ? 'active' : ''}"
                 href="${t.href}">
                ${t.label}
              </a>
            </li>`;
        }).join('')}
      </ul>
    </nav>
  `;

  // 스크롤 위치 복구
  const ul = mount.querySelector('ul');
  try {
    const saved = Number(sessionStorage.getItem(SCROLL_KEY) || 0);
    if (!Number.isNaN(saved)) ul.scrollLeft = saved;
  } catch {}

  // 스크롤 위치 저장
  ul?.addEventListener('scroll', () => {
    try { sessionStorage.setItem(SCROLL_KEY, String(ul.scrollLeft)); } catch {}
  });

  // 활성 탭이 보이도록 자동 스크롤
  const activeEl = mount.querySelector('.lv-chip.active');
  if (activeEl) {
    const { left, right } = activeEl.getBoundingClientRect();
    const { left: ulL, right: ulR } = ul.getBoundingClientRect();
    if (left < ulL || right > ulR) {
      ul.scrollTo({ left: activeEl.offsetLeft - 12, behavior: 'smooth' });
    }
  }
})();
</script>