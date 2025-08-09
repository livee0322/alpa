// 디버그: localStorage.LIVE_DEBUG='1'
const DEBUG = !!localStorage.getItem('LIVE_DEBUG');
const log = (...a)=>{ if(DEBUG) console.log('[LIVE_DEBUG]', ...a); };

document.addEventListener('DOMContentLoaded', () => {
  // 헤더 우측 사용자명 (있을 때만)
  const userName = localStorage.getItem('liveeName');
  const userEl = document.getElementById('user-info');
  if(userName && userEl) userEl.textContent = userName;

  // 터치/클릭 피드백 (리플 비슷한 효과)
  addTapEffect(document.body);

  // 이후 단계: API 연동 시 스켈레톤 → 데이터로 교체
  log('Home ready: CSS upgraded, tap effect enabled.');
});

/** 간단 탭/카드 터치 피드백 */
function addTapEffect(root){
  root.addEventListener('click', e=>{
    const el = e.target.closest('.lv-card, .lv-s-item, .lv-tab, .lv-more');
    if(!el) return;
    el.animate([{transform:'scale(1)'},{transform:'scale(.98)'},{transform:'scale(1)'}],
      {duration:180, easing:'ease-out'});
  }, {passive:true});
}