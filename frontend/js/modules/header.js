(function(){
  const mount = document.querySelector('.lv-header');
  if(!mount) return;

  const loggedIn = !!localStorage.getItem('liveeToken');
  const userName = localStorage.getItem('liveeName') || '';

  // 로고 + 사용자 정보
  mount.innerHTML = `
    <img src="/alpa/liveelogo.png" 
         alt="Livee" 
         class="lv-logo" 
         style="height:48px; cursor:pointer;" 
         onclick="location.href='/alpa/index.html'">
    <div id="user-info" class="lv-user">
      ${loggedIn 
        ? `<span>${userName ? userName + '님' : '마이페이지'}</span> <button id="logout-btn" class="logout-btn">로그아웃</button>`
        : `<a href="/alpa/login.html">로그인</a>`}
    </div>
  `;

  // 로그아웃 버튼 이벤트
  const logoutBtn = document.getElementById('logout-btn');
  if(logoutBtn){
    logoutBtn.addEventListener('click', () => {
      localStorage.removeItem('liveeToken');
      localStorage.removeItem('liveeName');
      location.href = '/alpa/index.html';
    });
  }
})();