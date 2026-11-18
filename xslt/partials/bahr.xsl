<?xml version="1.0" encoding="UTF-8"?>
<!-- Templates für die aus Drupal konvertierten TEI-Dateien von bahr-website-data.
     In editions.xsl als LETZTES xsl:import einbinden (höchste Import-Präzedenz). -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:bahr="http://bahr.univie.ac.at/ns"
    exclude-result-prefixes="#all">

    <!-- Menübaum, erzeugt von xslt/make_menu.xsl -->
    <xsl:variable name="menu" select="doc('../../data/menu.xml')"/>

    <!-- Autorzeile: Viele Seiten beginnen mit einer „Überschrift“, die nur den Namen der Verfasser
         nennt (in Drupal eine kursive Zwischenüberschrift). Sie ist kein Abschnitt: Sie wird als
         Zeile unter dem Titel gesetzt und fehlt in „Auf dieser Seite“ (editions.xsl).
         Erkannt wird die erste Überschrift der Seite, wenn sie ganz kursiv ist, nur aus den
         Namen der Projektmitarbeiter besteht oder wenn ihr Abschnitt sonst leer ist. -->
    <xsl:variable name="autor_namen" select="'Martin Anton Müller|Claus Pias|Gottfried Schnödl|Kurt Ifkovits'"/>
    <xsl:function name="bahr:autorzeile" as="xs:boolean">
        <xsl:param name="head" as="element(tei:head)?"/>
        <xsl:sequence select="exists($head)
            and exists($head/parent::tei:div/parent::tei:body)
            and empty($head/parent::tei:div/preceding-sibling::tei:div[normalize-space(tei:head)])
            and (
                (: ein „Abschnitt“ ohne Text, nur Namen als Überschrift :)
                not(normalize-space(string-join($head/parent::tei:div/(* except $head)//text(), '')))
                or (count($head/*) = 1 and $head/tei:hi[@rend = 'italic']
                    and not(normalize-space(string-join($head/text(), ''))))
                or matches(normalize-space($head),
                    concat('^(Herausgegeben von )?(', $autor_namen, ')((, | und | – )(', $autor_namen, '))*$'))
            )"/>
    </xsl:function>
    <xsl:template match="tei:div/tei:head[bahr:autorzeile(.)]" priority="1">
        <p class="autor"><xsl:value-of select="normalize-space(.)"/></p>
    </xsl:template>

    <!-- Abschnitte; @xml:id sind Sprungziele für target="datei.xml#id" -->
    <xsl:template match="tei:div">
        <div>
            <xsl:choose>
                <xsl:when test="@xml:id"><xsl:attribute name="id" select="@xml:id"/></xsl:when>
                <!-- Abschnitte der obersten Ebene ohne eigene id: Sprungziel für „Auf dieser Seite“ (editions.xsl) -->
                <xsl:when test="parent::tei:body and normalize-space(tei:head) and not(bahr:autorzeile(tei:head))">
                    <xsl:attribute name="id" select="concat('abschnitt-', count(preceding-sibling::tei:div[normalize-space(tei:head)]) + 1)"/>
                </xsl:when>
            </xsl:choose>
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
    <!-- das alte Impressum ist durch das ACDH-Impressum (imprint.html) ersetzt -->
    <xsl:template match="tei:ref[@target = 'impressum-und-datenschutz.xml']">
        <a class="ref {@type}" href="imprint.html">
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

    <!-- Literaturlisten (forschung__sekundaerliteratur.xml): listBibl je Jahr mit biblStruct.
         Die Zerlegung in biblStruct ist heuristisch und nicht verlustfrei; angezeigt wird deshalb
         das Originalzitat aus note[@type='original']. Aus der Struktur kommen Gliederung
         (Jahre, Gruppen, relatedItem), Sprungziele (@xml:id) und die Links (ref, idno[@type='DOI']). -->
    <xsl:template match="tei:listBibl[tei:biblStruct or tei:listBibl]">
        <dl class="literatur">
            <xsl:if test="normalize-space(tei:head)">
                <dt><xsl:apply-templates select="tei:head/node()"/></dt>
            </xsl:if>
            <dd>
                <ul><xsl:apply-templates select="tei:biblStruct | tei:listBibl"/></ul>
            </dd>
        </dl>
    </xsl:template>
    <!-- Gruppe innerhalb eines Jahres, etwa „Zum Tod“ -->
    <xsl:template match="tei:listBibl/tei:listBibl" priority="1">
        <li class="bibl-gruppe">
            <xsl:apply-templates select="tei:head/node()"/>
            <ul><xsl:apply-templates select="tei:biblStruct | tei:listBibl"/></ul>
        </li>
    </xsl:template>
    <xsl:template match="tei:biblStruct">
        <xsl:variable name="original" select="normalize-space(tei:note[@type = 'original'][1])"/>
        <!-- alles, was im Zitat zum Link wird; ein DOI kann dort als bloße Nummer oder als Adresse stehen -->
        <xsl:variable name="links" as="element()*">
            <xsl:for-each select="(tei:analytic | tei:monogr)/tei:idno[@type = 'DOI'][normalize-space()]">
                <xsl:variable name="doi" select="normalize-space()"/>
                <xsl:variable name="adresse" select="(for $p in ('https://doi.org/', 'http://doi.org/', 'https://dx.doi.org/', 'http://dx.doi.org/')
                    return concat($p, $doi))[contains($original, .)][1]"/>
                <a class="ref doi" href="https://doi.org/{$doi}"><xsl:value-of select="($adresse, $doi)[1]"/></a>
            </xsl:for-each>
            <xsl:for-each select="tei:ref[normalize-space()]">
                <a class="{normalize-space(concat('ref ', @type))}"
                   href="{replace(@target, '^([^/:#]+)\.xml(#|$)', '$1.html$2')}"><xsl:value-of select="normalize-space()"/></a>
            </xsl:for-each>
        </xsl:variable>
        <li class="{normalize-space(string-join(('bibl', @type, 'unvollstaendig'[current()/@status = 'incomplete']), ' '))}">
            <xsl:if test="@xml:id"><xsl:attribute name="id" select="@xml:id"/></xsl:if>
            <!-- „rosafarben“ laut Einleitung der Seite: Angaben unvollständig (style.css) -->
            <xsl:if test="@status = 'incomplete'"><xsl:attribute name="title" select="'Angaben unvollständig'"/></xsl:if>
            <xsl:choose>
                <xsl:when test="$original">
                    <xsl:call-template name="bibl_verlinken">
                        <xsl:with-param name="text" select="$original"/>
                        <xsl:with-param name="links" select="$links"/>
                    </xsl:call-template>
                    <!-- Links, deren Beschriftung im Zitat nicht vorkommt, anhängen -->
                    <xsl:for-each select="$links[not(contains($original, string(.)))]">
                        <xsl:text> [</xsl:text><xsl:copy-of select="."/><xsl:text>]</xsl:text>
                    </xsl:for-each>
                </xsl:when>
                <!-- kein Originalzitat: die Felder in Dokumentreihenfolge, besser als nichts -->
                <xsl:otherwise>
                    <xsl:value-of select="(tei:analytic | tei:monogr | tei:series | tei:note)/normalize-space()[.]" separator=". "/>
                    <xsl:for-each select="$links">
                        <xsl:text> [</xsl:text><xsl:copy-of select="."/><xsl:text>]</xsl:text>
                    </xsl:for-each>
                </xsl:otherwise>
            </xsl:choose>
            <!-- Beiträge eines Bandes, Rezensionen -->
            <xsl:if test="tei:relatedItem/tei:biblStruct">
                <ol><xsl:apply-templates select="tei:relatedItem/tei:biblStruct"/></ol>
            </xsl:if>
        </li>
    </xsl:template>
    <!-- Setzt die Links in den Zitattext ein: der letzte Link an die letzte Stelle, an der seine
         Beschriftung steht (sie stehen am Ende des Zitats; „Text“ o. ä. kann davor im Titel vorkommen),
         die übrigen Links davor und danach. -->
    <xsl:template name="bibl_verlinken">
        <xsl:param name="text" as="xs:string"/>
        <xsl:param name="links" as="element()*"/>
        <xsl:variable name="link" select="$links[last()]"/>
        <xsl:variable name="uebrige" select="$links[position() lt last()]"/>
        <xsl:choose>
            <xsl:when test="empty($link) or $text = ''">
                <xsl:value-of select="$text"/>
            </xsl:when>
            <xsl:when test="contains($text, string($link))">
                <xsl:variable name="teile" select="tokenize($text, replace(string($link), '[\\.\[\]{}()*+?^$|\-]', '\\$0'))"/>
                <xsl:call-template name="bibl_verlinken">
                    <xsl:with-param name="text" select="string-join($teile[position() lt last()], string($link))"/>
                    <xsl:with-param name="links" select="$uebrige"/>
                </xsl:call-template>
                <xsl:copy-of select="$link"/>
                <xsl:call-template name="bibl_verlinken">
                    <xsl:with-param name="text" select="$teile[last()]"/>
                    <xsl:with-param name="links" select="$uebrige"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="bibl_verlinken">
                    <xsl:with-param name="text" select="$text"/>
                    <xsl:with-param name="links" select="$uebrige"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- Tabellen (139 davon sind table[@type='bibliografie']) -->
    <xsl:template match="tei:table">
        <!-- der Rahmen lässt breite Tabellen auf schmalen Schirmen seitlich rollen -->
        <div class="tabelle">
            <table class="{normalize-space(concat('table ', @type))}">
                <xsl:apply-templates select="tei:head"/>
                <tbody><xsl:apply-templates select="tei:row"/></tbody>
            </table>
        </div>
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
        <blockquote><xsl:apply-templates/></blockquote>
    </xsl:template>

    <!-- Bilder: url="files/…" verweist auf html/files/… -->
    <xsl:template match="tei:figure">
        <figure>
            <xsl:apply-templates select="tei:graphic"/>
            <xsl:if test="tei:figDesc">
                <figcaption><xsl:apply-templates select="tei:figDesc/node()"/></figcaption>
            </xsl:if>
        </figure>
    </xsl:template>
    <xsl:template match="tei:graphic">
        <img src="{@url}" alt="{normalize-space(../tei:figDesc)}" loading="lazy"/>
    </xsl:template>

    <!-- Generierte Inhalte -->
    <xsl:template match="tei:divGen[@type = 'eintraege']">
        <xsl:variable name="id" select="ancestor::tei:TEI/@xml:id"/>
        <xsl:variable name="eintraege" select="$menu//item[@id = $id]/item[@eintrag = 'true']"/>
        <!-- „Titel (1924)“ oder „Titel [1896]“: die Klammer am Ende wird als Jahr rechts ausgerichtet -->
        <xsl:variable name="jahr" select="'^(.+?)\s*[\(\[]([^\(\)\[\]]*\d[^\(\)\[\]]*)[\)\]]$'"/>
        <div class="liste-kopf">
            <span><xsl:value-of select="count($eintraege)"/> Einträge</span>
            <xsl:if test="$eintraege[matches(normalize-space(label), $jahr)]"><span>Jahr</span></xsl:if>
        </div>
        <ul class="eintraege">
            <xsl:for-each select="$eintraege">
                <xsl:variable name="l" select="normalize-space(label)"/>
                <li>
                    <a href="{@href}">
                        <xsl:choose>
                            <xsl:when test="matches($l, $jahr)">
                                <span class="e-titel"><xsl:value-of select="replace($l, $jahr, '$1')"/></span>
                                <xsl:text> </xsl:text>
                                <span class="e-jahr"><xsl:value-of select="replace($l, $jahr, '$2')"/></span>
                            </xsl:when>
                            <xsl:otherwise><span class="e-titel"><xsl:value-of select="$l"/></span></xsl:otherwise>
                        </xsl:choose>
                    </a>
                </li>
            </xsl:for-each>
        </ul>
    </xsl:template>
    <!-- Bilder: Galerie mit dem ersten Bild jedes Eintrags statt einer Liste -->
    <xsl:template match="tei:divGen[@type = 'eintraege'][ancestor::tei:TEI/@xml:id = 'bilder']" priority="1">
        <div class="kacheln galerie">
            <xsl:for-each select="$menu//item[@id = 'bilder']/item[@eintrag = 'true']">
                <xsl:variable name="eintrag" select="doc(concat('../../data/editions/', @id, '.xml'))"/>
                <xsl:variable name="bild" select="($eintrag//tei:body//tei:graphic)[1]/@url"/>
                <a href="{@href}">
                    <xsl:if test="$bild">
                        <img src="{$bild}" alt="" loading="lazy"/>
                    </xsl:if>
                    <span class="kachel-titel"><xsl:value-of select="label"/></span>
                </a>
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
                    <input type="search" id="zl-q" class="input"
                        placeholder="Zeitleiste durchsuchen …" aria-label="Zeitleiste durchsuchen" autocomplete="off"/>
                    <select id="zl-jahr" class="input" aria-label="Zu einem Jahr springen">
                        <option value="">Jahr …</option>
                        <xsl:for-each select="distinct-values($jahre)">
                            <xsl:sort select="."/>
                            <option value="{.}"><xsl:value-of select="."/></option>
                        </xsl:for-each>
                    </select>
                    <span id="zl-anzahl" class="zl-anzahl" aria-live="polite">
                        <xsl:value-of select="count($events)"/> Einträge</span>
                    <button type="button" id="zl-reset" class="btn btn-ghost" hidden="hidden">Filter zurücksetzen</button>
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
