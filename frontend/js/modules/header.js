(function(){
  const mount = document.getElementById('header-container');
  if (!mount) return;

  const token = localStorage.getItem('liveeToken');
  const name = localStorage.getItem('liveeName') || '';
  const exp = Number(localStorage.getItem('liveeTokenExp') || 0);
  const isLoggedIn = !!token && exp > Date.now();

  let html = `
    <header class="lv-header">
      <div class="left">
        <a href="/alpa/index.html" class="logo">
          <img src="/alpa/img/logo.svg" alt="Livee">
        </a>
      </div>
      <div class="right">
  `;

  if (isLoggedIn) {
    html += `
      <span class="user-name">${name}님</span>
      <button class="logout-btn">로그아웃</button>
    `;
  } else {
    html += `<a href="/alpa/frontend/login.html" class="login-link">로그인</a>`;
  }

  html += `
      </div>
    </header>
  `;

  mount.innerHTML = html;

  // 로그아웃 동작
  if (isLoggedIn) {
    mount.querySelector('.logout-btn').addEventListener('click', () => {
      ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k => localStorage.removeItem(k));
      location.reload();
    });
  }
})();