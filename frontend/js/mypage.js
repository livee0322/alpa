// /* /alpa/frontend/js/mypage.js */

/* 헤더는 숨김 처리 (hidden이 무시될 경우 대비) */
document.addEventListener('DOMContentLoaded', () => {
  const hdr = document.getElementById('header-container');
  if (hdr) hdr.style.display = 'none';
});

/* 역할 판단: 로그인 시 저장해둔 lastRole 사용 (없으면 brand) */
function getRole() {
  return (localStorage.getItem('lastRole') || 'brand');
}

/* 쇼호스트 전용 메뉴 가드 */
(function guardShowhost(){
  const tabs  = document.querySelectorAll('.mp-tab');
  const links = document.querySelectorAll('.mypage-item.sh-only');
  const modal = document.getElementById('sh-modal');
  const closeBtn = document.getElementById('sh-cancel');

  function blockOrGo(href){
    if (getRole() !== 'showhost') {
      if (modal && typeof modal.showModal === 'function') modal.showModal();
      else alert('“쇼호스트” 유형 가입자만 사용 가능한 기능입니다.');
      return;
    }
    location.href = href;
  }

  tabs.forEach(btn=>{
    btn.addEventListener('click', () => blockOrGo(btn.dataset.href));
  });

  links.forEach(a=>{
    a.addEventListener('click', (e)=>{
      if (getRole() !== 'showhost') {
        e.preventDefault();
        if (modal && typeof modal.showModal === 'function') modal.showModal();
        else alert('“쇼호스트” 유형 가입자만 사용 가능한 기능입니다.');
      }
    });
  });

  if (closeBtn) closeBtn.addEventListener('click', ()=> modal.close());
})();

/* ✅ 로그아웃 */
(function initLogout(){
  const btn = document.getElementById('btnLogout');
  if(!btn) return;

  btn.addEventListener('click', () => {
    if (!confirm('로그아웃 하시겠어요?')) return;

    // 로그인 관련 로컬 스토리지 키 정리
    ['liveeToken','liveeName','liveeRole','liveeTokenExp','lastRole']
      .forEach(k => localStorage.removeItem(k));

    // 세션성 쿠키 등을 쓰는 경우 필요시 여기에 추가

    // 로그인 페이지로 이동
    location.href = '/alpa/login.html';
  });
})();