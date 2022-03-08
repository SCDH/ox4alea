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

    <xsl:template match="/">
        <xsl:variable name="single-recension">
            <xsl:apply-templates mode="extract-recension" select="/"/>
        </xsl:variable>
        <xsl:apply-templates mode="preview" select="$single-recension"/>
    </xsl:template>

</xsl:stylesheet>
