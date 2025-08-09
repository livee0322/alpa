// 임시 로그인 로직 (API 붙기 전 목업)
// 검증 OK → localStorage에 토큰/이름/역할 저장 → 홈 이동
(function(){
  const form = document.getElementById('loginForm');
  const submitBtn = document.querySelector('.lg-submit');
  const err = document.getElementById('formError');
  const remember = document.getElementById('rememberId');
  const rolePills = document.querySelectorAll('.lg-pill');

  // 현재 선택된 역할
  let role = localStorage.getItem('lastRole') || 'brand';
  rolePills.forEach(b=>{
    b.classList.toggle('active', b.dataset.role === role);
    b.addEventListener('click', ()=>{
      role = b.dataset.role;
      localStorage.setItem('lastRole', role);
      rolePills.forEach(x=>x.classList.toggle('active', x===b));
    });
  });

  // 아이디 저장 미리 반영
  const savedEmail = localStorage.getItem('savedEmail');
  if(savedEmail){
    form.email.value = savedEmail;
    remember.checked = true;
  }

  // 입력 변경 시 버튼 활성화
  form.addEventListener('input', ()=>{
    const ok = form.email.validity.valid && form.password.value.length >= 6;
    submitBtn.classList.toggle('enabled', ok);
    submitBtn.disabled = !ok;
  });
  form.dispatchEvent(new Event('input'));

  // 제출
  form.addEventListener('submit', (e)=>{
    e.preventDefault();
    err.hidden = true;

    const email = form.email.value.trim();
    const pw = form.password.value;

    if(!email || pw.length < 6){
      err.textContent = '입력 값을 확인하세요.';
      err.hidden = false;
      return;
    }

    // 아이디 저장
    if(remember.checked) localStorage.setItem('savedEmail', email);
    else localStorage.removeItem('savedEmail');

    // ===== 임시 로그인 성공 처리 (API 연동 전) =====
    const mockToken = `mock.${btoa(email)}.${Date.now()}`;
    localStorage.setItem('liveeToken', mockToken);
    localStorage.setItem('liveeName', email.split('@')[0]);
    localStorage.setItem('liveeRole', role);

    // 하단탭에서 '마이'로 전환되도록
    location.href = '/alpa/index.html';
  });
})();