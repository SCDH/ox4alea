<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.oxygenxml.com/ns/ccfilter/config"
    xmlns:tei="http://www.tei-c.org/ns/1.0"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs tei scdh"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output method="xml" indent="yes"/>
    
    <!-- project directory url -->
    <xsl:param name="documentSystemID"/>
    
    <!-- path to witness catalogue relative to project directory url -->
    <xsl:param name="witnessCatalogue" select="'WitnessCatalogue.xml'" as="xs:string"/>
    
    <xsl:template name="start">
        <xsl:variable name="witnessFile" select="scdh:locateFile($documentSystemID, $witnessCatalogue)"/>
        <xsl:variable name="witnesses"
            select="if (doc-available($witnessFile)) then (doc($witnessFile)/TEI/text//witness) else ()"/>
        <items>
            <xsl:apply-templates select="$witnesses"/>
            <!-- TODO: remove -->
            <item value="unkown"/>
        </items>
    </xsl:template>
    
    <xsl:template match="/">
        <items>
            <xsl:apply-templates select="/TEI/text//witness"/>
        </items>
    </xsl:template>
    
    <xsl:template match="witness">
        <item>
            <xsl:attribute name="value" select="@xml:id"/>
        </item>
    </xsl:template>
    
    <xsl:function name="scdh:locateFile">
        <xsl:param name="path"/>
        <xsl:param name="file"/>
        <xsl:value-of select="if ($path ='')
            then ($file)
            else (if (doc-available(concat($path, '/', $file)))
                then (concat($path, '/', $file))
                else (scdh:locateFile(substring($path, 1, string-length($path)-1), $file)))"/>
    </xsl:function>
    
</xsl:stylesheet>