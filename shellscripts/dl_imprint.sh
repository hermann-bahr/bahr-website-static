#!/bin/bash
# Lädt das ACDH-Impressum (Redmine-Issue 29434) nach data/imprint.xml; xslt/imprint.xsl macht daraus imprint.html
set -e

REDMINE_ID=29434
IMPRINT_URL="https://imprint.acdh.oeaw.ac.at/${REDMINE_ID}?format=xhtml&locale="
IMPRINT_XML=./data/imprint.xml

{
    echo '<?xml version="1.0" encoding="UTF-8"?>'
    echo '<root>'
    echo '<div lang="de">'
    curl -sSf "${IMPRINT_URL}de"
    echo '</div>'
    echo '<div lang="en">'
    curl -sSf "${IMPRINT_URL}en"
    echo '</div>'
    echo '</root>'
} > "${IMPRINT_XML}.tmp"
mv "${IMPRINT_XML}.tmp" "${IMPRINT_XML}"
