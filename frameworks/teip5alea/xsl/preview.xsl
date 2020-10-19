<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    version="2.0">
    
    <xsl:output media-type="text/html"/>

    <!-- ${pdu} oxygen editor variable: project root directory URI -->
    <xsl:param name="pdu" select="string('.')" as="xs:string"/>

    <!-- Filename of witness catalogue. -->
    <xsl:param name="witnessCat" select="'WitnessCatalogue.xml'" as="xs:string"/>
    
    <!-- writing direction, defaults to 'rtl' (right-to-left) -->
    <xsl:param name="direction" select="'rtl'" as="xs:string"/>

    <xsl:param name="debug" select="false()" as="xs:boolean"/>
    
    <xsl:include href="libwit.xsl"/>

    <xsl:template match="/">
        <html>
            <head>
                <title>ALEA Vorschau</title>
                <style>
                    .title {
                        color:red;
                        text-align: center;
                    }
                    body {
                        direction: <xsl:value-of select="$direction"/>;
                        font-family:"Arabic Typesetting";                    
                    }
                    .variants {
                        direction: <xsl:value-of select="$direction"/>;
                    }
                    .comments {
                        direction: <xsl:value-of select="$direction"/>;
                    }
                    hr {
                        margin: 20px
                    }
                    td {
                        text-align: right;  
                        justify-content: space-between;
                        justify-self: stretch;
                    }
                    sup {
                        font-size: 6pt
                    }
                    @font-face {
                    font-family:"Arabic Typesetting";
                    /*The location of the loaded TTF font must be relative to the CSS*/
                    src:url("arabt100.ttf");
                    }
                    
                </style>
            </head>
            <body>
                <xsl:if test="not(doc-available(concat($pdu, '/', $witnessCat))) or $debug">
                    <section>
                        <xsl:text>Project Directory URL (PDU): </xsl:text>
                        <xsl:value-of select="$pdu"/>
                        <br/>
                        <xsl:text>Witness Catalogue: </xsl:text>
                        <xsl:value-of select="$witnessCat"/>
                    </section>
                </xsl:if>
                <section class="content">
                    <xsl:apply-templates select="TEI/text/body/lg"/>                    
                </section>
                <hr/>
                <section class="variants">
                    <!-- todo: Für eine einheitliche Ausrichtung Zeilennummern und Varianten in eine Tabelle packen -->
                    <xsl:for-each select="TEI/text/body/lg/(head|lg/l)">
                        <xsl:variable name="linenr" select="if (/TEI/text/body/lg/head) then position() - 1 else position()"/>
                        <xsl:if test="app">
                            <div xmlns="http://www.w3.org/1999/xhtml" class="variants">
                                <span style="font-size: 8pt;padding-left: 20px">
                                    <xsl:if test="$linenr gt 0">
                                        <xsl:value-of select="$linenr"/>
                                    </xsl:if>
                                </span>
                                <xsl:for-each select="app">
                                    <xsl:value-of select="lem"/>]
                                    <xsl:for-each select="rdg">
                                        <xsl:value-of select="."/><span style="padding-left: 3px">:</span><span style="color: gray"><xsl:value-of select="scdh:getWitnessSiglum($pdu, $witnessCat, @wit, ',')"/></span>
                                        <xsl:if test="position() ne last()"><span style="padding-left: 4px">؛</span></xsl:if>
                                    </xsl:for-each>
                                    <xsl:if test="following-sibling::app"><span style="padding: 8px">|</span></xsl:if>
                                </xsl:for-each>
                            </div>
                        </xsl:if>
                    </xsl:for-each>                    
                </section>
                <hr/>
                <section class="comments">
                    <xsl:for-each select="TEI/text/body/lg/(head|lg/l)">
                        <xsl:variable name="linenr" select="if (/TEI/text/body/lg/head) then position() - 1 else position()"/>
                        <xsl:if test="note">
                            <div xmlns="http://www.w3.org/1999/xhtml" class="variants">
                                <span style="font-size: 8pt;padding-left: 20px">
                                    <xsl:if test="$linenr gt 0">
                                        <xsl:value-of select="$linenr"/>
                                    </xsl:if>
                                </span>
                                <xsl:for-each select="note">
                                    <xsl:value-of select="."/>
                                    <sup><xsl:value-of select="count(preceding-sibling::note) + 1"/></sup>
                                    <xsl:if test="following-sibling::note"><span style="padding: 5px">|</span></xsl:if>
                                </xsl:for-each>
                            </div>
                        </xsl:if>
                    </xsl:for-each>
                </section>
            </body>
        </html>
    </xsl:template>
    
    <xsl:template match="body/lg">
        <table xmlns="http://www.w3.org/1999/xhtml">
            <tr>
                <td colspan="3" class="title"><xsl:apply-templates select="head"/></td>
            </tr>
            <xsl:apply-templates select="lg"/>
        </table>
    </xsl:template>
    
    <xsl:template match="body/lg/lg">
        <tr xmlns="http://www.w3.org/1999/xhtml"><td colspan="2"></td></tr>
        <xsl:apply-templates select="l"/>
    </xsl:template>
    
    <xsl:template match="body/lg/lg/l">
        <xsl:choose>
            <!-- todo: Annahme hier: es gibt nur ein caesura. Müsste vorher mit Schematron abgeprüft werden. -->
	    <!-- Fallunterscheidung für Vorkommen und Positionen von caesura. -->
            <xsl:when test="child::caesura">
		<!-- Fall: caesura directes Kind von line -->
                <tr xmlns="http://www.w3.org/1999/xhtml">
                    <td style="font-size: 8pt; padding-left: 10px"><xsl:value-of select="position()"/></td>
                    <td style="padding-left: 40px"><xsl:apply-templates select="child::caesura/preceding-sibling::node()"/></td>
                    <td><xsl:apply-templates select="child::caesura/following-sibling::node()"/></td>
                </tr>
            </xsl:when>
            <xsl:when test="descendant::lem/descendant-or-self::caesura">
		<!-- Fall: caesura teilt lem wie in #1 -->
                <tr xmlns="http://www.w3.org/1999/xhtml">
                    <td style="font-size: 8pt; padding-left: 10px"><xsl:value-of select="position()"/></td>
                    <td style="padding-left: 40px"><xsl:apply-templates select="descendant::lem/descendant-or-self::caesura/preceding-sibling::node()"/></td>
                    <td><xsl:apply-templates select="descendant::lem/descendant-or-self::caesura/following-sibling::node()"/></td>
                </tr>
            </xsl:when>
            <xsl:when test="descendant::caesura and not(descendant::lem/descendant-or-self::caesura)">
		<!-- Fall: kein caesura in lem, aber in rdg -->
                <tr xmlns="http://www.w3.org/1999/xhtml">
                    <td style="font-size: 8pt; padding-left: 10px"><xsl:value-of select="position()"/></td>
                    <td style="padding-left: 40px"><xsl:apply-templates select="*[not(ancestor-or-self::rdg)]"/></td>
                    <td></td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <tr >
                    <td style="font-size: 8pt; padding-left: 10px"><xsl:value-of select="position()"/></td>
                    <td colspan="2"><xsl:copy-of select="descendant::node()"></xsl:copy-of></td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:template match="l/note">
        <sup><xsl:value-of select="count(preceding-sibling::note) + 1"/></sup>
    </xsl:template>
      
    <xsl:template match="(l|head)/app">
        <xsl:value-of select="lem"/>
    </xsl:template>
    
    <xsl:template name="variants">
        <xsl:param name="lg"/>
    </xsl:template>
    
</xsl:stylesheet>
