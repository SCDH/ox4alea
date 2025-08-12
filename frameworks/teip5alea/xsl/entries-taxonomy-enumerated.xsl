<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for generating labelled entries with oXbytei's plugin 'LabelledEntriesXSLTWithContext'.    
This values of the type tei.enumerated, like in @type and »@ subtype.

Use the parameter 'taxonomy', if the taxonomy is not contained or xi:included in the current file.

Use the parameter 'taxonomy-ids' to filter taxonomies in the taxomony file by their @xml:id.

Example config for generating suggestions for seg/@type:

        <plugin>
            <class>de.wwu.scdh.teilsp.extensions.LabelledEntriesXSLTWithContext</class>
            <type>de.wwu.scdh.teilsp.services.extensions.ILabelledEntriesProvider</type>
            <configurations>
                <configuration>
                    <conditions>
                        <condition domain="context">self::*:seg</condition>
                        <condition domain="priority">10</condition>
                        <condition domain="nodeType">attributeValue</condition>
                        <condition domain="nodeName">type</condition>
                    </conditions>
                    <arguments>
                        <argument name="script">${framework(ALEA NG)}/xsl/entries-taxonomy-enumerated.xsl</argument>
                        <argument name="parameters">taxonomy-ids=segment</argument>
                    </arguments>
                </configuration>
            </configurations>
         </plugin>

-->
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

    <!-- If we have an external taxonomy, i.e. a taxnomy not given in the current
        document's header, use this URI to get it. -->
    <xsl:param name="taxonomy" as="xs:string" select="''"/>

    <!-- To restrict the taxonmies to be read, give a comma separated list of taxnomy IDs. -->
    <xsl:param name="taxonomy-ids" as="xs:string" select="''"/>

    <!-- Not used with the plugin, only used for testing because we like a default value 
        for $document because it is difficult to pass in a document node. -->
    <xsl:param name="testfile" as="xs:string" select="'test.tei.xml'" required="false"/>



    <!-- get the context node. This is generic. -->
    <xsl:variable name="context-node" as="node()">
        <xsl:evaluate as="node()" context-item="$document" expand-text="true" xpath="$context"/>
    </xsl:variable>

    <xsl:variable name="taxonomy-doc" as="document-node()">
        <xsl:choose>
            <xsl:when test="$taxonomy eq ''">
                <xsl:sequence select="$document"/>
            </xsl:when>
            <xsl:when test="doc-available($taxonomy)">
                <xsl:sequence select="doc($taxonomy)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:text>Failed to open taxonomy file </xsl:text>
                    <xsl:value-of select="$taxonomy"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- entry template -->
    <xsl:template name="obt:generate-entries" as="map(xs:string, xs:string)*">
        <xsl:choose>
            <xsl:when test="$taxonomy-ids eq ''">
                <xsl:apply-templates select="$taxonomy-doc//taxonomy//category[@xml:id]"
                    mode="entries"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="taxes" as="xs:string*" select="tokenize($taxonomy-ids)"/>
                <xsl:apply-templates select="
                        $taxonomy-doc//taxonomy[let $id := @xml:id
                        return
                            some $tax in $taxes
                                satisfies $tax eq $id]//category[@xml:id]"
                    mode="entries"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="category" as="map(xs:string, xs:string)*" mode="entries">
        <xsl:variable name="label" as="xs:string*">
            <xsl:apply-templates mode="label"/>
        </xsl:variable>
        <xsl:sequence select="
                map {
                    'key': string(@xml:id),
                    'label': concat(@xml:id, ': ', (string-join($label, '') => normalize-space()))
                }"/>
    </xsl:template>

    <xsl:template match="catDesc[@xml:lang eq 'en']" mode="label"/>
    
    <!-- subcategories not in the label -->
    <xsl:template match="category" mode="label"/>

    <xsl:template match="*" mode="label">
        <xsl:apply-templates mode="label"/>
    </xsl:template>

    <xsl:template match="text()" mode="label">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
