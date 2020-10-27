<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs scdh"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <!-- language of the user interface, i.e. static text e.g. in the apparatus -->
    <!--xsl:param name="ui-language" as="xs:string" select="''"/-->

    <xsl:variable name="translations" select="'translation.xml'"/>

    <xsl:function name="scdh:language">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" select="$context/ancestor-or-self::*/@xml:lang[1]"/>
        <xsl:value-of select="if (exists($lang)) then $lang else $default"/>
    </xsl:function>

    <xsl:function name="scdh:language">
        <xsl:param name="context" as="node()"/>
        <!-- TODO: replace 'ar' with 'en' after @xml:lang is provided throughout ALEA -->
        <xsl:value-of select="scdh:language($context, 'ar')"/>
    </xsl:function>

    <xsl:function name="scdh:language-direction">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" as="xs:string" select="scdh:language($context, $default)"/>
        <xsl:choose>
            <xsl:when test="$lang eq 'ar'"><xsl:value-of select="'rtl'"/></xsl:when>
            <xsl:when test="$lang eq 'he'"><xsl:value-of select="'rtl'"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="'ltr'"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="scdh:language-direction">
        <xsl:param name="context" as="node()"/>
        <!-- TODO: replace 'ar' with 'en' after @xml:lang is provided throughout ALEA -->
        <xsl:value-of select="scdh:language-direction($context, 'ar')"/>
    </xsl:function>

    <xsl:function name="scdh:language-align">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" as="xs:string" select="scdh:language($context, $default)"/>
        <xsl:choose>
            <xsl:when test="$lang eq 'ar'"><xsl:value-of select="'right'"/></xsl:when>
            <xsl:when test="$lang eq 'he'"><xsl:value-of select="'right'"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="'left'"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="scdh:language-align">
        <xsl:param name="context" as="node()"/>
        <!-- TODO: replace 'ar' with 'en' after @xml:lang is provided throughout ALEA -->
        <xsl:value-of select="scdh:language-align($context, 'ar')"/>
    </xsl:function>

    <xsl:function name="scdh:translate">
        <xsl:param name="language" as="xs:string"/>
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:value-of select="if (doc-available($translations))
            then (let $t:=doc($translations)/*:translation/*:key[@value eq $key]/val[@lang eq $language] return
            (if (exists($t)) then $t else $default))
            else $default"/>
    </xsl:function>

    <xsl:template name="direction-style">
        <style>
            body {
            direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
            font-family:"Arabic Typesetting";
            }
            .variants {
            direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
            }
            .comments {
            direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
            }
            td {
            text-align: <xsl:value-of select="scdh:language-align(TEI/text)"/>;
            justify-content: space-between;
            justify-self: stretch;
            }
            @font-face {
            font-family:"Arabic Typesetting";
            /*The location of the loaded TTF font must be relative to the CSS*/
            src:url("arabt100.ttf");
            }
        </style>
    </xsl:template>

</xsl:stylesheet>