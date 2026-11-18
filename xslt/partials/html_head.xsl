<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:include href="./params.xsl"/>
    <xsl:template name="html_head">
        <xsl:param name="html_title" select="$project_short_title"></xsl:param>
        <meta charset="utf-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <!-- Favicons und Web-App-Manifest in html/img/ -->
        <link rel="icon" href="img/favicon.ico" sizes="any" />
        <link rel="icon" type="image/png" sizes="32x32" href="img/favicon-32x32.png" />
        <link rel="icon" type="image/png" sizes="16x16" href="img/favicon-16x16.png" />
        <link rel="apple-touch-icon" sizes="180x180" href="img/apple-touch-icon.png" />
        <link rel="manifest" href="img/site.webmanifest" />
        <meta name="theme-color" content="#f3f2f2" />
        <title>
            <xsl:value-of select="$html_title"/>
            <xsl:if test="$html_title != $project_short_title"> – Hermann Bahr</xsl:if>
        </title>
        <meta name="description" content="{$project_title}" />
        <meta property="og:type" content="website" />
        <meta property="og:title" content="{$html_title}" />
        <meta property="og:description" content="{$project_title}" />
        <meta property="og:site_name" content="{$project_short_title}" />
        <meta property="og:image" content="{$base_url}img/bahr-logo.jpg" />
        <meta property="og:image:width" content="2200" />
        <meta property="og:image:height" content="1200" />
        <!-- Schriften liegen in html/fonts/, die wichtigsten zwei werden vorgeladen -->
        <link rel="preload" href="fonts/archivo-latin-wght-normal.woff2" as="font" type="font/woff2" crossorigin="anonymous"/>
        <link rel="preload" href="fonts/federo-latin-400-normal.woff2" as="font" type="font/woff2" crossorigin="anonymous"/>
        <link rel="stylesheet" href="css/style.css" type="text/css"/>
    </xsl:template>
</xsl:stylesheet>
