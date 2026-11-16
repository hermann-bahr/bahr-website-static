<?xml version="1.0" encoding="UTF-8"?>
<!-- Erzeugt html/search-index.json für die Volltextsuche (html/js/search.js, FlexSearch).
     Ein Datensatz pro Seite aus data/editions und einer pro Ereignis der Zeitleiste
     (TEI-bahr-zeitleiste.xml), der auf den Eintrag in leben.html zeigt.

     Felder:  u = Adresse, t = Titel, x = Text, k = Art ("s" Seite, "z" Zeitleiste),
              p = Menüpfad (nur Seiten), d = Datum und c = Kategorie (nur Zeitleiste) -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:local="http://bahr.univie.ac.at/local"
    exclude-result-prefixes="#all">
    <xsl:output method="text" encoding="UTF-8"/>

    <xsl:variable name="docs" select="collection('../data/editions?select=*.xml')/tei:TEI"/>
    <xsl:variable name="monate" select="('Jänner', 'Februar', 'März', 'April', 'Mai', 'Juni', 'Juli',
        'August', 'September', 'Oktober', 'November', 'Dezember')"/>
    <!-- dieselben Bezeichnungen wie die Filterknöpfe der Zeitleiste (bahr.xsl, $zl_typen) -->
    <xsl:variable name="typen">
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

    <!-- JSON-Zeichenkette; nach normalize-space() bleiben nur \ und " zu maskieren -->
    <xsl:function name="local:json" as="xs:string">
        <xsl:param name="s" as="xs:string?"/>
        <xsl:sequence select="concat('&quot;',
            replace(replace(normalize-space($s), '\\', '\\\\'), '&quot;', '\\&quot;'), '&quot;')"/>
    </xsl:function>

    <!-- Text eines Elements; Blockgrenzen und Zeilenumbrüche werden zu Leerzeichen,
         damit Wörter benachbarter Absätze oder Tabellenzellen nicht verschmelzen -->
    <xsl:function name="local:text" as="xs:string">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:variable name="parts" as="xs:string*">
            <xsl:apply-templates select="$nodes" mode="text"/>
        </xsl:variable>
        <xsl:sequence select="normalize-space(string-join($parts, ''))"/>
    </xsl:function>
    <xsl:template match="text()" mode="text">
        <xsl:sequence select="string(.)"/>
    </xsl:template>
    <xsl:template match="tei:lb" mode="text">
        <xsl:sequence select="' '"/>
    </xsl:template>
    <xsl:template match="tei:p | tei:head | tei:cell | tei:row | tei:item | tei:label | tei:quote
        | tei:figDesc | tei:div | tei:note | tei:bibl | tei:desc" mode="text">
        <xsl:sequence select="' '"/>
        <xsl:apply-templates mode="text"/>
        <xsl:sequence select="' '"/>
    </xsl:template>

    <!-- "1891-03-02" -> "2. März 1891" -->
    <xsl:function name="local:datum" as="xs:string">
        <xsl:param name="iso" as="xs:string"/>
        <xsl:sequence select="concat(number(substring($iso, 9, 2)), '. ',
            $monate[number(substring($iso, 6, 2))], ' ', substring($iso, 1, 4))"/>
    </xsl:function>

    <xsl:template match="/">
        <xsl:variable name="records" as="xs:string*">
            <xsl:for-each select="$docs[not(.//tei:listEvent)][.//tei:body]">
                <xsl:sort select="@xml:id"/>
                <xsl:variable name="terms" select=".//tei:keywords[@scheme = 'menu']/tei:term"/>
                <xsl:sequence select="concat('{&quot;k&quot;:&quot;s&quot;,&quot;u&quot;:', local:json(concat(@xml:id, '.html')),
                    ',&quot;t&quot;:', local:json((.//tei:titleStmt/tei:title)[1]),
                    ',&quot;p&quot;:', local:json(string-join($terms[position() lt last()]/normalize-space(), ' › ')),
                    ',&quot;x&quot;:', local:json(local:text(.//tei:body)), '}')"/>
            </xsl:for-each>
            <xsl:for-each select="$docs//tei:listEvent/tei:event[@when or @from][@xml:id]">
                <xsl:sort select="string((@when, @from)[1])"/>
                <xsl:variable name="typ" select="string(@type)"/>
                <xsl:variable name="quelle" select="local:text(tei:note)"/>
                <xsl:sequence select="concat('{&quot;k&quot;:&quot;z&quot;,&quot;u&quot;:', local:json(concat('leben.html#', @xml:id)),
                    ',&quot;t&quot;:', local:json(tei:head),
                    ',&quot;d&quot;:', local:json(concat(local:datum(string((@when, @from)[1])),
                        if (@to) then concat(' – ', local:datum(string(@to))) else '')),
                    ',&quot;c&quot;:', local:json(string(($typen/typ[@key = $typ], $typ)[1])),
                    ',&quot;x&quot;:', local:json(concat(local:text(tei:p | tei:desc),
                        if ($quelle) then concat(' Quelle: ', $quelle) else '')), '}')"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:value-of select="concat('[', string-join($records, ',&#10;'), ']')"/>
    </xsl:template>
</xsl:stylesheet>
