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
    <xsl:param name="langUsage-id" as="xs:string" select="'langUsage'"/>

    <xsl:param name="uri" as="xs:string"
        select="'https://zivgitlab.uni-muenster.de/ALEA/Vocabulary.xml'"/>

    <!-- insert new xinclude -->
    <xsl:template match="teiHeader[not(encodingDesc) or not(profileDesc)]" expand-text="yes">
        <xsl:if test="not(preceding-sibling::text())">
            <xsl:text>&#xa;&tab;</xsl:text>
        </xsl:if>
        <teiHeader xml:space="default">
            <xsl:text>&#xa;&tab2;</xsl:text>
            <xsl:apply-templates select="fileDesc"/>
            <xsl:text>&#xa;&tab2;</xsl:text>
            <profileDesc>
                <xsl:text>&#xa;&tab2;</xsl:text>
                <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
                    <xsl:attribute name="href" select="$uri"/>
                    <xsl:attribute name="xpointer" select="$langUsage-id"/>
                </xsl:element>
                <xsl:text>&#xa;&tab2;</xsl:text>
            </profileDesc>
            <xsl:text>&#xa;&tab2;</xsl:text>
            <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
                <xsl:attribute name="href" select="$uri"/>
                <xsl:attribute name="xpointer" select="$encodingDesc-id"/>
            </xsl:element>
            <xsl:if test="revisionDesc">
                <xsl:text>&#xa;&tab2;</xsl:text>
            </xsl:if>
            <xsl:apply-templates select="revisionDesc"/>
            <xsl:text>&#xa;&tab;</xsl:text>
        </teiHeader>
    </xsl:template>

    <!-- include is expanded, so replace profileDesc with xinclude -->
    <xsl:template match="langUsage" expand-text="yes">
        <xsl:message>found profileDesc, replacing</xsl:message>
        &tab;<xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
            <xsl:attribute name="href" select="$uri"/>
            <xsl:attribute name="xpointer" select="$langUsage-id"/>
        </xsl:element>
        <!--xsl:text>&#xa;   </xsl:text-->
    </xsl:template>

    <!-- include is expanded, so replace encodingDesc with xinclude -->
    <xsl:template match="encodingDesc">
        <xsl:message>found encodingDesc, replacing</xsl:message>
        <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
            <xsl:attribute name="href" select="$uri"/>
            <xsl:attribute name="xpointer" select="$encodingDesc-id"/>
        </xsl:element>
        <!--xsl:if test="following-sibling::*">
            <xsl:text>&#xa;   </xsl:text>
        </xsl:if-->
    </xsl:template>

</xsl:stylesheet>
