<?xml version="1.0" encoding="UTF-8"?>
<!-- extract a certain reading in order to make a new document encoding another recension of the work -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xi" version="3.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">

    <!-- ID of the reading to be extracted or 'lemma' -->
    <xsl:param name="reading" as="xs:string" select="'lemma'"/>

    <!-- whether to replace notes with XIncludes or not -->
    <xsl:param name="note-references" as="xs:boolean" select="true()"/>

    <!-- whether to generate IDs for block (p-like and verse elements) or not -->
    <xsl:param name="block-ids" as="xs:boolean" select="false()"/>

    <!-- internal ID of the author -->
    <xsl:param name="authorname" as="xs:string" select="'unknown'"/>

    <!-- the identifier of the custom URI scheme for linking to collated text -->
    <xsl:param name="protocol" as="xs:string" select="'diwan'"/>

    <!-- XPath expression how to get the source identifier for the collation references -->
    <xsl:param name="source-xpath" as="xs:string">
        <!-- per default we take the first existing of some values that make sense -->
        <xsl:text>(/@xml:id, //idno[@type eq 'canonical-id'], //idno[@type eq 'work-identifier'], tokenize(tokenize(base-uri(/), '/')[last()], '\.')[1])[1]</xsl:text>
    </xsl:param>

    <!-- the $source is the work identifier -->
    <xsl:variable name="source" as="xs:string">
        <xsl:evaluate as="xs:string" expand-text="true" context-item="/" xpath="$source-xpath"/>
    </xsl:variable>

    <!-- whether to keep the existing collation or drop it -->
    <xsl:param name="keep-existing-collation" as="xs:boolean" select="true()"/>

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="respStmt[@n eq 'transcribed']">
        <respStmt>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="resp"/>
            <persName sameAs="#{$authorname}">
                <xsl:choose>
                    <xsl:when test="//*[@xml:id eq $authorname]">
                        <xsl:value-of select="//*[@xml:id eq $authorname] => normalize-space()"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:text>???</xsl:text>
                    </xsl:otherwise>
                </xsl:choose>
            </persName>
        </respStmt>
    </xsl:template>

    <xsl:template match="/">
        <xsl:apply-templates/>
        <xsl:message>Extracting text from <xsl:value-of select="$reading"/>.</xsl:message>
    </xsl:template>

    <!-- drop listWit from source description -->
    <xsl:template match="sourceDesc">
        <sourceDesc/>
    </xsl:template>


    <!-- start a new revision description -->

    <xsl:template match="revisionDesc">
        <revisionDesc xml:lang="en">
            <xsl:call-template name="report"/>
        </revisionDesc>
    </xsl:template>

    <!-- add revisionDesc if not present -->
    <xsl:template match="teiHeader[not(child::revisionDesc)]">
        <xsl:copy>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
            <revisionDesc xml:lang="en">
                <xsl:call-template name="report"/>
            </revisionDesc>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="report">
        <change when="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}" who="#{$authorname}"
            type="derived">
            <xsl:text>Extracted reading '</xsl:text>
            <xsl:value-of select="$reading"/>
            <xsl:text>' of </xsl:text>
            <ref target="{$protocol}:{$source}">
                <xsl:value-of select="$source"/>
            </ref>
            <xsl:text>.</xsl:text>
        </change>
    </xsl:template>


    <!-- select reading depending on stylesheet parameter $reading -->
    <xsl:template match="
            lem[$reading eq 'lemma'] | *[@wit][some $w in tokenize(@wit) ! replace(., '#', '')
                satisfies $w eq $reading]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="lem | rdg"/>
    <xsl:template match="app">
        <!-- drop text nodes -->
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <!-- drop witDetail, which is specific to a certain reading. -->
    <xsl:template match="witDetail"/>

    <!-- select the correction of a choice between orig and corr -->
    <xsl:template match="choice[corr and sic]">
        <xsl:apply-templates select="corr"/>
    </xsl:template>

    <!-- select the first one of unclear alternatives -->
    <xsl:template match="choice[unclear]">
        <xsl:apply-templates select="unclear[1]"/>
    </xsl:template>

    <!-- of all other choices: only select text -->
    <xsl:template match="choice">
        <xsl:value-of select="*/text()"/>
    </xsl:template>

    <!-- unwrap elements -->
    <xsl:template match="corr | sic | unclear | orig">
        <xsl:apply-templates/>
    </xsl:template>


    <!-- Collate verses -->

    <!-- assert that each verse has an ID -->
    <xsl:template match="l[not(@xml:id)]">
        <xsl:message terminate="yes">Error: There are verses without IDs. Please assign IDs to the
            verses before extracting a reading. The presence of IDs is inevitable for collating
            verses.</xsl:message>
    </xsl:template>

    <!-- put the old ID into @corresp if there's none -->
    <xsl:template match="l/@xml:id">
        <xsl:if test="$block-ids">
            <xsl:attribute name="xml:id" select="generate-id(parent::*)"/>
        </xsl:if>
        <xsl:if test="not(parent::*/@corresp)">
            <xsl:attribute name="corresp" select="concat($protocol, ':', $source, '#', .)"/>
        </xsl:if>
    </xsl:template>

    <!-- append the old ID to existing @corresp -->
    <xsl:template match="l/@corresp">
        <xsl:variable name="current"
            select="concat($protocol, ':', $source, '#', parent::*/@xml:id)"/>
        <xsl:choose>
            <xsl:when test="$keep-existing-collation">
                <xsl:attribute name="corresp" select="concat(., ' ', $current)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:attribute name="corresp" select="$current"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>


    <!-- replace notes with XInclude -->

    <xsl:template match="note[exists(@xml:id) and $note-references]">
        <xsl:element name="include" namespace="http://www.w3.org/2001/XInclude">
            <xsl:attribute name="href" select="tokenize(base-uri(), '/')[last()]"/>
            <xsl:attribute name="xpointer" select="@xml:id"/>
        </xsl:element>
    </xsl:template>

</xsl:stylesheet>
