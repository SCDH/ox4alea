<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT module of the preview: apparatus and commentary -->
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
    xmlns:scdhx="http://scdh.wwu.de/xslt#" exclude-result-prefixes="xs scdh scdhx"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:include href="libi18n.xsl"/>
    <xsl:include href="libcommon.xsl"/>
    <xsl:import href="libbetween.xsl"/>
    <xsl:import href="libld.xsl"/>
    <xsl:import href="libbiblio.xsl"/>


    <!-- Notes / Comments -->

    <xsl:template name="line-referencing-comments">
        <table>
            <!-- add the following to get anchor-based things to comments:
                            | TEI/text//anchor[exists(let $id := @xml:id return //span[@from eq concat('#', $id)])] -->
            <xsl:apply-templates select="/TEI/text//note" mode="editorial-note-entry"/>
        </table>
    </xsl:template>


    <!-- # Mode editorial-note -->
    <!-- This mode is used for the content of all kinds of editorial notes, be in <note>, be in <witDetail> -->

    <!-- the entry point for an editorial note -->
    <xsl:template match="note" mode="editorial-note-entry">
        <tr>
            <td class="editorial-note-number">
                <xsl:value-of
                    select="scdh:line-number(./ancestor::*[self::p or self::l[not(ancestor::head)] or self::head])"
                />
            </td>
            <td class="editorial-note-text">
                <span class="note-lemma">
                    <xsl:variable name="lemma-nodes">
                        <!-- we use the same mode as in the apparatus -->
                        <xsl:apply-templates select="parent::*/child::node() except ."
                            mode="note-text-repetition"/>
                    </xsl:variable>
                    <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
                    <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                </span>
                <span class="note-text" lang="{scdh:language(.)}"
                    style="direction:{scdh:language-direction(.)}; text-align:{scdh:language-align(.)};">
                    <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
                    <xsl:value-of select="scdh:direction-embedding(.)"/>
                    <xsl:apply-templates mode="editorial-note"/>
                    <xsl:text>&pdf;</xsl:text>
                    <xsl:if
                        test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </span>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="anchor" mode="editorial-note-entry">
        <xsl:variable name="idref" select="concat('#', @xml:id)"/>
        <xsl:variable name="referering-node" as="node()"
            select="(//*[@from eq $idref], //*[@to eq $idref])[1]"/>
        <xsl:variable name="fromId" select="substring($referering-node/@from, 2)"/>
        <xsl:variable name="toId" select="substring($referering-node/@to, 2)"/>
        <xsl:message>Anchor of <xsl:value-of select="name($referering-node)"/></xsl:message>
        <tr>
            <td class="editorial-note-number">
                <xsl:value-of
                    select="scdh:line-number(./ancestor::*[self::p or self::l[not(ancestor::head)] or self::head])"
                />
            </td>
            <td class="editorial-note-text">
                <span class="note-lemma">
                    <xsl:variable name="lemma-nodes"
                        select="scdhx:subtrees-between-anchors(., $fromId, $toId)"/>
                    <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
                    <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                </span>
                <!--
                <span class="note-text"
                    lang="{scdh:language(.)}"
                    style="direction:{scdh:language-direction(.)}; text-align:{scdh:language-align(.)};">
                    <!-/- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -/->
                    <xsl:value-of select="scdh:direction-embedding(.)"/>
                    <xsl:apply-templates mode="editorial-note" select="$referering-node"/>
                    <xsl:text>&pdf;</xsl:text>
                    <xsl:if test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </span>
                -->
                <span class="note-text">
                    <xsl:call-template name="lang-attributes">
                        <xsl:with-param name="context" select="$referering-node"/>
                    </xsl:call-template>
                    <xsl:apply-templates mode="editorial-note" select="$referering-node"/>
                </span>
            </td>
        </tr>
    </xsl:template>


    <!-- MODE: note-text-repetition
        These templates are generate the text repeated in front of the note.-->

    <xsl:mode name="note-text-repetition" on-no-match="shallow-skip"/>

    <xsl:template mode="note-text-repetition"
        match="app[//variantEncoding[@method ne 'parallel-segmentation']]"/>

    <xsl:template match="rdg" mode="note-text-repetition"/>

    <xsl:template match="choice[corr]/sic" mode="note-text-repetition"/>

    <xsl:template match="witDetail" mode="note-text-repetition"/>

    <xsl:template match="note" mode="note-text-repetition"/>

    <!-- this fixes issue #38 on the surface -->
    <xsl:template match="caesura" mode="note-text-repetition #default">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="text()" mode="note-text-repetition">
        <xsl:value-of select="."/>
    </xsl:template>


    <!-- mode: editorial-note -->

    <xsl:mode name="editorial-note" on-no-match="shallow-skip"/>

    <xsl:template mode="editorial-note" match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <xsl:template mode="editorial-note" match="hi[@rend eq 'italic']">
        <i>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="editorial-note"/>
        </i>
    </xsl:template>

    <xsl:template mode="editorial-note" match="hi[@rend eq 'bold']">
        <b>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="editorial-note"/>
        </b>
    </xsl:template>

    <xsl:template mode="editorial-note" match="hi[@rend eq 'ul']">
        <u>
            <xsl:call-template name="lang-attributes">
                <xsl:with-param name="context" select="."/>
            </xsl:call-template>
            <xsl:apply-templates mode="editorial-note"/>
        </u>
    </xsl:template>

    <!-- change language if necessary -->
    <xsl:template match="*[@xml:lang]" mode="editorial-note">
        <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
        <xsl:value-of select="scdh:direction-embedding(.)"/>
        <xsl:apply-templates mode="editorial-note"/>
        <xsl:text>&pdf;</xsl:text>
        <xsl:if
            test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- pass over to tei-ld.xsl, if not in note context -->
    <xsl:template match="(persName | orgName | placeName | geoName)[not(ancestor::note)]"
        mode="editorial-note">
        <xsl:apply-templates select="." mode="tei-ld"/>
    </xsl:template>

</xsl:stylesheet>
