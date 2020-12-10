<?xml version="1.0" encoding="UTF-8"?>
<!-- This performs the identity transformation but replaces 
     literal Sigla by witness IDs from the witness catalogue. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs scdh"
    version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:output method="xml"/>

    <xsl:import href="libwit.xsl"/>

    <xsl:param name="witness-cat" select="'WitnessCatalogue.xml'"/>

    <xsl:template match="@wit">
        <xsl:attribute name="wit" select="scdh:get-witness-id(.)"/>
    </xsl:template>

    <xsl:template match="sourceDesc[not(descendant::listWit)]">
        <sourceDesc>
            <xsl:copy-of select="*[local-name(.) ne bible and empty(.)]"/>
            <listWit>
                <xsl:for-each
                    select="distinct-values(tokenize(replace(string-join(/descendant::*[@wit]/scdh:get-witness-id(@wit), ' '), '#', ''), '\s+'))">
                    <witness>
                        <xsl:attribute name="xml:id" select="."/>
                    </witness>
                </xsl:for-each>
            </listWit>
        </sourceDesc>
    </xsl:template>
    
    <xsl:template match="listWit">
        <listWit>
            <xsl:copy-of select="*"/>
            <xsl:for-each
                select="let $headWits := /TEI/teiHeader//witness/@xml:id,
                            $usedWits := /descendant::*[@wit]/scdh:get-witness-id(@wit) return
                        for $w in distinct-values(tokenize(replace(string-join($usedWits, ' '), '#', ''), '\s+')) return
                            if (exists(index-of($headWits, $w))) then () else $w">
                <witness>
                    <xsl:attribute name="xml:id" select="."/>
                </witness>
            </xsl:for-each>
        </listWit>
    </xsl:template>

</xsl:stylesheet>