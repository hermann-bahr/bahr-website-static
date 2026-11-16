<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xsl tei xs">

    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/layout.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="no" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Suche'"/>
        <html lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"/>
                </xsl:call-template>
            </head>
            <body>
                <xsl:call-template name="nav_bar">
                    <xsl:with-param name="current" select="'search'"/>
                </xsl:call-template>
                <div class="seite">
                    <main id="main" tabindex="-1">
                        <nav class="krume" aria-label="Brotkrumen">
                            <a href="index.html">Start</a>
                            <xsl:text> / </xsl:text>
                            <span aria-current="page"><xsl:value-of select="$doc_title"/></span>
                        </nav>
                        <xsl:call-template name="titel">
                            <xsl:with-param name="text" select="$doc_title"/>
                        </xsl:call-template>
                        <!-- Die Suche läuft vollständig im Browser: js/search.js lädt search-index.json
                             (erzeugt von xslt/search_index.xsl) und baut daraus einen FlexSearch-Index.
                             Der Daten-Hash in der Adresse sorgt dafür, dass nach einem neuen Build
                             nicht der alte Index aus dem Browser-Cache verwendet wird. -->
                        <div id="suche" data-base="{replace($base_url, '^https?://', '')}"
                            data-index="search-index.json{if ($DATAHASH) then concat('?v=', $DATAHASH) else ''}">
                            <form class="suche-form" role="search" action="search.html" method="get">
                                <label class="suche-feld">
                                    <span class="nur-vorlesen">Suchbegriff</span>
                                    <input type="search" id="suche-q" name="q" class="input" autocomplete="off"
                                        placeholder="Seiten und Zeitleiste durchsuchen …"/>
                                </label>
                                <button class="btn btn-primary" type="submit">Suchen</button>
                            </form>
                            <p id="suche-status" class="liste-kopf" aria-live="polite">Der Suchindex wird geladen …</p>
                            <noscript>
                                <p>Die Suche benötigt JavaScript.</p>
                            </noscript>
                            <ol id="suche-treffer" class="suche-treffer"></ol>
                            <p>
                                <button type="button" id="suche-mehr" class="btn btn-secondary" hidden="hidden">Weitere Treffer anzeigen</button>
                            </p>
                        </div>
                    </main>
                    <aside class="rail" aria-label="Zu dieser Seite">
                        <fieldset class="rail-block suche-bereich">
                            <legend class="label">Bereich</legend>
                            <label><input type="checkbox" class="suche-art" value="s" checked="checked"/> Seiten <span class="suche-n"></span></label>
                            <label><input type="checkbox" class="suche-art" value="z" checked="checked"/> Zeitleiste <span class="suche-n"></span></label>
                        </fieldset>
                    </aside>
                </div>
                <xsl:call-template name="html_footer"/>
                <script src="vendor/flexsearch/flexsearch.bundle.min.js"></script>
                <script src="js/search.js"></script>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
