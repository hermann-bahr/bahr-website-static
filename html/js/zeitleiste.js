/* Zeitleiste auf leben.html: Filter nach Kategorie, Volltextsuche, Sprung zu Jahren.
   Das Markup erzeugt xslt/partials/bahr.xsl (Template "zeitleiste"); ohne JavaScript
   bleibt die Liste vollständig lesbar, die Balken und Jahrzehnte sind normale Anker. */
(function () {
  "use strict";

  const root = document.getElementById("zeitleiste");
  if (!root) return;
  root.classList.add("zl-js");

  const bar = root.querySelector(".zl-bar");
  const input = document.getElementById("zl-q");
  const select = document.getElementById("zl-jahr");
  const anzahl = document.getElementById("zl-anzahl");
  const reset = document.getElementById("zl-reset");
  const leer = document.getElementById("zl-leer");
  const chips = Array.from(root.querySelectorAll(".zl-chip"));
  const balken = Array.from(root.querySelectorAll(".zl-balken a"));
  const total = Number(root.dataset.total);

  const sections = Array.from(root.querySelectorAll(".zl-jahr")).map((el) => ({
    el,
    jahr: Number(el.dataset.jahr),
    sichtbar: true,
  }));
  const sectionByYear = new Map(sections.map((s) => [s.jahr, s]));
  const events = [];
  sections.forEach((s) => {
    s.el.querySelectorAll(".zl-event").forEach((el) => {
      events.push({ el, typ: el.dataset.typ, section: s, text: null });
    });
  });
  const balkenByYear = new Map(balken.map((a) => [Number(a.dataset.jahr), a]));
  const optionByYear = new Map(
    Array.from(select.options)
      .filter((o) => o.value)
      .map((o) => [Number(o.value), o])
  );

  // Kleinschreibung und ohne Diakritika, damit "cafe" auch "Café" findet
  const fold = (s) =>
    s
      .toLowerCase()
      .normalize("NFD")
      .replace(/[̀-ͯ]/g, "")
      .replace(/ß/g, "ss")
      .replace(/\s+/g, " ");

  const state = { typen: new Set(), q: "" };

  /* ---- Zustand <-> URL (?typ=Orte,Person&q=…), damit sich eine Auswahl verlinken lässt ---- */
  function readUrl() {
    const p = new URLSearchParams(location.search);
    const known = new Set(chips.map((c) => c.dataset.typ));
    state.typen = new Set((p.get("typ") || "").split(",").filter((t) => known.has(t)));
    state.q = p.get("q") || "";
    input.value = state.q;
  }
  function writeUrl() {
    const p = new URLSearchParams(location.search);
    if (state.typen.size) p.set("typ", Array.from(state.typen).join(","));
    else p.delete("typ");
    if (state.q.trim()) p.set("q", state.q.trim());
    else p.delete("q");
    const qs = p.toString();
    history.replaceState(null, "", location.pathname + (qs ? "?" + qs : "") + location.hash);
  }

  /* ---- Filtern ---- */
  function apply() {
    const terms = fold(state.q).split(" ").filter(Boolean);
    if (terms.length) {
      events.forEach((e) => {
        if (e.text === null) e.text = fold(e.el.textContent);
      });
    }
    const proJahr = new Map();
    const proTyp = new Map();
    let n = 0;
    events.forEach((e) => {
      const textOk = terms.every((t) => e.text.includes(t));
      // Zähler der Kategorien: Treffer der Suche, unabhängig von der Kategorienauswahl
      if (textOk) proTyp.set(e.typ, (proTyp.get(e.typ) || 0) + 1);
      const ok = textOk && (!state.typen.size || state.typen.has(e.typ));
      e.el.hidden = !ok;
      if (ok) {
        n++;
        proJahr.set(e.section.jahr, (proJahr.get(e.section.jahr) || 0) + 1);
      }
    });

    sections.forEach((s) => {
      s.sichtbar = proJahr.has(s.jahr);
      s.el.hidden = !s.sichtbar;
      const opt = optionByYear.get(s.jahr);
      if (opt) opt.disabled = !s.sichtbar;
    });

    // Balken: blasser Balken = alle Einträge des Jahres, kräftiger = aktuelle Auswahl
    balken.forEach((a) => {
      const alle = Number(a.dataset.n);
      const k = proJahr.get(Number(a.dataset.jahr)) || 0;
      a.style.setProperty("--f", String(k / alle));
      a.classList.toggle("zl-null", k === 0);
      a.title =
        a.dataset.jahr + ": " + (k === alle ? alle : k + " von " + alle) + (alle === 1 ? " Eintrag" : " Einträge");
    });

    chips.forEach((c) => {
      const k = proTyp.get(c.dataset.typ) || 0;
      c.setAttribute("aria-pressed", String(state.typen.has(c.dataset.typ)));
      c.querySelector(".zl-n").textContent = k;
      c.classList.toggle("zl-null", k === 0);
    });

    const aktiv = state.typen.size > 0 || terms.length > 0;
    anzahl.textContent = aktiv
      ? n + " von " + total + " Einträgen"
      : total + " Einträge";
    reset.hidden = !aktiv;
    leer.hidden = n > 0;
    spy();
  }

  /* ---- Springen ---- */
  // nächstes Jahr mit sichtbaren Einträgen ab `jahr`, sonst das letzte davor
  function nearest(jahr) {
    const visible = sections.filter((s) => s.sichtbar);
    return visible.find((s) => s.jahr >= jahr) || visible[visible.length - 1] || null;
  }
  function jump(jahr) {
    const s = nearest(jahr);
    if (!s) return;
    // "instant", weil Bootstrap weiches Scrollen setzt und die Seite sehr lang ist
    s.el.scrollIntoView({ behavior: "instant", block: "start" });
    history.replaceState(null, "", location.pathname + location.search + "#" + s.el.id);
    mark(s.jahr);
  }

  /* ---- aktuelles Jahr in der Sprungleiste mitführen ---- */
  let current = null;
  function mark(jahr) {
    if (jahr === current) return;
    const old = balkenByYear.get(current);
    if (old) old.classList.remove("zl-aktuell");
    current = jahr;
    const a = balkenByYear.get(jahr);
    if (a) a.classList.add("zl-aktuell");
    select.value = jahr === null ? "" : String(jahr);
  }
  function spy() {
    const line = bar.getBoundingClientRect().bottom + 24;
    let found = null;
    for (const s of sections) {
      if (!s.sichtbar) continue;
      if (s.el.getBoundingClientRect().top <= line) found = s.jahr;
      else break;
    }
    mark(found);
  }
  let ticking = false;
  window.addEventListener(
    "scroll",
    () => {
      if (ticking) return;
      ticking = true;
      requestAnimationFrame(() => {
        ticking = false;
        spy();
      });
    },
    { passive: true }
  );

  // Sprungziele sollen unter der fixierten Leiste landen
  function measure() {
    root.style.setProperty("--zl-offset", Math.ceil(bar.getBoundingClientRect().height) + 12 + "px");
  }
  if ("ResizeObserver" in window) new ResizeObserver(measure).observe(bar);
  measure();

  /* ---- Ereignisse ---- */
  let timer = null;
  input.addEventListener("input", () => {
    clearTimeout(timer);
    timer = setTimeout(() => {
      state.q = input.value;
      apply();
      writeUrl();
    }, 150);
  });
  chips.forEach((c) =>
    c.addEventListener("click", () => {
      const t = c.dataset.typ;
      if (state.typen.has(t)) state.typen.delete(t);
      else state.typen.add(t);
      apply();
      writeUrl();
    })
  );
  reset.addEventListener("click", () => {
    state.typen.clear();
    state.q = "";
    input.value = "";
    apply();
    writeUrl();
  });
  select.addEventListener("change", () => {
    if (select.value) jump(Number(select.value));
  });
  root.querySelector(".zl-hist").addEventListener("click", (ev) => {
    const a = ev.target.closest("a[data-jahr]");
    if (!a) return;
    ev.preventDefault();
    jump(Number(a.dataset.jahr));
  });

  readUrl();
  apply();

  // Direktlink auf einen Eintrag oder ein Jahr: nach dem Messen der Leiste noch einmal ansteuern
  if (location.hash.length > 1) {
    const target = document.getElementById(decodeURIComponent(location.hash.slice(1)));
    if (target && root.contains(target)) {
      if (target.hidden || (target.closest(".zl-jahr") || target).hidden) {
        // der Filter aus der URL blendet das Ziel aus: Ziel hat Vorrang
        state.typen.clear();
        state.q = "";
        input.value = "";
        apply();
        writeUrl();
      }
      // mehrfach, weil sich das Layout bis zum Laden von Schriften und Leiste noch verschiebt;
      // nicht mehr, sobald selbst gescrollt wurde
      let moved = false;
      const go = () => {
        if (!moved) target.scrollIntoView({ behavior: "instant", block: "start" });
      };
      requestAnimationFrame(go);
      window.addEventListener("load", go, { once: true });
      if (document.fonts && document.fonts.ready) document.fonts.ready.then(go);
      ["wheel", "touchstart", "keydown"].forEach((t) =>
        window.addEventListener(t, () => (moved = true), { once: true, passive: true })
      );
    }
  }
})();
