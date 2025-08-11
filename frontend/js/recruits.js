(() => {
  const { API_BASE, BASE_PATH = '/alpa', thumb } = window.LIVEE_CONFIG || {};
  const token = localStorage.getItem('liveeToken');
  const role  = localStorage.getItem('liveeRole');

  const $ = (s) => document.querySelector(s);
  const listEl  = $('#rcList');
  const emptyEl = $('#rcEmpty');
  const notice  = $('#rcNotice');

  // 공통 fetch 래퍼
  async function api(path, opts = {}) {
    const headers = { 'Content-Type': 'application/json', ...(opts.headers || {}) };
    if (token) headers.Authorization = `Bearer ${token}`;
    const res = await fetch(`${API_BASE}${path}`, { ...opts, headers });
    const data = await res.json().catch(() => ({ ok:false, message:'INVALID_JSON' }));
    if (res.status === 401) {
      ['liveeToken','liveeName','liveeRole','liveeTokenExp'].forEach(k => localStorage.removeItem(k));
      location.href = `${BASE_PATH}/login.html`;
      return;
    }
    if (!res.ok || data.ok === false) throw new Error(data.message || `HTTP_${res.status}`);
    return data;
  }

  function setBottomActive() {
    const nav = document.getElementById('bottom-tab-container');
    if (!nav) return;
    const a = nav.querySelector(`[data-tab="recruits"]`);
    if (a) a.classList.add('active');
  }

  function cloudThumb(url) {
    // 썸네일 변환 파라미터 삽입(c_fill…)
    if (!url) return '';
    try {
      const [base, rest] = url.split('/upload/');
      return `${base}/upload/${thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto'}/${rest}`;
    } catch { return url; }
  }

  function cardTemplate(item) {
    const img = cloudThumb(item.imageUrl || '');
    const date = item.date ? `일정: ${item.date}${item.time ? ' ' + item.time : ''}` : '';
    const applicants = typeof item.applicantsCount === 'number'
      ? `지원자 ${item.applicantsCount}명`
      : '지원자 현황';

    return `
      <article class="rc-card" data-id="${item.id || item._id}">
        <img class="rc-thumb" src="${img}" alt="" onerror="this.src='${BASE_PATH}/frontend/img/placeholder-16x9.png'">
        <div class="rc-body">
          <div class="rc-h">
            <h3 class="rc-title-sm" title="${escapeHtml(item.title || '')}">${escapeHtml(item.title || '')}</h3>
            <div class="rc-badges">
              <span class="rc-badge">${applicants}</span>
            </div>
          </div>
          <p class="rc-desc">${escapeHtml((item.description || '').trim())}</p>
          <div class="rc-meta">${date}</div>
          <div class="rc-actions">
            <button class="rc-btn primary" data-act="edit">공고 수정</button>
            <button class="rc-btn danger"  data-act="delete">삭제</button>
          </div>
        </div>
      </article>
    `;
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
  }

  async function loadMyRecruits() {
    // 권한 체크
    if (!token) {
      location.href = `${BASE_PATH}/login.html`;
      return;
    }
    if (role !== 'brand') {
      notice.textContent = '브랜드 계정만 공고를 관리할 수 있습니다.';
      notice.hidden = false;
      emptyEl.hidden = true;
      listEl.hidden = true;
      return;
    }

    try {
      const data = await api('/recruits/mine'); // { ok:true, items:[...] } 형태를 기대
      const items = data.items || data.data || [];
      if (!items.length) {
        emptyEl.hidden = false;
        listEl.hidden = true;
      } else {
        listEl.innerHTML = items.map(cardTemplate).join('');
        hookActions();
        listEl.hidden = false;
        emptyEl.hidden = true;
      }
    } catch (e) {
      notice.textContent = `내 공고를 불러올 수 없습니다. ${e.message || ''}`;
      notice.hidden = false;
      emptyEl.hidden = true;
      listEl.hidden = true;
    } finally {
      setBottomActive();
    }
  }

  function hookActions() {
    listEl.addEventListener('click', async (e) => {
      const btn = e.target.closest('[data-act]');
      if (!btn) return;
      const card = btn.closest('.rc-card');
      const id = card?.dataset.id;
      if (!id) return;

      if (btn.dataset.act === 'edit') {
        location.href = `${BASE_PATH}/recruitform.html?edit=${encodeURIComponent(id)}`;
      }
      if (btn.dataset.act === 'delete') {
        if (!confirm('이 공고를 삭제할까요?')) return;
        try {
          await api(`/recruits/${id}`, { method: 'DELETE' });
          card.remove();
          if (!listEl.children.length) {
            emptyEl.hidden = false;
            listEl.hidden = true;
          }
        } catch (err) {
          alert(err.message || '삭제에 실패했습니다.');
        }
      }
    }, { once: true }); // 최초 바인딩 1회 (리렌더 시 다시 호출됨)
  }

  // 초기 로드
  document.addEventListener('DOMContentLoaded', loadMyRecruits);
})();