(() => {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const form = document.getElementById('signupForm');
  const btn  = document.querySelector('.su-submit');
  const err  = document.getElementById('signupError');
  const pills= document.querySelectorAll('.su-pill');
  let role = 'brand';
  pills.forEach(b=>b.addEventListener('click',()=>{ role=b.dataset.role; pills.forEach(x=>x.classList.toggle('active',x===b)); }));

  form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    err.hidden = true;
    btn.disabled = true; btn.textContent = '가입 중...';
    try{
      const body = {
        name: form.nickname.value.trim(),
        email: form.email.value.trim(),
        password: form.password.value,
        role
      };
      const res = await fetch(`${API_BASE}/users/signup`, {
        method:'POST', headers:{'Content-Type':'application/json'}, body:JSON.stringify(body)
      });
      const data = await res.json().catch(()=>({ok:false}));
      if(!res.ok || data.ok===false) throw new Error(data.message || '가입 실패');
      alert('가입이 완료되었습니다. 로그인 해주세요.');
      localStorage.setItem('lastRole', role);
      location.href = '/alpa/login.html';
    }catch(e){
      err.textContent = e.message || '가입 중 오류가 발생했습니다.'; err.hidden = false;
    }finally{
      btn.disabled = false; btn.textContent = '가입하기';
    }
  });
})();