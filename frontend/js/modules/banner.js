(function(){
  const mount = document.getElementById('banner-container');
  if(!mount) return;

  mount.innerHTML = `
    <div class="lv-banner" role="region" aria-label="공지">
      <div class="lv-banner-in">현재 클로즈 베타 테스트 중입니다. 피드백을 환영합니다! 🚀</div>
    </div>
  `;

  const applyBannerHeight = () => {
    const el = mount.querySelector('.lv-banner');
    const h = el ? el.offsetHeight : 0;
    document.documentElement.style.setProperty('--banner-h', h + 'px');
  };
  requestAnimationFrame(applyBannerHeight);
  window.addEventListener('resize', () => requestAnimationFrame(applyBannerHeight));
})();