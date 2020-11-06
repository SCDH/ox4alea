<?xml version="1.0" encoding="UTF-8"?>
<!-- This generates a JSON translation file.
    USAGE: saxon -xsl:listI18nKeys.xsl -it:main docs:SOME_XSL.xsl
    -->
 <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    version="2.0">
     
     <xsl:output method="text"/>

    <xsl:param name="docs" as="xs:string" select="'preview.xsl'" required="no"/>

    <xsl:variable name="parsed" select="for $d in tokenize($docs, '\s+') return doc($d)"/>

    <xsl:template name="main">
        <!--xsl:variable name="parsed" select="doc($docs)"/-->
        <xsl:text>{&#x0a;</xsl:text>
        <xsl:for-each select="sort(distinct-values($parsed//@data-i18n-key))">
            <xsl:variable name="key" select="."/>
            <xsl:text>    "</xsl:text>
            <xsl:value-of select="$key"/>
            <xsl:text>": "</xsl:text>
            <xsl:value-of select="$parsed//*[@data-i18n-key eq $key][1]"/>
            <xsl:text>"</xsl:text>
            <xsl:if test="position() ne last()">
                <xsl:text>,</xsl:text>
            </xsl:if>
            <xsl:text>&#x0a;</xsl:text>
        </xsl:for-each>
        <xsl:text>}&#x0a;</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>