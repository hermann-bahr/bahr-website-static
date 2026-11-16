<?xml version="1.0" encoding="UTF-8"?>
<!-- Suchseite. Die Suche läuft vollständig im Browser: html/js/search.js lädt
     search-index.json (erzeugt von xslt/search_index.xsl) und baut daraus einen FlexSearch-Index. -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="xsl tei xs">

    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="yes" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Suche'"/>
        <html class="h-100" lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"/>
                </xsl:call-template>
                <link rel="stylesheet" href="css/search.css" type="text/css"/>
            </head>

            <body class="d-flex flex-column h-100">
                <xsl:call-template name="nav_bar"/>
                <main id="main" tabindex="-1" class="flex-shrink-0 flex-grow-1">
                    <nav style="--bs-breadcrumb-divider: '>';" aria-label="breadcrumb"
                        class="ps-5 p-3">
                        <ol class="breadcrumb">
                            <li class="breadcrumb-item">
                                <a href="index.html">
                                    <xsl:value-of select="$project_short_title"/>
                                </a>
                            </li>
                            <li class="breadcrumb-item active" aria-current="page">
                                <xsl:value-of select="$doc_title"/>
                            </li>
                        </ol>
                    </nav>
                    <!-- der Daten-Hash in der Adresse sorgt dafür, dass nach einem neuen Build
                         nicht der alte Index aus dem Browser-Cache verwendet wird -->
                    <div class="container suche pb-5" id="suche"
                        data-index="search-index.json{if ($DATAHASH) then concat('?v=', $DATAHASH) else ''}">
                        <h1 class="display-5 text-center">
                            <xsl:value-of select="$doc_title"/>
                        </h1>
                        <form class="suche-form" role="search" action="search.html" method="get">
                            <input type="search" id="suche-q" name="q" class="form-control form-control-lg"
                                placeholder="Seiten und Zeitleiste durchsuchen …"
                                aria-label="Seiten und Zeitleiste durchsuchen" autocomplete="off"/>
                        </form>
                        <div class="suche-arten" role="group" aria-label="Treffer eingrenzen">
                            <button type="button" class="suche-chip" data-art="" aria-pressed="true">Alle <span class="suche-n"/></button>
                            <button type="button" class="suche-chip" data-art="s" aria-pressed="false">Seiten <span class="suche-n"/></button>
                            <button type="button" class="suche-chip" data-art="z" aria-pressed="false">Zeitleiste <span class="suche-n"/></button>
                        </div>
                        <p id="suche-status" class="suche-status" aria-live="polite">Der Suchindex wird geladen …</p>
                        <noscript>
                            <p class="suche-status">Die Suche benötigt JavaScript.</p>
                        </noscript>
                        <ol id="suche-treffer" class="suche-treffer"/>
                        <div class="text-center">
                            <button type="button" id="suche-mehr" class="btn btn-outline-secondary" hidden="hidden">Weitere Treffer anzeigen</button>
                        </div>
                    </div>
                </main>
                <xsl:call-template name="html_footer"/>
                <script src="vendor/flexsearch/flexsearch.bundle.min.js"/>
                <script src="js/search.js"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
