(() => {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const form = document.getElementById('loginForm');
  const btn  = form.querySelector('.lo-submit');
  const err  = document.getElementById('loginError');
  const pillsWrap = document.getElementById('rolePills');
  const pills = pillsWrap.querySelectorAll('.lo-pill');

  // 마지막 역할 기억(회원가입에서 저장했던 것)
  let role = localStorage.getItem('lastRole') || 'brand';
  pills.forEach(p => p.classList.toggle('active', p.dataset.role === role));

  // 역할 선택 UI
  pills.forEach(p => p.addEventListener('click', () => {
    role = p.dataset.role;
    pills.forEach(x => x.classList.toggle('active', x === p));
    // 선택 역할을 기억만 해두자(백엔드는 로그인에 role이 필요없음)
    localStorage.setItem('lastRole', role);
  }));

  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    err.hidden = true;

    const email = form.email.value.trim();
    const password = form.password.value;

    if (!API_BASE) {
      err.textContent = 'API 설정을 찾을 수 없습니다(config.js 확인).';
      err.hidden = false;
      return;
    }

    btn.disabled = true; btn.textContent = '로그인 중...';
    try {
      const res = await fetch(`${API_BASE}/users/login`, {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({ email, password })
      });
      const data = await res.json().catch(() => ({ ok:false, message:'INVALID_JSON' }));
      if (!res.ok || data.ok === false) {
        throw new Error(data.message || '로그인 실패');
      }

      // 표준 저장 규칙
      localStorage.setItem('liveeToken', data.token);
      if (data.name) localStorage.setItem('liveeName', data.name);
      if (data.role) localStorage.setItem('liveeRole', data.role);
      // 백엔드가 role을 안주면 UI에서 고른 값으로 fallback
      if (!data.role) localStorage.setItem('liveeRole', role);

      // 다음 페이지로
      const next = localStorage.getItem('afterLogin') || '/alpa/mypage.html';
      localStorage.removeItem('afterLogin');
      location.href = next;
    } catch (e) {
      err.textContent = e.message || '로그인 중 오류가 발생했습니다.';
      err.hidden = false;
    } finally {
      btn.disabled = false; btn.textContent = '로그인';
    }
  });
})();