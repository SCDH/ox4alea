<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.oxygenxml.com/ns/ccfilter/config"
    exclude-result-prefixes="xs" version="2.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="documentSystemID" required="yes"/>

    <xsl:param name="taxonomy_id" select="'object'" required="no"/>

    <xsl:template name="start">
        <items>
            <xsl:apply-templates
                select="doc($documentSystemID)//taxonomy[@xml:id eq $taxonomy_id]//category"/>
        </items>
    </xsl:template>

    <xsl:template match="category">
        <item>
            <xsl:attribute name="value" select="@xml:id"/>
        </item>
    </xsl:template>

</xsl:stylesheet>
