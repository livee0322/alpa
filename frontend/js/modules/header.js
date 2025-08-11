(function(){
  const headerHost = document.querySelector('header.lv-header') || (()=>{
    const h = document.createElement('header');
    h.className = 'lv-header';
    document.body.insertBefore(h, document.body.firstChild); // 배너 아래에 이미 container가 있으면 그 다음
    return h;
  })();

  const token = localStorage.getItem('liveeToken');
  const userHtml = token
    ? `<button id="lv-logout" class="btn-text">로그아웃</button>`
    : `<a href="/alpa/login.html" class="btn-text">로그인</a>`;

  headerHost.innerHTML = `
    <img src="/alpa/liveelogo.png" alt="Livee" class="lv-logo" onclick="location.href='/alpa/index.html'">
    <div class="lv-user">${userHtml}</div>
  `;

  const btn = headerHost.querySelector('#lv-logout');
  if(btn){
    btn.addEventListener('click', ()=>{
      ['liveeToken','liveeName','liveeTokenExp'].forEach(k=>localStorage.removeItem(k));
      location.href = '/alpa/index.html';
    });
  }
})();