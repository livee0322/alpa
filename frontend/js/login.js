(() => {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const form = document.getElementById('loginForm');
  const btn  = document.querySelector('.lg-submit');
  const err  = document.getElementById('loginError');

  form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    err.hidden = true;
    btn.disabled = true; btn.textContent = '로그인 중...';
    try{
      const body = {
        email: form.email.value.trim(),
        password: form.password.value
      };
      const res = await fetch(`${API_BASE}/users/login`, {
        method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body)
      });
      const data = await res.json();
      if(!res.ok || data.ok===false) throw new Error(data.message || '로그인 실패');
      localStorage.setItem('liveeToken', data.token);
      localStorage.setItem('liveeName', data.name || '');
      location.href = '/alpa/index.html';
    }catch(e){
      err.textContent = e.message || '로그인 중 오류가 발생했습니다.'; err.hidden = false;
    }finally{
      btn.disabled = false; btn.textContent = '로그인';
    }
  });
})();