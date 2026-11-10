<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="#all"
    version="2.0">
    <xsl:template name="html_footer">
        <footer class="py-3 bg-body-tertiary">
            <div class="text-center">
                <!-- Footer-Menü der alten Website: Impressum und Datenschutz, Barrierefreiheit -->
                <p class="mb-2">
                    <xsl:for-each select="doc('../../data/menu.xml')/menus/menu[@name = 'footer']/item">
                        <xsl:if test="position() &gt; 1"><xsl:text> | </xsl:text></xsl:if>
                        <a href="{@href}"><xsl:value-of select="label"/></a>
                    </xsl:for-each>
                    <!-- „Kontakt“ war ein Drupal-Formular ohne Datei, jetzt mailto -->
                    <xsl:text> | </xsl:text>
                    <a href="mailto:{$contact_email}">Kontakt</a>
                </p>
                <a href="{$github_url}">
                    <i aria-hidden="true" class="bi bi-github fs-2"></i>
                    <span class="visually-hidden">GitHub repo</span>
                </a>
                <xsl:if test="$DATAHASH">
                    <span class="fs-2"><xsl:text> | </xsl:text></span>
                    <a href="{$data_repo||'/tree/'||$DATAHASH}">
                        <i class="bi bi-filetype-xml fs-2"></i>
                        <span class="visually-hidden">GitHub data repo</span>
                    </a>
                </xsl:if>
            </div>
        </footer>
        <script src="vendor/jquery/jquery-3.7.1.min.js"></script>
        <script src="vendor/bootstrap-5.3.5-dist/js/bootstrap.bundle.min.js"></script>
        
    </xsl:template>
</xsl:stylesheet>