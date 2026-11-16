<?xml version="1.0" encoding="UTF-8"?>
<!-- Kopfzeile: Marke und Hauptmenü aus data/menu.xml (xslt/make_menu.xsl).
     Die Untermenüs sind <details>, sie funktionieren ohne JavaScript und mit der Tastatur;
     js/menu.js schließt sie nur zusätzlich bei Escape und Klick daneben.
     Auf schmalen Schirmen blendet der Knopf „Menü“ das Menü über #menue:target ein. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:template name="nav_bar">
        <!-- id des aktuellen Hauptmenüpunkts, 'search' für die Suche -->
        <xsl:param name="current" as="xs:string" select="''"/>
        <a class="skip" href="#main">Zum Inhalt springen</a>
        <header class="kopf">
            <a class="marke" href="index.html">
                <span class="marke-q" aria-hidden="true"><i></i><i></i><i></i></span>
                <xsl:text>Hermann Bahr</xsl:text>
            </a>
            <a class="btn btn-secondary menue-knopf" href="#menue">Menü</a>
            <nav id="menue" class="menue" aria-label="Hauptmenü">
                <a class="btn btn-secondary menue-zu" href="#">Menü schließen</a>
                <ul>
                    <xsl:for-each select="doc('../../data/menu.xml')/menus/menu[@name = 'main-menu']/item">
                        <xsl:variable name="sub" select="item[@eintrag = 'false']"/>
                        <li>
                            <xsl:choose>
                                <xsl:when test="$sub">
                                    <details name="menue">
                                        <summary>
                                            <xsl:if test="@id = $current"><xsl:attribute name="class" select="'aktuell'"/></xsl:if>
                                            <xsl:value-of select="label"/>
                                        </summary>
                                        <ul class="sub">
                                            <li><a class="ueber" href="{@href}"><xsl:value-of select="label"/> · Übersicht</a></li>
                                            <xsl:for-each select="$sub">
                                                <li><a href="{@href}"><xsl:value-of select="label"/></a></li>
                                            </xsl:for-each>
                                        </ul>
                                    </details>
                                </xsl:when>
                                <xsl:otherwise>
                                    <a href="{@href}">
                                        <xsl:if test="@id = $current"><xsl:attribute name="aria-current" select="'true'"/></xsl:if>
                                        <xsl:value-of select="label"/>
                                    </a>
                                </xsl:otherwise>
                            </xsl:choose>
                        </li>
                    </xsl:for-each>
                    <li>
                        <a href="search.html">
                            <xsl:if test="$current = 'search'"><xsl:attribute name="aria-current" select="'page'"/></xsl:if>
                            <xsl:text>Suche</xsl:text>
                        </a>
                    </li>
                </ul>
            </nav>
        </header>
    </xsl:template>
</xsl:stylesheet>
