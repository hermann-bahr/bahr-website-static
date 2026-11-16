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
        <xsl:variable name="doc_title" select="'Inhaltsverzeichnis'"/>
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
                        <xsl:variable name="docs" select="collection('../data/editions?select=*.xml')/tei:TEI[not(@xml:id = 'zeitleiste')]"/>
                        <p>Alle <xsl:value-of select="count($docs)"/> Seiten in der Reihenfolge ihres Menüpfads.</p>
                        <div class="tabelle">
                            <table class="table">
                                <thead>
                                    <tr>
                                        <th scope="col">Titel</th>
                                        <th scope="col">Menüpfad</th>
                                    </tr>
                                </thead>
                                <tbody>
                                    <xsl:for-each select="$docs">
                                        <xsl:sort select="string(@xml:id)"/>
                                        <tr>
                                            <td>
                                                <a href="{concat(@xml:id, '.html')}">
                                                    <xsl:value-of select="normalize-space((.//tei:titleStmt/tei:title)[1])"/>
                                                </a>
                                            </td>
                                            <td>
                                                <xsl:value-of select="string-join(.//tei:keywords[@scheme = 'menu']/tei:term/normalize-space(), ' › ')"/>
                                            </td>
                                        </tr>
                                    </xsl:for-each>
                                </tbody>
                            </table>
                        </div>
                    </main>
                    <aside class="rail" aria-label="Zu dieser Seite">
                        <xsl:call-template name="apparat">
                            <xsl:with-param name="pageId" select="'toc.html'"/>
                            <xsl:with-param name="titel" select="$doc_title"/>
                        </xsl:call-template>
                    </aside>
                </div>
                <xsl:call-template name="html_footer"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
