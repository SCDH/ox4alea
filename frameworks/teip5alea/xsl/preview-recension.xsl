<?xml version="1.0" encoding="UTF-8"?>
<!-- HTML preview for a document, that contains multiple recensions.

This is simply a composition of extract-recension and preview.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:import href="extract-recension.xsl"/>

    <xsl:import href="preview.xsl"/>

    <xsl:param name="needs-static-base" as="xs:boolean" select="true()"/>

    <xsl:template match="/">
        <!-- We do a composition of extract-recension and preview: -->
        <xsl:variable name="single-recension">
            <xsl:apply-templates mode="extract-recension" select="/"/>
        </xsl:variable>
        <xsl:apply-templates mode="preview" select="$single-recension"/>
    </xsl:template>


    <!-- During composition, the base URI of nodes is the base URI of the xsl:variable element
        and the base URI of the source document becomes inaccessible.
        That's why we set @xml:base of the TEI element.
        Cf. https://www.w3.org/TR/xslt-30/#temporary-trees
        This even works in combination with Base fixup for xi:include (tested).
    -->
    <xsl:template mode="extract-recension" match="TEI">
        <xsl:copy>
            <!-- we have to do everything like in the rule for TEI in extract-recension.xsl -->
            <xsl:apply-templates mode="extract-recension" select="@* except @xml:id"/>
            <xsl:attribute name="xml:id" select="$work-id"/>
            <!-- we use document URI from the source by explicitly passing / as a parameter. -->
            <xsl:attribute name="xml:base" select="document-uri(/)"/>
            <xsl:apply-templates mode="extract-recension" select="node()"/>
        </xsl:copy>
    </xsl:template>


</xsl:stylesheet>
