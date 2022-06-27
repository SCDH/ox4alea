<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for resetting the MRE:
    sets 'visible' to all recensions
    sets 'fading' and 'othertarget' to all recensions but the current one
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="3.0">

    <xsl:import href="mre-common.xsl"/>

    <!-- leave current recension unchanged -->
    <xsl:variable name="recension-to-become-current" as="xs:integer" select="$current-index"/>

    <!-- fading empty: set 'fading' to all recensions but the one to become current -->
    <xsl:template match="
            application[@ident eq 'oxmre']/ptr[@subtype eq 'fading' and not(@target)]">
        <xsl:copy>
            <xsl:apply-templates select="@* except @target"/>
            <xsl:attribute name="target">
                <xsl:value-of
                    select="string-join($recensions[position() ne $recension-to-become-current], ' ')"
                />
            </xsl:attribute>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

    <!-- fading non-empty: reset 'fading' -->
    <xsl:template match="
            application[@ident eq 'oxmre']/ptr[@subtype eq 'fading' and @target]">
        <xsl:copy>
            <xsl:apply-templates select="@* except @target"/>
            <xsl:apply-templates select="node()"/>
        </xsl:copy>
    </xsl:template>

</xsl:stylesheet>
