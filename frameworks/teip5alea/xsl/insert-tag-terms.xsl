<?xml version="1.0" encoding="UTF-8"?>
<!-- append <term> elements from tags to the current element -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/xslt#"
    xmlns:oxy="http://www.oxygenxml.com/ns/author/xpath-extension-functions"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="#all" version="3.1">

    <xsl:import href="libref.xsl"/>

    <xsl:param name="default-language" as="xs:string" select="'en'"/>

    <xsl:template match="/">
        <xsl:apply-templates mode="to-current" select="oxy:current-element()"/>
    </xsl:template>

    <xsl:mode on-no-match="shallow-copy"/>

    <!-- replace <seg n="here"/> completely -->
    <xsl:template mode="to-current" match="seg[@n eq 'here' and normalize-space(.) eq '']">
        <xsl:call-template name="insert-terms"/>
    </xsl:template>

    <!-- append to all other kinds current elements -->
    <xsl:template mode="to-current" match="*">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="insert-terms"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="insert-terms">
        <xsl:context-item as="element()" use="required"/>
        <xsl:variable name="context" select="."/>
        <xsl:variable name="tags" select="(ancestor-or-self::*/@ana)[last()]"/>
        <xsl:variable name="language"
            select="($default-language, ancestor-or-self::*/@xml:lang)[last()]"/>
        <xsl:message>
            <xsl:text>context item </xsl:text>
            <xsl:value-of select="name(.)"/>
            <xsl:text> language </xsl:text>
            <xsl:value-of select="$language"/>
            <xsl:text> tags: </xsl:text>
            <xsl:value-of select="$tags"/>
        </xsl:message>
        <xsl:for-each select="tokenize($tags)">
            <xsl:variable name="tag" select="."/>
            <xsl:if test="position() gt 1">
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:variable name="term"
                select="scdh:dereference(scdh:process-reference(., $context), $context)/desc[@xml:lang eq $language]/term[1]"/>
            <xsl:copy select="$term">
                <xsl:apply-templates select="$term/@* except @sameAs"/>
                <xsl:attribute name="sameAs" select="$tag"/>
                <xsl:apply-templates select="node()"/>
            </xsl:copy>
        </xsl:for-each>
    </xsl:template>

</xsl:stylesheet>
