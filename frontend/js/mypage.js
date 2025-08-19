// 헤더는 숨김 처리(혹시 hidden 속성 무시될 경우 대비)
document.addEventListener('DOMContentLoaded', () => {
  const hdr = document.getElementById('header-container');
  if (hdr) hdr.style.display = 'none';
});

// 역할 판단: 로그인 시 저장해둔 값 사용 (없으면 brand로 가정)
function getRole() {
  // 토큰에서 파싱하는 로직이 있다면 여기에 연결. 임시로 lastRole 사용.
  return (localStorage.getItem('lastRole') || 'brand');
}

(function guardShowhost(){
  const role = getRole();
  const tabs = document.querySelectorAll('.mp-tab');
  const links = document.querySelectorAll('.mypage-item.sh-only');
  const modal = document.getElementById('sh-modal');
  const closeBtn = document.getElementById('sh-cancel');

  function blockOrGo(href){
    if (getRole() !== 'showhost') {
      if (typeof modal.showModal === 'function') modal.showModal();
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
        if (typeof modal.showModal === 'function') modal.showModal();
        else alert('“쇼호스트” 유형 가입자만 사용 가능한 기능입니다.');
      }
    });
  });

  if (closeBtn) closeBtn.addEventListener('click', ()=> modal.close());
})();