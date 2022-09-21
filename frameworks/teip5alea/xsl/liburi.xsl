<?xml version="1.0" encoding="UTF-8"?>
<!-- DEPRECATED: use libref.xsl instead!

Function for handling URIs locally defined with <prefixDef>.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="3.0">

    <xsl:param name="debug" as="xs:boolean" select="false()" required="false"/>

    <!-- expand a local URI -->
    <xsl:function name="scdh:expand-local-uri" as="xs:string">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="ident" as="xs:string" select="tokenize($uri, ':')[1]"/>
        <xsl:if test="$debug">
            <xsl:message>URI: <xsl:value-of select="$uri"/></xsl:message>
        </xsl:if>
        <xsl:variable name="prefixDef" as="node()"
            select="root($context)//teiHeader//prefixDef[@ident eq $ident]"/>
        <xsl:value-of select="replace($uri, concat($ident, ':'), $prefixDef/@replacementPattern)"/>
    </xsl:function>

    <!-- get the URL part of a URI following a local scheme -->
    <xsl:function name="scdh:local-uri-url" as="xs:string">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="(scdh:expand-local-uri($uri, $context) => tokenize('#'))[1]"/>
    </xsl:function>

    <!-- get the node referenced in a local URI -->
    <xsl:function name="scdh:local-uri-node" as="node()*">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="expanded" select="scdh:expand-local-uri($uri, $context)"/>
        <xsl:choose>
            <xsl:when test="matches($expanded, '#')">
                <xsl:variable name="url" select="tokenize($expanded, '#')[1]"/>
                <xsl:variable name="fragment" select="tokenize($expanded, '#')[2]"/>
                <xsl:if test="$debug">
                    <xsl:message>Getting fragment <xsl:value-of select="$fragment"/> from
                            <xsl:value-of select="$url"/></xsl:message>
                </xsl:if>
                <xsl:sequence select="doc($url)/descendant::*[@xml:id eq $fragment]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>What to do with this reference? <xsl:value-of select="$expanded"
                    /></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
