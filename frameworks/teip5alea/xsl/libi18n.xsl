<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:param name="framework" select=".."/>
    <xsl:param name="translations" select=" concat($framework, '/i18n/translate.xml')"/>
    <xsl:param name="language"/>
    
    <xsl:function name="scdh:i18n">
        <xsl:param name="key"/>
        <xsl:param name="default"/>
        <xsl:value-of select="if (doc-available($translations)) 
            then (let $t:=doc($translations)/*:translation/*:key[@value eq $key]/val[@lang eq $language] return 
                      (if (exists($t)) then $t else $default))
            else $default"/>
    </xsl:function>
    
</xsl:stylesheet>