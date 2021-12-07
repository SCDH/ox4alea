<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs scdh"
    version="2.0">

    <!-- Whether to use line (block-element) counting, or verse (typed) counting. -->
    <xsl:param name="typed-line-numbering" as="xs:boolean" select="true()"/>

    <!-- returns the line or verse number, depending on the value of $typed-line-numbering -->
    <xsl:function name="scdh:line-number" as="xs:string">
        <xsl:param name="el" as="element()"/>
        <xsl:choose>
            <xsl:when test="$typed-line-numbering">
                <xsl:value-of select="scdh:typed-line-number($el)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="scdh:plain-line-number($el)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- returns the verse or paragraph number  -->
    <xsl:function name="scdh:typed-line-number" as="xs:string">
        <xsl:param name="el" as="element()"/>
        <!-- suffix is a marker for additional verses or paragraphs in readings.
            It is displayed in the apparatus. -->
        <xsl:variable name="suffix" select="
                if (exists($el/ancestor::rdg)) then
                    '+'
                else
                    ''"/>
        <xsl:choose>
            <xsl:when test="$el/self::head[l]">
                <xsl:value-of select="
                        concat('H', count($el/preceding::head[not(ancestor::rdg)]) + 1,
                        '/V', count($el/preceding::l[not(ancestor::rdg)]) + 1, $suffix)"
                />
            </xsl:when>
            <xsl:when test="$el/self::head">
                <xsl:value-of
                    select="concat('H', count($el/preceding::head[not(ancestor::rdg)]) + 1, $suffix)"
                />
            </xsl:when>
            <xsl:when test="$el/self::p">
                <xsl:value-of
                    select="concat('P', count($el/preceding::p[not(ancestor::rdg)]) + 1, $suffix)"/>
            </xsl:when>
            <xsl:when test="$el/self::l">
                <xsl:value-of
                    select="concat('V', count($el/preceding::l[not(ancestor::rdg)]) + 1, $suffix)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="concat('?', $suffix)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- returns the line number of a given element as string -->
    <xsl:function name="scdh:plain-line-number" as="xs:string">
        <xsl:param name="el" as="element()"/>
        <xsl:variable name="suffix" select="
                if (exists($el/ancestor::rdg)) then
                    '+'
                else
                    ''"/>
        <xsl:value-of select="
                concat(count($el/preceding::l[not(parent::head) and not(ancestor::rdg)] union
                $el/preceding::head[not(ancestor::rdg)] union
                $el/preceding::p[not(ancestor::rdg)])
                + 1, $suffix)"/>
    </xsl:function>

    <!-- returns the number of the editorial note in context -->
    <xsl:function name="scdh:note-number" as="xs:string">
        <xsl:param name="context" as="element()"/>
        <xsl:value-of select="string(count($context/preceding-sibling::note) + 1)"/>
    </xsl:function>

    <!-- shorten a string of N words to w1 … wN, but returned it as is when N<=3
        USAGE: see preview.xsl -->
    <xsl:function name="scdh:shorten-string" as="xs:normalizedString">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:variable name="lemma-text" select="tokenize(normalize-space(string($nodes)), '\s+')"/>
        <xsl:value-of select="
                if (count($lemma-text) gt 3)
                then
                    (concat($lemma-text[1], ' … ', $lemma-text[last()]))
                else
                    string-join($lemma-text, ' ')"/>
    </xsl:function>

</xsl:stylesheet>
