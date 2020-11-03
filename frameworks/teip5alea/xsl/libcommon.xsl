<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs scdh"
    version="2.0">

    <!-- returns the line number of a given element as string -->
    <xsl:function name="scdh:line-number" as="xs:string">
        <xsl:param name="el" as="element()"/>
        <!-- TODO: verses in parallel readings have to be counted as one -->
        <xsl:value-of select="string(count($el/preceding::l union
                                           $el/preceding::head[empty(descendant::l)])
                                     + 1)"/>
    </xsl:function>

    <!-- shorten a string of N words to w1 … wN, but returned it as is when N<=3
        USAGE: see preview.xsl -->
    <xsl:function name="scdh:shorten-string" as="xs:normalizedString">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:variable name="lemma-text" select="tokenize(normalize-space(string($nodes)), '\s+')"/>
        <xsl:value-of select="if (count($lemma-text) gt 3)
            then (concat($lemma-text[1], ' … ', $lemma-text[last()]))
            else string-join($lemma-text, ' ')"/>
    </xsl:function>

</xsl:stylesheet>