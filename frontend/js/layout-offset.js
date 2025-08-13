// /alpa/frontend/js/layout-offset.js
(function () {
  const R = document.documentElement.style;

  function px(n){ return `${n|0}px`; }

  function measureAndSet() {
    // 요소 가져오기(없으면 0 처리)
    const banner = document.getElementById('banner-container');
    const header = document.getElementById('header-container') || document.querySelector('.lv-header');
    const topTab = document.getElementById('top-tab-container');
    const bottom = document.getElementById('bottom-tab-container');

    const hBanner = banner?.offsetHeight || 0;
    const hHeader = header?.offsetHeight || 0;
    const hTop    = topTab?.offsetHeight || 0;
    const hBottom = bottom?.offsetHeight || 0;

    // CSS 변수 덮어쓰기
    R.setProperty('--banner-h', px(hBanner));
    R.setProperty('--header-h', px(hHeader));
    R.setProperty('--top-h',    px(hTop));
    R.setProperty('--bottom-h', px(hBottom));

    // 상단 3종 + 간격(칩 사이 여백)을 더해 stack 높이 계산
    const GAP = 6; // CSS의 --stack-gap 과 동일
    const stackH = hBanner + (hHeader ? (GAP + hHeader) : 0) + (hTop ? (GAP + hTop) : 0);
    R.setProperty('--stack-h', px(stackH));
  }

  // 최초 실행
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', measureAndSet, { once:true });
  } else {
    measureAndSet();
  }

  // 폰트 로드/이미지/리사이즈 등으로 높이가 변할 수 있어요
  window.addEventListener('load', measureAndSet);
  window.addEventListener('resize', debounce(measureAndSet, 100));

  // 배너가 토글되는 경우를 대비해 MutationObserver로 감지
  const banner = document.getElementById('banner-container');
  if (banner && 'MutationObserver' in window) {
    const mo = new MutationObserver(measureAndSet);
    mo.observe(banner, { attributes:true, childList:true, subtree:true });
  }

  function debounce(fn, wait){
    let t; return (...a)=>{ clearTimeout(t); t=setTimeout(()=>fn.apply(null,a), wait); };
  }
})();