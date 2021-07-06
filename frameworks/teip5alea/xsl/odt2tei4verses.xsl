<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    xpath-default-namespace="urn:oasis:names:tc:opendocument:xmlns:text:1.0" version="2.0">

    <xsl:output indent="yes"/>

    <xsl:param name="authorname" as="xs:string" required="yes"/>

    <xsl:template match="/">
        <TEI>
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
                <revisionDesc xml:lang="de">
                    <change when="{format-date(current-date(), '[Y]-[M]-[D]')}" who="{$authorname}"
                        >Konvertierung von Textverarbeitung nach TEI.</change>
                </revisionDesc>
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
        <l>
            <xsl:apply-templates select="node()"/>
        </l>
    </xsl:template>

    <xsl:template match="span">
        <xsl:apply-templates select="node()"/>
    </xsl:template>

    <xsl:template match="tab | s">
        <caesura/>
    </xsl:template>

</xsl:stylesheet>
