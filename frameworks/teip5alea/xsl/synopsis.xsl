<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs scdh"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output media-type="html"/>
    
    <!-- ${pdu} oxygen editor variable: project root directory URI -->
    <xsl:param name="pdu" select="string('.')" as="xs:string"/>
    
    <!-- Filename of witness catalogue. -->
    <xsl:param name="witnessCat" select="'WitnessCatalogue.xml'" as="xs:string"/>

    <xsl:include href="libwit.xsl"/>
    <xsl:include href="libi18n.xsl"/>
    <xsl:include href="libcommon.xsl"/>
    
    <xsl:template match="/">
        <html>
            <head>
                <title>ALEA Synopse</title>
                <xsl:call-template name="direction-style"/>
                <style>
                    .lemma { 
                        background-color: #D6E3B5;
                    }
                    .variant {
                        background-color: #FFC3CE;
                    }
                    table tr, table td * {
                        vertical-align: top;
                    }
                    table tr.head {
                        font-weight:900;
                    }
                </style>
            </head>
            <body>
                <xsl:variable name="witnesses" select="/TEI/teiHeader//witness/@xml:id"/>
                <xsl:variable name="lines" select="/TEI/text//l"/>
                <section>
                    <table>
                        <!-- TODO: add attribute for column-wise reading -->
                        <thead>
                        <tr>
                            <th><span style="display:none;">Vers/Zeile</span></th>
                            <th>Lemma</th>
                            <xsl:for-each select="$witnesses">
                                <th>
                                    <xsl:text>Handschrift </xsl:text>
                                    <xsl:value-of select="scdh:getWitnessSiglum($pdu, $witnessCat, .)"/>
                                </th>
                            </xsl:for-each>
                        </tr>
                        </thead>
                        <tbody>
                        <xsl:for-each select="$lines">
                            <xsl:variable name="line" select="."/>
                            <tr class="{if ($line[ancestor::head]) 
                                        then 'head' 
                                        else (if (local-name($line) eq 'l') then 'verse' else 'paragraph')}">
                                <td class="number-column"><xsl:value-of select="scdh:line-number($line)"/></td>
                                <td class="lemma-column">
                                    <xsl:apply-templates select="$line" mode="synopsis">
                                        <xsl:with-param name="wit" select="'lemma'" tunnel="yes"/>
                                        <xsl:with-param name="class" select="'lemma'" tunnel="yes"/>
                                    </xsl:apply-templates>
                                </td>
                                <xsl:for-each select="for $w in $witnesses return concat('#', $w)">
                                    <td class="reading-column">
                                        <xsl:apply-templates select="$line" mode="synopsis">
                                            <xsl:with-param name="wit" select="." tunnel="yes"/>
                                            <xsl:with-param name="class" select="'lemma'" tunnel="yes"/>
                                        </xsl:apply-templates>
                                    </td>
                                </xsl:for-each>
                            </tr>
                        </xsl:for-each>
                        </tbody>
                    </table>
                </section>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="l[ancestor::app]" mode="synopsis">
        <xsl:param name="wit" tunnel="yes"/>
        <xsl:param name="class" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$wit eq 'lemma'">
                <xsl:apply-templates select="ancestor::app[1]/lem/l/node()" mode="synopsis">
                    <xsl:with-param name="class" select="'lemma'" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when
                test="some $w in tokenize(string-join(ancestor::app[1]/*/@wit, ' '), '\s+') satisfies $w eq $wit">
                <xsl:apply-templates
                    select="ancestor::app[1]/*[some $w in tokenize(@wit, '\s+') satisfies $w eq $wit]/l/node()"
                    mode="synopsis">
                    <xsl:with-param name="class" select="'variant'" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="ancestor::app[1]/lem/l/node()" mode="synopsis">
                    <xsl:with-param name="class" select="'lemma'" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="app" mode="synopsis">
        <xsl:param name="wit" tunnel="yes"/>
        <xsl:param name="class" tunnel="yes"/>
        <xsl:choose>
            <xsl:when test="$wit eq 'lemma'">
                <xsl:apply-templates select="lem" mode="synopsis">
                    <xsl:with-param name="class" select="'lemma'" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:when test="some $w in tokenize(string-join(child::*/@wit, ' '), '\s+') satisfies $w eq $wit">
                <xsl:apply-templates select="child::*[some $w in tokenize(@wit, '\s+') satisfies $w eq $wit]" mode="synopsis">
                    <xsl:with-param name="class" select="'variant'" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="lem" mode="synopsis">
                    <xsl:with-param name="class" select="'lemma'" tunnel="yes"/>
                </xsl:apply-templates>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="text()" mode="synopsis">
        <xsl:param name="class" tunnel="yes"/>
        <xsl:param name="wit" tunnel="yes" select="'#?'"/>
        <span class="{$class} {$wit}">
            <xsl:value-of select="."/>            
        </span>
    </xsl:template>
    
    <xsl:template match="choice" mode="synopsis">
        <xsl:apply-templates select="corr" mode="synopsis"/>
    </xsl:template>
    
    <xsl:template match="gap" mode="synopsis">
        <xsl:param name="class" tunnel="yes"/>
        <span class="{$class}"><xsl:text>[...]</xsl:text></span>        
    </xsl:template>
    
    <xsl:template match="caesura" mode="synopsis">
        <xsl:param name="class" tunnel="yes"/>
        <span class="{$class}" style="padding:0 0.5em;">||</span>
    </xsl:template>

</xsl:stylesheet>