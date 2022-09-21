<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:template match="/">
        <xsl:choose>
            <xsl:when test="descendant::idno[@type eq 'local-work-id']">
                <xsl:call-template name="update-idno"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="update-title"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="update-idno">
        <idno type="local-work-id">
            <xsl:value-of select="/TEI/@xml:id"/>
        </idno>
    </xsl:template>

    <xsl:template name="update-title">
        <title>
            <xsl:call-template name="update-idno"/>
            <xsl:copy-of select="//teiHeader/fileDesc/titleStmt/title/(* | text())"/>
        </title>
    </xsl:template>

</xsl:stylesheet>
