<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs scdh"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    xmlns="http://www.w3.org/1999/xhtml"
    version="2.0">
    
    <xsl:output media-type="text/html"/>

    <xsl:import href="libwit.xsl"/>
    <xsl:include href="libi18n.xsl"/>
    <xsl:include href="libcommon.xsl"/>

    <!-- URI of witness catalogue. -->
    <xsl:param name="witness-cat" select="'WitnessCatalogue.xml'" as="xs:string"/>

    <xsl:param name="i18n" select="'i18n.js'" as="xs:string"/>
    <xsl:param name="i18next" select="'https://unpkg.com/i18next/i18next.min.js'" as="xs:string"/>
    <xsl:param name="locales-directory" select="'./locales'" as="xs:string"/>

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
                    .static-text, .apparatus-sep, .siglum {
                        color: gray;
                    }
                    @font-face {
                    font-family:"Arabic Typesetting";
                    /*The location of the loaded TTF font must be relative to the CSS*/
                    src:url("arabt100.ttf");
                    }
                    
                </style>
            </head>
            <body>
                <xsl:if test="not(doc-available($witness-cat)) or $debug">
                    <section>
                        <xsl:text>Witness Catalogue: </xsl:text>
                        <xsl:value-of select="$witness-cat"/>
                        <br/>
                        <xsl:text>UI language: </xsl:text>
                        <xsl:value-of select="$ui-language"/>
                    </section>
                </xsl:if>
                <section class="content">
                    <xsl:apply-templates select="TEI/text"/>
                </section>
                <hr/>
                <section class="variants">
                    <table>
                        <xsl:apply-templates
                            select="TEI/text//(l|p)
                                       [descendant::app or
                                        descendant::gap or
                                        descendant::unclear or
                                        descendant::choice or
                                        descendant::sic or
                                        descendant::corr or
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
                <hr/>
                <xsl:call-template name="i18n-language-chooser-html">
                    <xsl:with-param name="debug" select="$debug"/>
                </xsl:call-template>
                <!--xsl:call-template name="i18n-direction-indicator"/-->
                <script src="{$i18next}"></script>
                <script>
                    <xsl:call-template name="i18n-language-resources-inline">
                        <xsl:with-param name="locales-directory" select="$locales-directory"/>
                    </xsl:call-template>
                </script>
                <script src="{$i18n}"></script>
            </body>
        </html>
    </xsl:template>

    <xsl:template match="text">
        <table>
            <!-- this table has 3 columns: 1: line number,
                2 and 3: hemispheres of a verse or something else with @colspan="2" -->
            <xsl:apply-templates select="*"/>
        </table>
    </xsl:template>

    <xsl:template match="p[not(ancestor::note)]">
        <tr>
            <td style="font-size: 8pt; padding-left: 10px" valign="top">
                <xsl:value-of select="scdh:line-number(.)"/>
            </td>
            <td colspan="2">
                <xsl:apply-templates/>
            </td>
        </tr>
    </xsl:template>

    <!-- verses with head -->
    <xsl:template match="lg[not(parent::lg) and child::head]">
        <tr>
            <td><xsl:value-of select="scdh:line-number(head)"/></td>
            <td colspan="2" class="title">
                <xsl:apply-templates select="head"/>
                <xsl:apply-templates select="@met" mode="head"/>
            </td>
        </tr>
        <xsl:apply-templates select="* except head"/>
    </xsl:template>

    <!-- print verse meter -->
    <xsl:template match="@met" mode="head">
        <xsl:variable name="met" select="."/>
        <span class="static-text">
            <xsl:text> [</xsl:text>
            <xsl:value-of select="/TEI/teiHeader//metSym[@value eq $met]//term[1]"/>
            <xsl:text>] </xsl:text>
        </span>
    </xsl:template>

    <!-- verses without head -->
    <xsl:template match="lg[not(parent::lg) and not(child::head)]">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <xsl:template match="lg/lg">
        <tr xmlns="http://www.w3.org/1999/xhtml"><td colspan="3"></td></tr>
        <xsl:apply-templates select="l|app/lem/l"/>
    </xsl:template>

    <xsl:template match="l[not(ancestor::head)]">
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

    <xsl:template match="l|app//l|p|app//p[not(ancestor::note)]" mode="apparatus-number">
        <tr>
            <td><xsl:value-of select="scdh:line-number(.)"/></td>
            <td>
                <!-- we can't add simple ...|ancestor::app to the selector, because then we
                    lose focus on the line when there are several in an <app>. See #12.
                    We need app//l instead an some etra templates for handling app//l. -->
                <xsl:for-each select="app|gap|unclear|sic|choice|app/lem/(gap|unclear|choice)|self::l[ancestor::app]|self::p[ancestor::app and not(ancestor::note)]">
                    <xsl:apply-templates select="." mode="apparatus"/>
                    <xsl:if test="position() != last()">
                        <span class="apparatus-sep" data-i18n-key="app-entry-sep">&nbsp;|&emsp;</span>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="app" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates select="lem" mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
        <xsl:for-each select="rdg">
            <!-- repeat prefix if necessary -->
            <xsl:if test="parent::app/lem[. eq '']">
                <xsl:apply-templates select="parent::app/lem" mode="apparatus-lemma"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:apply-templates select="." mode="apparatus"/>
            <xsl:apply-templates select="." mode="apparatus-annotation"/>
            <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep">:</span>
            <xsl:call-template name="witness-siglum-html">
                <xsl:with-param name="wit" select="@wit"/>
            </xsl:call-template>
            <xsl:if test="position() ne last()"><span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span></xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="app/lem/l|app/lem/p[not(ancestor::note)]" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates select="parent::lem" mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
        <xsl:for-each select="parent::lem/parent::app/rdg">
            <xsl:apply-templates select="." mode="apparatus"/>
            <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep">:</span>
            <xsl:call-template name="witness-siglum-html">
                <xsl:with-param name="wit" select="@wit"/>
            </xsl:call-template>
            <xsl:if test="position() ne last()"><span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span></xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="l[not(ancestor::app/lem/l)]|p[not(ancestor::app/lem/p) and not(ancestor::note)]"
        mode="apparatus">
        <xsl:apply-templates mode="apparatus"/>
        <xsl:text> </xsl:text>
        <span class="static-text" data-i18n-key="extra-verse">&lre;extra verse&pdf;</span>
        <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep">:</span>
        <xsl:call-template name="witness-siglum-html">
            <xsl:with-param name="wit" select="parent::rdg/@wit"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="rdg[. eq '']" mode="apparatus">
        <xsl:choose>
            <xsl:when test="parent::app/lem/l|parent::app/rdg/l">
                <span class="static-text" data-i18n-key="verse-missing">&lre;verse missing&pdf;</span>
            </xsl:when>
            <xsl:when test="parent::app/lem/p|parent::app/rdg/p">
                <span class="static-text" data-i18n-key="paragraph-missing">&lre;paragraph missing&pdf;</span>
            </xsl:when>
            <xsl:otherwise>
                <span class="static-text" data-i18n-key="missing">&lre;missing&pdf;</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="unclear" mode="apparatus">
        <xsl:apply-templates select="."/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <xsl:choose>
            <xsl:when test="@reason">
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of select="@reason"/>&pdf;</span>
            </xsl:when>
            <xsl:otherwise>
                <span class="static-text" data-i18n-key="unclear">&lre;unclear&pdf;</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- needed for unclear in rdg for printing the reading -->
    <xsl:template match="unclear[parent::rdg]" mode="apparatus">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="gap" mode="apparatus">
        <span class="static-text" data-i18n-key="gap-rep">[...]</span>
        <xsl:text> </xsl:text>
        <xsl:choose>
            <xsl:when test="@reason">
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of select="@reason"/>&pdf;</span>
            </xsl:when>
            <xsl:otherwise><span class="static-text" data-i18n-key="gap">&lre;omitted&pdf;</span></xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@quantity and @unit">
            <span class="apparatus-sep" data-i18n-key="reason-quantity-sep">, </span>
            <span class="static-text"><xsl:value-of select="@quantity"/></span>
            <xsl:text>&#160;</xsl:text>
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"/>&pdf;</span>
        </xsl:if>
    </xsl:template>

    <!-- needed for gap in rdg for printing the reading -->
    <xsl:template match="gap[parent::rdg]" mode="apparatus">
        <span class="static-text" data-i18n-key="gap-rdg">(…)</span>
    </xsl:template>

    <xsl:template match="choice[child::sic and child::corr]" mode="apparatus">
        <xsl:apply-templates select="corr"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <xsl:apply-templates select="sic"/>
        <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="corr-sic-sep"> </span>
        <span class="static-text" data-i18n-key="corr-sic">&lre;(corrected)&pdf;</span>
    </xsl:template>

    <xsl:template match="choice[child::sic/app and child::corr]" mode="apparatus">
        <xsl:apply-templates select="corr"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <xsl:for-each select="sic/app/rdg">
            <xsl:apply-templates select="." mode="apparatus"/>
            <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep">:</span>
            <xsl:call-template name="witness-siglum-html">
                <xsl:with-param name="wit" select="@wit"/>
            </xsl:call-template>
            <xsl:if test="position() ne last()"><span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span></xsl:if>
        </xsl:for-each>
        <xsl:text> </xsl:text>
        <span class="static-text" data-i18n-key="corr-rdgs">&lre;(corrected)&pdf;</span>
    </xsl:template>

    <xsl:template match="sic[not(parent::choice)]" mode="apparatus">
        <xsl:apply-templates/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <span class="static-text" data-i18n-key="sic">&lre;sic!&pdf;</span>
    </xsl:template>

    <xsl:template match="corr[not(parent::choice)]" mode="apparatus">
        <xsl:apply-templates/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <span class="static-text" data-i18n-key="corr">&lre;corrected&pdf;</span>
    </xsl:template>

    <xsl:template match="caesura[ancestor::rdg]" mode="apparatus">
        <span>||</span>
    </xsl:template>


    <!-- MODE: apparatus-annotation
        When an rdg has nested unclear, gap or corr elements, we have to put that in the apparatus.
        The templates in apparatus-annotation mode append annotations on a apparatus entry. -->

    <!-- Append annotation to rdg. This is an entry point to be reused. -->
    <xsl:template match="rdg" mode="apparatus-annotation">
        <xsl:if test="unclear|gap|corr|sic">
            <span class="apparatus-sep" data-i18n-key="rdg-annotation-pre"> (</span>
            <xsl:for-each select="unclear|gap|corr|sic">
                <xsl:apply-templates select="." mode="apparatus-annotation"/>
                <xsl:if test="position() ne last()"><span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdg-annotation-sep">, </span></xsl:if>
            </xsl:for-each>
            <span class="apparatus-sep" data-i18n-key="rdg-annotation-post">) </span>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gap" mode="apparatus-annotation">
        <xsl:choose>
            <xsl:when test="@reason">
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of select="@reason"/>&pdf;</span>
            </xsl:when>
            <xsl:otherwise><span class="static-text" data-i18n-key="gap">&lre;omitted&pdf;</span></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="unclear" mode="apparatus-annotation">
        <xsl:choose>
            <xsl:when test="@reason">
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of select="@reason"/>&pdf;</span>
            </xsl:when>
            <xsl:otherwise>
                <span class="static-text" data-i18n-key="unclear">&lre;unclear&pdf;</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="sic" mode="apparatus-annotation">
        <span class="static-text" data-i18n-key="sic">&lre;sic!&pdf;</span>
    </xsl:template>

    <xsl:template match="corr" mode="apparatus-annotation">
        <span class="static-text" data-i18n-key="corr">&lre;corrected&pdf;</span>
    </xsl:template>

    <!-- MODE: apparatus-lemma
        These templates are generate the text repeated as the lemma in the apparatus.-->

    <xsl:template match="lem[. eq '']" mode="apparatus-lemma">
        <!-- We have to present something, to mark the place where the variant adds something.
             So we decide:
             If it is the start of the line to present a special character and
             else to present a one-word prefix! If and only if it is not the start of the line. -->
        <xsl:choose>
            <!-- This branch should not be used anymore -->
            <xsl:when test="(parent::app/preceding-sibling::l) or (parent::app/following-sibling::l)">
                <xsl:text>^ </xsl:text>
            </xsl:when>
            <xsl:when test="(parent::app/preceding-sibling::p) or (parent::app/following-sibling::p)">
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

    <xsl:template match="l|p[not(ancestor::note)]" mode="apparatus-lemma">
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

    <xsl:template match="sic[not(parent::choice)]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="corr[not(parent::choice)]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template name="variants">
        <xsl:param name="lg"/>
    </xsl:template>
    
</xsl:stylesheet>
