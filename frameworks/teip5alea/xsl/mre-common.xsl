<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for resetting the MRE:
This module contains components reused by other stylesheets.

    sets 'current' to the recension given in the variable 'recension-to-become-current' which must be calcalated
        by the importing stylesheet
    sets 'othertarget' ato all recension before the next one or to the first if we're currently at the last one
    sets 'visible' to all recensions
    sets 'fading' to all recensions but the next one

-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:oxy="http://www.oxygenxml.com/ns/author/xpath-extension-functions"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs oxy"
    version="3.0">

    <!-- this needs to be overwritten by the importing stylesheet -->
    <xsl:variable name="recension-to-become-current" as="xs:integer" select="1"/>

    <!-- xpath how to generate a list of the @xml:id's of all the recensions encoded in the current file -->
    <xsl:param name="recensions-xpath" as="xs:string">
        <xsl:text>//sourceDesc//listWit/@xml:id</xsl:text>
    </xsl:param>

    <xsl:param name="debug" select="false()"/>

    <xsl:variable name="recensions" as="xs:string*">
        <xsl:variable name="ids" as="xs:string*">
            <xsl:evaluate as="xs:string*" context-item="/" expand-text="true"
                xpath="$recensions-xpath"/>
        </xsl:variable>
        <xsl:if test="$debug">
            <xsl:message>
                <xsl:text>all recension found with XPath </xsl:text>
                <xsl:value-of select="$recensions-xpath"/>
                <xsl:text> : </xsl:text>
                <xsl:value-of select="string-join($ids ! concat('#', .), ' ')"/>
            </xsl:message>
        </xsl:if>
        <xsl:sequence select="$ids ! concat('#', .)"/>
    </xsl:variable>

    <xsl:variable name="current-index" as="xs:integer">
        <xsl:choose>
            <xsl:when
                test="//appInfo/application[@ident eq 'oxmre']/ptr[@subtype eq 'current']/@target">
                <xsl:variable name="current" as="xs:string"
                    select="tokenize(concat(//appInfo/application[@ident eq 'oxmre']/ptr[@subtype eq 'current']/@target, ' '))[1]"/>
                <xsl:sequence select="
                        sum($recensions ! (if (. eq $current) then
                            position()
                        else
                            0))"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="0"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <xsl:mode on-no-match="shallow-copy"/>

    <!-- This template is only applied in Oxygen's XSLTOperation where oxy:current-element() is present. -->
    <xsl:template match="/" use-when="function-available('oxy:current-element', 0)">
        <xsl:apply-templates select="//appInfo/application[@ident eq 'oxmre']"/>
    </xsl:template>

    <!-- all recension visible -->
    <xsl:template match="application[@ident eq 'oxmre']/ptr[@subtype eq 'visible']">
        <xsl:copy>
            <xsl:apply-templates select="@* except @target"/>
            <xsl:attribute name="target">
                <xsl:value-of select="string-join($recensions, ' ')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- set 'fading' to all recensions but the next one -->
    <xsl:template match="
            application[@ident eq 'oxmre']/ptr[@subtype eq 'fading']">
        <xsl:copy>
            <xsl:apply-templates select="@* except @target"/>
            <xsl:attribute name="target">
                <xsl:value-of
                    select="string-join($recensions[position() ne $recension-to-become-current], ' ')"
                />
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- set 'othertarget'/'done' to recensions before next -->
    <xsl:template match="
            application[@ident eq 'oxmre']/ptr[@subtype eq 'othertarget']">
        <xsl:copy>
            <xsl:apply-templates select="@* except @target"/>
            <!-- If next-index is 1, we don't put any @target -->
            <xsl:if test="$recension-to-become-current > 1">
                <xsl:attribute name="target">
                    <xsl:value-of
                        select="string-join($recensions[position() lt $recension-to-become-current], ' ')"
                    />
                </xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- set 'current' to next -->
    <xsl:template match="
            application[@ident eq 'oxmre']/ptr[@subtype eq 'current']">
        <xsl:copy>
            <xsl:apply-templates select="@* except @target"/>
            <xsl:attribute name="target">
                <xsl:value-of select="$recensions[$recension-to-become-current]"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
