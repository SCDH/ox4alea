<?xml version="1.0" encoding="UTF-8"?>
<!-- generic XSLT library for basic text formatting

This is to be imported once into your main stylesheet if you want basic formatting
in the base text, the apparatus and in the editorial notes. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:import href="libi18n.xsl"/>

    <xsl:template mode="text apparatus-reading-text editorial-note" match="hi[@rend eq 'bold']">
        <b>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </b>
    </xsl:template>

    <xsl:template mode="text apparatus-reading-text editorial-note" match="hi[@rend eq 'italic']">
        <i>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </i>
    </xsl:template>

    <xsl:template mode="text apparatus-reading-text editorial-note" match="hi[@rend eq 'underline']">
        <u>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </u>
    </xsl:template>

    <xsl:template mode="text apparatus-reading-text editorial-note"
        match="hi[@rend eq 'superscript']">
        <sup>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </sup>
    </xsl:template>

    <xsl:template mode="text apparatus-reading-text editorial-note"
        match="title[@type eq 'lemma'] | q | quote">
        <xsl:variable name="content">
            <xsl:apply-templates mode="#current"/>
        </xsl:variable>
        <span>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:value-of select="concat('“', normalize-space($content), '”')"/>
        </span>
    </xsl:template>

    <xsl:template mode="text apparatus-reading-text editorial-note"
        match="seg[matches(@type, 'booktitle')] | title">
        <i>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </i>
    </xsl:template>

</xsl:stylesheet>
