// /alpa/frontend/js/mypage.js
(() => {
  const { API_BASE, BASE_PATH = '/alpa' } = window.LIVEE_CONFIG || {};

  // 로그인 체크
  const t = localStorage.getItem('liveeToken');
  if (!t) { location.href = `${BASE_PATH}/login.html`; return; }

  // DOM
  const secAccount = document.getElementById('sec-account');
  const secBrand   = document.getElementById('sec-brand');
  const secShow    = document.getElementById('sec-showhost');
  const miAccountSub = document.getElementById('mi-account-sub');

  async function api(path, opts = {}) {
    const headers = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
    const tk = localStorage.getItem('liveeToken');
    if (tk) headers.Authorization = `Bearer ${tk}`;
    const res = await fetch(`${API_BASE}${path}`, { ...opts, headers });
    let data;
    try { data = await res.json(); } catch { data = { ok:false }; }
    if (res.status === 401) {
      console.warn('401 from /users/me – token invalid/expired');
      ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k=>localStorage.removeItem(k));
      location.href = `${BASE_PATH}/login.html`;
      throw new Error('UNAUTHORIZED');
    }
    if (!res.ok || data.ok === false) {
      const msg = data?.message || `HTTP_${res.status}`;
      throw new Error(msg);
    }
    return data;
  }

  function showByRole(role, name) {
    const nm = name ? `이름: ${name}` : '이름을 설정해 주세요';
    miAccountSub.textContent = nm;

    if (role === 'brand') {
      secBrand.hidden = false; secShow.hidden = true;
    } else {
      secBrand.hidden = true;  secShow.hidden = false;
    }
    secAccount.hidden = false;
  }

  (async function init(){
    try {
      const me = await api('/users/me', { method:'GET' });
      // 기대 스키마: { ok:true, id, name, role }
      const role = me.role || localStorage.getItem('liveeRole') || 'brand';
      localStorage.setItem('liveeRole', role);
      if (me.name) localStorage.setItem('liveeName', me.name);
      showByRole(role, me.name);
    } catch (e) {
      console.error('[/users/me] 실패:', e?.message);
      // 우회: 저장된 role로라도 화면 구성
      const role = localStorage.getItem('liveeRole') || 'brand';
      const name = localStorage.getItem('liveeName') || '';
      showByRole(role, name);
      // 알림은 과하게 떠서 제거(콘솔만)
      // alert('마이페이지 정보를 불러올 수 없습니다.');
    }
  })();
})();