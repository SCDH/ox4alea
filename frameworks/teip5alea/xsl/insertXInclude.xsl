<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
  <!ENTITY tab "   ">
  <!ENTITY tab2 "      ">
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs xi" version="3.0">

    <xsl:param name="encodingDesc-id" as="xs:string" select="'encodingDesc'"/>
    <xsl:param name="profileDesc-id" as="xs:string" select="'profileDesc'"/>

    <xsl:param name="uri" as="xs:string"
        select="'https://zivgitlab.uni-muenster.de/ALEA/Vocabulary.xml'"/>

    <!-- insert new xinclude -->
    <xsl:template match="teiHeader[not(encodingDesc) or not(profileDesc)]">
        <teiHeader xml:space="default">
            <xsl:text>&#xa;&tab2;</xsl:text>
            <xsl:copy-of select="fileDesc"/>
            <xsl:text>&#xa;&tab2;</xsl:text>
            <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
                <xsl:attribute name="href" select="$uri"/>
                <xsl:attribute name="xpointer" select="$profileDesc-id"/>
            </xsl:element>
            <xsl:text>&#xa;&tab2;</xsl:text>
            <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
                <xsl:attribute name="href" select="$uri"/>
                <xsl:attribute name="xpointer" select="$encodingDesc-id"/>
            </xsl:element>
            <xsl:text>&#xa;&tab2;</xsl:text>
            <xsl:copy-of select="revisionDesc"/>
            <xsl:text>&#xa;&tab;</xsl:text>
        </teiHeader>
    </xsl:template>

    <!-- include is expanded, so replace profileDesc with xinclude -->
    <xsl:template match="profileDesc">
        <xsl:message>found profileDesc, replacing</xsl:message>
        <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
            <xsl:attribute name="href" select="$uri"/>
            <xsl:attribute name="xpointer" select="$profileDesc-id"/>
        </xsl:element>
        <xsl:text>&#xa;   </xsl:text>
    </xsl:template>

    <!-- include is expanded, so replace encodingDesc with xinclude -->
    <xsl:template match="encodingDesc">
        <xsl:message>found encodingDesc, replacing</xsl:message>
        <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
            <xsl:attribute name="href" select="$uri"/>
            <xsl:attribute name="xpointer" select="$encodingDesc-id"/>
        </xsl:element>
        <xsl:text>&#xa;   </xsl:text>
    </xsl:template>

</xsl:stylesheet>
