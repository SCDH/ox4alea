<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT module of the preview: apparatus and commentary -->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY sp   "&#x20;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:alea="http://scdh.wwu.de/oxygen#ALEA"
    xmlns:scdh="http://scdh.wwu.de/xslt#" xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    exclude-result-prefixes="xs scdh scdh" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:include href="libapp2.xsl"/>

    <!-- function for making a sequence of mappings from editorial notes -->
    <xsl:function name="scdh:editorial-notes" as="map(*)*">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="editorial-nodes-xpath" as="xs:string"/>
        <xsl:variable name="notes" as="node()*">
            <xsl:evaluate as="node()*" context-item="$context" expand-text="true"
                xpath="$editorial-nodes-xpath"/>
        </xsl:variable>
        <xsl:sequence select="$notes ! scdh:mk-note-map(.)"/>
    </xsl:function>

    <!-- template that generates the editorial notes -->
    <xsl:template name="scdh:editorial-notes">
        <xsl:param name="notes" as="map(*)*"/>
        <div class="editorial-notes">
            <xsl:for-each-group select="$notes" group-by="map:get(., 'line-number')">
                <xsl:for-each select="current-group()">
                    <xsl:variable name="note" select="map:get(., 'entry')"/>
                    <div class="editorial-note">
                        <span class="editorial-note-line-number line-number">
                            <xsl:value-of select="current-grouping-key()"/>
                            <xsl:text>&sp;</xsl:text>
                        </span>
                        <span class="editorial-note-lemma">
                            <xsl:call-template name="scdh:editorial-note-lemma">
                                <xsl:with-param name="entry" select="."/>
                            </xsl:call-template>
                        </span>
                        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                        <span class="note-text" lang="{alea:language($note)}"
                            style="direction:{alea:language-direction($note)}; text-align:{alea:language-align($note)};">
                            <!-- This must be paired with pdf character entity,
                                because directional embeddings are an embedded CFG! -->
                            <xsl:value-of select="alea:direction-embedding($note)"/>
                            <xsl:apply-templates mode="editorial-note" select="$note"/>
                            <xsl:text>&pdf;</xsl:text>
                            <xsl:if
                                test="alea:language-direction($note) eq 'ltr' and alea:language-direction($note/parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
                                <xsl:text> </xsl:text>
                            </xsl:if>
                        </span>
                    </div>
                </xsl:for-each>
            </xsl:for-each-group>
        </div>
    </xsl:template>

    <!-- template for making the lemma text with some logic for handling empty lemmas -->
    <xsl:template name="scdh:editorial-note-lemma">
        <xsl:param name="entry" as="map(*)"/>
        <span class="apparatus-lemma">
            <xsl:variable name="full-lemma" as="xs:string"
                select="map:get($entry, 'lemma-text-nodes') => alea:shorten-string()"/>
            <xsl:choose>
                <xsl:when test="$full-lemma ne ''">
                    <xsl:value-of select="$full-lemma"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- FIXME -->
                    <xsl:text>empty</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>

    <!-- make a map for a given note -->
    <xsl:function name="scdh:mk-note-map" as="map(*)">
        <xsl:param name="note" as="node()"/>
        <xsl:variable name="lemma-text-nodes" as="text()*">
            <xsl:apply-templates select="$note" mode="editorial-note-text-nodes-dspt"/>
        </xsl:variable>
        <xsl:sequence select="scdh:mk-entry-map($note, $lemma-text-nodes)"/>
    </xsl:function>

    <xsl:mode name="editorial-note-text-nodes-dspt" on-no-match="shallow-skip"/>

    <!-- if there is no @targetEnd, the referring passage is the whole parent element -->
    <xsl:template mode="editorial-note-text-nodes-dspt"
        match="note[not(@targetEnd)] | noteGrp[not(@targetEnd)]">
        <xsl:apply-templates mode="lemma-text-nodes" select="parent::*"/>
    </xsl:template>

    <!-- note with @targetEnd -->
    <xsl:template mode="editorial-note-text-nodes-dspt"
        match="note[@targetEnd] | noteGrp[@targetEnd]">
        <xsl:variable name="targetEnd" as="xs:string" select="@targetEnd"/>
        <xsl:variable name="target-end-node" as="node()" select="//*[@xml:id eq $targetEnd]"/>
        <xsl:choose>
            <xsl:when test="following-sibling::*[@xml:id eq $targetEnd]">
                <xsl:apply-templates mode="lemma-text-nodes"
                    select="scdh:subtrees-between-anchors(., $target-end-node)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates mode="lemma-text-nodes"
                    select="scdh:subtrees-between-anchors($target-end-node, .)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- default rule -->
    <xsl:template mode="editorial-note-text-nodes-dspt" match="*">
        <xsl:message>
            <xsl:text>WARNING: </xsl:text>
            <xsl:text>no matching rule in mode 'editorial-note-text-nodes-dspt' for </xsl:text>
            <xsl:value-of select="name(.)"/>
        </xsl:message>
        <xsl:apply-templates mode="lemma-text-nodes"/>
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
    <xsl:template match="caesura" mode="note-text-repetition" as="text()">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="text()" mode="note-text-repetition" as="text()">
        <xsl:sequence select="."/>
    </xsl:template>


    <!-- mode: editorial-note -->

    <xsl:mode name="editorial-note" on-no-match="shallow-skip"/>

    <xsl:template mode="editorial-note" match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- change language if necessary -->
    <xsl:template match="*[@xml:lang]" mode="editorial-note">
        <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
        <xsl:value-of select="alea:direction-embedding(.)"/>
        <xsl:apply-templates mode="editorial-note"/>
        <xsl:text>&pdf;</xsl:text>
        <xsl:if
            test="alea:language-direction(.) eq 'ltr' and alea:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
