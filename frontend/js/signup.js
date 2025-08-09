(() => {
  const form = document.getElementById('signupForm');
  const submit = document.querySelector('.su-submit');
  const err = document.getElementById('formError');
  const pills = document.querySelectorAll('.su-pill');
  let role = 'brand';

  // 역할 선택
  pills.forEach(b=>{
    b.addEventListener('click',()=>{
      role = b.dataset.role;
      pills.forEach(x=>x.classList.toggle('active', x===b));
    });
  });

  // 비밀번호 보기 토글
  document.querySelectorAll('.toggle-eye').forEach(btn=>{
    btn.addEventListener('click', ()=>{
      const target = form[btn.dataset.target];
      if(!target) return;
      target.type = (target.type === 'password') ? 'text' : 'password';
    });
  });

  // 유효성 체크
  const validate = () => {
    const nn = form.nickname.value.trim();
    const id = form.username.value.trim();
    const pw = form.password.value;
    const pw2 = form.password2.value;
    const em = form.email.value.trim();

    const idOk = /^[a-zA-Z0-9_]{4,16}$/.test(id);
    const nnOk = nn.length >= 2 && nn.length <= 12;
    const pwOk = pw.length >= 6;
    const match = pw && pw === pw2;
    const emOk = /\S+@\S+\.\S+/.test(em);

    const ok = nnOk && idOk && pwOk && match && emOk;
    submit.classList.toggle('enabled', ok);
    submit.disabled = !ok;

    err.hidden = true;
    return ok;
  };

  form.addEventListener('input', validate);
  validate();

  // 제출(현재는 목업 → 나중에 API 연동)
  form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    if(!validate()){
      err.textContent = '입력 값을 다시 확인해 주세요.';
      err.hidden = false; return;
    }

    const payload = {
      name: form.nickname.value.trim(),
      username: form.username.value.trim(),  // 백엔드에서 필요하면 사용
      email: form.email.value.trim(),
      password: form.password.value,
      role
    };

    try {
      // === 실제 연동시 ===
      // const res = await fetch('https://main-server-ekgr.onrender.com/api/v1/users/signup', {
      //   method:'POST', headers:{'Content-Type':'application/json'},
      //   body: JSON.stringify(payload)
      // });
      // const data = await res.json();
      // if(!res.ok || data.ok === false) throw new Error(data.message || '가입 실패');

      // === 목업 성공 ===
      localStorage.setItem('lastRole', role);
      alert('가입이 완료되었습니다. 로그인 해주세요.');
      location.href = '/alpa/login.html';
    } catch (e) {
      err.textContent = '가입 중 오류가 발생했습니다. 잠시 후 다시 시도해주세요.';
      err.hidden = false;
    }
  });
})();