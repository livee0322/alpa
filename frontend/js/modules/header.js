(() => {
  const mount = document.querySelector('.lv-header');
  if (!mount) return;

  const BASE = '/alpa';
  const name = localStorage.getItem('liveeName') || '사용자';
  const token = localStorage.getItem('liveeToken');
  const exp   = Number(localStorage.getItem('liveeTokenExp') || 0);
  const loggedIn = !!token && (!exp || exp > Date.now());

  mount.innerHTML = `
    <img src="${BASE}/liveelogo.png" alt="Livee" class="lv-logo" onclick="location.href='${BASE}/index.html'">
    <div class="lv-head-right">
      ${
        loggedIn
        ? `<button class="lv-head-name" type="button" title="마이페이지">${name}님</button>
           <span class="lv-divider" aria-hidden="true">·</span>
           <button class="lv-logout" type="button">로그아웃</button>`
        : `<a class="lv-login-link" href="${BASE}/login.html">로그인</a>`
      }
    </div>
  `;

  if (loggedIn) {
    mount.querySelector('.lv-head-name')?.addEventListener('click', () => {
      location.href = `${BASE}/mypage.html`;
    });
    mount.querySelector('.lv-logout')?.addEventListener('click', () => {
      ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k => localStorage.removeItem(k));
      location.reload();
    });
  }
})();