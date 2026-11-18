<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bahr="http://bahr.univie.ac.at/ns"
    version="2.0"
    exclude-result-prefixes="xsl tei xs bahr">

    <xsl:import href="./partials/shared.xsl"/>
    <xsl:import href="./partials/html_navbar.xsl"/>
    <xsl:import href="./partials/html_head.xsl"/>
    <xsl:import href="./partials/html_footer.xsl"/>
    <xsl:import href="./partials/layout.xsl"/>
    <xsl:import href="./partials/zotero.xsl"/>
    <!-- Templates für bahr-website-data; als letztes Import, damit sie shared.xsl übersteuern -->
    <xsl:import href="./partials/bahr.xsl"/>
    <xsl:output encoding="UTF-8" media-type="text/html" method="html" version="5.0" indent="no" omit-xml-declaration="yes"/>

    <!-- @xml:id ist der Dateiname ohne .xml; Navigation kommt aus data/menu.xml ($menu, bahr.xsl) -->
    <xsl:variable name="doc_id" select="string(/tei:TEI/@xml:id)"/>
    <xsl:variable name="teiSource" select="concat($doc_id, '.xml')"/>
    <xsl:variable name="link" select="concat($doc_id, '.html')"/>
    <xsl:variable name="self" select="$menu//item[@id = $doc_id]"/>
    <!-- Hauptmenüpunkt, zu dem die Seite gehört -->
    <xsl:variable name="bereich" select="$self/ancestor-or-self::item[parent::menu[@name = 'main-menu']]"/>
    <!-- Vor/Zurück nur zwischen Einträgen derselben Liste -->
    <xsl:variable name="prev" select="$self[@eintrag = 'true']/preceding-sibling::item[@eintrag = 'true'][1]"/>
    <xsl:variable name="next" select="$self[@eintrag = 'true']/following-sibling::item[@eintrag = 'true'][1]"/>
    <xsl:variable name="doc_title" select="normalize-space((.//tei:titleStmt/tei:title)[1])"/>
    <xsl:variable name="ist_start" select="$doc_id = 'index'"/>
    <!-- reine Menüknoten (bibliografie, briefe, forschung): kein Text, nur Unterseiten -->
    <xsl:variable name="ist_uebersicht" select="not(normalize-space(string-join(.//tei:body//text(), '')))
        and not(.//tei:body//tei:divGen) and exists($self/item)"/>
    <!-- Abschnitte mit Überschrift, für „Auf dieser Seite“; die Autorzeile (bahr.xsl) ist keiner -->
    <xsl:variable name="abschnitte" select="/tei:TEI/tei:text/tei:body/tei:div[normalize-space(tei:head)][not(bahr:autorzeile(tei:head))]"/>
    <!-- Kritische Schriften: Zeile der Bandübersicht (Umschlag, Bandnummer, Herausgeber), die auf diese Seite zeigt -->
    <xsl:variable name="band" select="(doc('../data/editions/kritische-schriften.xml')//tei:row[.//tei:ref/@target = $teiSource])[1]"/>
    <!-- das PDF des Bandes: nur ein Link auf /sites/all/ks/{Bandnummer}-….pdf, nicht irgendein PDF der Seite
         (etwa ein Zeitungsartikel). Gibt es zwei Auflagen, gewinnt die zweite (…-2.pdf). Sonst kein Knopf. -->
    <xsl:variable name="band_nr" select="replace(normalize-space(($band/tei:cell)[1]), '\D', '')"/>
    <xsl:variable name="pdf_kandidaten" select="if ($band_nr) then .//tei:body//tei:ref[matches(@target, concat('/sites/all/ks/', $band_nr, '-[^/]*\.pdf$'), 'i')] else ()"/>
    <xsl:variable name="pdf" select="($pdf_kandidaten[matches(@target, '-2\.pdf$', 'i')], $pdf_kandidaten)[1]"/>

    <xsl:template match="/">
        <html lang="{$default_lang}">
            <head>
                <xsl:call-template name="html_head">
                    <xsl:with-param name="html_title" select="$doc_title"/>
                </xsl:call-template>
                <link rel="canonical" href="{concat($base_url, $link)}"/>
                <xsl:call-template name="zoterMetaTags">
                    <xsl:with-param name="pageId" select="$link"/>
                    <xsl:with-param name="zoteroTitle" select="$doc_title"/>
                </xsl:call-template>
            </head>
            <body>
                <xsl:if test="$ist_start"><xsl:attribute name="class" select="'start'"/></xsl:if>
                <xsl:call-template name="nav_bar">
                    <xsl:with-param name="current" select="string($bereich/@id)"/>
                </xsl:call-template>
                <div class="seite">
                    <main id="main" tabindex="-1">
                        <xsl:choose>
                            <xsl:when test="$ist_start">
                                <p class="start-logo">
                                    <img src="img/bahr-logo.jpg" width="2200" height="1200"
                                        alt="Hermann Bahr, Österreichischer Kritiker europäischer Avantgarden"/>
                                </p>
                            </xsl:when>
                            <xsl:otherwise>
                                <nav class="krume" aria-label="Brotkrumen">
                                    <a href="index.html">Start</a>
                                    <xsl:for-each select="$self/ancestor::item">
                                        <xsl:text> / </xsl:text>
                                        <a href="{@href}"><xsl:value-of select="label"/></a>
                                    </xsl:for-each>
                                    <xsl:text> / </xsl:text>
                                    <span aria-current="page"><xsl:value-of select="$doc_title"/></span>
                                </nav>
                            </xsl:otherwise>
                        </xsl:choose>
                        <xsl:call-template name="titel">
                            <xsl:with-param name="text" select="$doc_title"/>
                            <xsl:with-param name="gross" select="$ist_start or $ist_uebersicht"/>
                        </xsl:call-template>
                        <!-- schmale Schirme: die Knöpfe der Randspalte stehen hier unter dem Titel -->
                        <xsl:if test="$pdf">
                            <p class="knopfzeile">
                                <a class="btn btn-primary" href="{$pdf/@target}">PDF laden</a>
                                <a class="btn btn-secondary" href="{$teiSource}">TEI/XML</a>
                            </p>
                        </xsl:if>

                        <div class="inhalt">
                            <xsl:apply-templates select=".//tei:body"/>
                        </div>

                        <xsl:if test="$ist_uebersicht">
                            <div class="kacheln">
                                <xsl:for-each select="$self/item">
                                    <xsl:variable name="n" select="count(item[@eintrag = 'true'])"/>
                                    <a href="{@href}">
                                        <xsl:if test="$n gt 0">
                                            <span class="label">
                                                <xsl:value-of select="concat($n, if ($n = 1) then ' Eintrag' else ' Einträge')"/>
                                            </span>
                                        </xsl:if>
                                        <span class="kachel-titel"><xsl:value-of select="label"/></span>
                                    </a>
                                </xsl:for-each>
                            </div>
                        </xsl:if>

                        <xsl:if test="$ist_start">
                            <xsl:variable name="baende" select="doc('../data/editions/kritische-schriften.xml')//tei:row[.//tei:graphic][.//tei:ref]"/>
                            <xsl:if test="$baende">
                                <h2 class="label">Kritische Schriften in Einzelausgaben</h2>
                                <div class="umschlaege">
                                    <xsl:for-each select="$baende">
                                        <a href="{replace((.//tei:ref)[1]/@target, '\.xml$', '.html')}">
                                            <img src="{(.//tei:graphic)[1]/@url}" loading="lazy"
                                                alt="Umschlag: {normalize-space((.//tei:ref)[1])}"/>
                                        </a>
                                    </xsl:for-each>
                                </div>
                            </xsl:if>
                        </xsl:if>

                        <!-- nur Noten im Text, nicht die note in sourceDesc/bibl -->
                        <xsl:if test=".//tei:body//tei:note[not(./tei:p)]">
                            <section class="fussnoten" aria-label="Anmerkungen">
                                <xsl:for-each select=".//tei:body//tei:note[not(./tei:p)]">
                                    <xsl:variable name="nr"><xsl:number level="any" format="1" count="tei:note"/></xsl:variable>
                                    <p id="fn{$nr}">
                                        <a href="#fna_{$nr}"><xsl:value-of select="$nr"/></a>
                                        <xsl:text> </xsl:text>
                                        <xsl:apply-templates/>
                                    </p>
                                </xsl:for-each>
                            </section>
                        </xsl:if>
                    </main>

                    <aside class="rail" aria-label="Zu dieser Seite">
                        <!-- Band der Kritischen Schriften: Umschlag, Angaben, PDF -->
                        <xsl:if test="$band">
                            <xsl:if test="$band//tei:graphic">
                                <figure class="rail-bild">
                                    <img src="{($band//tei:graphic)[1]/@url}" alt="Umschlag: {normalize-space(($band//tei:figDesc)[1])}"/>
                                </figure>
                            </xsl:if>
                            <div class="rail-block">
                                <h2 class="label">Band</h2>
                                <xsl:text>Kritische Schriften </xsl:text>
                                <xsl:value-of select="translate(normalize-space($band/tei:cell[1]), '[]', '')"/>
                                <br/>
                                <xsl:value-of select="normalize-space($band/tei:cell[last()])"/>
                            </div>
                        </xsl:if>
                        <xsl:if test="$pdf">
                            <a class="btn btn-primary btn-block" href="{$pdf/@target}">PDF laden</a>
                        </xsl:if>

                        <!-- Unterseiten des Bereichs -->
                        <xsl:if test="$bereich/item[@eintrag = 'false']">
                            <nav class="rail-block" aria-label="{$bereich/label}">
                                <h2 class="label"><xsl:value-of select="$bereich/label"/></h2>
                                <ul class="rail-liste">
                                    <xsl:for-each select="$bereich/item[@eintrag = 'false']">
                                        <li>
                                            <a href="{@href}">
                                                <xsl:choose>
                                                    <xsl:when test="@id = $doc_id"><xsl:attribute name="aria-current" select="'page'"/></xsl:when>
                                                    <xsl:when test=".//item[@id = $doc_id]"><xsl:attribute name="aria-current" select="'true'"/></xsl:when>
                                                </xsl:choose>
                                                <xsl:value-of select="label"/>
                                            </a>
                                        </li>
                                    </xsl:for-each>
                                </ul>
                            </nav>
                        </xsl:if>

                        <!-- Einträge einer Liste: blättern -->
                        <xsl:if test="$prev or $next">
                            <nav class="rail-block" aria-label="Blättern">
                                <h2 class="label">Blättern</h2>
                                <ul class="rail-liste">
                                    <xsl:if test="$prev">
                                        <li><a href="{$prev/@href}" rel="prev">← <xsl:value-of select="$prev/label"/></a></li>
                                    </xsl:if>
                                    <xsl:if test="$next">
                                        <li><a href="{$next/@href}" rel="next">→ <xsl:value-of select="$next/label"/></a></li>
                                    </xsl:if>
                                </ul>
                            </nav>
                        </xsl:if>

                        <xsl:if test="count($abschnitte) ge 2">
                            <nav class="rail-block" aria-label="Auf dieser Seite">
                                <h2 class="label">Auf dieser Seite</h2>
                                <ul class="rail-liste">
                                    <xsl:for-each select="$abschnitte">
                                        <li><a href="#{(@xml:id, concat('abschnitt-', count(preceding-sibling::tei:div[normalize-space(tei:head)]) + 1))[1]}"><xsl:value-of select="normalize-space(tei:head)"/></a></li>
                                    </xsl:for-each>
                                </ul>
                            </nav>
                        </xsl:if>

                        <xsl:call-template name="apparat">
                            <xsl:with-param name="pageId" select="$link"/>
                            <xsl:with-param name="titel" select="$doc_title"/>
                            <xsl:with-param name="teiSource" select="$teiSource"/>
                        </xsl:call-template>
                    </aside>
                </div>
                <xsl:call-template name="html_footer"/>
            </body>
        </html>
    </xsl:template>
</xsl:stylesheet>
