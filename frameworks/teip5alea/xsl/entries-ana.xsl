<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:obt="http://scdh.wwu.de/oxbytei"
    xmlns:map="http://www.w3.org/2005/xpath-functions/map" exclude-result-prefixes="xs map obt"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:import href="entries-prefixDef.xsl"/>

    <xsl:template mode="generate-entries" match="category[@xml:id]" as="map(xs:string, xs:string)">
        <xsl:variable name="key" select="@xml:id" as="xs:string"/>
        <xsl:variable name="label">
            <xsl:apply-templates mode="label"/>
        </xsl:variable>
        <xsl:sequence select="
                map {
                    'key': concat($prefix, ':', $key),
                    'label': $label => string-join('') => normalize-space() => substring(1, 100)
                }"/>
    </xsl:template>

    <xsl:template mode="label" match="catDesc">
        <xsl:apply-templates mode="label"/>
    </xsl:template>

    <!-- do not show subcategories in label -->
    <xsl:template mode="label" match="category"/>

    <xsl:template mode="label" match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
