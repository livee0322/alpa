(() => {
  const { API_BASE } = window.LIVEE_CONFIG || {};
  const list = document.getElementById("campaignList");

  const toThumb = (url = "") => {
    if (!url) return "";
    const [h, t] = url.split("/upload/");
    if (!t) return url;
    return `${h}/upload/c_fill,g_auto,w_320,h_180,f_auto,q_auto/${t}`;
  };

  async function loadMine() {
    const token = localStorage.getItem("liveeToken");
    if (!token) return;

    const res = await fetch(`${API_BASE}/campaigns/mine`, {
      headers: { Authorization: `Bearer ${token}` },
    });
    const data = await res.json();
    render(data.items || []);
  }

  function render(items) {
    list.innerHTML = "";
    items.forEach((it) => {
      const card = document.createElement("div");
      card.className = "cl-card";

      const img = document.createElement("img");
      img.className = "cl-thumb";
      // ✅ 보강: coverImageUrl도 고려
      img.src =
        it.thumbnailUrl ||
        toThumb(it.imageUrl) ||
        toThumb(it.coverImageUrl) ||
        "";

      const body = document.createElement("div");
      body.className = "cl-body";

      const title = document.createElement("div");
      title.className = "cl-title";
      title.textContent = it.title;

      const meta = document.createElement("div");
      meta.className = "cl-meta";
      meta.textContent = it.type;

      body.appendChild(title);
      body.appendChild(meta);

      const act = document.createElement("div");
      act.className = "cl-act";

      const btnEdit = document.createElement("button");
      btnEdit.textContent = "수정";
      btnEdit.onclick = () => {
        location.href = `/livee-beta/frontend/campaign-edit.html?id=${it.id}`;
      };

      const btnDel = document.createElement("button");
      btnDel.textContent = "삭제";
      btnDel.className = "danger";
      btnDel.onclick = async () => {
        if (!confirm("삭제하시겠습니까?")) return;
        const token = localStorage.getItem("liveeToken");
        await fetch(`${API_BASE}/campaigns/${it.id}`, {
          method: "DELETE",
          headers: { Authorization: `Bearer ${token}` },
        });
        loadMine();
      };

      act.appendChild(btnEdit);
      act.appendChild(btnDel);

      card.appendChild(img);
      card.appendChild(body);
      card.appendChild(act);

      list.appendChild(card);
    });
  }

  loadMine();
})();