<?xml version="1.0" encoding="UTF-8"?>
<!-- This stylesheet produces a list of allowed values for the wit attribute 
     from the list of witnesses in the sourceDesc of the current TEI file -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.oxygenxml.com/ns/ccfilter/config"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>
    
    <xsl:param name="documentSystemID"/>
    
    <xsl:template name="start">
        <xsl:variable name="witnesses" select="doc($documentSystemID)//sourceDesc/listWit/witness" />
        <items>
            <xsl:apply-templates select="$witnesses"/>
        </items>
    </xsl:template>
    
    <xsl:template match="witness">
        <item>
            <xsl:attribute name="value" select="concat('#', @xml:id)"/>
        </item>
    </xsl:template>
 
</xsl:stylesheet>