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
        <xsl:value-of select="string(count($el/preceding-sibling::l union
            $el/ancestor::*/preceding::*//l union
            $el/ancestor::*/preceding::head[empty(descendant::l)] union
            $el/ancestor::*/preceding::*//head[empty(descendant::l)]) + 1)"/>
    </xsl:function>

</xsl:stylesheet>