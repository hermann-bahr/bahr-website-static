<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="2.0">
    <xsl:template name="nav_bar">
        <a class="visually-hidden-focusable" href="#main">Zum Inhalt springen</a>
        <header>
            <nav aria-label="Primary" class="navbar navbar-expand-lg bg-body-tertiary">
                <div class="container-fluid">
                    <a class="navbar-brand" href="index.html">
                        <xsl:value-of select="$project_short_title"/>
                    </a>
                    <button class="navbar-toggler" type="button" data-bs-toggle="collapse" data-bs-target="#navbarSupportedContent" aria-controls="navbarSupportedContent" aria-expanded="false" aria-label="Toggle navigation">
                        <span class="navbar-toggler-icon"></span>
                    </button>
                    <div class="collapse navbar-collapse" id="navbarSupportedContent">
                        <ul class="navbar-nav me-auto mb-2 mb-lg-0">
                            <!-- Hauptmenü der alten Website, aus data/menu.xml (xslt/make_menu.xsl) -->
                            <xsl:for-each select="doc('../../data/menu.xml')/menus/menu[@name = 'main-menu']/item">
                                <xsl:variable name="sub" select="item[@eintrag = 'false']"/>
                                <xsl:choose>
                                    <xsl:when test="$sub">
                                        <li class="nav-item dropdown">
                                            <a class="nav-link dropdown-toggle" href="#" role="button" data-bs-toggle="dropdown" aria-expanded="false">
                                                <xsl:value-of select="label"/>
                                            </a>
                                            <ul class="dropdown-menu">
                                                <li><a class="dropdown-item" href="{@href}"><xsl:value-of select="label"/></a></li>
                                                <li><hr class="dropdown-divider"/></li>
                                                <xsl:for-each select="$sub">
                                                    <li><a class="dropdown-item" href="{@href}"><xsl:value-of select="label"/></a></li>
                                                </xsl:for-each>
                                            </ul>
                                        </li>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        <li class="nav-item"><a class="nav-link" href="{@href}"><xsl:value-of select="label"/></a></li>
                                    </xsl:otherwise>
                                </xsl:choose>
                            </xsl:for-each>
                            <!-- Suche erst einblenden, wenn es einen Typesense-Index gibt:
                            <li class="nav-item"><a title="Suche" class="nav-link" href="search.html">Suche</a></li> -->
                        </ul>
                    </div>
                </div>
            </nav>
        </header>
    </xsl:template>
</xsl:stylesheet>