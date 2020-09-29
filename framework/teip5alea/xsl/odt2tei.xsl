<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    exclude-result-prefixes="xs"
    xpath-default-namespace="urn:oasis:names:tc:opendocument:xmlns:text:1.0"
    version="2.0">
    
    <xsl:output indent="yes"/>
    
    <xsl:template match="/">
        <TEI xmlns="http://www.tei-c.org/ns/1.0">
            <teiHeader>
                <fileDesc>
                    <titleStmt>
                        <title/>
                    </titleStmt>
                    <publicationStmt>
                        <authority/>
                    </publicationStmt>
                    <sourceDesc>
                        <bibl/>
                    </sourceDesc>
                </fileDesc>
            </teiHeader>
            <text>
                <body>
                    <lg>
                        <head>
                            <xsl:apply-templates select="//p[node()][1]"/>
                        </head>
                        <lg>
                            <xsl:apply-templates select="//p[node()][position() gt 1]"/>
                        </lg>
                    </lg>
                </body>
            </text>
        </TEI>
    </xsl:template>
    
    <xsl:template match="p">
        <l xmlns="http://www.tei-c.org/ns/1.0">
            <xsl:apply-templates select="node()"/>
        </l>
    </xsl:template>
    
    <xsl:template match="span">
        <xsl:apply-templates select="node()"/>
    </xsl:template>
    
    <xsl:template match="tab|s">
        <caesura xmlns="http://www.tei-c.org/ns/1.0"/>
    </xsl:template>
    
</xsl:stylesheet>