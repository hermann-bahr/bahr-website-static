<?xml version="1.0" encoding="UTF-8"?>
<!-- Bausteine des Seitenrasters (Gestaltung: design_handoff_bahr_website, Fassung 2a):
     Titel mit Ornament und die Apparat-Blöcke der Randspalte (Permalink, Quelle, Zitieren). -->
<xsl:stylesheet version="2.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all">

    <!-- h1 und darunter die Quadratreihe; $gross für Startseite und Übersichten (64px) -->
    <xsl:template name="titel">
        <xsl:param name="text"/>
        <xsl:param name="gross" as="xs:boolean" select="false()"/>
        <h1>
            <xsl:if test="$gross"><xsl:attribute name="class" select="'gross'"/></xsl:if>
            <xsl:value-of select="$text"/>
        </h1>
        <div class="ornament" aria-hidden="true"><i></i><i></i><i></i><i></i></div>
    </xsl:template>

    <!-- Randspalte: Permalink, Quelle, Zitieren -->
    <xsl:template name="apparat">
        <xsl:param name="pageId" as="xs:string"/>
        <xsl:param name="titel" as="xs:string"/>
        <xsl:param name="teiSource" as="xs:string" select="''"/>
        <xsl:variable name="url" select="concat($base_url, $pageId)"/>
        <div class="rail-block">
            <h2 class="label">Permalink</h2>
            <a class="permalink" href="{$url}"><xsl:value-of select="replace($url, '^https?://', '')"/></a>
        </div>
        <xsl:if test="$teiSource">
            <div class="rail-block">
                <h2 class="label">Quelle</h2>
                <a href="{$teiSource}">TEI/XML-Dokument</a>
            </div>
        </xsl:if>
        <div class="rail-block">
            <h2 class="label">Zitieren</h2>
            <p class="zitat">
                <xsl:value-of select="$titel"/>
                <xsl:text>. In: </xsl:text>
                <xsl:value-of select="$project_title"/>
                <xsl:text>. </xsl:text>
                <span class="permalink"><xsl:value-of select="$url"/></span>
            </p>
        </div>
    </xsl:template>
</xsl:stylesheet>
