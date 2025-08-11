(() => {
  const { API_BASE, BASE_PATH } = window.LIVEE_CONFIG || {};
  const form  = document.getElementById('loginForm');
  const btn   = form.querySelector('.lg-submit');
  const err   = document.getElementById('loginError');
  const pills = document.querySelectorAll('#rolePills .lg-pill');

  // 마지막 선택 롤 복원 (기본: brand)
  let role = localStorage.getItem('lastRole') || 'brand';
  pills.forEach(p => p.classList.toggle('active', p.dataset.role === role));

  // 롤 선택 토글
  pills.forEach(p => {
    p.addEventListener('click', () => {
      role = p.dataset.role;
      localStorage.setItem('lastRole', role);
      pills.forEach(x => x.classList.toggle('active', x === p));
    });
  });

  // 로그인 제출
  form.addEventListener('submit', async (e) => {
    e.preventDefault();
    err.hidden = true;
    btn.disabled = true;
    const origText = btn.textContent;
    btn.textContent = '로그인 중...';

    try {
      const payload = {
        email: form.email.value.trim(),
        password: form.password.value,
        role // 서버가 롤을 검증/반환할 때 참고용
      };

      const res = await fetch(`${API_BASE}/users/login`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      const data = await res.json().catch(() => ({ ok: false }));
      if (!res.ok || data.ok === false) {
        throw new Error(data.message || '로그인에 실패했습니다.');
      }

      // 성공: 토큰/이름/롤 저장
      if (data.token) localStorage.setItem('liveeToken', data.token);
      if (data.name)  localStorage.setItem('liveeName', data.name);
      if (data.role)  localStorage.setItem('lastRole', data.role);

      // 이동: 기본은 홈. 원하면 쇼호스트만 마이페이지로 바꿔도 됨.
      const next = `${BASE_PATH || '/alpa'}/index.html`;
      location.replace(next);
    } catch (e2) {
      err.textContent = e2.message || '알 수 없는 오류가 발생했습니다.';
      err.hidden = false;
    } finally {
      btn.disabled = false;
      btn.textContent = origText;
    }
  });
})();