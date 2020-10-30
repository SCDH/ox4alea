<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs scdh"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    version="2.0">
    
    <xsl:output media-type="text/html"/>

    <xsl:include href="libwit.xsl"/>
    <xsl:include href="libi18n.xsl"/>
    <xsl:include href="libcommon.xsl"/>

    <!-- ${pdu} oxygen editor variable: project root directory URI -->
    <xsl:param name="pdu" select="string('.')" as="xs:string"/>

    <!-- Filename of witness catalogue. -->
    <xsl:param name="witnessCat" select="'WitnessCatalogue.xml'" as="xs:string"/>
    
    <xsl:param name="debug" select="false()" as="xs:boolean"/>

    <!-- language of the user interface, i.e. static text e.g. in the apparatus -->
    <xsl:param name="ui-language" as="xs:string" select="''"/>

    <xsl:function name="scdh:ui-language">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:value-of
            select="if ($ui-language eq '') then scdh:language($context, $default) else $ui-language"/>
    </xsl:function>

    <xsl:function name="scdh:ui-language">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of
            select="if ($ui-language eq '') then scdh:language($context, 'ar') else $ui-language"/>
    </xsl:function>

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
                        direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
                        font-family:"Arabic Typesetting";                    
                    }
                    .variants {
                        direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
                    }
                    .comments {
                        direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
                    }
                    hr {
                        margin: 20px
                    }
                    td {
                        text-align: <xsl:value-of select="scdh:language-align(TEI/text)"/>;
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
                        <br/>
                        <xsl:text>UI language: </xsl:text>
                        <xsl:value-of select="$ui-language"/>
                    </section>
                </xsl:if>
                <section class="content">
                    <xsl:apply-templates select="TEI/text/body"/>
                </section>
                <hr/>
                <section class="variants">
                    <table>
                        <xsl:apply-templates
                            select="//l[descendant::app or
                                        descendant::gap or
                                        descendant::unclear or
                                        descendant::choice or
                                        ancestor::app]"
                            mode="apparatus-number"/>
                    </table>
                </section>
                <hr/>
                <section class="comments">
                    <xsl:for-each select="TEI/text/body/lg/(head|lg/l)">
                        <xsl:variable name="linenr" select="if (/TEI/text/body/lg/head) then position() - 1 else position()"/>
                        <xsl:if test="note">
                            <div xmlns="http://www.w3.org/1999/xhtml" class="variants">
                                <span style="font-size: 8pt;padding-left: 20px">
                                    <xsl:value-of select="scdh:line-number(.)"/>
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
    
    <xsl:template match="lg[child::head and child::lg]">
        <table xmlns="http://www.w3.org/1999/xhtml">
            <tr>
                <td><xsl:value-of select="scdh:line-number(head)"/></td>
                <td colspan="1" class="title"><xsl:apply-templates select="head"/></td>
            </tr>
            <xsl:apply-templates select="lg"/>
        </table>
    </xsl:template>
    
    <xsl:template match="lg/lg">
        <tr xmlns="http://www.w3.org/1999/xhtml"><td colspan="3"></td></tr>
        <xsl:apply-templates select="l|app/lem/l"/>
    </xsl:template>
    
    <xsl:template match="lg/lg//l">
        <xsl:choose>
            <!-- todo: Annahme hier: es gibt nur ein caesura. Müsste vorher mit Schematron abgeprüft werden. -->
	    <!-- Fallunterscheidung für Vorkommen und Positionen von caesura. -->
            <xsl:when test="child::caesura">
		<!-- Fall: caesura directes Kind von line -->
                <tr xmlns="http://www.w3.org/1999/xhtml">
                    <td style="font-size: 8pt; padding-left: 10px"><xsl:value-of select="scdh:line-number(.)"/></td>
                    <td style="padding-left: 40px"><xsl:apply-templates select="child::caesura/preceding-sibling::node()"/></td>
                    <td><xsl:apply-templates select="child::caesura/following-sibling::node()"/></td>
                </tr>
            </xsl:when>
            <xsl:when test="descendant::lem//caesura">
		<!-- Fall: caesura teilt lem wie in #1 -->
                <tr xmlns="http://www.w3.org/1999/xhtml">
                    <td style="font-size: 8pt; padding-left: 10px"><xsl:value-of select="scdh:line-number(.)"/></td>
                    <td style="padding-left: 40px">
                        <xsl:apply-templates
                            select="descendant::lem//caesura/preceding::node() intersect descendant::node()
                                    except scdh:non-lemma-nodes(.)"/>
                    </td>
                    <td>
                        <xsl:apply-templates
                            select="(descendant::lem//caesura/following::node() intersect descendant::node())
                                    except scdh:non-lemma-nodes(.)"/>
                    </td>
                </tr>
            </xsl:when>
            <xsl:when test="descendant::caesura and not(descendant::lem/descendant-or-self::caesura)">
		<!-- Fall: kein caesura in lem, aber in rdg -->
                <tr xmlns="http://www.w3.org/1999/xhtml">
                    <td style="font-size: 8pt; padding-left: 10px"><xsl:value-of select="scdh:line-number(.)"/></td>
                    <td style="padding-left: 40px"><xsl:apply-templates select="*[not(ancestor-or-self::rdg)]"/></td>
                    <td></td>
                </tr>
            </xsl:when>
            <xsl:otherwise>
                <tr>
                    <td style="font-size: 8pt; padding-left: 10px"><xsl:value-of select="scdh:line-number(.)"/></td>
                    <td colspan="2"><xsl:apply-templates/></td>
                </tr>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    
    <xsl:function name="scdh:non-lemma-nodes" as="node()*">
        <xsl:param name="element" as="node()"/>
        <xsl:sequence select="$element/descendant-or-self::rdg/descendant-or-self::node()"/>
    </xsl:function>

    <xsl:template match="(l|app//l)" mode="apparatus-number">
        <tr>
            <td><xsl:value-of select="scdh:line-number(.)"/></td>
            <td>
                <xsl:for-each select="app|gap|unclear|choice|app/lem/(gap|unclear|choice)|ancestor::app">
                    <xsl:apply-templates select="." mode="apparatus"/>
                    <xsl:if test="position() != last()">
                        <span style="white-space:nowrap">&#8201;</span><xsl:text>|&#8195;</xsl:text>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="app" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates select="lem" mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>]
        <xsl:for-each select="rdg">
            <!-- repeat prefix if necessary -->
            <xsl:if test="parent::app/lem[. eq '']">
                <xsl:apply-templates select="parent::app/lem" mode="apparatus-lemma"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:apply-templates select="." mode="apparatus"/>
            <span style="padding-left: 3px">:</span>
            <span style="color: gray"><xsl:value-of select="scdh:getWitnessSiglum($pdu, $witnessCat, @wit, ',')"/></span>
            <xsl:if test="position() ne last()"><span style="padding-left: 4px">؛</span></xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="rdg[. eq '']" mode="apparatus">
        <xsl:choose>
            <xsl:when test="parent::app/lem/l|parent::app/rdg/l">
                <xsl:value-of select="scdh:translate(scdh:ui-language(.), 'verse missing', '&lre;verse missing&pdf;')"/>
            </xsl:when>
            <xsl:when test="parent::app/lem/p|parent::app/rdg/p">
                <xsl:value-of select="scdh:translate(scdh:ui-language(.), 'paragraph missing', '&lre;paragraph missing&pdf;')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="scdh:translate(scdh:ui-language(.), 'missing', '&lre;missing&pdf;')"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="unclear" mode="apparatus">
        <xsl:apply-templates select="."/>]
        <xsl:value-of select="scdh:translate(scdh:ui-language(.), 'unclear', '&lre;unclear&pdf;')"/>
        <xsl:if test="@reason">
            <xsl:value-of select="scdh:translate(scdh:ui-language(.), ', ', ', ')"/>
            <xsl:value-of select="scdh:translate(scdh:ui-language(.), @reason, concat('&lre;', @reason, '&pdf;'))"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="gap" mode="apparatus">
        <!--xsl:text>[...] </xsl:text-->
        <xsl:if test="@reason">
            <xsl:value-of select="scdh:translate(scdh:ui-language(.), @reason, concat('&lre;', @reason, '&pdf;'))"/>
        </xsl:if>
        <xsl:if test="@quantity and @unit">
            <xsl:value-of select="scdh:translate(scdh:ui-language(.), ', ', ', ')"/>
            <xsl:value-of select="scdh:translate(scdh:ui-language(.), @quantity, concat('&lre;', @quantity, '&pdf;'))"/>
            <xsl:text>&#160;</xsl:text>
            <xsl:value-of select="scdh:translate(scdh:ui-language(.), @unit, concat('&lre;', @unit, '&pdf;'))"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="choice[child::sic and child::corr]" mode="apparatus">
        <xsl:value-of select="corr"/>
        <xsl:text>] </xsl:text>
        <xsl:value-of select="sic"/>
        <span style="padding-left: 3px">:</span>
        <span style="color: gray"><xsl:value-of select="scdh:translate(scdh:ui-language(.), 'reading', '&lre;reading&pdf;')"/></span>
    </xsl:template>


    <!-- MODE: apparatus-lemma
        These templates are generate the text repeated as the lemma in the apparatus.-->

    <xsl:template match="lem[. eq '']" mode="apparatus-lemma">
        <!-- We have to present something, to mark the place where the variant adds something.
             So we decide:
             If it is the start of the line to present a special character and
             else to present a one-word prefix! If and only if it is not the start of the line. -->
        <xsl:choose>
            <xsl:when test="(parent::app/preceding-sibling::l) or (parent::app/following-sibling::l)">
                <!--xsl:value-of select="scdh:translate(scdh:language(.), 'extra verse', '&lre;extra verse&pdf;')"/-->
                <xsl:text>^ </xsl:text>
            </xsl:when>
            <xsl:when test="(normalize-space(string-join(parent::app/preceding-sibling::node(), ' ')) eq '')">
                <xsl:text>^ </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="predecessors">
                    <!-- we use the apparatus-lemma mode because we do not want the line numbers -->
                    <xsl:apply-templates select="parent::app/preceding-sibling::node()" mode="apparatus-lemma"/>
                </xsl:variable>
                <xsl:value-of select="tokenize(normalize-space(string($predecessors)), '\s+')[last()]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="lem" mode="apparatus-lemma">
        <xsl:apply-templates mode="apparatus-lemma"/>
    </xsl:template>

    <xsl:template match="l" mode="apparatus-lemma">
        <xsl:apply-templates mode="apparatus-lemma"/>
    </xsl:template>

    <xsl:template match="*" mode="apparatus-lemma">
        <!-- We can pass it over to the default templates, now. -->
        <xsl:apply-templates/>
    </xsl:template>


    <!-- MODE: default
        These templates are used to generate the main text presented. -->
    
    <xsl:template match="l/note">
        <sup><xsl:value-of select="count(preceding-sibling::note) + 1"/></sup>
    </xsl:template>
      
    <xsl:template match="app">
        <xsl:apply-templates select="lem"/>
    </xsl:template>

    <xsl:template match="(lem[not(/*|/text())]|rdg[not(/*|/text())])">
        <xsl:text>[!!!]</xsl:text>
    </xsl:template>

    <xsl:template match="gap">
        <xsl:text>[...]</xsl:text>
    </xsl:template>
    
    <xsl:template match="unclear">
        <!--xsl:text>[? </xsl:text-->
        <xsl:apply-templates />
        <!--xsl:text> ?]</xsl:text-->
    </xsl:template>
    
    <xsl:template match="choice[child::sic and child::corr]">
        <xsl:apply-templates select="corr"/>
    </xsl:template>
    
    <xsl:template name="variants">
        <xsl:param name="lg"/>
    </xsl:template>
    
</xsl:stylesheet>
