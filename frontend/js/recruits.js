(() => {
  const { API_BASE, BASE_PATH = '/alpa', thumb } = window.LIVEE_CONFIG || {};
  const token = localStorage.getItem('liveeToken');
  const role  = localStorage.getItem('liveeRole');

  const $ = (s) => document.querySelector(s);
  const listEl  = $('#rcList');
  const emptyEl = $('#rcEmpty');
  const notice  = $('#rcNotice');

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
    if (!url) return '';
    try {
      const [base, rest] = url.split('/upload/');
      return `${base}/upload/${thumb?.card169 || 'c_fill,g_auto,w_640,h_360,f_auto,q_auto'}/${rest}`;
    } catch { return url; }
  }

  function escapeHtml(s) {
    return String(s).replace(/[&<>"']/g, m => ({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[m]));
  }

  function cardTemplate(item) {
    const img = cloudThumb(item.imageUrl || item.thumbnailUrl || '');
    const dateStr = item.date ? new Date(item.date).toLocaleDateString('ko-KR') : '';
    const timeStr = item.time ? ` ${item.time}` : '';
    const date = item.date ? `일정: ${dateStr}${timeStr}` : '';
    const applicants = typeof item.applicantsCount === 'number'
      ? `지원자 ${item.applicantsCount}명` : '지원자 현황';

    return `
      <article class="rc-card" data-id="${item.id || item._id}">
        <img class="rc-thumb" src="${img}" alt=""
             onerror="this.src='${BASE_PATH}/frontend/img/placeholder-16x9.png'">
        <div class="rc-body">
          <div class="rc-h">
            <h3 class="rc-title-sm" title="${escapeHtml(item.title || '')}">
              ${escapeHtml(item.title || '')}
            </h3>
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

  async function loadMyRecruits() {
    if (!token) { location.href = `${BASE_PATH}/login.html`; return; }
    if (role !== 'brand' && role !== 'admin') {
      notice.textContent = '브랜드 계정만 공고를 관리할 수 있습니다.';
      notice.hidden = false;
      emptyEl.hidden = true;
      listEl.hidden = true;
      return;
    }

    try {
      const data = await api('/recruits/mine'); // { ok:true, items:[...] }
      const items = data.items || data.data || [];
      if (!items.length) {
        emptyEl.hidden = false;      // 빈 문구 보이기
        listEl.hidden = true;
        listEl.innerHTML = '';
      } else {
        emptyEl.hidden = true;       // ✅ 아이템 있으면 빈 문구 숨김
        listEl.innerHTML = items.map(cardTemplate).join('');
        listEl.hidden = false;
        hookActions();               // 액션 바인딩
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
    // 이벤트 중복 방지 위해 한 번만 바인딩
    listEl.onclick = async (e) => {
      const btn = e.target.closest('[data-act]');
      if (!btn) return;
      const card = btn.closest('.rc-card');
      const id = card?.dataset.id;
      if (!id) return;

      if (btn.dataset.act === 'edit') {
        location.href = `${BASE_PATH}/recruitform.html?edit=${encodeURIComponent(id)}`;
        return;
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
    };
  }

  document.addEventListener('DOMContentLoaded', loadMyRecruits);
})();