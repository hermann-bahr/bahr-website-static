<?xml version="1.0" encoding="UTF-8"?>
<!-- imprint.html: das ACDH-Impressum aus data/imprint.xml (shellscripts/dl_imprint.sh, Redmine-Issue 29434).
     Erst die deutsche, dann die englische Fassung; die Randspalte springt zwischen beiden. -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    version="2.0"
    exclude-result-prefixes="#all">

    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/layout.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="no" omit-xml-declaration="yes"/>

    <xsl:template match="/">
        <xsl:variable name="doc_title" select="'Impressum'"/>
        <html lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"/>
                </xsl:call-template>
                <link rel="canonical" href="{concat($base_url, 'imprint.html')}"/>
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
                        <div class="inhalt">
                            <section id="de">
                                <xsl:apply-templates select="/root/div[@lang = 'de']/node()"/>
                            </section>
                            <section id="en" lang="en">
                                <xsl:apply-templates select="/root/div[@lang = 'en']/node()"/>
                            </section>
                        </div>
                    </main>
                    <aside class="rail" aria-label="Zu dieser Seite">
                        <div class="rail-block">
                            <h2 class="label">Sprache</h2>
                            <ul class="rail-liste">
                                <li><a href="#de">Deutsch</a></li>
                                <li lang="en"><a href="#en">English</a></li>
                            </ul>
                        </div>
                    </aside>
                </div>
                <xsl:call-template name="html_footer"/>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="@* | node()">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
        </xsl:copy>
    </xsl:template>
</xsl:stylesheet>
