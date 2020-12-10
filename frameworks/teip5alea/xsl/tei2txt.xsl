<?xml version="1.0" encoding="UTF-8"?>
<!-- export to plain text. Notes and apparatus are not printed. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:alea="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:param name="witness" as="xs:string" select="'lemma'"/>

    <xsl:param name="caesura-mark" as="xs:string" select="'||'"/>

    <xsl:output method="text"/>

    <xsl:template match="/">
        <xsl:apply-templates select="*"/>
        <xsl:text>&#xa;</xsl:text>
    </xsl:template>

    <!-- do not output (whitespace) text nodes -->
    <xsl:template match="TEI|text|body|lg|head|title">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="teiHeader"/>

    <xsl:template match="lg[parent::lg]">
        <xsl:text>&#xa;</xsl:text>
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="l">
        <xsl:text>&#xa;</xsl:text>
        <xsl:variable name="verse">
            <xsl:apply-templates/>            
        </xsl:variable>
        <xsl:value-of select="normalize-space($verse)"/>
    </xsl:template>

    <xsl:template match="caesura">
        <xsl:text> </xsl:text>
        <xsl:value-of select="$caesura-mark"/>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="choose">
        <xsl:choose>
            <xsl:when test="child::corr">
                <xsl:apply-templates select="corr"/>
            </xsl:when>
            <xsl:when test="count(child::unclear) gt 1">
                <!-- TODO: evaluate more criteria than position -->
                <xsl:apply-templates select="unclear[1]"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="app[child::rdg[@wit eq $witness]]">
        <xsl:apply-templates select="rdg[@wit eq $witness]"/>
    </xsl:template>

    <xsl:template match="app">
        <xsl:apply-templates select="lem"/>
    </xsl:template>

    <xsl:template match="note"/>

    <xsl:template match="p">
        <xsl:text>&#xa;&#xa;</xsl:text>
        <xsl:variable name="content">
            <xsl:apply-templates/>    
        </xsl:variable>
        <xsl:value-of select="normalize-space($content)"/>
    </xsl:template>

</xsl:stylesheet>
