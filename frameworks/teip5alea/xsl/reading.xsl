<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xi" version="3.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">

    <xsl:include href="insertXInclude.xsl"/>

    <xsl:param name="reading" as="xs:string" select="'lemma'"/>

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="/">
        <xsl:apply-templates/>
        <xsl:message>Extracting text from <xsl:value-of select="$reading"/>.</xsl:message>
    </xsl:template>

    <!-- drop listWit from source description -->
    <xsl:template match="sourceDesc/listWit">
        <p xml:lang="en">
            <xsl:text>Text from </xsl:text>
            <xsl:value-of select="base-uri()"/>
            <xsl:text>, witness </xsl:text>
            <xsl:value-of select="$reading"/>
        </p>
    </xsl:template>

    <!-- select reading depending on stylesheet parameter $reading -->
    <xsl:template
        match="
            lem[$reading eq 'lemma'] | *[@wit][some $w in tokenize(@wit) ! replace(., '#', '')
                satisfies $w eq $reading]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="lem | rdg"/>
    <xsl:template match="app">
        <!-- drop text nodes -->
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <!-- select the correction of a choice between orig and corr -->
    <xsl:template match="choice[corr and sic]">
        <xsl:apply-templates select="corr"/>
    </xsl:template>

    <!-- select the first one of unclear alternatives -->
    <xsl:template match="choice[unclear]">
        <xsl:apply-templates select="unclear[1]"/>
    </xsl:template>

    <!-- of all other choices: only select text -->
    <xsl:template match="choice">
        <xsl:value-of select="*/text()"/>
    </xsl:template>

    <!-- unwrap elements -->
    <xsl:template match="corr | sic | unclear | orig">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- drop notes -->
    <xsl:template match="note"/>

</xsl:stylesheet>
