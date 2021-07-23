<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="documentSystemID" required="yes"/>

    <xsl:template name="start">
        <items>
            <!-- TODO/FIXME: does not get replaced when written in xml-catalog -->
            <xsl:apply-templates select="doc('../samples/biblio.xml')//body"/>
        </items>
    </xsl:template>

    <xsl:template match="bibl[@xml:id]">
        <item>
            <xsl:attribute name="value" select="concat('#', @xml:id)"/>
        </item>
    </xsl:template>

</xsl:stylesheet>
