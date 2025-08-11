(() => {
  const { API_BASE, BASE_PATH='/alpa' } = window.LIVEE_CONFIG || {};
  const form = document.getElementById('loginForm');
  const pills= document.querySelectorAll('.lo-pill');
  const btn  = document.querySelector('.lo-submit');
  const err  = document.getElementById('loginError');

  let role = localStorage.getItem('lastRole') || 'brand';
  pills.forEach((b)=> {
    if (b.dataset.role === role) b.classList.add('active');
    b.addEventListener('click',()=>{ 
      role = b.dataset.role; 
      pills.forEach(x=>x.classList.toggle('active', x===b));
    });
  });

  async function tryLogin(path, payload){
    const res = await fetch(`${API_BASE}${path}`, {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify(payload)
    });
    const data = await res.json().catch(()=>({ ok:false, message:'INVALID_JSON'}));
    return { res, data };
  }

  form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    err.hidden = true;
    btn.disabled = true; btn.textContent = '로그인 중...';

    const payload = {
      email: form.email.value.trim(),
      password: form.password.value,
      // role은 서버가 필요없어도 보낼 수 있지만, 혹시 문제 되면 주석 처리해도 됨
      role
    };

    try{
      // 1차: 규약대로
      let { res, data } = await tryLogin('/users/login', payload);

      // 404거나 실패면 2차: /auth/login 폴백 (서버 라우팅 불일치 대비)
      if (!res.ok) {
        const firstStatus = res.status;
        ({ res, data } = await tryLogin('/auth/login', payload));
        // 두 번 다 실패면 첫 실패 메시지/상태를 같이 보여주기
        if (!res.ok) {
          const msg = data?.message || `로그인 실패 (status ${firstStatus} -> ${res.status})`;
          throw new Error(msg);
        }
      }

      if (data.ok === false) throw new Error(data.message || '로그인 실패');

      // 서버에서 온 이름/토큰/role 사용
      if (data.token) localStorage.setItem('liveeToken', data.token);
      if (data.name)  localStorage.setItem('liveeName', data.name);
      if (data.role)  localStorage.setItem('lastRole', data.role);
      // next
      location.href = `${BASE_PATH}/mypage.html`;
    }catch(e){
      err.textContent = e.message || '로그인에 실패했습니다.';
      err.hidden = false;
      // 네트워크/응답 로그 확인을 위해 콘솔에도 남김
      console.error('LOGIN_ERROR:', e);
    }finally{
      btn.disabled = false; btn.textContent = '로그인';
    }
  });
})();