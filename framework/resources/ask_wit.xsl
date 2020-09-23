<?xml version="1.0" encoding="UTF-8"?>
<!-- This stylesheet generates a list of values (and labels) for
    the wit attribute in the ${ask(...)} editor variable.
    It takes a witness catalogue as input.

    Right now the values in the framework file need to be updated
    by hand. :( -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output method="text"/>
    
    <xsl:template match="/">
        <xsl:apply-templates select="/TEI/text//witness"/>
        <xsl:text>&#x0a;</xsl:text>
    </xsl:template>
    
    <xsl:template match="witness">
        <xsl:if test="not(position() = 1)">
            <xsl:text>; </xsl:text>
        </xsl:if>
        <xsl:text>'#</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <xsl:text>': '#</xsl:text>
        <xsl:value-of select="@xml:id"/>
        <!--xsl:text> = </xsl:text>
        <xsl:apply-templates select="abbr[@type = 'siglum' and @xml:lang = 'ar']"/-->
        <xsl:text>'</xsl:text>
    </xsl:template>
    
</xsl:stylesheet>