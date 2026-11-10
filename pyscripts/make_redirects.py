"""Schreibt Weiterleitungsseiten von den alten Drupal-Pfaden auf die neuen Seiten.

Aus data/mapping.csv wird für jeden alten Pfad (z. B. /bibliografie/38703)
html/<pfad>/index.html mit einem meta-refresh auf die neue Datei erzeugt.
Nach dem ant-Lauf aufrufen: uv run pyscripts/make_redirects.py
"""

import csv
from html import escape
from pathlib import Path

MAPPING = Path("data/mapping.csv")
TARGET = Path("html")


def main():
    count = 0
    with MAPPING.open(encoding="utf-8") as f:
        for row in csv.DictReader(f):
            alias = row["old_alias"].strip("/")
            if not alias:
                continue
            page = TARGET / alias / "index.html"
            if (TARGET / alias).with_suffix(".html").exists():
                # gleichnamige neue Seite nicht überschreiben
                continue
            up = "../" * (alias.count("/") + 1)
            target = escape(up + row["file"].removesuffix(".xml") + ".html")
            page.parent.mkdir(parents=True, exist_ok=True)
            page.write_text(
                '<!doctype html><html lang="de"><head><meta charset="utf-8">'
                f'<meta http-equiv="refresh" content="0; url={target}">'
                f'<link rel="canonical" href="{target}">'
                "<title>Weiterleitung</title></head>"
                f'<body><p>Die Seite ist umgezogen: <a href="{target}">{target}</a></p></body></html>',
                encoding="utf-8",
            )
            count += 1
    print(f"{count} Weiterleitungen geschrieben")


if __name__ == "__main__":
    main()
