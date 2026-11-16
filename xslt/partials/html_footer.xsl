<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:template name="html_footer">
        <footer class="fuss">
            <!-- Footer-Menü der alten Website: Impressum und Datenschutz, Barrierefreiheit -->
            <xsl:for-each select="doc('../../data/menu.xml')/menus/menu[@name = 'footer']/item">
                <a href="{@href}"><xsl:value-of select="label"/></a>
            </xsl:for-each>
            <!-- „Kontakt“ war ein Drupal-Formular ohne Datei, jetzt mailto -->
            <a href="mailto:{$contact_email}">Kontakt</a>
            <span class="fuss-rechts">
                <xsl:if test="$DATAHASH">
                    <a href="{concat($data_repo, '/tree/', $DATAHASH)}">Daten (TEI)</a>
                </xsl:if>
                <a href="{$github_url}">GitHub</a>
            </span>
        </footer>
        <script src="js/menu.js" defer="defer"></script>
    </xsl:template>
</xsl:stylesheet>
