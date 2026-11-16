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
        <xsl:variable name="doc_title" select="'Seite nicht gefunden'"/>
        <html lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"/>
                </xsl:call-template>
            </head>
            <body>
                <xsl:call-template name="nav_bar">
                    <xsl:with-param name="current" select="''"/>
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
                        <p class="lead">Diese Seite gibt es nicht (Fehler 404).</p>
                        <p>Vielleicht hilft die <a href="search.html">Suche</a> oder das <a href="toc.html">Inhaltsverzeichnis</a> weiter.</p>
                    </main>
                    <aside class="rail" aria-label="Zu dieser Seite">
                        <div class="rail-block">
                            <h2 class="label">Weiter</h2>
                            <ul class="rail-liste">
                                <li><a href="index.html">Startseite</a></li>
                                <li><a href="search.html">Suche</a></li>
                                <li><a href="toc.html">Inhaltsverzeichnis</a></li>
                            </ul>
                        </div>
                    </aside>
                </div>
                <xsl:call-template name="html_footer"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
