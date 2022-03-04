<?xml version="1.0" encoding="UTF-8"?>
<!--
Update the abbr by the abbr from the bibliography that is identified
by self::abbr/parent::bible/@corresp

To be used in XSLTOperation.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xmlns:oxy="http://www.oxygenxml.com/ns/author/xpath-extension-functions"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" version="3.0">

    <xsl:import href="liburi.xsl"/>

    <xsl:template match="/">
        <xsl:apply-templates select="oxy:current-element()/abbr"/>
    </xsl:template>

    <!-- replace the abbr by the abbr in the bibliography -->
    <xsl:template match="abbr[@type eq 'siglum']">
        <xsl:variable name="entry" select="ancestor::bibl[1]/@corresp"/>
        <xsl:apply-templates mode="tei2tei-biblio"
            select="scdh:local-uri-node($entry, /)//abbr[@type eq 'siglum']"/>
    </xsl:template>

    <xsl:mode name="tei2tei-biblio" on-no-match="shallow-copy"/>

    <xsl:template mode="tei2tei-biblio" match="am"/>

</xsl:stylesheet>
