<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs scdh"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">
    
    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:import href="libwit.xsl"/>
    <xsl:include href="libi18n.xsl"/>
    <xsl:include href="libcommon.xsl"/>
    <xsl:include href="libanchors.xsl"/>
    <xsl:import href="libld.xsl"/>

    <!-- URI of witness catalogue. -->
    <xsl:param name="witness-cat" select="'WitnessCatalogue.xml'" as="xs:string"/>

    <!-- URI of bibliography -->
    <xsl:param name="biblio" as="xs:string" select="'../samples/biblio.xml'"/>

    <xsl:param name="i18n" select="'i18n.js'" as="xs:string"/>
    <xsl:param name="i18next" select="'https://unpkg.com/i18next/i18next.min.js'" as="xs:string"/>
    <xsl:param name="locales-directory" select="'./locales'" as="xs:string"/>

    <xsl:param name="debug" select="false()" as="xs:boolean"/>

    <!-- language of the user interface, i.e. static text e.g. in the apparatus -->
    <xsl:param name="ui-language" as="xs:string" select="''"/>

    <!-- If true, this an extra space is added on the end of an ltr-to-rtl changeover. -->
    <xsl:param name="ltr-to-rtl-extra-space" as="xs:boolean" select="true()" required="no"/>

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
        <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;&lb;</xsl:text>
        <html lang="{scdh:language(TEI)}">
            <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <title>ALEA Vorschau</title>
                <style>
                    .title {
                        color:red;
                    }
                    body {
                        direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
                        font-family:"Arabic Typesetting";                    
                    }
                    .metadata {
                        direction: ltr;
                        text-align: right;
                        margin: 0 2em;
                    }
                    .variants {
                        direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
                    }
                    .comments {
                        direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
                    }
                    hr {
                        margin: 1em 2em;                    }
                    td {
                        text-align: <xsl:value-of select="scdh:language-align(TEI/text)"/>;
                        justify-content: space-between;
                        justify-self: stretch;
                    }
                    td.line-number, td.apparatus-line-number, td.editorial-note-number {
                        vertical-align:top;
                        text-align:right;
                        font-size: 0.7em;
                        padding-top: 0.3em;
                        padding-left: 10px;
                    }
                    td.text-col1 {
                        padding-left: 40px;
                    }
                    sup {
                        font-size: 6pt
                    }
                    .static-text, .apparatus-sep, .siglum {
                        color: gray;
                    }
                    abbr {
                        text-decoration: none;
                    }
                    @font-face {
                        font-family:"Arabic Typesetting";
                        src:url("../../../arabt100.ttf");
                    }
                    @font-face {
                        font-family:"Amiri Regular";
                        src:url("../../../resources/css/Amiri-Regular.ttf");
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
                <section class="metadata">
                    <xsl:apply-templates select="TEI/teiHeader" mode="metadata"/>
                </section>
                <hr/>
                <section class="content">
                    <xsl:apply-templates select="TEI/text/body"/>
                </section>
                <hr/>
                <section class="variants">
                    <table>
                        <xsl:apply-templates
                            select="TEI/text//(l[not(ancestor::head)]|p|head)
                                       [descendant::app or
                                        descendant::witDetail or
                                        descendant::gap or
                                        descendant::unclear or
                                        descendant::choice or
                                        descendant::sic or
                                        descendant::corr or
                                        descendant::supplied or
                                        ancestor::app]"
                            mode="apparatus-line"/>
                    </table>
                </section>
                <hr/>
                <section class="comments">
                    <table>
                        <xsl:apply-templates
                            select="TEI/text//note |
                                    TEI/text//anchor[exists(let $id := @xml:id return //span[@from eq concat('#', $id)])]"
                            mode="editorial-note-entry"/>
                    </table>
                    <!--
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
                    -->
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


    <!-- # Edited text (main text) # -->

    <!-- Prose -->
    <xsl:template match="p[not(ancestor::note)]">
        <p>
            <span class="line-number paragraph-number"><xsl:value-of select="scdh:line-number(.)"/></span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- Verse: This matches a group of verses, i.e. a poem.
        In the output, a table is created. The verse number goes
        into the first column, verses go into the other column(s).
        If there is a caesura (if the verse is a hemistichion)
        there must be left and right text columns. -->
    <xsl:template match="lg">
        <!-- This kind of poem goes into a table of columns -->
        <table>
            <!-- this table has 3 columns: 1: line number,
                2 and 3: hemispheres of a verse or something else with @colspan="2" -->
            <xsl:apply-templates select="*"/>
        </table>
    </xsl:template>

    <!-- nested group of verses, i.e. a stanza -->
    <xsl:template match="lg[parent::lg]">
        <xsl:apply-templates select="*"/>
    </xsl:template>

    <!-- header of a poem -->
    <xsl:template match="head[ancestor::lg]">
        <tr>
            <td class="line-number"><xsl:value-of select="scdh:line-number(.)"/></td>
            <td colspan="2" class="title text-col1">
                <!-- Note: The head should not contain a verse, because that would result in
                    a table row nested in a tabel row. -->
                <xsl:apply-templates/>
                <!-- verse meter (metrum) is printed along with the poems header -->
                <xsl:if test="ancestor::*/@met">
                    <xsl:variable name="met" select="ancestor::*/@met[1]"/>
                    <span class="static-text">
                        <xsl:text> [</xsl:text>
                        <!-- The meters name is pulled from the metDecl
                            in the encodingDesc in the document header -->
                        <xsl:value-of select="/TEI/teiHeader//metSym[@value eq $met]//term[1]"/>
                        <xsl:text>] </xsl:text>
                    </span>
                </xsl:if>
            </td>
        </tr>
    </xsl:template>

    <!-- single verse with caesura: The hemistichion must be split by caesura and distributed
        into text columns.
        Since the caesura may be deeply nested in other elements, we enter a recursive distribution
        of the two hemispheres.
        Implementation note: xsl:for-each-group may seem as an alternative, but isn't well-suited
        for handling nested structures and we only have 2 target groups. -->
    <xsl:template match="l[not(ancestor::head) and descendant::caesura]">
        <tr>
            <td class="line-number"><xsl:value-of select="scdh:line-number(.)"/></td>
            <td class="text-col1">
                <!-- output of nodes that preced caesura -->
                <xsl:apply-templates select="node() intersect descendant::caesura[not(ancestor::rdg)]/preceding::node() except scdh:non-lemma-nodes(.)"/>
                <!-- recursively handle nodes, that contain caesura -->
                <xsl:apply-templates select="*[descendant::caesura]" mode="before-caesura"/>
            </td>
            <td>
                <!-- recursively handle nodes, that contain caesura -->
                <xsl:apply-templates select="*[descendant::caesura]" mode="after-caesura"/>
                <!-- output nodes that follow caesura -->
                <xsl:apply-templates select="node() intersect descendant::caesura[not(ancestor::rdg)]/following::node() except scdh:non-lemma-nodes(.)"/>
            </td>
        </tr>
    </xsl:template>

    <!-- nodes that contain caesura: recursively output everything preceding caesura -->
    <xsl:template match="*[descendant::caesura]" mode="before-caesura">
        <xsl:message>Entered before-caesura mode: <xsl:value-of select="local-name()"/></xsl:message>
        <!-- output of nodes that preced caesura -->
        <xsl:apply-templates select="node() intersect descendant::caesura[not(ancestor::rdg)]/preceding::node() except scdh:non-lemma-nodes(.)"/>
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="before-caesura"/>
    </xsl:template>

    <!-- nodes that contain caesura: recursively output everything following caesura -->
    <xsl:template match="*[descendant::caesura]" mode="after-caesura">
        <xsl:message>Entered after-caesura mode: <xsl:value-of select="local-name()"/></xsl:message>
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="after-caesura"/>
        <!-- output nodes that follow caesura -->
        <xsl:apply-templates select="node() intersect descendant::caesura[not(ancestor::rdg)]/following::node() except scdh:non-lemma-nodes(.)"/>
    </xsl:template>

    <!-- When the caesura is not present in the nested node, then output the node only once and warn the user.  -->
    <xsl:template match="*" mode="before-caesura">
        <xsl:message>WARNING: broken document? caesura missing</xsl:message>
        <xsl:apply-templates/>
    </xsl:template>
    <xsl:template match="*" mode="after-caesura"/>

    <!-- verse without caesura in lemma: the verse goes into the first text column
        NOTE: This must override the one for simple verses with caesura by setting its priority! -->
    <xsl:template match="l[not(ancestor::head) and descendant::caesura[ancestor::rdg ] and not(descendant::caesura[ancestor::lem])]"
        priority="1">
        <tr>
            <td class="line-number"><xsl:value-of select="scdh:line-number(.)"/></td>
            <td class="text-col1">
                <!--xsl:apply-templates select="descendant::caesura/preceding-sibling::node()"/-->
                <xsl:apply-templates select="node() except scdh:non-lemma-nodes(.)"/>
            </td>
            <td></td>
        </tr>
    </xsl:template>

    <!-- verse without caesura, but within group of verses: the whole verse spans the two text columns -->
    <xsl:template match="l[not(ancestor::head) and not(descendant::caesura) and ancestor::lg]">
        <tr>
            <td class="apparatus-line-number"><xsl:value-of select="scdh:line-number(.)"/></td>
            <td colspan="2" class="text-col1">
                <xsl:apply-templates select="node() except scdh:non-lemma-nodes(.)"/>
            </td>
        </tr>
    </xsl:template>

    <!-- verses nested in head -->
    <xsl:template match="l[ancestor::head]">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- all other verses, i.e. verses outside of lg (and not in head) -->
    <xsl:template match="l">
        <p>
            <span class="line-number verse-number"><xsl:value-of select="scdh:line-number(.)"/> </span>
            <xsl:text> </xsl:text>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <xsl:template match="name[@type]">
        <xsl:variable name="cat" select="@type"/>
        <abbr title="{/TEI/teiHeader/encodingDesc//category[@xml:id eq replace($cat, '#', '')]/catDesc[1]}">
            <xsl:apply-templates/>
        </abbr>
    </xsl:template>

    <!-- rdg: Do not output reading (variant) in all modes generating edited text. -->
    <xsl:template match="rdg"/>
    <xsl:template match="rdg" mode="before-caesura" priority="2"/>
    <xsl:template match="rdg" mode="after-caesura" priority="2"/>

    <xsl:function name="scdh:non-lemma-nodes" as="node()*">
        <xsl:param name="element" as="node()"/>
        <xsl:sequence select="$element/descendant-or-self::rdg/descendant-or-self::node()"/>
    </xsl:function>


    <!-- ## inline elements ## -->

    <!--
    <xsl:template match="note">
        <sup><xsl:value-of select="scdh:note-number(.)"/></sup>
    </xsl:template>
    -->

    <xsl:template match="note"/>

    <xsl:template match="witDetail"/>

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

    <xsl:template match="choice[child::sic and child::corr]" mode="before-caesura" priority="1">
        <xsl:message>entered choice in before-caesura mode</xsl:message>
        <xsl:apply-templates select="corr" mode="before-caesura"/>
    </xsl:template>

    <xsl:template match="choice[child::sic and child::corr]" mode="after-caesura" priority="1">
        <xsl:message>entered choice in after-caesura mode</xsl:message>
        <xsl:apply-templates select="corr" mode="after-caesura"/>
    </xsl:template>

    <xsl:template match="sic[not(parent::choice)]">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="corr[not(parent::choice)]">
        <xsl:apply-templates/>
    </xsl:template>

    <!-- for segmentation, a prefix or suffix may be needed -->
    <xsl:template match="seg">
        <xsl:call-template name="tag-start-end">
            <xsl:with-param name="node" as="node()" select="."/>
            <xsl:with-param name="type" select="'start'"/>
        </xsl:call-template>
        <xsl:apply-templates/>
        <xsl:call-template name="tag-start-end">
            <xsl:with-param name="node" as="node()" select="."/>
            <xsl:with-param name="type" select="'end'"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="seg" mode="before-caesura" priority="1">
        <xsl:call-template name="tag-start-end">
            <xsl:with-param name="node" select="."/>
            <xsl:with-param name="type" select="'start'"/>
        </xsl:call-template>
        <!-- output of nodes that preced caesura -->
        <xsl:apply-templates select="node() intersect descendant::caesura[not(ancestor::rdg)]/preceding::node() except scdh:non-lemma-nodes(.)"/>
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="before-caesura"/>
    </xsl:template>

    <xsl:template match="seg" mode="after-caesura" priority="1">
        <!-- recursively handle nodes, that contain caesura -->
        <xsl:apply-templates select="*[descendant::caesura]" mode="after-caesura"/>
        <!-- output nodes that follow caesura -->
        <xsl:apply-templates select="node() intersect descendant::caesura/following::node() except scdh:non-lemma-nodes(.)"/>
        <xsl:call-template name="tag-start-end">
            <xsl:with-param name="node" select="."/>
            <xsl:with-param name="type" select="'end'"/>
        </xsl:call-template>
    </xsl:template>

    <!-- named template for inserting prefixes and suffixes of tagged content -->
    <xsl:template name="tag-start-end">
        <xsl:param name="node" as="node()"/>
        <xsl:param name="type" as="xs:string"/>
        <xsl:choose>
            <!-- ornamented parenthesis around verbatim citation from holy text:
                not in verses (poems) -->
            <xsl:when test="not($node/ancestor::l) and name($node) eq 'seg' and $node/@type eq '#verbatim-holy' and matches(scdh:language($node), '^ar') and $type eq 'start'">
                <xsl:text>&#xfd3f;</xsl:text>
            </xsl:when>
            <!-- closing ornamented parenthesis -->
            <xsl:when test="not($node/ancestor::l) and name($node) eq 'seg' and $node/@type eq '#verbatim-holy' and matches(scdh:language($node), '^ar') and $type eq 'end'">
                <xsl:text>&#xfd3e;</xsl:text>
            </xsl:when>
            <xsl:otherwise/>
        </xsl:choose>
    </xsl:template>

    <!-- DEPRECATED -->
    <xsl:template name="variants">
        <xsl:param name="lg"/>
    </xsl:template>


    <!-- # Apparatus # -->

    <!-- ## Apparatus line ## -->

    <!-- make an apparatus line and hand over to templates that do the apparatus entries -->
    <xsl:template match="head|app//head|l|app//l|p|app//p[not(ancestor::note)]" mode="apparatus-line">
        <tr>
            <td class="apparatus-line-number">
                <xsl:value-of select="scdh:line-number(.)"/>
            </td>
            <td>
                <!-- we can't add simple ...|ancestor::app to the selector, because then we
                    lose focus on the line when there are several in an <app>. See #12.
                    We need app//l instead an some etra templates for handling app//l. -->
                <xsl:for-each select="descendant::app[not(parent::sic)] |
                                      descendant::gap[not(parent::lem)] |
                                      descendant::unclear[not(parent::lem)] |
                                      descendant::sic[not(parent::choice)] |
                                      descendant::corr[not(parent::choice)] |
                                      descendant::choice |
                                      descendant::supplied[not(parent::rdg)] |
                                      descendant::witDetail[not(parent::app)] |
                                      descendant::app/lem/(gap|unclear|choice) |
                                      self::l[ancestor::app] |
                                      self::head[ancestor::app] |
                                      self::p[ancestor::app and not(ancestor::note)]">
                    <xsl:apply-templates select="." mode="apparatus"/>
                    <xsl:if test="position() != last()">
                        <span class="apparatus-sep" data-i18n-key="app-entry-sep">&nbsp;|&emsp;</span>
                    </xsl:if>
                </xsl:for-each>
            </td>
        </tr>
    </xsl:template>

    <!-- ## Apparatus entries ## -->

    <xsl:template match="app" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates select="lem" mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
        <xsl:for-each select="rdg | witDetail">
            <!-- repeat prefix if necessary -->
            <xsl:if test="parent::app/lem[. eq '']">
                <xsl:apply-templates select="parent::app/lem" mode="apparatus-lemma"/>
                <xsl:text>&#x20;</xsl:text>
            </xsl:if>
            <xsl:apply-templates select="." mode="apparatus-rdg"/>
            <xsl:apply-templates select=".[not(self::witDetail)]" mode="apparatus-annotation"/>
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
        <xsl:for-each select="parent::lem/parent::app/rdg | parent::lem/parent::app/witDetail">
            <xsl:apply-templates select="." mode="apparatus-rdg"/>
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

    <!-- the apparatus-rdg mode is needed to avoid loopings -->

    <xsl:template match="rdg[. ne '']" mode="apparatus-rdg">
        <xsl:apply-templates select="self::rdg" mode="apparatus"/>
    </xsl:template>

    <xsl:template match="rdg[. eq '']" mode="apparatus-rdg">
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

    <xsl:template match="witDetail" mode="apparatus-rdg">
        <span class="note-text witDetail"
            lang="{scdh:language(.)}"
            style="direction:{scdh:language-direction(.)}; text-align:{scdh:language-align(.)};">
            <xsl:value-of select="scdh:direction-embedding(.)"/>
            <xsl:apply-templates mode="editorial-note"/>
            <xsl:text>&pdf;</xsl:text>
            <xsl:if test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
                <xsl:text> </xsl:text>
            </xsl:if>
        </span>
    </xsl:template>

    <!-- apparatus entry for standanlone witDetail -->
    <xsl:template match="witDetail[not(parent::app)]" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates select="parent::*" mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <xsl:apply-templates select="self::witDetail" mode="apparatus-rdg"/>
        <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep">:</span>
        <xsl:call-template name="witness-siglum-html">
            <xsl:with-param name="wit" select="@wit"/>
        </xsl:call-template>
        <xsl:if test="position() ne last()"><span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span></xsl:if>
    </xsl:template>

    <xsl:template match="unclear" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
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

    <!-- apparatus entry for supplied -->
    <xsl:template match="supplied" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <xsl:choose>
            <xsl:when test="@reason">
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of select="@reason"/>&pdf;</span>
            </xsl:when>
            <xsl:otherwise><span class="static-text" data-i18n-key="supplied">&lre;supplied&pdf;</span></xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- needed for supplied text in rdg -->
    <xsl:template match="supplied[ancestor::rdg]" mode="apparatus">
        <span class="static-text">[</span>
        <xsl:apply-templates mode="apparatus"/>
        <span class="static-text">]</span>
    </xsl:template>

    <xsl:template match="choice[child::sic and child::corr]" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates select="corr" mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <xsl:apply-templates select="sic"/>
        <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="corr-sic-sep"> </span>
        <span class="static-text" data-i18n-key="corr-sic">&lre;(corrected)&pdf;</span>
    </xsl:template>

    <!-- apparatus entry for choice/sic/app -->
    <xsl:template match="choice[child::sic/app and child::corr]" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates select="corr" mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <xsl:for-each select="sic/app/rdg|sic/app/witDetail">
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

    <!-- apparatus entry for sic/app -->
    <xsl:template match="sic[not(parent::choice) and child::app]" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates select="app/lem" mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <span class="static-text" data-i18n-key="sic">&lre;sic!&pdf;</span>
        <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span>
        <xsl:for-each select="app/rdg|app/witDetail">
            <xsl:apply-templates select="." mode="apparatus"/>
            <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep">:</span>
            <xsl:call-template name="witness-siglum-html">
                <xsl:with-param name="wit" select="@wit"/>
            </xsl:call-template>
            <xsl:if test="position() ne last()"><span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span></xsl:if>
        </xsl:for-each>
    </xsl:template>

    <!-- apparatus entry for simple sic -->
    <xsl:template match="sic[not(parent::choice) and not(child::app)]" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <span class="static-text" data-i18n-key="sic">&lre;sic!&pdf;</span>
    </xsl:template>

    <!-- apparatus entry for simple corr -->
    <xsl:template match="corr[not(parent::choice)]" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <span class="static-text" data-i18n-key="corr">&lre;corrected&pdf;</span>
    </xsl:template>

    <xsl:template match="caesura[ancestor::rdg]" mode="apparatus">
        <span> || </span>
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

    <xsl:template match="witDetail" mode="apparatus-lemma"/>

    <xsl:template match="note" mode="apparatus-lemma"/>

    <!-- this fixes issue #38 on the surface -->
    <xsl:template match="caesura" mode="apparatus-lemma #default">
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="*" mode="apparatus-lemma">
        <!-- We can pass it over to the default templates, now. -->
        <xsl:apply-templates/>
    </xsl:template>


<!-- # Mode editorial-note -->
    <!-- This mode is used for the content of all kinds of editorial notes, be in <note>, be in <witDetail> -->

    <!-- the entry point for an editorial note -->
    <xsl:template match="note" mode="editorial-note-entry">
        <tr>
            <td class="editorial-note-number">
                <xsl:value-of select="scdh:line-number(./ancestor::*[self::p or self::l[not(ancestor::head)] or self::head])"/>
            </td>
            <td class="editorial-note-text">
                <span class="note-lemma">
                    <xsl:variable name="lemma-nodes">
                        <!-- we use the same mode as in the apparatus -->
                        <xsl:apply-templates select="parent::*/child::node() except ." mode="apparatus-lemma"/>
                    </xsl:variable>
                    <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
                    <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                </span>
                <span class="note-text"
                    lang="{scdh:language(.)}"
                    style="direction:{scdh:language-direction(.)}; text-align:{scdh:language-align(.)};">
                    <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
                    <xsl:value-of select="scdh:direction-embedding(.)"/>
                    <xsl:apply-templates mode="editorial-note"/>
                    <xsl:text>&pdf;</xsl:text>
                    <xsl:if test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </span>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="anchor" mode="editorial-note-entry">
        <xsl:variable name="idref" select="concat('#', @xml:id)"/>
        <xsl:variable name="referering-node" as="node()" select="(//*[@from eq $idref], //*[@to eq $idref])[1]"/>
        <xsl:variable name="fromId" select="substring($referering-node/@from, 2)"/>
        <xsl:variable name="toId" select="substring($referering-node/@to, 2)"/>
        <xsl:message>Anchor of <xsl:value-of select="name($referering-node)"/></xsl:message>
        <tr>
            <td class="editorial-note-number">
                <xsl:value-of select="scdh:line-number(./ancestor::*[self::p or self::l[not(ancestor::head)] or self::head])"/>
            </td>
            <td class="editorial-note-text">
                <span class="note-lemma">
                    <xsl:variable name="lemma-nodes">
                        <xsl:call-template name="nodes-between">
                            <xsl:with-param name="startId" select="$fromId"/>
                            <xsl:with-param name="endId" select="$toId"/>
                        </xsl:call-template>
                    </xsl:variable>
                    <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
                    <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                </span>
                <!--
                <span class="note-text"
                    lang="{scdh:language(.)}"
                    style="direction:{scdh:language-direction(.)}; text-align:{scdh:language-align(.)};">
                    <!-/- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -/->
                    <xsl:value-of select="scdh:direction-embedding(.)"/>
                    <xsl:apply-templates mode="editorial-note" select="$referering-node"/>
                    <xsl:text>&pdf;</xsl:text>
                    <xsl:if test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </span>
                -->
                <span class="note-text">
                    <xsl:call-template name="lang-attributes">
                        <xsl:with-param name="context" select="$referering-node"/>
                    </xsl:call-template>
                    <xsl:apply-templates mode="editorial-note" select="$referering-node"/>
                </span>
            </td>
        </tr>
    </xsl:template>

    <!-- change language if necessary -->
    <xsl:template match="*[@xml:lang]" mode="editorial-note">
        <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
        <xsl:value-of select="scdh:direction-embedding(.)"/>
        <xsl:apply-templates mode="editorial-note"/>
        <xsl:text>&pdf;</xsl:text>
        <xsl:if test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- pass over to tei-ld.xsl -->
    <xsl:template match="persName | orgName | placeName | geoName" mode="editorial-note">
        <xsl:apply-templates select="." mode="tei-ld"/>
    </xsl:template>

    <!-- DEPRECATED -->
    <xsl:template match="bibl" mode="OFF">
        <span class="bibliographic-reference">
            <xsl:value-of select="replace(@corresp, '#', '')"/>
            <xsl:choose>
                <xsl:when test="biblScope">
                    <xsl:text>,</xsl:text>
                    <span class="bibl-scope">
                        <xsl:value-of select="biblScope"/>
                    </span>
                </xsl:when>
            </xsl:choose>
        </span>
    </xsl:template>


    <!-- # Metadata # -->

    <xsl:template match="/ | TEI | teiHeader" mode="metadata">
        <xsl:apply-templates select="//sourceDesc" mode="metadata"/>
    </xsl:template>

    <xsl:template match="sourceDesc" mode="metadata">
        <p>
            <span lang="de">
                <xsl:value-of select="tokenize(base-uri(), '/')[last()] => replace('\.[a-zA-Z]+', '')"/>
                <xsl:text>: </xsl:text>
            </span>
            <xsl:apply-templates select="listWit/witness" mode="metadata"/>
        </p>
    </xsl:template>

    <xsl:template match="witness" mode="metadata">
        <span>
            <!--xsl:value-of select="@xml:id"/-->
            <xsl:text>&lre;</xsl:text>
            <span class="siglum">
            <xsl:call-template name="witness-siglum-html">
                <xsl:with-param name="wit" select="@xml:id"/>
            </xsl:call-template>
            </span>
            <xsl:text>&pdf;: </xsl:text>
            <xsl:value-of select="replace(@facs, '^[a-zA-Z]+', '')"/>
        </span>
        <xsl:if test="position() ne last()">
            <span>; </span>
        </xsl:if>
    </xsl:template>


    <!-- # Bibliography # -->

    <xsl:template match="bibl[@corresp]" mode="#all">
        <xsl:variable name="biblnode" select="."/>
        <xsl:variable name="autotext" as="xs:boolean"
            select="exists(parent::note[normalize-space(string-join((text()|*) except bibl, '')) eq ''])"/>
        <xsl:variable name="analogous" as="xs:boolean"
            select="exists(parent::note/parent::seg[matches(@type, '^#analogous')])"/>
        <xsl:variable name="ref-id" as="xs:string" select="replace(@corresp, '^#', '')"/>
        <xsl:variable name="bibliography" select="doc($biblio)"/>
        <xsl:variable name="ref" select="$bibliography//*[@xml:id eq $ref-id]"/>
        <xsl:variable name="ref-lang" select="scdh:language($ref)"/>
        <xsl:if test="exists($bibliography) and $debug">
            <xsl:message>Bibliography present</xsl:message>
        </xsl:if>
        <xsl:if test="not($ref)">
            <xsl:message>Bibliographic entry '<xsl:value-of select="$ref-id"/>' not found in '<xsl:value-of select="$biblio"/>'</xsl:message>
            (reference not found!)
        </xsl:if>
        <span class="bibliographic-reference"
            lang="{scdh:language($ref)}"
            style="direction:{scdh:language-direction($ref)};">
            <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
            <xsl:value-of select="scdh:direction-embedding($ref)"/>
            <!-- [normalize-space((text()|*) except bibl) eq ''] -->
            <xsl:if test="$autotext and $analogous">
                <span class="static-text" data-i18n-key="Cf.">&lre;Cf.&pdf;</span>
                <xsl:text> </xsl:text>
            </xsl:if>
            <xsl:choose>
                <xsl:when test="$ref">
                    <xsl:apply-templates select="$ref" mode="biblio"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="replace(@corresp, '#', '')"/>
                </xsl:otherwise>
            </xsl:choose>
            <xsl:apply-templates mode="biblio"/>
            <xsl:if test="$autotext">
                <xsl:text>.</xsl:text>
            </xsl:if>
            <xsl:text>&pdf;</xsl:text>
            <xsl:if test="scdh:language-direction($ref) eq 'ltr' and scdh:language-direction(.) ne 'ltr' and $ltr-to-rtl-extra-space">
                <xsl:text> </xsl:text>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template match="bibl" mode="biblio">
        <xsl:apply-templates mode="biblio"/>
    </xsl:template>

    <xsl:template match="choice[child::abbr and child::expan]" mode="biblio">
        <xsl:apply-templates select="abbr" mode="biblio"/>
    </xsl:template>

    <xsl:template match="am[parent::abbr/parent::choice[child::expan]]" mode="biblio"/>

    <!-- Exclude whitespace nodes from the bibliographic reference,
        because they break the interpunctation at the end.
        This may lead to unwanted effects with some bibliographies. -->
    <xsl:template match="text()[ancestor::listBibl and matches(., '^\s+$')]" mode="biblio"/>

    <xsl:template match="biblScope[@unit][@from and @to]" mode="biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"/>&pdf;</span>
            <xsl:text> </xsl:text>
            <xsl:value-of select="@from"/>
            <xsl:text>-</xsl:text>
            <xsl:value-of select="@to"/>
        </span>
    </xsl:template>

    <xsl:template match="biblScope[@unit]" mode="biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"/>&pdf;</span>
            <xsl:apply-templates mode="biblio"/>
        </span>
    </xsl:template>

    <xsl:template match="biblScope" mode="biblio">
        <xsl:text>, </xsl:text>
        <span class="bibl-scope">
            <xsl:apply-templates mode="biblio"/>
        </span>
    </xsl:template>

</xsl:stylesheet>
