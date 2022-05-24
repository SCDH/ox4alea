<?xml version="1.0" encoding="UTF-8"?>
<!--
XSL transfromation for extracting a single recension from a multiple-recension document.

Recensions and the witnesses belonging to them are expected to be encoded
as a sourceDesc//listWit with an @xml:id.

We define a default mode in order to make stylesheet composition simpler.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0"
    default-mode="extract-recension">

    <xsl:mode name="extract-recension" on-no-match="shallow-copy"/>
    <xsl:mode name="single-recension" on-no-match="shallow-copy"/>

    <xsl:param name="source" as="xs:string" required="true"/>

    <xsl:param name="debug" as="xs:boolean" select="false()" required="false"/>

    <xsl:template match="/">
        <xsl:if test="$debug">
            <xsl:message>extracting recension '<xsl:value-of select="$source"/>'</xsl:message>
        </xsl:if>
        <xsl:choose>
            <xsl:when test="exists(//teiHeader//sourceDesc//listWit[@xml:id eq $source])">
                <xsl:apply-templates/>
            </xsl:when>
            <xsl:when test="$source eq ''">
                <!-- No recension selected: Apply simple identity transformation -->
                <xsl:if test="$debug">
                    <xsl:message>No recension selected. Performing identity
                        transformation.</xsl:message>
                </xsl:if>
                <xsl:apply-templates mode="single-recension"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">Recension not found</xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- delete recension and its witnesses from the source description -->
    <xsl:template match="sourceDesc//listWit[@xml:id ne $source]"/>

    <!-- this rule applys for positive recension encoding, i.e. all
        recensions are explicitly given. -->
    <xsl:template match="choice[child::seg[@source]]">
        <xsl:if test="$debug">
            <xsl:message>selecting reading ...</xsl:message>
        </xsl:if>
        <xsl:apply-templates select="
                seg[some $s in tokenize(@source, '\s+')
                    satisfies $s eq concat('#', $source)]/node()"/>
    </xsl:template>

    <!-- this rule applies to positive recension encoding -->
    <xsl:template match="*[@source]">
        <xsl:choose>
            <xsl:when test="
                    some $s in tokenize(@source, '\s+')
                        satisfies $s eq concat('#', $source)">
                <xsl:if test="$debug">
                    <xsl:message>selecting <xsl:value-of select="name(.)"/> of
                        recension</xsl:message>
                </xsl:if>
                <xsl:copy>
                    <xsl:apply-templates select="@* except @source"/>
                    <xsl:apply-templates select="node()"/>
                </xsl:copy>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="$debug">
                    <xsl:message>unselecting <xsl:value-of select="name(.)"/> of
                        recension</xsl:message>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- delete apparatus entries that only belong to other recensions -->
    <xsl:template match="
            app[every $wit in (string-join(child::rdg/@wit, ' ') => tokenize()) ! substring(., 2)
                satisfies not(exists(//teiHeader//sourceDesc//listWit[@xml:id eq $source]//witness[@xml:id eq $wit]))]">
        <!-- handle the lemma according to variant encoding -->
        <xsl:if test="$debug">
            <xsl:message>delete whole app with readings from <xsl:value-of
                    select="string-join(child::rdg/@wit, ' ')"/>
            </xsl:message>
        </xsl:if>
        <xsl:apply-templates select="lem" mode="lemma"/>
    </xsl:template>

    <!-- keep the lemma in parallel segmentation -->
    <xsl:template mode="lemma"
        match="lem[//descendant::variantEncoding[@method eq 'parallel-segmentation']]">
        <xsl:if test="$debug">
            <xsl:message>keeping lemma</xsl:message>
        </xsl:if>
        <xsl:apply-templates/>
    </xsl:template>

    <!-- delete the lemma in all other encoding variants -->
    <xsl:template mode="lemma" match="lem"/>

    <!-- remove variant readings not from the current recension -->
    <xsl:template match="
            rdg[every $wit in tokenize(@wit) ! substring(., 2)
                satisfies not(exists(//teiHeader//sourceDesc//listWit[@xml:id eq $source]//witness[@xml:id eq $wit]))]">
        <xsl:if test="$debug">
            <xsl:message>deleting single reading</xsl:message>
        </xsl:if>
    </xsl:template>

    <!-- remove all sigla from other recensions -->
    <xsl:template match="@wit">
        <xsl:variable name="root" select="root()"/>
        <xsl:variable name="tokenized" select="tokenize(.)"/>
        <xsl:variable name="filtered" select="
                ($tokenized)[let $s := substring(., 2)
                return
                    exists($root//teiHeader//sourceDesc//listWit[@xml:id eq $source]//witness[@xml:id eq $s])]"/>
        <xsl:attribute name="wit" select="string-join($filtered, ' ')"/>
    </xsl:template>

</xsl:stylesheet>
