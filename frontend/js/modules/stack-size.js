// /frontend/js/modules/stack-size.js
(function(){
  const $ = id => document.getElementById(id);
  const banner = $('banner-container');
  const header = $('header-container');
  const topTab = $('top-tab-container');

  function apply() {
    const h =
      (banner?.offsetHeight || 0) +
      (header?.offsetHeight || 0) +
      (topTab?.offsetHeight || 0);
    document.documentElement.style.setProperty('--stack-h', h + 'px');
  }

  // 최초 및 리사이즈 시 반영
  window.addEventListener('load', apply, { once:true });
  window.addEventListener('resize', () => requestAnimationFrame(apply));
  // 탭/헤더가 동적으로 바뀔 때도 반영
  new MutationObserver(apply).observe(document.body, { subtree:true, childList:true, attributes:true });
})();