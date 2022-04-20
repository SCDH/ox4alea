<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs xi" version="3.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0">

    <!-- ID of the reading to be extracted or 'lemma' -->
    <xsl:param name="reading" as="xs:string" select="'lemma'"/>

    <!-- URL of the project root folder -->
    <xsl:param name="pdu" as="xs:string" required="true"/>

    <!-- internal ID of the author -->
    <xsl:param name="authorname" as="xs:string" select="'unknown'"/>

    <!-- We make a project-relative URI to the source.
        We will be able to fix this using xml:baseurl in the right place. -->
    <xsl:variable name="source" select="
            let $l := string-length($pdu) + 2
            return
                substring(base-uri(), $l)"/>

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

    <!-- add prefix definition for extracted source -->

    <xsl:template match="encodingDesc[@n ne 'common']/listPrefixDef">
        <listPrefixDef>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <xsl:call-template name="collactionSourcePrefixDef"/>
        </listPrefixDef>
    </xsl:template>

    <xsl:template match="encodingDesc[@n ne 'common'][not(listPrefixDef)]">
        <encodingDesc>
            <xsl:copy-of select="@*"/>
            <xsl:apply-templates/>
            <listPrefixDef>
                <xsl:call-template name="collactionSourcePrefixDef"/>
            </listPrefixDef>
        </encodingDesc>
    </xsl:template>

    <xsl:template name="collactionSourcePrefixDef">
        <!-- this creates a project-relative URI to the extraction source.
            We can fix this using xml:baseurl in the right place. -->
        <prefixDef ident="cs">
            <xsl:attribute name="replacementPattern" select="concat($source, '#$1')"/>
            <xsl:attribute name="matchPattern" select="'[a-zA-Z_][a-zA-Z0-9_]*'"/>
            <xsl:comment>
                <xsl:text>extracted witness '</xsl:text>
                <xsl:value-of select="$reading"/>
                <xsl:text>' from </xsl:text>
                <xsl:value-of select="$source"/>
            </xsl:comment>
        </prefixDef>
    </xsl:template>

    <!-- drop prefix definition to older extraction source -->
    <xsl:template match="prefixDef[@ident eq 'cs']"/>


    <!-- start a new revision description -->

    <xsl:template match="revisionDesc">
        <revisionDesc xml:lang="en">
            <xsl:call-template name="report"/>
        </revisionDesc>
    </xsl:template>

    <!-- add revisionDesc if not present -->
    <xsl:template match="teiHeader[not(child::revisionDesc)]">
        <teiHeader>
            <xsl:apply-templates select="@*"/>
            <xsl:apply-templates/>
            <revisionDesc xml:lang="en">
                <xsl:call-template name="report"/>
            </revisionDesc>
        </teiHeader>
    </xsl:template>

    <xsl:template name="report">
        <change when="{format-date(current-date(), '[Y0001]-[M01]-[D01]')}" who="#{$authorname}"
            type="derived">
            <xsl:text>Extracted reading '</xsl:text>
            <xsl:value-of select="$reading"/>
            <xsl:text>' of </xsl:text>
            <ref target="cs:{replace($reading, '^#', '')}">
                <xsl:value-of
                    select="//teiHeader/fileDesc/titleStmt[1]/title[1] => normalize-space()"/>
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

    <!-- put the old ID into @corresp -->
    <xsl:template match="l/@xml:id">
        <xsl:attribute name="corresp" select="concat('cs:', .)"/>
    </xsl:template>

</xsl:stylesheet>
