<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:obt="http://scdh.wwu.de/oxbytei"
    xmlns:oxy="http://www.oxygenxml.com/ns/author/xpath-extension-functions"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="#all"
    version="3.0">

    <xsl:param name="template-id" as="xs:string" select="'TEMPLATE'"/>

    <xsl:param name="entry-id" as="xs:string?" required="1"/>

    <xsl:mode on-no-match="shallow-copy"/>

    <xsl:template match="/" use-when="function-available('oxy:current-element', 0)">
        <xsl:variable name="current-id" as="xs:string"
            select="oxy:current-element() => generate-id()"/>
        <xsl:variable name="entry" as="element()" select="id($entry-id)"/>
        <xsl:message>
            <xsl:text>cleaning up from </xsl:text>
            <xsl:value-of select="oxy:current-element() => name()"/>
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$current-id"/>
            <xsl:text>) entry with ID </xsl:text>
            <xsl:value-of select="$entry/@xml:id"/>
        </xsl:message>
        <xsl:apply-templates select="$entry"/>
    </xsl:template>

    <xsl:function name="obt:get-template" as="element()">
        <xsl:param name="context" as="node()"/>
        <xsl:sequence select="root($context)//id($template-id)"/>
    </xsl:function>

    <xsl:template name="notify">
        <xsl:message>
            <xsl:text>removing </xsl:text>
            <xsl:value-of select="local-name(.)"/>
            <xsl:text> from </xsl:text>
            <xsl:value-of select="ancestor::person/@xml:id"/>
            <xsl:text>   </xsl:text>
            <xsl:value-of select="serialize(.)"/>
        </xsl:message>
    </xsl:template>

    <!-- remove empty or un-changes template elements -->

    <xsl:template
        match="birth[@calendar = 'islamic' and @when = (obt:get-template(.)//*:birth[@calendar = 'islamic']/@when ! string(.), '')]">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template
        match="birth[@calendar = 'gregorian' and @when = (obt:get-template(.)//*:birth[@calendar = 'gregorian']/@when, '')]">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template match="birth[not(@when | @notBefore | @notAfter) and normalize-space(.) eq '']">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template
        match="death[@calendar = 'islamic' and @when = (obt:get-template(.)/*:death[@calendar = 'islamic']/@when, '')]">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template
        match="death[@calendar = 'gregorian' and @when = (obt:get-template(.)/*:death[@calendar = 'gregorian']/@when, '')]">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template match="death[not(@when | @notBefore | @notAfter) and normalize-space(.) eq '']">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template
        match="reg[@calendar = 'islamic' and @when = (obt:get-template(.)/*:reg[@calendar = 'islamic']/@when, '')]">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template
        match="reg[@calendar = 'gregorian' and @when = (obt:get-template(.)/*:reg[@calendar = 'gregorian']/@when, '')]">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template match="reg[not(@when | @notBefore | @notAfter) and normalize-space(.) eq '']">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template match="namePart[normalize-space(.) eq '']">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template
        match="floruit[@when = obt:get-template(.)/*:floruit/@when and normalize-space(.) eq '']">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template
        match="socecStatus[(not(@code) or @code = obt:get-template(.)/*:socecStatus/@code) and normalize-space(.) eq '']">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template
        match="oppucation[@code = obt:get-template(.)/*:occupation/@code and normalize-space() eq '']">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <xsl:template match="note[normalize-space(.) = '']">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <!--xsl:template match="
            persName[let $context := .
            return
                obt:get-template($context)/persName ! deep-equal(., $context)]">
        <xsl:call-template name="notify"/>
    </xsl:template-->

    <xsl:template match="persName[normalize-space(.) = '']">
        <xsl:call-template name="notify"/>
    </xsl:template>

    <!-- comments are dropped, because they shall not be used to record information -->
    <xsl:template match="comment()"/>



    <!-- structural changes -->

    <!-- rewrites years like 1266/7 to @when-custom -->
    <xsl:template match="@when[matches(., '/')]">
        <xsl:attribute name="when-custom" select="."/>
    </xsl:template>

</xsl:stylesheet>
