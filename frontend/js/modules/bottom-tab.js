(function(){
  const mount = document.getElementById('bottom-tab-container');
  if(!mount) return;

  const isLoggedIn = !!localStorage.getItem('liveeToken');
  const myHref = isLoggedIn ? '/blank/blank.html?p=mypage' : '/blank/blank.html?p=login';
  const myText = isLoggedIn ? '마이' : '로그인';

  const items = [
    { key:'home',  label:'홈',       href:'/index.html', active:true },
    { key:'recrt', label:'공고',     href:'/blank/blank.html?p=recruits' },
    { key:'show',  label:'쇼호스트', href:'/blank/blank.html?p=showhost' },
    { key:'influ', label:'인플루언서', href:'/blank/blank.html?p=influencer' },
    { key:'my',    label:myText,    href: myHref },
  ];

  mount.innerHTML = `
    <div class="lv-bottom" role="navigation" aria-label="하단탭">
      ${items.map(i => `<a href="${i.href}" class="${i.active?'active':''}" data-key="${i.key}">${i.label}</a>`).join('')}
    </div>
  `;
})();
