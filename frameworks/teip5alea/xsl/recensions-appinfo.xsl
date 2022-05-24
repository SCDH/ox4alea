<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for adding the multiple recensions editor application information -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="encodingDesc[not(child::appInfo) and not(//encodingDesc/appInfo)]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <appInfo>
                <xsl:call-template name="mre-app"/>
            </appInfo>
        </xsl:copy>
    </xsl:template>

    <xsl:template match="appInfo[not(child::application[@ident eq 'oxmre']) and not(//application[@ident eq 'oxmre'])]">
        <xsl:copy>
            <xsl:apply-templates select="@* | node()"/>
            <xsl:call-template name="mre-app"/>
        </xsl:copy>
    </xsl:template>

    <xsl:template name="mre-app">
        <application ident="oxmre" version="0">
            <label>oXbytao multiple recensions editor</label>
            <ptr type="recension" subtype="visible"/>
            <ptr type="recension" subtype="othertarget"/>
            <ptr type="recension" subtype="current"/>
        </application>
    </xsl:template>

</xsl:stylesheet>
