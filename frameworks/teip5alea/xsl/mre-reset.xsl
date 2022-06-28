<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for resetting the MRE:
    Removes @target attributes of all pointers.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:oxy="http://www.oxygenxml.com/ns/author/xpath-extension-functions"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs oxy" version="3.0">

    <!-- xpath how to generate a list of the @xml:id's of all the recensions encoded in the current file -->
    <xsl:param name="recensions-xpath" as="xs:string">
        <xsl:text>//sourceDesc//listWit/@xml:id</xsl:text>
    </xsl:param>

    <xsl:param name="debug" select="true()"/>

    <xsl:variable name="recensions" as="xs:string*">
        <xsl:evaluate as="xs:string*" context-item="/" expand-text="true" xpath="$recensions-xpath"
        />
    </xsl:variable>

    <xsl:mode on-no-match="shallow-copy"/>

    <!-- This template is only applied in Oxygen's XSLTOperation where oxy:current-element() is present. -->
    <xsl:template match="/" use-when="function-available('oxy:current-element', 0)">
        <xsl:apply-templates select="//appInfo/application[@ident eq 'oxmre']"/>
    </xsl:template>

    <!-- remove @target attribute from all pointers in MRE -->
    <xsl:template match="application[@ident eq 'oxmre']/ptr[@type eq 'recension']">
        <xsl:copy>
            <xsl:apply-templates select="@* except @target"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
