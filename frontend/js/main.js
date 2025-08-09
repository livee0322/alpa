// 전역 디버그 스위치: localStorage.LIVE_DEBUG='1'
const DEBUG = !!localStorage.getItem('LIVE_DEBUG');
const log = (...a)=>{ if(DEBUG) console.log('[LIVE_DEBUG]', ...a); };

document.addEventListener('DOMContentLoaded', () => {
  // 사용자 이름 표시 (로그인 후 name 저장한다고 가정)
  const userName = localStorage.getItem('liveeName');
  if(userName) {
    const el = document.getElementById('user-info');
    if(el) el.textContent = userName;
  }

  // 지금은 API 연동 전이므로 데모 카드 없이 빈상태만 유지
  log('Home loaded. Modules mounted (banner/top/bottom).');
});