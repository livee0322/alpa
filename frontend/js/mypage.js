// /alpa/frontend/js/mypage.js
(() => {
  const { API_BASE, BASE_PATH = '/alpa' } = window.LIVEE_CONFIG || {};

  // 로그인 체크
  const t = localStorage.getItem('liveeToken');
  if (!t) {
    location.href = `${BASE_PATH}/login.html`;
    return;
  }

  // 섹션 DOM
  const secAccount = document.getElementById('sec-account');
  const secBrand   = document.getElementById('sec-brand');
  const secShow    = document.getElementById('sec-showhost');
  const miAccountSub = document.getElementById('mi-account-sub');

  // 공통 api 헬퍼
  async function api(path, opts = {}) {
    const headers = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
    const tk = localStorage.getItem('liveeToken');
    if (tk) headers.Authorization = `Bearer ${tk}`;

    const res = await fetch(`${API_BASE}${path}`, { ...opts, headers });
    let data = {};
    try { data = await res.json(); } catch(_) { data = { ok:false }; }

    if (res.status === 401) {
      ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k=>localStorage.removeItem(k));
      location.href = `${BASE_PATH}/login.html`;
      throw new Error('UNAUTHORIZED');
    }
    if (!res.ok || data.ok === false) throw new Error(data.message || `HTTP_${res.status}`);
    return data;
  }

  // 초기화
  (async function init() {
    try {
      const me = await api('/users/me', { method:'GET' });
      const role = me.role || localStorage.getItem('liveeRole') || 'brand';
      localStorage.setItem('liveeRole', role);

      // 계정 서브텍스트 갱신
      const nm = me.name ? `이름: ${me.name}` : '이름을 설정해 주세요';
      miAccountSub.textContent = nm;

      // 역할별 섹션 보이기
      if (role === 'brand') {
        secBrand.hidden = false;
        secShow.hidden  = true;
      } else {
        secBrand.hidden = true;
        secShow.hidden  = false;
      }
      // 계정 섹션은 공통으로 노출
      secAccount.hidden = false;
    } catch (e) {
      console.error(e);
      alert('마이페이지 정보를 불러올 수 없습니다.');
    }
  })();
})();