<script>
(function(){
  const headerHost = document.querySelector('header.lv-header') || (()=>{
    const h = document.createElement('header');
    h.className = 'lv-header';
    document.body.insertBefore(h, document.body.firstChild.nextSibling); // 배너 다음
    return h;
  })();

  // 로그인 상태 텍스트 (임시)
  const token = localStorage.getItem('liveeToken');
  const userHtml = token 
    ? `<button id="lv-logout" class="btn-text">로그아웃</button>`
    : `<a href="/alpa/login.html" class="btn-text">로그인</a>`;

  headerHost.innerHTML = `
    <img src="/alpa/liveelogo.png" alt="Livee" class="lv-logo" onclick="location.href='/alpa/index.html'">
    <div class="lv-user">${userHtml}</div>
  `;

  // 로그아웃
  const btn = headerHost.querySelector('#lv-logout');
  if(btn){
    btn.addEventListener('click', ()=>{
      ['liveeToken','liveeName','liveeTokenExp'].forEach(k=>localStorage.removeItem(k));
      location.href = '/alpa/index.html';
    });
  }
})();
</script>