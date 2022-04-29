<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for handling references of different types -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs scdh"
    version="3.0">

    <xsl:param name="debug" as="xs:boolean" select="false()"/>

    <xsl:function name="scdh:uri-schemes-regex" as="xs:string">
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="root" select="root($context)"/>
        <xsl:variable name="prefixes"
            select="concat('^(', string-join($root//prefixDef/@ident, '|'), ')')"/>
        <xsl:if test="$debug">
            <xsl:message>prefixes: <xsl:value-of select="$prefixes"/></xsl:message>
        </xsl:if>
        <xsl:value-of select="$prefixes"/>
    </xsl:function>

    <xsl:function name="scdh:get-reference" as="element()">
        <xsl:param name="uri" as="xs:string"/>
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="root" as="node()" select="root($context)"/>
        <xsl:choose>
            <xsl:when test="substring($uri, 0, 1) eq '#'">
                <!-- internal fragment -->
                <xsl:sequence select="$root//*[@xml:id eq substring($uri, 2)]"/>
            </xsl:when>
            <xsl:when test="matches($uri, scdh:uri-schemes-regex($context))">
                <!-- fragment referenced by local URI scheme -->
                <xsl:variable name="prefix" select="tokenize($uri, ':')[1]"/>
                <xsl:variable name="prefixDef" as="node()"
                    select="$root//prefixDef[@ident eq $prefix]"/>
                <xsl:variable name="link"
                    select="replace($uri, concat($prefix, ':'), $prefixDef/@replacementPattern)"/>
                <xsl:variable name="url" select="tokenize($link, '#')[1]"/>
                <xsl:variable name="fragment" select="tokenize($link, '#')[2]"/>
                <xsl:sequence select="
                        let $doc := doc($url)
                        return
                            if (exists($fragment)) then
                                $doc//*[@xml:id eq $fragment]
                            else
                                root($doc)"/>
            </xsl:when>
            <xsl:when test="matches($uri, '^(file|https?|ftps?):') and doc-available($uri)">
                <xsl:variable name="url" select="tokenize($uri, '#')[1]"/>
                <xsl:variable name="fragment" select="tokenize($uri, '#')[2]"/>
                <xsl:sequence select="
                        let $doc := doc($url)
                        return
                            if (exists($fragment)) then
                                $doc//*[@xml:id eq $fragment]
                            else
                                root($doc)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message>Broken reference <xsl:value-of select="$uri"/></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

</xsl:stylesheet>
