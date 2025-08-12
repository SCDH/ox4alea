<?xml version="1.0" encoding="UTF-8"?>
<!-- Overwrite default note.xsl from oXbytao

This adds a default language to the note.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="2.0">

    <xsl:param name="anchorId" as="xs:string" required="yes"/>

    <xsl:param name="style" as="xs:string" select="'anchored'" required="no"/>

    <xsl:param name="insert-caret" as="xs:boolean" select="true()" required="no"/>

    <!-- the language -->
    <xsl:param name="language" select="'en'" required="no"/>

    <xsl:param name="note-id" as="xs:string" required="yes"/>

    <xsl:template match="/ | *">
        <xsl:choose>
            <xsl:when test="$style eq 'anchored'">
                <xsl:call-template name="anchored"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:call-template name="external"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template name="anchored">
        <note anchored="true" xml:id="{$note-id}">
            <xsl:if test="$language ne ''">
                <xsl:attribute name="xml:lang" select="$language"/>
            </xsl:if>
            <xsl:if test="$insert-caret">
                <xsl:text>${caret}</xsl:text>
            </xsl:if>
        </note>
    </xsl:template>

    <xsl:template name="external">
        <note targetEnd="#{$anchorId}" xml:id="{$note-id}">
            <xsl:if test="$language ne ''">
                <xsl:attribute name="xml:lang" select="$language"/>
            </xsl:if>
            <xsl:if test="$insert-caret">
                <xsl:text>${caret}</xsl:text>
            </xsl:if>
        </note>
    </xsl:template>


</xsl:stylesheet>
