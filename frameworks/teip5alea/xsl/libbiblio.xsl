<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs scdh"
    version="3.0">

    <xsl:import href="libi18n.xsl"/>

    <xsl:param name="biblio" as="xs:string" required="yes"/>

    <xsl:variable name="bibliography" select="doc($biblio)"/>

    <xsl:template match="bibl[@corresp]" mode="#all">
        <xsl:variable name="ref-id" as="xs:string" select="replace(@corresp, '^#', '')"/>
        <xsl:variable name="ref" select="$bibliography//bibliography[@xml:id eq $ref-id]"/>
        <xsl:variable name="ref-lang" select="scdh:language($ref)"/>
        <xsl:if test="not($ref)">
            <xsl:message>Bibliographic entry '<xsl:value-of select="$ref-id"/>' not found in '<xsl:value-of select="$biblio"/>'</xsl:message>
            (reference not found!)
        </xsl:if>
        <span class="bibliographic-reference"
            lang="scdh:language($ref)">
            <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
            <xsl:value-of select="scdh:direction-embedding(.)"/>
            <xsl:choose>
                <xsl:when test="$ref">
                    <xsl:apply-templates mode="biblio"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(@corresp, '#', '')"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="editorial-note"/>
            <xsl:text>&pdf;</xsl:text>
            <xsl:if test="scdh:language-direction(.) eq 'ltr'">
                <xsl:text> </xsl:text>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="biblScope[@unit][@from and @to]" mode="biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"/>&pdf;</span>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@from"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="@to"/>
        </span>
    </xsl:template>

    <xsl:template match="biblScope[@unit]" mode="biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"/>&pdf;</span>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="biblScope" mode="biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <xsl:apply-templates/>
        </span>
    </xsl:template>

</xsl:stylesheet>