<?xml version="1.0" encoding="UTF-8"?>
<!-- deal with annotated entities (persons, places)

This stylesheet uses 'tei-ld-out' as default mode which produces HTML5 output of the referenced entities.

However, the entry mode is 'tei-ld' for getting an entity from a link.
The link may use a private URI scheme defined in a <prefixDef>.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math scdh"
    version="3.0" default-mode="tei-ld-out">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:import href="libref.xsl"/>
    <xsl:import href="libi18n.xsl"/>

    <xsl:variable name="debug" select="true()"/>

    <!-- get the real link from an URI scheme defined in a <prefixDef> -->
    <xsl:template mode="tei-ld" match="*[@ref][matches(@ref, scdh:uri-schemes-regex(/))]">
        <xsl:variable name="docnode" select="."/>
        <xsl:variable name="ref" select="@ref"/>
        <xsl:variable name="prefix" select="tokenize($ref, ':')[1]"/>
        <xsl:variable name="prefixDef" select="//prefixDef[@ident eq $prefix]"/>
        <xsl:variable name="link"
            select="replace($ref, concat($prefix, ':'), $prefixDef/@replacementPattern)"/>
        <xsl:variable name="url" select="tokenize($link, '#')[1]"/>
        <xsl:variable name="fragment" select="tokenize($link, '#')[2]"/>
        <xsl:variable name="entity" select="doc($url)//*[@xml:id eq $fragment]"/>
        <xsl:if test="$debug">
            <xsl:message>
                <xsl:text>tei-ld: Getting entity from: </xsl:text>
                <xsl:value-of select="$link"/>
            </xsl:message>
        </xsl:if>
        <span>
            <!-- set the language in this container -->
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="$entity"/>
            </xsl:call-template>
            <!-- output the content -->
            <xsl:apply-templates select="$entity" mode="tei-ld-out"/>
        </span>
    </xsl:template>

    <xsl:template match="persName/*">
        <xsl:text> </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="birth">
        <xsl:text>, *</xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="death">
        <xsl:text>, gest. </xsl:text>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- do not output white-space nodes -->
    <xsl:template match="text()[matches(., '^\s+$')]"/>

</xsl:stylesheet>
