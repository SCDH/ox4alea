<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT module for the preview: font rendering -->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs scdh" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:template mode="#all" match="hi[@rend eq 'bold']" priority="2">
        <b>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </b>
    </xsl:template>

    <xsl:template mode="#all" match="hi[@rend eq 'italic']" priority="2">
        <i>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </i>
    </xsl:template>

    <xsl:template mode="#all" match="hi[@rend eq 'underline']" priority="2">
        <span style="text-decoration: underline;">
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </span>
    </xsl:template>

    <xsl:template mode="#all" match="hi[@rend eq 'superscript']" priority="2">
        <sup>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </sup>
    </xsl:template>

    <xsl:template mode="#all" match="title[@type eq 'lemma'] | q | quote" priority="2">
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

    <xsl:template mode="#all" match="seg[matches(@type, 'booktitle')] | title">
        <i>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="#current"/>
        </i>
    </xsl:template>

</xsl:stylesheet>
