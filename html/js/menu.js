/* Hauptmenü: Die Untermenüs sind <details> und funktionieren ohne dieses Skript.
   Hier nur Komfort: Escape und ein Klick daneben schließen das offene Untermenü. */
(function () {
  "use strict";
  const menue = document.getElementById("menue");
  if (!menue) return;
  const offen = () => Array.from(menue.querySelectorAll("details[open]"));
  document.addEventListener("click", (ev) => {
    offen().forEach((d) => {
      if (!d.contains(ev.target)) d.open = false;
    });
  });
  document.addEventListener("keydown", (ev) => {
    if (ev.key !== "Escape") return;
    offen().forEach((d) => {
      d.open = false;
      if (d.contains(document.activeElement)) d.querySelector("summary").focus();
    });
  });
})();
