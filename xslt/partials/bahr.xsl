<?xml version="1.0" encoding="UTF-8"?>
<!-- Templates für die aus Drupal konvertierten TEI-Dateien von bahr-website-data.
     In editions.xsl als LETZTES xsl:import einbinden (höchste Import-Präzedenz). -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">

    <!-- Menübaum, erzeugt von xslt/make_menu.xsl -->
    <xsl:variable name="menu" select="doc('../../data/menu.xml')"/>

    <!-- Abschnitte; @xml:id sind Sprungziele für target="datei.xml#id" -->
    <xsl:template match="tei:div">
        <div>
            <xsl:if test="@xml:id"><xsl:attribute name="id" select="@xml:id"/></xsl:if>
            <xsl:apply-templates/>
        </div>
    </xsl:template>
    <xsl:template match="tei:div/tei:head">
        <xsl:element name="h{min((count(ancestor::tei:div) + 1, 6))}">
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>
    <xsl:template match="tei:p[not(node())]"/>

    <!-- Hervorhebungen: die Daten verwenden @rend, nicht @rendition -->
    <xsl:template match="tei:hi[@rend]">
        <xsl:choose>
            <xsl:when test="@rend = 'italic'"><em><xsl:apply-templates/></em></xsl:when>
            <xsl:when test="@rend = 'bold'"><strong><xsl:apply-templates/></strong></xsl:when>
            <xsl:when test="@rend = 'small'"><small><xsl:apply-templates/></small></xsl:when>
            <xsl:when test="@rend = 'superscript'"><sup><xsl:apply-templates/></sup></xsl:when>
            <xsl:when test="@rend = 'subscript'"><sub><xsl:apply-templates/></sub></xsl:when>
            <xsl:when test="@rend = 'underline'"><u><xsl:apply-templates/></u></xsl:when>
            <xsl:when test="@rend = 'strikethrough'"><s><xsl:apply-templates/></s></xsl:when>
            <xsl:when test="@rend = 'code'"><code><xsl:apply-templates/></code></xsl:when>
            <!-- h3/h4: Zwischenüberschriften, die im Original in Absätzen/Listen standen -->
            <xsl:otherwise><span class="hi-{@rend}"><xsl:apply-templates/></span></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Links: interne Ziele "datei.xml" bzw. "datei.xml#id" auf .html umbiegen -->
    <xsl:template match="tei:ref">
        <a class="ref {@type}"
           href="{replace(@target, '^([^/:#]+)\.xml(#|$)', '$1.html$2')}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
    <!-- Drupal-Kontaktformular gibt es nicht mehr -->
    <xsl:template match="tei:ref[@type = 'kontaktformular']">
        <a class="ref kontaktformular" href="mailto:{$contact_email}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>

    <!-- Listen -->
    <xsl:template match="tei:list">
        <ul><xsl:apply-templates/></ul>
    </xsl:template>
    <xsl:template match="tei:list[@rend = 'numbered']">
        <ol><xsl:apply-templates/></ol>
    </xsl:template>
    <xsl:template match="tei:item">
        <li>
            <xsl:if test="@xml:id"><xsl:attribute name="id" select="@xml:id"/></xsl:if>
            <xsl:apply-templates/>
        </li>
    </xsl:template>
    <xsl:template match="tei:list[@type = 'gloss']">
        <dl><xsl:apply-templates/></dl>
    </xsl:template>
    <xsl:template match="tei:list[@type = 'gloss']/tei:label">
        <dt><xsl:apply-templates/></dt>
    </xsl:template>
    <xsl:template match="tei:list[@type = 'gloss']/tei:item">
        <dd><xsl:apply-templates/></dd>
    </xsl:template>

    <!-- Tabellen (139 davon sind table[@type='bibliografie']) -->
    <xsl:template match="tei:table">
        <table class="table table-sm {@type}">
            <xsl:apply-templates select="tei:head"/>
            <tbody><xsl:apply-templates select="tei:row"/></tbody>
        </table>
    </xsl:template>
    <xsl:template match="tei:table/tei:head">
        <caption><xsl:apply-templates/></caption>
    </xsl:template>
    <xsl:template match="tei:row">
        <tr><xsl:apply-templates/></tr>
    </xsl:template>
    <xsl:template match="tei:cell">
        <xsl:element name="{if (@role = 'label') then 'th' else 'td'}">
            <xsl:if test="@cols"><xsl:attribute name="colspan" select="@cols"/></xsl:if>
            <xsl:if test="@rows"><xsl:attribute name="rowspan" select="@rows"/></xsl:if>
            <xsl:apply-templates/>
        </xsl:element>
    </xsl:template>

    <!-- Blockzitate (aus HTML-blockquote) -->
    <xsl:template match="tei:quote">
        <blockquote class="blockquote"><xsl:apply-templates/></blockquote>
    </xsl:template>

    <!-- Bilder: url="files/…" verweist auf html/files/… -->
    <xsl:template match="tei:figure">
        <figure class="figure d-block">
            <xsl:apply-templates select="tei:graphic"/>
            <xsl:if test="tei:figDesc">
                <figcaption class="figure-caption"><xsl:apply-templates select="tei:figDesc/node()"/></figcaption>
            </xsl:if>
        </figure>
    </xsl:template>
    <xsl:template match="tei:graphic">
        <img src="{@url}" alt="{normalize-space(../tei:figDesc)}" class="img-fluid" loading="lazy"/>
    </xsl:template>

    <!-- Generierte Inhalte -->
    <xsl:template match="tei:divGen[@type = 'eintraege']">
        <xsl:variable name="id" select="ancestor::tei:TEI/@xml:id"/>
        <ul class="eintraege">
            <xsl:for-each select="$menu//item[@id = $id]/item[@eintrag = 'true']">
                <li><a href="{@href}"><xsl:value-of select="label"/></a></li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <!-- Bilder: Galerie mit dem ersten Bild jedes Eintrags statt einer Liste -->
    <xsl:template match="tei:divGen[@type = 'eintraege'][ancestor::tei:TEI/@xml:id = 'bilder']" priority="1">
        <div class="galerie row row-cols-2 row-cols-sm-3 row-cols-lg-4 g-3 my-3">
            <xsl:for-each select="$menu//item[@id = 'bilder']/item[@eintrag = 'true']">
                <xsl:variable name="eintrag" select="doc(concat('../../data/editions/', @id, '.xml'))"/>
                <xsl:variable name="bild" select="($eintrag//tei:body//tei:graphic)[1]/@url"/>
                <div class="col">
                    <a href="{@href}" class="card h-100 text-decoration-none">
                        <xsl:if test="$bild">
                            <img src="{$bild}" alt="" class="card-img-top" loading="lazy"/>
                        </xsl:if>
                        <span class="card-body small"><xsl:value-of select="label"/></span>
                    </a>
                </div>
            </xsl:for-each>
        </div>
    </xsl:template>
    <!-- ============ Zeitleiste (leben.html) ============
         Daten: data/editions/TEI-bahr-zeitleiste.xml (listEvent/event mit @when oder @from/@to).
         Die Ereignisse werden statisch nach Jahren gruppiert ausgegeben; Filter, Suche und
         Sprungnavigation ergänzt html/js/zeitleiste.js. -->
    <xsl:variable name="zl_file" select="'../../data/editions/TEI-bahr-zeitleiste.xml'"/>
    <xsl:variable name="zl_monate" select="('Jänner', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli',
        'August', 'September', 'Oktober', 'November', 'Dezember')"/>
    <!-- Kategorien (event/@type) in der Reihenfolge der Filterknöpfe -->
    <xsl:variable name="zl_typen">
        <typ key="Ereignis">Ereignisse</typ>
        <typ key="Person">Personen</typ>
        <typ key="Orte">Orte</typ>
        <typ key="Vortrag">Vorträge</typ>
        <typ key="Journalismus">Journalismus</typ>
        <typ key="Theater">Theater</typ>
        <typ key="KritischeSchriften">Kritische Schriften</typ>
        <typ key="LiterarischeProsa">Literarische Prosa</typ>
        <typ key="Theaterschriften">Schriften zum Theater</typ>
        <typ key="Tagebuecher">Tagebücher</typ>
    </xsl:variable>

    <!-- "1891-03-02" -> "2. März", mit $jahr = true() -> "2. März 1891" -->
    <xsl:template name="zl_datum">
        <xsl:param name="iso" as="xs:string"/>
        <xsl:param name="jahr" as="xs:boolean" select="false()"/>
        <xsl:value-of select="concat(number(substring($iso, 9, 2)), '. ',
            $zl_monate[number(substring($iso, 6, 2))],
            if ($jahr) then concat(' ', substring($iso, 1, 4)) else '')"/>
    </xsl:template>

    <xsl:template match="tei:divGen[@type = 'zeitleiste']">
        <xsl:choose>
            <xsl:when test="doc-available($zl_file)">
                <xsl:call-template name="zeitleiste">
                    <xsl:with-param name="events" select="doc($zl_file)//tei:listEvent/tei:event[@when or @from]"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <p><a href="https://github.com/martinantonmueller/bahr-zeitleiste">Zeitleiste (TEI-Daten auf GitHub)</a></p>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="zeitleiste">
        <xsl:param name="events"/>
        <xsl:variable name="jahre" select="for $e in $events return xs:integer(substring(($e/@when, $e/@from)[1], 1, 4))"/>
        <xsl:variable name="min" select="min($jahre)"/>
        <xsl:variable name="max" select="max($jahre)"/>
        <xsl:variable name="hoch" select="max(for $j in distinct-values($jahre) return count($jahre[. = $j]))"/>
        <div class="zl" id="zeitleiste" data-total="{count($events)}">
            <div class="zl-bar">
                <div class="zl-controls">
                    <input type="search" id="zl-q" class="form-control form-control-sm"
                        placeholder="Zeitleiste durchsuchen …" aria-label="Zeitleiste durchsuchen" autocomplete="off"/>
                    <select id="zl-jahr" class="form-select form-select-sm" aria-label="Zu einem Jahr springen">
                        <option value="">Jahr …</option>
                        <xsl:for-each select="distinct-values($jahre)">
                            <xsl:sort select="."/>
                            <option value="{.}"><xsl:value-of select="."/></option>
                        </xsl:for-each>
                    </select>
                    <span id="zl-anzahl" class="zl-anzahl" aria-live="polite">
                        <xsl:value-of select="count($events)"/> Einträge</span>
                    <button type="button" id="zl-reset" class="btn btn-sm btn-link" hidden="hidden">Filter zurücksetzen</button>
                </div>
                <!-- Sprungleiste: ein Balken pro Jahr, Höhe = Zahl der Einträge -->
                <nav class="zl-hist" aria-label="Sprung zu einem Jahr" style="--zl-cols: {$max - $min + 1}">
                    <div class="zl-balken">
                        <xsl:for-each select="$min to $max">
                            <xsl:variable name="j" select="."/>
                            <xsl:variable name="n" select="count($jahre[. = $j])"/>
                            <xsl:choose>
                                <xsl:when test="$n gt 0">
                                    <a href="#jahr-{$j}" data-jahr="{$j}" data-n="{$n}"
                                        title="{$j}: {$n} {if ($n = 1) then 'Eintrag' else 'Einträge'}"
                                        style="--h: {format-number(100 * $n div $hoch, '0.#')}%">
                                        <span class="visually-hidden"><xsl:value-of select="$j"/></span>
                                    </a>
                                </xsl:when>
                                <xsl:otherwise><span data-jahr="{$j}"/></xsl:otherwise>
                            </xsl:choose>
                        </xsl:for-each>
                    </div>
                    <div class="zl-dekaden">
                        <xsl:for-each select="$min to $max">
                            <xsl:if test=". mod 10 = 0">
                                <xsl:variable name="d" select="."/>
                                <!-- erstes Jahr des Jahrzehnts, zu dem es Einträge gibt -->
                                <a href="#jahr-{min($jahre[. ge $d])}" data-jahr="{$d}"
                                    style="grid-column: {$d - $min + 1} / span {min((10, $max - $d + 1))}">
                                    <xsl:value-of select="$d"/>
                                </a>
                            </xsl:if>
                        </xsl:for-each>
                    </div>
                </nav>
                <div class="zl-typen" role="group" aria-label="Nach Kategorie filtern">
                    <xsl:for-each select="$zl_typen/typ">
                        <xsl:variable name="key" select="@key"/>
                        <xsl:if test="$events[@type = $key]">
                            <button type="button" class="zl-chip" data-typ="{$key}" aria-pressed="false">
                                <xsl:value-of select="."/>
                                <xsl:text> </xsl:text>
                                <span class="zl-n"><xsl:value-of select="count($events[@type = $key])"/></span>
                            </button>
                        </xsl:if>
                    </xsl:for-each>
                </div>
            </div>
            <p class="zl-hinweis">Die Datumsangaben am Rand dienen der Einordnung. Bei ungefähr datierten
                Ereignissen ist die Angabe im Text maßgeblich. Die Daten stehen als
                <a href="TEI-bahr-zeitleiste.xml">TEI-Datei</a> zur Verfügung.</p>
            <p id="zl-leer" class="zl-leer" hidden="hidden">Keine Einträge für diese Auswahl.</p>
            <xsl:for-each-group select="$events" group-by="substring((@when, @from)[1], 1, 4)">
                <xsl:sort select="current-grouping-key()"/>
                <section class="zl-jahr" id="jahr-{current-grouping-key()}" data-jahr="{current-grouping-key()}">
                    <h2><xsl:value-of select="current-grouping-key()"/></h2>
                    <xsl:for-each select="current-group()">
                        <xsl:sort select="string((@when, @from)[1])"/>
                        <xsl:sort select="string(@to)"/>
                        <xsl:apply-templates select="." mode="zl"/>
                    </xsl:for-each>
                </section>
            </xsl:for-each-group>
            <script src="js/zeitleiste.js" defer="defer"/>
        </div>
    </xsl:template>

    <xsl:template match="tei:event" mode="zl">
        <xsl:variable name="start" select="string((@when, @from)[1])"/>
        <xsl:variable name="typ" select="string(@type)"/>
        <article class="zl-event" id="{@xml:id}" data-typ="{$typ}">
            <div class="zl-datum">
                <time datetime="{$start}">
                    <xsl:call-template name="zl_datum">
                        <xsl:with-param name="iso" select="$start"/>
                        <!-- bei Zeiträumen über den Jahreswechsel das Jahr mitnennen -->
                        <xsl:with-param name="jahr" select="exists(@to) and substring(@to, 1, 4) ne substring($start, 1, 4)"/>
                    </xsl:call-template>
                </time>
                <xsl:if test="@to">
                    <xsl:text> – </xsl:text>
                    <time datetime="{@to}">
                        <xsl:call-template name="zl_datum">
                            <xsl:with-param name="iso" select="string(@to)"/>
                            <xsl:with-param name="jahr" select="substring(@to, 1, 4) ne substring($start, 1, 4)"/>
                        </xsl:call-template>
                    </time>
                </xsl:if>
            </div>
            <div class="zl-inhalt">
                <h3>
                    <a href="#{@xml:id}"><xsl:value-of select="normalize-space(tei:head)"/></a>
                    <xsl:text> </xsl:text>
                    <span class="zl-typ"><xsl:value-of select="($zl_typen/typ[@key = $typ], $typ)[1]"/></span>
                </h3>
                <xsl:apply-templates select="tei:p | tei:desc" mode="zl"/>
                <xsl:if test="normalize-space(tei:note)">
                    <p class="zl-quelle">
                        <span class="zl-quelle-label">Quelle: </span>
                        <xsl:value-of select="normalize-space(tei:note)"/>
                    </p>
                </xsl:if>
            </div>
        </article>
    </xsl:template>
    <xsl:template match="tei:desc" mode="zl">
        <xsl:apply-templates mode="zl"/>
    </xsl:template>
    <xsl:template match="tei:p[not(normalize-space())]" mode="zl" priority="2"/>
    <!-- Absätze, die ein Zitat enthalten, dürfen in HTML kein p sein (blockquote in p) -->
    <xsl:template match="tei:p[tei:quote]" mode="zl">
        <div class="zl-absatz"><xsl:apply-templates mode="zl"/></div>
    </xsl:template>
    <xsl:template match="tei:p" mode="zl">
        <p><xsl:apply-templates mode="zl"/></p>
    </xsl:template>
    <xsl:template match="tei:quote" mode="zl">
        <blockquote><xsl:apply-templates mode="zl"/></blockquote>
    </xsl:template>
    <xsl:template match="tei:lb" mode="zl">
        <br/>
    </xsl:template>
    <!-- Zeilenumbruch am Absatz- oder Zitatende ist nur ein Rest der Konvertierung -->
    <xsl:template match="tei:lb[not(following-sibling::node()[normalize-space()])]" mode="zl" priority="2"/>

    <!-- Links auf Ereignisse der alten Zeitleiste (…/node/27934) zeigen auf den Eintrag in leben.html -->
    <xsl:template match="tei:ref[@type = 'zeitleiste'][matches(@target, '/node/\d+$')]" priority="1">
        <a class="ref" href="leben.html#node{replace(@target, '^.*/node/', '')}">
            <xsl:apply-templates/>
        </a>
    </xsl:template>
</xsl:stylesheet>
