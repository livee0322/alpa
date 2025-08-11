// /alpa/frontend/js/login.js
(() => {
  const { API_BASE, BASE_PATH='/alpa' } = window.LIVEE_CONFIG || {};
  const form = document.getElementById('loginForm');
  const emailEl = document.getElementById('email');
  const pwEl = document.getElementById('password');
  const btn = document.getElementById('loginBtn');
  const err = document.getElementById('loginError');

  function showError(msg){ err.textContent = msg || '로그인에 실패했습니다.'; err.style.display='block'; }
  function clearError(){ err.textContent=''; err.style.display='none'; }

  async function tryLogin(path, body){
    const url = `${API_BASE}${path}`;
    console.log('[LOGIN] TRY', url);
    const res = await fetch(url, {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify(body)
    });
    let data={}; try { data = await res.json(); } catch(e){}
    if (!res.ok || data.ok===false) throw new Error(`${data.message||`HTTP_${res.status}`} @ ${url}`);
    return data;
  }

  form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    clearError();

    const email = emailEl.value.trim();
    const password = pwEl.value;
    if(!email || !password){ return showError('이메일과 비밀번호를 입력해주세요.'); }

    btn.disabled = true; btn.textContent = '로그인 중...';

    const candidates = ['/users/login','/auth/login','/users/signin'];
    const payload = { email, password };

    let lastErr;
    for (const p of candidates){
      try{
        const data = await tryLogin(p, payload);
        localStorage.setItem('liveeToken', data.token);
        if (data.name) localStorage.setItem('liveeName', data.name);
        if (data.role) localStorage.setItem('liveeRole', data.role);
        location.href = `${BASE_PATH}/mypage.html`;
        return;
      }catch(e2){
        console.warn('[LOGIN] fail:', e2.message);
        lastErr = e2;
        // 404면 다음 후보 계속, 그 외(400/401/500)는 그대로 중단
        if (!/HTTP_404/.test(e2.message)) break;
      }
    }

    showError(lastErr ? lastErr.message : '로그인 실패');
    btn.disabled = false; btn.textContent = '로그인';
  });
})();