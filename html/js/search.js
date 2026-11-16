/* Volltextsuche auf search.html mit FlexSearch (https://github.com/nextapps-de/flexsearch).
   Es gibt keinen Suchserver: search-index.json (erzeugt von xslt/search_index.xsl) wird geladen
   und der Index im Browser aufgebaut. Ein Datensatz ist eine Seite (k = "s") oder ein Eintrag
   der Zeitleiste (k = "z"), der auf leben.html#<id> zeigt. */
(function () {
  "use strict";

  const root = document.getElementById("suche");
  if (!root) return;

  const input = document.getElementById("suche-q");
  const status = document.getElementById("suche-status");
  const list = document.getElementById("suche-treffer");
  const mehr = document.getElementById("suche-mehr");
  const chips = Array.from(root.querySelectorAll(".suche-chip"));

  const PRO_SEITE = 20;
  const MARKS = "̀-ͯ"; // kombinierende Diakritika
  const state = { q: "", art: "", gezeigt: PRO_SEITE };
  let data = null;
  let textIndex = null;
  let titleIndex = null;
  let hits = []; // Nummern der Datensätze zur aktuellen Suche, nach Relevanz
  let ungefaehr = false;

  // FlexSearch entfernt Diakritika selbst ("cafe" findet "Café"), ß bleibt aber stehen
  const sz = (s) => s.replace(/ß/g, "ss");
  const zahl = (n) => n.toLocaleString("de-AT");
  const esc = (s) =>
    s.replace(/[&<>"]/g, (c) => ({ "&": "&amp;", "<": "&lt;", ">": "&gt;", '"': "&quot;" }[c]));

  /* ---- Zustand <-> URL (?q=…&art=z), damit sich eine Suche verlinken lässt ---- */
  function readUrl() {
    const p = new URLSearchParams(location.search);
    state.q = p.get("q") || "";
    state.art = ["s", "z"].includes(p.get("art")) ? p.get("art") : "";
    input.value = state.q;
  }
  function writeUrl() {
    const p = new URLSearchParams();
    if (state.q.trim()) p.set("q", state.q.trim());
    if (state.art) p.set("art", state.art);
    const qs = p.toString();
    history.replaceState(null, "", location.pathname + (qs ? "?" + qs : ""));
  }

  /* ---- Suchen ---- */
  function search() {
    const q = sz(state.q.trim());
    hits = [];
    ungefaehr = false;
    if (!textIndex || q.length < 2) return;
    const limit = data.length;
    let ids = textIndex.search(q, { limit });
    // kein Datensatz enthält alle Begriffe: Treffer zulassen, denen einzelne Begriffe fehlen
    if (!ids.length && /\s/.test(q)) {
      ids = textIndex.search(q, { limit, suggest: true });
      ungefaehr = ids.length > 0;
    }
    // Treffer im Titel zuerst, sonst die Reihenfolge von FlexSearch
    const imTitel = new Set(titleIndex.search(q, { limit }));
    hits = ids.filter((i) => imTitel.has(i)).concat(ids.filter((i) => !imTitel.has(i)));
  }

  /* ---- Hervorheben ----
     Der Ausdruck läuft über den NFD-zerlegten Text, so findet "cafe" auch "Café" und "muller" auch
     "Müller". Wie im Index (tokenize: "forward") zählt nur der Wortanfang. */
  function termRegex() {
    const terms = state.q
      .normalize("NFD")
      .replace(new RegExp("[" + MARKS + "]", "g"), "")
      .toLowerCase()
      .split(/[^\p{L}\p{N}]+/u)
      .filter(Boolean)
      .sort((a, b) => b.length - a.length);
    if (!terms.length) return null;
    const alt = terms.map((t) =>
      sz(t)
        .replace(/ss|[^s]|s/g, (c) => (c === "ss" ? "(?:ss|ß)" : c) + "[" + MARKS + "]*")
    );
    return new RegExp("(?<![\\p{L}\\p{N}" + MARKS + "])(?:" + alt.join("|") + ")", "giu");
  }

  function mark(text, re) {
    if (!re) return esc(text.normalize("NFC"));
    let out = "";
    let pos = 0;
    re.lastIndex = 0;
    for (let m; (m = re.exec(text)); ) {
      out += esc(text.slice(pos, m.index).normalize("NFC")) + "<mark>" + esc(m[0].normalize("NFC")) + "</mark>";
      pos = m.index + m[0].length;
    }
    return out + esc(text.slice(pos).normalize("NFC"));
  }

  // Textausschnitt um die erste Fundstelle; ohne Fundstelle der Anfang des Textes
  function snippet(rec, re) {
    const text = rec.x.normalize("NFD");
    let at = -1;
    let wort = "";
    if (re) {
      re.lastIndex = 0;
      const m = re.exec(text);
      if (m) {
        at = m.index;
        const rest = new RegExp("[\\p{L}\\p{N}" + MARKS + "]*", "uy");
        rest.lastIndex = at + m[0].length;
        wort = (m[0] + rest.exec(text)[0]).normalize("NFC");
      }
    }
    const VOR = 90;
    const LAENGE = 280;
    let from = Math.max(0, at - VOR);
    if (from > 0) {
      const sp = text.indexOf(" ", from);
      from = sp > -1 && sp < at ? sp + 1 : from;
    }
    let to = Math.min(text.length, from + LAENGE);
    if (to < text.length) {
      const sp = text.lastIndexOf(" ", to);
      if (sp > from + LAENGE / 2) to = sp;
    }
    const html = (from > 0 ? "… " : "") + mark(text.slice(from, to), re) + (to < text.length ? " …" : "");
    return { html, wort };
  }

  /* ---- Ausgabe ---- */
  function item(rec, re) {
    const s = snippet(rec, re);
    let href = rec.u;
    // Seiten: der Browser springt zur Fundstelle und hebt sie hervor (Text Fragments);
    // Zeitleisteneinträge haben schon ihr eigenes Sprungziel
    if (rec.k === "s" && s.wort) {
      href += "#:~:text=" + encodeURIComponent(s.wort).replace(/-/g, "%2D");
    }
    const meta =
      rec.k === "z"
        ? '<span class="suche-art">Zeitleiste</span> ' + esc(rec.d) + (rec.c ? " · " + esc(rec.c) : "")
        : esc(rec.p || "");
    return (
      '<li class="suche-item">' +
      (meta ? '<div class="suche-meta">' + meta + "</div>" : "") +
      '<h2><a href="' + esc(href) + '">' + mark(rec.t.normalize("NFD"), re) + "</a></h2>" +
      (rec.x ? "<p>" + s.html + "</p>" : "") +
      "</li>"
    );
  }

  function render() {
    const proArt = { "": hits.length, s: 0, z: 0 };
    hits.forEach((i) => proArt[data[i].k]++);
    chips.forEach((c) => {
      c.setAttribute("aria-pressed", String(c.dataset.art === state.art));
      c.querySelector(".suche-n").textContent = hits.length ? zahl(proArt[c.dataset.art]) : "";
    });

    const q = state.q.trim();
    const sichtbar = state.art ? hits.filter((i) => data[i].k === state.art) : hits;
    const re = termRegex();
    list.innerHTML = sichtbar
      .slice(0, state.gezeigt)
      .map((i) => item(data[i], re))
      .join("");
    mehr.hidden = sichtbar.length <= state.gezeigt;

    if (!data) return;
    if (q.length < 2) {
      status.textContent =
        "Durchsucht werden " +
        zahl(data.filter((r) => r.k === "s").length) +
        " Seiten und " +
        zahl(data.filter((r) => r.k === "z").length) +
        " Einträge der Zeitleiste.";
    } else if (!hits.length) {
      status.textContent = "Keine Treffer für „" + q + "“.";
    } else {
      const n = sichtbar.length;
      status.textContent =
        (ungefaehr ? "Kein Treffer enthält alle Suchbegriffe. Ähnliche Treffer: " : "") +
        zahl(n) +
        " Treffer" +
        (state.art && n !== hits.length ? " von " + zahl(hits.length) : "");
    }
  }

  function update() {
    state.gezeigt = PRO_SEITE;
    search();
    render();
    writeUrl();
  }

  /* ---- Ereignisse ---- */
  let timer = null;
  input.addEventListener("input", () => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      state.q = input.value;
      update();
    }, 150);
  });
  input.form.addEventListener("submit", (ev) => {
    ev.preventDefault();
    clearTimeout(timer);
    state.q = input.value;
    update();
  });
  chips.forEach((c) =>
    c.addEventListener("click", () => {
      state.art = c.dataset.art;
      state.gezeigt = PRO_SEITE;
      render();
      writeUrl();
    })
  );
  mehr.addEventListener("click", () => {
    state.gezeigt += PRO_SEITE;
    render();
  });

  /* ---- Index laden und aufbauen ---- */
  readUrl();
  fetch(root.dataset.index)
    .then((r) => {
      if (!r.ok) throw new Error(r.status + " " + r.statusText);
      return r.json();
    })
    .then((records) => {
      const options = { tokenize: "forward", encoder: FlexSearch.Charset.Normalize };
      textIndex = new FlexSearch.Index(options);
      titleIndex = new FlexSearch.Index(options);
      records.forEach((r, i) => {
        textIndex.add(i, sz(r.t + " " + r.x));
        titleIndex.add(i, sz(r.t));
      });
      data = records;
      search();
      render();
      input.focus();
    })
    .catch((err) => {
      console.error(err);
      status.textContent =
        "Der Suchindex konnte nicht geladen werden. (Die Suche funktioniert nur über einen Webserver, nicht aus einer lokal geöffneten Datei.)";
    });
})();
