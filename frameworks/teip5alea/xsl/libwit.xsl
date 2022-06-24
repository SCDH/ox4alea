<?xml version="1.0" encoding="UTF-8"?>
<!-- A TEI document may contain full witness information
    or only stubs that relate to a witnesses in central catalog.

    This is an XSLT library to deal with this.
    It hides away the details of the witness catalog and provides lookup functions.
    It takes an XPath expression as parameter that tells, where the information is stored.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs scdh"
    version="3.0">

    <!-- XPath where to get information about the witnesses from.
        Defaults to the source description in the current document.
        This may be e.g. doc('witnesses.xml')//text//listWit//witness -->
    <xsl:param name="witnesses-xpath" as="xs:string" required="false">
        <xsl:text>ancestor::TEI//sourceDesc//witness | /teiCorpus/teiHeader//sourceDesc//witness</xsl:text>
    </xsl:param>

    <!-- XPath where to get the siglum of a witness -->
    <xsl:param name="witness-siglum-xpath" as="xs:string" required="false">
        <xsl:text>descendant::abbr[@type eq 'siglum'][1]</xsl:text>
    </xsl:param>

    <xsl:param name="debug" as="xs:boolean" select="true()" required="false"/>

    <xsl:variable name="witnesses" as="element()*">
        <xsl:if test="true()">
            <xsl:message>Getting witness information from <xsl:value-of select="$witnesses-xpath"
                /></xsl:message>
        </xsl:if>
        <xsl:variable name="wits" as="element()*">
            <xsl:evaluate as="element()*" context-item="/" expand-text="true"
                xpath="$witnesses-xpath"/>
        </xsl:variable>
        <xsl:if test="true()">
            <xsl:message>Found <xsl:value-of select="count($wits)"/> witnesses.</xsl:message>
        </xsl:if>
        <xsl:sequence select="$wits"/>
    </xsl:variable>

    <!-- returns a list of space separated sigla for a list of IDREFs eg. from @wit -->
    <xsl:function name="scdh:getWitnessSiglum" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:value-of select="scdh:getWitnessSiglum($id, ' ')"/>
    </xsl:function>

    <!-- returns a list of arbitrarily separated sigla for a list of IDREFs eg. from @wit -->
    <xsl:function name="scdh:getWitnessSiglum" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="sep" as="xs:string"/>
        <xsl:value-of select="string-join(scdh:get-witness-siglum-seq($id), $sep)"/>
    </xsl:function>

    <!-- lookup the sigla for a list of IDs or IDREFs eg. form @wit -->
    <xsl:function name="scdh:get-witness-siglum-seq" as="xs:string*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:for-each select="tokenize($id)">
            <xsl:variable name="theId" select="scdh:normalize-id(.)"/>
            <xsl:variable name="witness" select="$witnesses[@xml:id eq $theId]"/>
            <xsl:choose>
                <xsl:when test="$witness">
                    <xsl:evaluate as="xs:string" context-item="$witness" expand-text="true"
                        xpath="$witness-siglum-xpath"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="$theId"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <xsl:template name="witness-siglum-html">
        <xsl:param name="wit" as="xs:string"/>
        <span class="siglum">
            <xsl:for-each select="scdh:get-witness-siglum-seq($wit)">
                <xsl:value-of select="."/>
                <xsl:if test="position() ne last()">
                    <span data-i18n-key="witness-sep">, </span>
                </xsl:if>
            </xsl:for-each>
        </span>
    </xsl:template>

    <xsl:function name="scdh:get-witness-id" as="xs:string*">
        <xsl:param name="siglum" as="xs:string"/>
        <xsl:variable as="xs:string*" name="sigla" select="tokenize($siglum, '[,،\s]+')"/>
        <xsl:for-each select="$witnesses">
            <xsl:variable name="witness" select="."/>
            <xsl:variable name="theSiglum" as="xs:string">
                <xsl:evaluate as="xs:string" context-item="." expand-text="true"
                    xpath="$witness-siglum-xpath"/>
            </xsl:variable>
            <xsl:choose>
                <xsl:when test="
                        some $s in $sigla
                            satisfies $s eq $theSiglum">
                    <xsl:value-of select="concat('#', @xml:id)"/>
                </xsl:when>
                <xsl:otherwise/>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>

    <!-- get the ID in an ID or an IDREF -->
    <xsl:function name="scdh:normalize-id">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace(normalize-space($in), '#', '')"/>
    </xsl:function>

    <xsl:function name="scdh:tokenize-wit">
        <xsl:param name="witnesses" as="xs:string"/>
        <xsl:value-of select="tokenize($witnesses, '[,،\s]+')"/>
    </xsl:function>

</xsl:stylesheet>
