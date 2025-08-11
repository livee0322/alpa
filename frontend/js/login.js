// /alpa/frontend/js/login.js
(() => {
  const conf = window.LIVEE_CONFIG || {};
  const API_BASE = conf.API_BASE;
  const BASE_PATH = conf.BASE_PATH || '/alpa';

  const form = document.getElementById('loginForm');
  const emailEl = document.getElementById('email');
  const pwEl = document.getElementById('password');
  const btn = document.getElementById('loginBtn');
  const err = document.getElementById('loginError');

  function showError(msg) {
    err.textContent = msg || '로그인에 실패했습니다.';
    err.style.display = 'block';
  }
  function clearError() {
    err.textContent = '';
    err.style.display = 'none';
  }

  if (!API_BASE) {
    console.error('CONFIG_NOT_LOADED: API_BASE missing', { conf });
    showError('설정이 로드되지 않았습니다. config.js 경로/순서를 확인하세요.');
    throw new Error('API_BASE_MISSING');
  }
  console.log('[LOGIN] API_BASE =', API_BASE, 'BASE_PATH =', BASE_PATH);

  async function postJSON(path, body) {
    const url = `${API_BASE}${path}`;
    console.log('[LOGIN] POST', url, body);
    const res = await fetch(url, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok || data.ok === false) {
      const message = data.message || `HTTP_${res.status}`;
      const debug = data.debug_id ? ` (debug_id: ${data.debug_id})` : '';
      // 에러에 요청 URL까지 포함해서 원인 추적 쉽게
      throw new Error(`${message}${debug} @ ${url}`);
    }
    return data;
  }

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    clearError();

    const email = emailEl.value.trim();
    const password = pwEl.value;
    if (!email || !password) {
      showError('이메일과 비밀번호를 입력해주세요.');
      return;
    }

    btn.disabled = true;
    btn.textContent = '로그인 중...';

    try {
      // 서버 계약: { ok:true, token, name, role }
      const data = await postJSON('/users/login', { email, password });

      localStorage.setItem('liveeToken', data.token);
      if (data.name) localStorage.setItem('liveeName', data.name);
      if (data.role) localStorage.setItem('liveeRole', data.role);

      location.href = `${BASE_PATH}/mypage.html`;
    } catch (e) {
      console.error('[LOGIN] ERROR', e);
      showError(e.message);
      btn.disabled = false;
      btn.textContent = '로그인';
    }
  });
})();