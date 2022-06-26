<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">

    <xsl:output method="text" encoding="UTF-8"/>

    <!-- XPath to apply on the ID (siglum) of a recensions to get a the file name part from it -->
    <xsl:param name="siglum-fixum-xpath" as="xs:string">
        <xsl:text>replace(., '[a-z]', '')</xsl:text>
    </xsl:param>

    <xsl:template match="/">
        <xsl:text>recensions=</xsl:text>
        <xsl:for-each select="//sourceDesc//listWit/@xml:id">
            <xsl:value-of select="."/>
            <xsl:if test="position() ne last()">
                <xsl:text>,</xsl:text>
            </xsl:if>            
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
