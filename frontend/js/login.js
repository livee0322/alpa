// /alpa/frontend/js/login.js
(() => {
  const { API_BASE, BASE_PATH='/alpa' } = window.LIVEE_CONFIG || {};
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

  async function postJSON(path, body) {
    const res = await fetch(`${API_BASE}${path}`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify(body)
    });
    const data = await res.json().catch(() => ({}));
    if (!res.ok || data.ok === false) {
      const message = data.message || `HTTP_${res.status}`;
      const debug = data.debug_id ? ` (debug_id: ${data.debug_id})` : '';
      throw new Error(message + debug);
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
      // 백엔드 계약: { ok:true, token, name, role }
      const data = await postJSON('/users/login', { email, password });

      // 토큰/유저정보 저장 규칙
      localStorage.setItem('liveeToken', data.token);
      if (data.name) localStorage.setItem('liveeName', data.name);
      if (data.role) localStorage.setItem('liveeRole', data.role);

      // 로그인 후 이동 (마이페이지 우선)
      location.href = `${BASE_PATH}/mypage.html`;
    } catch (e) {
      console.error(e);
      showError(e.message);
      btn.disabled = false;
      btn.textContent = '로그인';
    }
  });
})();