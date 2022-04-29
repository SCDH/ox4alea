<?xml version="1.0" encoding="UTF-8"?>
<!-- Bibliography -->
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
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs scdh"
    version="3.0">

    <xsl:import href="libi18n.xsl"/>
    <xsl:import href="libref.xsl"/>

    <!-- bibliographic reference that needs text pulled from the bibliography -->
    <xsl:template
        match="bibl[@corresp and normalize-space(string-join(child::node() except child::biblScope, '')) eq '']"
        mode="#all">
        <xsl:variable name="biblnode" select="."/>
        <xsl:variable name="autotext" as="xs:boolean"
            select="exists(parent::note[normalize-space(string-join((text() | *) except bibl, '')) eq ''])"/>
        <xsl:variable name="analogous" as="xs:boolean"
            select="exists(parent::note/parent::seg[matches(@type, '^analogous')])"/>
        <xsl:variable name="ref" as="element()" select="scdh:get-reference(@corresp, .)"/>
        <xsl:variable name="ref-lang" select="scdh:language($ref)"/>
        <span class="bibliographic-reference" lang="{scdh:language($ref)}"
            style="direction:{scdh:language-direction($ref)};">
            <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
            <xsl:value-of select="scdh:direction-embedding($ref)"/>
            <!-- [normalize-space((text()|*) except bibl) eq ''] -->
            <xsl:if test="$autotext and $analogous">
                <span class="static-text" data-i18n-key="Cf.">&lre;Cf.&pdf;</span>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$ref">
                    <xsl:apply-templates select="$ref" mode="biblio"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="@corresp"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="biblio"/>
            <xsl:if test="$autotext">
                <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:text>&pdf;</xsl:text>
            <xsl:call-template name="ltr-to-rtl-extra-space">
                <xsl:with-param name="first-direction" select="scdh:language-direction($ref)"/>
                <xsl:with-param name="then-direction" select="scdh:language-direction(.)"/>
            </xsl:call-template>
        </span>
    </xsl:template>

    <!-- bibliographic reference where reference text is already present -->
    <xsl:template
        match="bibl[@corresp and normalize-space(string-join(child::node() except child::biblScope, '')) ne '']"
        mode="#all">
        <xsl:variable name="biblnode" select="."/>
        <xsl:variable name="hasBiblText" as="xs:boolean"
            select="normalize-space(node() except biblScope) ne ''"/>
        <xsl:variable name="autotext" as="xs:boolean"
            select="exists(parent::note[normalize-space(string-join((text() | *) except bibl, '')) eq ''])"/>
        <xsl:variable name="analogous" as="xs:boolean"
            select="exists(parent::note/parent::seg[matches(@type, '^analogous')])"/>
        <span class="bibliographic-reference" lang="{scdh:language(.)}"
            style="direction:{scdh:language-direction(.)};">
            <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
            <xsl:value-of select="scdh:direction-embedding(.)"/>
            <!-- [normalize-space((text()|*) except bibl) eq ''] -->
            <xsl:if test="$autotext and $analogous">
                <span class="static-text" data-i18n-key="Cf.">&lre;Cf.&pdf;</span>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:apply-templates mode="biblio"/>
            <xsl:if test="$autotext">
                <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:text>&pdf;</xsl:text>
        </span>
    </xsl:template>

    <xsl:mode name="biblio" on-no-match="shallow-skip"/>

    <xsl:template match="choice[child::abbr and child::expan]" mode="biblio">
        <xsl:apply-templates select="abbr" mode="biblio"/>
    </xsl:template>

    <xsl:template match="am[parent::abbr/parent::choice[child::expan]]" mode="biblio"/>

    <!-- Exclude whitespace nodes from the bibliographic reference,
        because they break the interpunctation at the end.
        This may lead to unwanted effects with some bibliographies. -->
    <xsl:template match="text()[ancestor::listBibl and matches(., '^\s+$')]" mode="biblio"/>

    <xsl:template match="biblScope[@unit][@from and @to]" mode="biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"
                />&pdf;</span>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@from"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="@to"/>
        </span>
    </xsl:template>

    <xsl:template match="biblScope[@unit]" mode="biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"
                />&pdf;</span>
            <xsl:apply-templates mode="biblio"/>
        </span>
    </xsl:template>

    <xsl:template match="biblScope" mode="biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <xsl:apply-templates mode="biblio"/>
        </span>
    </xsl:template>

    <xsl:template match="text()" mode="biblio">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
