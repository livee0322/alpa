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

  // 역할 토글
  const pills = document.querySelectorAll('.pill-group .pill');
  let selectedRole = localStorage.getItem('lastRole') || 'brand';
  pills.forEach(p => {
    const isActive = p.dataset.role === selectedRole;
    p.setAttribute('aria-selected', String(isActive));
    p.addEventListener('click', () => {
      selectedRole = p.dataset.role;
      pills.forEach(x => x.setAttribute('aria-selected', String(x===p)));
      localStorage.setItem('lastRole', selectedRole);
    });
  });

  function showError(msg){ err.textContent = msg || '로그인에 실패했습니다.'; err.hidden = false; }
  function clearError(){ err.textContent=''; err.hidden = true; }

  if (!API_BASE){ showError('설정이 로드되지 않았습니다.'); throw new Error('API_BASE_MISSING'); }

  async function postJSON(path, body){
    const url = `${API_BASE}${path}`;
    const res = await fetch(url, {
      method:'POST',
      headers:{'Content-Type':'application/json'},
      body: JSON.stringify(body)
    });
    const data = await res.json().catch(()=>({}));
    if (!res.ok || data.ok === false){
      const message = data.message || `HTTP_${res.status}`;
      throw new Error(`${message}`);
    }
    return data;
  }

  form.addEventListener('submit', async (e)=>{
    e.preventDefault();
    clearError();

    const email = emailEl.value.trim();
    const password = pwEl.value;
    if(!email || !password) return showError('이메일과 비밀번호를 입력해주세요.');

    btn.disabled = true; btn.textContent = '로그인 중...';
    try{
      // 서버 계약: { ok:true, token, name, role }
      const data = await postJSON('/users/login', { email, password });

      // 저장
      localStorage.setItem('liveeToken', data.token);
      if (data.name) localStorage.setItem('liveeName', data.name);
      if (data.role) localStorage.setItem('liveeRole', data.role);

      // 역할 불일치시 안내(로그인은 성공 처리)
      if (data.role && selectedRole && data.role !== selectedRole){
        // 안내만 하고 진행
        console.warn(`[LOGIN] 선택역할(${selectedRole}) ≠ 서버역할(${data.role})`);
      }

      // 역할 기반 이동(원하시면 페이지 변경 가능)
      // 브랜드: 공고관리, 쇼호스트: 마이/포트폴리오 등
      const next = (data.role === 'brand')
        ? `${BASE_PATH}/mypage.html`
        : `${BASE_PATH}/mypage.html`;
      location.href = next;
    }catch(e){
      showError(e.message);
      btn.disabled = false; btn.textContent = '로그인';
    }
  });
})();