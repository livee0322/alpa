(() => {
  const mount = document.getElementById('banner-container');
  if (!mount) return;
  mount.innerHTML = `
    <div class="lv-banner" role="region" aria-label="알림 배너">
      <span>현재 클로즈 베타 테스트 중입니다. 피드백을 환영합니다! 🚀</span>
      <button type="button" aria-label="배너 닫기" id="lv-banner-close">닫기</button>
    </div>
  `;
  document.getElementById('lv-banner-close')?.addEventListener('click', () => {
    mount.style.display = 'none';
  });
})();