<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.oxygenxml.com/ns/ccfilter/config"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="2.0">

    <xsl:output method="xml" indent="yes"/>

    <xsl:param name="documentSystemID" required="yes"/>

    <xsl:template name="start">
        <items>
            <!-- Note: ../../teip5alea/... is for uniform rewriting through an XML catalog -->
            <xsl:apply-templates select="doc('../../teip5alea/samples/biblio.xml')//body"/>
        </items>
    </xsl:template>

    <xsl:template match="bibl[@xml:id] | biblStruct[@xml:id]">
        <item>
            <xsl:attribute name="value" select="concat('#', @xml:id)"/>
        </item>
    </xsl:template>

</xsl:stylesheet>
