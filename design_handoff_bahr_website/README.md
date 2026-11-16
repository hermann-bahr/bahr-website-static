# Handoff: Bahr-Website redesign

## Overview
Redesign of the static scholarly site https://hermann-bahr.github.io/bahr-website-static/ (Hermann Bahr – Österreichischer Kritiker europäischer Avantgarden). Goals: scholarly, readable, durable (plain HTML/CSS, self-hosted fonts, WCAG AA, maintainable for 10+ years). Top bar with dropdowns is kept.

## About the design files
`Bahr Website Redesign.dc.html` is a **design reference built in HTML**, not production code. Open it in a browser to see every artboard. Recreate the designs in the site's existing static generator/templates (TEI → HTML) as plain HTML + one CSS file. Do not ship the reference file. `styles.css` is the token and component sheet the designs are built on and can be used as the starting stylesheet.

## Fidelity
High-fidelity: colors, type, spacing and rules are final. Placeholder images (striped boxes) and some copy are not (see "Open points").

## Directions in the file
- **2a — Raster, Wiener Fassung (preferred).** Grid and apparatus rail of 1a with Jugendstil hints.
- **1a — Raster.** Same layout, all Archivo, single 2px rules, no ornament.
- **1b — Plakat.** Alternative: black masthead, poster-scale titles, single column, metadata in a ruled strip under the title. Not selected.

Everything below describes 2a; differences to 1a are noted.

## Design tokens
Colors
- Ground `#f3f2f2`, surface `#eae9e9`, text `#201e1d`
- Accent `#ec3013` (large type, fills, markers only); links and small accent text `#ae1800`; link hover `#dd2b0f`
- Muted text `#605d5d`; divider `rgba(32,30,29,.4)`
- Placeholder stripes `#d7d3d3` / `#eae7e7`

Type
- Body/UI: Archivo 400/600/800, fallback `system-ui, sans-serif`
- Titles, h1–h6, buttons, brand (2a): Federo 400, fallback Archivo. (1a: Archivo 800.) Alternatives tried: Marcellus 400, Josefin Sans 600.
- Self-host both as woff2 (OFL); no Google Fonts request in production.
- h1 48px (64px on Start and Briefe), uppercase, letter-spacing .04em, line-height 1.08 (1a: mixed case, -0.015em, 1.12)
- h3 25px, letter-spacing .02em; h6 13px uppercase .08em, muted
- Lead paragraph 20px/1.45, max 60ch; body 16px/1.6, max 66ch
- Reading text 18px/1.65, max 62ch, `hyphens:auto`, `lang="de"`
- Rail text 13px; breadcrumb 13px muted; table/list rows 15px; small caps labels 11px uppercase .08em

Spacing: 4 / 8 / 12 / 16 / 24 / 32px. Radius 0 everywhere. No shadows.

Rules
- Major: `4px double #201e1d` (1a: `2px solid #201e1d`) — under header, above footer, section tops, list header
- Secondary: `2px solid` divider color — rail edge, cell borders
- Rows: `1px solid` divider color

Ornament (2a only, decorative, `aria-hidden`)
- Brand: three 7px squares (red, ink, ink), 3px gap, before "HERMANN BAHR"
- Under each h1: 9px squares (one red filled, two 2px ink outline), 5px gap, then a 2px ink line up to 160px; 20px below

## Page shell (all pages, desktop design width 1000px)
- **Header:** flex, baseline aligned, gap 22px, padding 14px 32px, major rule below. Brand left (Federo 17px, uppercase, letter-spacing .14em, ink, no underline). Nav right: Bibliografie, Kritische Schriften, Leben, Briefe, Forschung, Bilder, Suche — 14px/600 ink, no underline; current section `#ae1800`.
- **Dropdown:** 250px panel under the item, ground fill, 2px ink border (no top), first row "Section · Übersicht" 800 in link red with 2px divider below, then sub-pages 14px with 1px row rules, padding 8px 14px; hover/focus row fill `#eae9e9`. Implement with `<details>` or CSS `:focus-within` so it works without JS; items must be keyboard reachable.
- **Body:** grid `232px minmax(0,1fr)`.
  - Rail (`<aside>`): padding 28px 24px 28px 32px, 2px divider on the right, 13px text, blocks 20px apart, each with an h6 label: section sub-navigation or "Auf dieser Seite" (current item 800, 4px red left bar), **Permalink** (canonical `bahr.univie.ac.at/...` URL, `word-break:break-all`), **Quelle** (link "TEI/XML-Dokument"), **Zitieren**, optional image.
  - Main: padding 28px 32px 36px; breadcrumb, h1, ornament, content.
- **Footer:** flex, gap 20px, padding 14px 32px, major rule above, 13px links: Impressum und Datenschutz, Barrierefreiheit, Kontakt; GitHub right-aligned.
- Focus: `outline:2px solid #ec3013; outline-offset:2px`. Keep the skip link "Zum Inhalt springen".

## Screens
1. **Start (Zum Projekt)** — tagline line, h1 64px, lead paragraph, two equal cells (2px divider between; major rule above) "Kritische Schriften" / "Textverzeichnis" each with red h6 kicker, h3 link, 16px text; then h6 + strip of 8 cover thumbnails (8-col grid, 8px gap, ratio 2:3, grayscale). Rail holds portrait (3:4).
2. **Bibliografie list (Theaterstücke)** — rail lists the 8 Bibliografie sub-pages. Intro paragraph, header row "41 Titel · alphabetisch / Jahr" (11px caps) over a major rule, then a 2-column list (`columns:2`, gap 32px, 2px column rule): each row a link, title 600 left, year muted right with tabular numerals, padding 7px 0, 1px row rule.
3. **Edition reading text** — rail: cover image, "Band" block (volume, editor), primary button "PDF laden" (full width, label flush left), Permalink, Quelle. Main: h1 (max 24ch), year, then paragraphs each in a `36px 1fr` grid with a 1px rule above; left cell is the paragraph number "¶1" as a link to that paragraph's anchor (13px/600, link red).
4. **Briefe index** — h1 64px, 3-column grid of cells (major rule on top, 2px divider borders): image 4:3, 11px caps category, title 21px Federo. Cell hover fill `#eae9e9`.
5. **Personenregister** — rail has "Auf dieser Seite" anchors and a facsimile image. Intro, then sections opened by a major rule + h3; "Gesamtindex →" as bold link; table (Nr. / Band / Zeitraum / Register→PDF): header 11px caps over 2px rule, rows 15px with 1px rules, hover tint.
6. **Suche** — rail: "Bereich" checkboxes (Kritische Schriften, Bibliografie, Briefe, Forschung; all checked by default; `accent-color:#ae1800`). Main: search input 48px high, 18px text, 2px ink border + primary button "Suchen"; result count line over a major rule; results as rows `48px 1fr`: thumbnail 2:3, caps section label, title 21px Federo, URL 13px link red.

## Mobile (390px)
- Header: brand + "Menü" button (secondary, min-height 44px); menu opens the full section tree (open state not designed — use stacked `<details>`).
- Single column, padding 20px 16px. Rail content moves below the main content as a ruled block (Start) or becomes a button row under the title (reading page: "PDF laden" primary + "TEI/XML" secondary, 44px high).
- h1 44px (Start), 34px (reading); reading text 18px/1.6.
- Suggested breakpoint: collapse the rail under ~760px.

## Interactions & state
Static site; no state. Links get hover color `#dd2b0f`; buttons: primary `#ec3013` → hover `#dd2b0f` → active `#ae1800`. No animations. Search and its filters use whatever the current `search.html` uses; only the presentation changes. Add a print stylesheet later if wanted (not designed).

## Accessibility
Body text and links meet 4.5:1 on the ground; pure accent red is used only for large type, fills and markers. All images need alt text; ornaments are `aria-hidden`. Minimum text size 13px (11px only for uppercase labels). Mobile targets ≥44px.

## Assets
- Cover images: existing `files/bilder/vdg/*.jpg` on the current site (hot-linked in the reference).
- Portraits, facsimiles, search thumbnails: placeholders — supply real images; display in grayscale (`filter:grayscale(1) contrast(1.08)`).
- Fonts: Archivo, Federo (both OFL, Google Fonts) — download and self-host.

## Open points
- The reading-text sample (Die Überwindung des Naturalismus) was typed from memory; use the edition text.
- Invented for the mock: "4 Treffer" count, Briefe category labels ("Briefwechsel", "Verzeichnis", "Briefe"), "Arbeitsfeld 1/2" kickers. Play list shows only the first year where the site gives two.
- Paragraph permalinks need stable ids generated from the TEI.

## Files
- `Bahr Website Redesign.dc.html` — all artboards (2a at top, 1a/1b below). Needs `support.js` beside it to open.
- `styles.css` — Modernist tokens and component classes (`.btn`, `.table`, `.input`, `.grayscale` …).
