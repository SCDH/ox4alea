<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA" xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs scdh xi"
    version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:param name="xpointer" as="xs:string" select="'encodingDesc'"/>

    <xsl:param name="uri" as="xs:string"
        select="'https://zivgitlab.uni-muenster.de/ALEA/Vocabulary.xml'"/>

    <xsl:param name="file-path" as="xs:string" select="$uri"/>

    <!-- insert new xinclude -->
    <xsl:template match="teiHeader[not(encodingDesc)]">
        <teiHeader>
            <xsl:apply-templates/>
            <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
                <xsl:attribute name="href" select="$uri"/>
                <xsl:attribute name="xpointer" select="$xpointer"/>
            </xsl:element>
        </teiHeader>
    </xsl:template>

    <!-- include is expanded, so replace encodingDesc with xinclude -->
    <xsl:template match="encodingDesc">
        <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
            <xsl:attribute name="href" select="$uri"/>
            <xsl:attribute name="xpointer" select="$xpointer"/>
        </xsl:element>
    </xsl:template>

    <!-- insert @met -->
    <xsl:template match="lg[head and not(@met)]">
        <xsl:variable name="head" as="xs:string" select="head"/>
        <lg>
            <xsl:attribute name="met"
                select="doc($file-path)/TEI/teiHeader/encodingDesc/metDecl/metSym[matches($head, concat('.*\[.*', descendant::term[1]/text(), '.*\].*'))]/@value"/>
            <xsl:apply-templates/>
        </lg>
    </xsl:template>

    <!-- delete verse meter from header text -->
    <xsl:template match="lg/head//text()">
        <xsl:variable name="met-pattern"
            select="concat('\[.*(', string-join(doc($file-path)/TEI/teiHeader/encodingDesc/metDecl/metSym//term[1], '|'), ').*\]')"/>
        <xsl:value-of select="normalize-space(replace(., $met-pattern, ''))"/>
    </xsl:template>

</xsl:stylesheet>
