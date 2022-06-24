<?xml version="1.0" encoding="UTF-8"?>
<!-- HTML preview for a document, that contains multiple recensions.

This is simply a composition of extract-recension and preview.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:math="http://www.w3.org/2005/xpath-functions/math" exclude-result-prefixes="xs math"
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

    <!-- During composition, the base-uri of nodes seem to be inaccessible.
        That's why we rewrite it. -->
    <xsl:template mode="extract-recension" match="@xml:base[$needs-static-base]">
        <xsl:attribute name="xml:base" select="resolve-uri(., static-base-uri())"/>
    </xsl:template>

</xsl:stylesheet>
