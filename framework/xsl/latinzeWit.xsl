<?xml version="1.0" encoding="UTF-8"?>
<!-- This performs the identity transformation but replaces 
     literal Sigla by witness IDs from the witness catalogue. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="3.0">
    
    <xsl:mode on-no-match="shallow-copy"/>
    
    <xsl:output method="xml"/>
    
    <xsl:include href="libwit.xsl"/>
    
    <xsl:param name="pdu"/>
    <xsl:param name="witnessCat" select="'WitnessCatalogue.xml'"/>
   
    <xsl:template match="@wit">
        <xsl:attribute name="wit" select="scdh:get-witness-id($pdu, $witnessCat, .)"/>    
    </xsl:template>
    
</xsl:stylesheet>