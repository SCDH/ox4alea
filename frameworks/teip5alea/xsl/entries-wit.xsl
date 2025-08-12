<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:obt="http://scdh.wwu.de/oxbytei"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs obt map"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <!-- the currently edited document,
        parameter needed for de.wwu.scdh.teilsp.extension.LabelledEntriesXSLTWithContext -->
    <xsl:param name="document" as="document-node()" select="doc($testfile)"/>

    <!-- the current editing context as XPath,
        parameter needed for de.wwu.scdh.teilsp.extension.LabelledEntriesXSLTWithContext -->
    <xsl:param name="context" as="xs:string" select="'/*'"/>

    <!-- parameter specific for this plugin configuration -->
    <xsl:param name="witness-catalog" as="xs:string" select="'../../WitnessCatalogue.xml'"/>

    <!-- Not used with the plugin, only used for testing because we like a default value 
        for $document because it is difficult to pass in a document node. -->
    <xsl:param name="testfile" as="xs:string" select="'test.tei.xml'" required="false"/>


    <!-- get the context node. This is generic. -->
    <xsl:variable name="context-node" as="node()">
        <xsl:evaluate as="node()" context-item="$document" expand-text="true" xpath="$context"/>
    </xsl:variable>

    <xsl:variable name="witness-doc">
        <xsl:choose>
            <xsl:when test="$witness-catalog eq ''">
                <xsl:sequence select="$document"/>
            </xsl:when>
            <xsl:when test="doc-available($witness-catalog)">
                <xsl:sequence select="doc($witness-catalog)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">No such file: <xsl:value-of select="$witness-catalog"
                    /></xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- entry template -->
    <xsl:template name="obt:generate-entries" as="map(xs:string, xs:string)*">
        <xsl:message>
            <xsl:value-of select="name($context-node)"/>
        </xsl:message>
        <!-- Get the IDs of the witnesses in the header and use them
            as a filter for witnesses from the catalog. -->
        <xsl:apply-templates select="$document//teiHeader//sourceDesc//witness[@xml:id]"
            mode="entries"/>
    </xsl:template>

    <xsl:template match="witness" as="map(xs:string, xs:string)*" mode="entries">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:variable name="label" as="xs:string*">
            <!-- we may have pseudo witnesses.
                So we first if we can get the witness label from the catalog or not. -->
            <xsl:choose>
                <xsl:when test="$witness-doc//witness[@xml:id eq $id]">
                    <xsl:apply-templates select="$witness-doc//witness[@xml:id eq $id]" mode="label"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="concat(parent::listWit/@xml:id, ': ', $id, ' ', @n)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="
                map {
                    'key': concat('#', $id),
                    'label': string-join($label, '') => normalize-space()
                }"/>
    </xsl:template>

    <xsl:template match="witness" mode="label">
        <xsl:value-of select="parent::listWit/@xml:id"/>
        <xsl:text>: </xsl:text>
        <xsl:apply-templates mode="label"/>
    </xsl:template>

    <xsl:template match="*" mode="label">
        <xsl:apply-templates mode="label"/>
    </xsl:template>

    <xsl:template match="text()" mode="label">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
