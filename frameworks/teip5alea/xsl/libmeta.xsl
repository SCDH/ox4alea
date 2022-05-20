<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT module of the preview: metadata -->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs scdh" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0" default-mode="metadata">

    <xsl:import href="libwit.xsl"/>

    <xsl:mode name="metadata" on-no-match="shallow-skip"/>

    <xsl:template match="/ | TEI | teiHeader" mode="metadata">
        <p>
            <xsl:apply-templates select="descendant-or-self::teiHeader/descendant::titleStmt/title"
                mode="metadata"/>
            <xsl:apply-templates select="descendant-or-self::teiHeader/descendant::witness"
                mode="metadata"/>
        </p>
    </xsl:template>

    <xsl:template match="titleStmt/title" mode="metadata">
        <span lang="de">
            <xsl:value-of select="normalize-space(.)"/>
            <xsl:text>: </xsl:text>
        </span>
    </xsl:template>

    <xsl:template match="witness" mode="metadata">
        <span>
            <!--xsl:value-of select="@xml:id"/-->
            <xsl:text>&lre;</xsl:text>
            <span class="siglum">
                <xsl:call-template name="witness-siglum-html">
                    <xsl:with-param name="wit" select="@xml:id"/>
                </xsl:call-template>
            </span>
            <xsl:text>&pdf;: </xsl:text>
            <xsl:value-of select="replace(@n, '^[a-zA-Z]+', '')"/>
        </span>
        <xsl:if test="position() ne last()">
            <span>; </span>
        </xsl:if>
    </xsl:template>

    <xsl:template match="text()" mode="metadata">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>