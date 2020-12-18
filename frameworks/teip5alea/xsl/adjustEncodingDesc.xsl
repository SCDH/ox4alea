<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:param name="pdu" as="xs:string" required="yes"/>

    <xsl:param name="cfdu" as="xs:string" required="yes"/>

    <xsl:param name="xptr" as="xs:string" select="'encodingDesc'"/>

    <xsl:param name="file-path" as="xs:string" select="'Vocabulary.tei'"/>

    <xsl:variable name="rel-path" as="xs:string"
        select="
            string-join(for $dir in tokenize(substring-after($cfdu, $pdu), '[/\\]')
            return
                '../', '')"/>

    <xsl:variable name="file-name" as="xs:string"
        select="tokenize($file-path, '[/\\]')[position() eq last()]"/>

    <xsl:template
        match="teiHeader[not(scdh:includes-encodingDesc(xi:include)) and not(encodingDesc)]">
        <xsl:apply-templates/>
        <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
            <xsl:attribute name="href" select="concat($rel-path, $file-path)"/>
            <xsl:attribute name="xpointer" select="$xptr"/>
        </xsl:element>
    </xsl:template>

    <xsl:template
        match="teiHeader/xi:include/@href[not(scdh:includes-encodingDesc(parent::xi:include))]">
        <xsl:attribute name="xpointer" select="concat($rel-path, $file-path)"/>
    </xsl:template>

    <xsl:function name="scdh:includes-encodingDesc" as="xs:boolean">
        <xsl:param name="context" as="node()"/>
        <xsl:sequence select="contains($context/@href, $file-name)"/>
    </xsl:function>

</xsl:stylesheet>
