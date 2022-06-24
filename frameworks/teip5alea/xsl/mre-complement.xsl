<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for resetting the MRE:
    sets 'visible' to all recensions
    sets 'fading' and 'othertarget' to all recensions but the current one
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="3.0">

    <!-- xpath how to generate a list of the @xml:id's of all the recensions encoded in the current file -->
    <xsl:param name="recensions-xpath" as="xs:string">
        <xsl:text>//sourceDesc//listWit/@xml:id</xsl:text>
    </xsl:param>

    <xsl:param name="debug" select="true()"/>

    <xsl:variable name="recensions" as="xs:string*">
        <xsl:evaluate as="xs:string*" context-item="/" expand-text="true" xpath="$recensions-xpath"
        />
    </xsl:variable>

    <xsl:variable name="recensions-but-current" as="xs:string*">
        <xsl:if test="$debug">
            <xsl:message>
                <xsl:text>all recension found with XPath </xsl:text>
                <xsl:value-of select="$recensions-xpath"/>
                <xsl:text> : </xsl:text>
                <xsl:value-of select="string-join($recensions ! concat('#', .), ' ')"/>
            </xsl:message>
        </xsl:if>
        <xsl:variable name="current" as="xs:string*"
            select="tokenize(//appInfo/application[@ident eq 'oxmre']/ptr[@subtype eq 'current']/@target)"/>
        <xsl:sequence select="
                $recensions[let $recension := .
                return
                    some $c in $current
                        satisfies $c ne concat('#', $recension)]"/>
    </xsl:variable>

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="application[@ident eq 'oxmre']/ptr[@subtype eq 'visible']">
        <xsl:copy>
            <xsl:apply-templates select="@* except @target"/>
            <xsl:attribute name="target">
                <xsl:value-of select="string-join($recensions ! concat('#', .), ' ')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="
            application[@ident eq 'oxmre']/ptr[@subtype eq 'othertarget'] |
            application[@ident eq 'oxmre']/ptr[@subtype eq 'fading']">
        <xsl:copy>
            <xsl:apply-templates select="@* except @target"/>
            <xsl:attribute name="target">
                <xsl:value-of select="string-join($recensions-but-current ! concat('#', .), ' ')"/>
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
