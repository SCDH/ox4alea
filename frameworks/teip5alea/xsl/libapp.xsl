<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT module of the preview: apparatus and commentary -->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY nbsp "&#xa0;" >
    <!ENTITY emsp "&#x2003;" >
    <!ENTITY lb "&#xa;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs scdh" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:import href="libwit.xsl"/>
    <xsl:include href="libi18n.xsl"/>
    <xsl:include href="libcommon.xsl"/>
    <xsl:include href="libanchors.xsl"/>
    <xsl:import href="libld.xsl"/>
    <xsl:import href="libbiblio.xsl"/>


    <!-- # Apparatus # -->

    <!-- XPath expression, that describes, what appears in the apparatus: context: verse or other block element -->
    <xsl:param name="apparatus-entries-xpath">
        <xsl:choose>
            <xsl:when test="//variantEncoding[@method eq 'parallel-segmentation']">
                <!-- we can't add simple ...|ancestor::app to the selector, because then we
                    lose focus on the line when there are several in an <app>. See #12.
                    We need app//l instead an some etra templates for handling app//l. -->
                <xsl:text>
                    descendant::gap[not(parent::lem)] |
                    descendant::unclear[not(parent::lem | parent::rdg)] |
                    descendant::sic[not(parent::choice)] |
                    descendant::corr[not(parent::choice)] |
                    descendant::choice |
                    descendant::supplied[not(parent::rdg)] |
                    descendant::witDetail[not(parent::app)] |
                    descendant::app[not(parent::sic)] |
                    descendant::app/lem/(gap | unclear | choice) |
                    self::l[ancestor::app] |
                    self::head[ancestor::app] |
                    self::p[ancestor::app and not(ancestor::note)]
                </xsl:text>
            </xsl:when>
        </xsl:choose>
    </xsl:param>


    <!-- ## Apparatus line ## -->

    <xsl:template name="line-referencing-apparatus">
        <table>
            <xsl:apply-templates select="/TEI/text/body" mode="apparatus-line"/>
        </table>
    </xsl:template>


    <!-- make an apparatus line and hand over to templates that do the apparatus entries -->
    <xsl:template
        match="head | app//head | l | app//l | p | app//p[not(ancestor::note)] | lg/anchor"
        mode="apparatus-line">
        <xsl:variable name="entries" as="node()*">
            <!-- make a sequence of all nodes, that need an apparatus entry for this line -->
            <xsl:evaluate as="node()*" context-item="." xpath="$apparatus-entries-xpath"
                expand-text="true"/>
        </xsl:variable>
        <xsl:if test="not(empty($entries))">
            <tr>
                <td class="apparatus-line-number">
                    <xsl:value-of select="scdh:line-number(.)"/>
                </td>
                <td>
                    <xsl:for-each select="$entries">
                        <xsl:apply-templates select="." mode="apparatus"/>
                        <xsl:if test="position() != last()">
                            <span class="apparatus-sep" data-i18n-key="app-entry-sep"
                                >&nbsp;|&emsp;</span>
                        </xsl:if>
                    </xsl:for-each>
                </td>
            </tr>
        </xsl:if>
    </xsl:template>

    <!-- ## Apparatus entries ## -->

    <xsl:template match="
            anchor[let $id := @xml:id
            return
                //app[@from eq concat('#', $id)]]" mode="apparatus">
        <xsl:variable name="id" select="@xml:id"/>
        <xsl:apply-templates mode="apparatus" select="//app[@from eq concat('#', $id)]"/>
    </xsl:template>

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
            <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                >:</span>
            <xsl:call-template name="witness-siglum-html">
                <xsl:with-param name="wit" select="@wit"/>
            </xsl:call-template>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template match="app/lem/l | app/lem/p[not(ancestor::note)]" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates select="parent::lem" mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
        <xsl:for-each select="parent::lem/parent::app/rdg | parent::lem/parent::app/witDetail">
            <xsl:apply-templates select="." mode="apparatus-rdg"/>
            <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                >:</span>
            <xsl:call-template name="witness-siglum-html">
                <xsl:with-param name="wit" select="@wit"/>
            </xsl:call-template>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
        </xsl:for-each>
    </xsl:template>

    <xsl:template
        match="l[not(ancestor::app/lem/l)] | p[not(ancestor::app/lem/p) and not(ancestor::note)]"
        mode="apparatus">
        <xsl:apply-templates mode="apparatus"/>
        <xsl:text> </xsl:text>
        <span class="static-text" data-i18n-key="extra-verse">&lre;extra verse&pdf;</span>
        <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
            >:</span>
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
            <xsl:when test="parent::app/lem/l | parent::app/rdg/l">
                <span class="static-text" data-i18n-key="verse-missing">&lre;verse
                    missing&pdf;</span>
            </xsl:when>
            <xsl:when test="parent::app/lem/p | parent::app/rdg/p">
                <span class="static-text" data-i18n-key="paragraph-missing">&lre;paragraph
                    missing&pdf;</span>
            </xsl:when>
            <xsl:otherwise>
                <span class="static-text" data-i18n-key="missing">&lre;missing&pdf;</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="witDetail" mode="apparatus-rdg">
        <span class="note-text witDetail" lang="{scdh:language(.)}"
            style="direction:{scdh:language-direction(.)}; text-align:{scdh:language-align(.)};">
            <xsl:value-of select="scdh:direction-embedding(.)"/>
            <xsl:apply-templates mode="editorial-note"/>
            <xsl:text>&pdf;</xsl:text>
            <xsl:if
                test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
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
        <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
            >:</span>
        <xsl:call-template name="witness-siglum-html">
            <xsl:with-param name="wit" select="@wit"/>
        </xsl:call-template>
        <xsl:if test="position() ne last()">
            <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep">;</span>
        </xsl:if>
    </xsl:template>

    <xsl:template match="unclear" mode="apparatus">
        <xsl:variable name="lemma-nodes">
            <xsl:apply-templates mode="apparatus-lemma"/>
        </xsl:variable>
        <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
        <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">] </span>
        <xsl:choose>
            <xsl:when test="@reason">
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of
                        select="@reason"/>&pdf;</span>
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
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of
                        select="@reason"/>&pdf;</span>
            </xsl:when>
            <xsl:otherwise>
                <span class="static-text" data-i18n-key="gap">&lre;omitted&pdf;</span>
            </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@quantity and @unit">
            <span class="apparatus-sep" data-i18n-key="reason-quantity-sep">, </span>
            <span class="static-text">
                <xsl:value-of select="@quantity"/>
            </span>
            <xsl:text>&#160;</xsl:text>
            <span class="static-text" data-i18n-key="{@unit}">&lre;<xsl:value-of select="@unit"
                />&pdf;</span>
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
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of
                        select="@reason"/>&pdf;</span>
            </xsl:when>
            <xsl:otherwise>
                <span class="static-text" data-i18n-key="supplied">&lre;supplied&pdf;</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- needed for supplied text in rdg -->
    <xsl:template match="supplied[ancestor::rdg]" mode="apparatus">
        <span class="static-text">[</span>
        <xsl:apply-templates mode="apparatus"/>
        <span class="static-text">]</span>
    </xsl:template>

    <xsl:template
        match="choice[child::sic[exists(child::node() except child::app)] and child::corr]"
        mode="apparatus">
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
        <xsl:for-each select="sic/app/rdg | sic/app/witDetail">
            <xsl:apply-templates select="." mode="apparatus"/>
            <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                >:</span>
            <xsl:call-template name="witness-siglum-html">
                <xsl:with-param name="wit" select="@wit"/>
            </xsl:call-template>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
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
        <xsl:for-each select="app/rdg | app/witDetail">
            <xsl:apply-templates select="." mode="apparatus"/>
            <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                >:</span>
            <xsl:call-template name="witness-siglum-html">
                <xsl:with-param name="wit" select="@wit"/>
            </xsl:call-template>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
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
        <xsl:if test="unclear | gap | corr | sic">
            <span class="apparatus-sep" data-i18n-key="rdg-annotation-pre"> (</span>
            <xsl:for-each select="unclear | gap | corr | sic">
                <xsl:apply-templates select="." mode="apparatus-annotation"/>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px"
                        data-i18n-key="rdg-annotation-sep">, </span>
                </xsl:if>
            </xsl:for-each>
            <span class="apparatus-sep" data-i18n-key="rdg-annotation-post">) </span>
        </xsl:if>
    </xsl:template>

    <xsl:template match="gap" mode="apparatus-annotation">
        <xsl:choose>
            <xsl:when test="@reason">
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of
                        select="@reason"/>&pdf;</span>
            </xsl:when>
            <xsl:otherwise>
                <span class="static-text" data-i18n-key="gap">&lre;omitted&pdf;</span>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="unclear" mode="apparatus-annotation">
        <xsl:choose>
            <xsl:when test="@reason">
                <span class="static-text" data-i18n-key="{@reason}">&lre;<xsl:value-of
                        select="@reason"/>&pdf;</span>
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

    <xsl:template match="lem[. eq ''][//variantEncoding[@method eq 'parallel-segmentation']]"
        mode="apparatus-lemma">
        <!-- We have to present something, to mark the place where the variant adds something.
             So we decide:
             If it is the start of the line to present a special character and
             else to present a one-word prefix! If and only if it is not the start of the line. -->
        <xsl:choose>
            <!-- This branch should not be used anymore -->
            <xsl:when
                test="(parent::app/preceding-sibling::l) or (parent::app/following-sibling::l)">
                <xsl:text>^ </xsl:text>
            </xsl:when>
            <xsl:when
                test="(parent::app/preceding-sibling::p) or (parent::app/following-sibling::p)">
                <xsl:text>^ </xsl:text>
            </xsl:when>
            <xsl:when
                test="(normalize-space(string-join(parent::app/preceding-sibling::node(), ' ')) eq '')">
                <xsl:text>^ </xsl:text>
            </xsl:when>
            <xsl:otherwise>
                <xsl:variable name="predecessors">
                    <!-- we use the apparatus-lemma mode because we do not want the line numbers -->
                    <xsl:apply-templates select="parent::app/preceding-sibling::node()"
                        mode="apparatus-lemma"/>
                </xsl:variable>
                <xsl:value-of
                    select="tokenize(normalize-space(string($predecessors)), '\s+')[last()]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <xsl:template match="lem" mode="apparatus-lemma">
        <xsl:apply-templates mode="apparatus-lemma"/>
    </xsl:template>

    <xsl:template match="rdg" mode="apparatus-lemma"/>

    <xsl:template match="choice" mode="apparatus-lemma">
        <xsl:apply-templates mode="apparatus-lemma"/>
    </xsl:template>

    <xsl:template match="choice/corr[parent::choice/sic]" mode="apparatus-lemma">
        <xsl:apply-templates mode="apparatus-lemma"/>
    </xsl:template>

    <xsl:template match="choice/sic[parent::choice/corr]" mode="apparatus-lemma"/>

    <xsl:template match="l | p[not(ancestor::note)]" mode="apparatus-lemma">
        <xsl:apply-templates mode="apparatus-lemma"/>
    </xsl:template>

    <xsl:template match="seg | persName | placeName | orgName" mode="apparatus-lemma">
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



    <!-- Notes / Comments -->

    <xsl:template name="line-referencing-comments">
        <table>
            <!-- add the following to get anchor-based things to comments:
                            | TEI/text//anchor[exists(let $id := @xml:id return //span[@from eq concat('#', $id)])] -->
            <xsl:apply-templates select="/TEI/text//note" mode="editorial-note-entry"/>
        </table>
    </xsl:template>


    <!-- # Mode editorial-note -->
    <!-- This mode is used for the content of all kinds of editorial notes, be in <note>, be in <witDetail> -->

    <!-- the entry point for an editorial note -->
    <xsl:template match="note" mode="editorial-note-entry">
        <tr>
            <td class="editorial-note-number">
                <xsl:value-of
                    select="scdh:line-number(./ancestor::*[self::p or self::l[not(ancestor::head)] or self::head])"
                />
            </td>
            <td class="editorial-note-text">
                <span class="note-lemma">
                    <xsl:variable name="lemma-nodes">
                        <!-- we use the same mode as in the apparatus -->
                        <xsl:apply-templates select="parent::*/child::node() except ."
                            mode="apparatus-lemma"/>
                    </xsl:variable>
                    <xsl:value-of select="scdh:shorten-string($lemma-nodes)"/>
                    <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
                </span>
                <span class="note-text" lang="{scdh:language(.)}"
                    style="direction:{scdh:language-direction(.)}; text-align:{scdh:language-align(.)};">
                    <!-- This must be paired with pdf character entity,
                        because directional embeddings are an embedded CFG! -->
                    <xsl:value-of select="scdh:direction-embedding(.)"/>
                    <xsl:apply-templates mode="editorial-note"/>
                    <xsl:text>&pdf;</xsl:text>
                    <xsl:if
                        test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
                        <xsl:text> </xsl:text>
                    </xsl:if>
                </span>
            </td>
        </tr>
    </xsl:template>

    <xsl:template match="anchor" mode="editorial-note-entry">
        <xsl:variable name="idref" select="concat('#', @xml:id)"/>
        <xsl:variable name="referering-node" as="node()"
            select="(//*[@from eq $idref], //*[@to eq $idref])[1]"/>
        <xsl:variable name="fromId" select="substring($referering-node/@from, 2)"/>
        <xsl:variable name="toId" select="substring($referering-node/@to, 2)"/>
        <xsl:message>Anchor of <xsl:value-of select="name($referering-node)"/></xsl:message>
        <tr>
            <td class="editorial-note-number">
                <xsl:value-of
                    select="scdh:line-number(./ancestor::*[self::p or self::l[not(ancestor::head)] or self::head])"
                />
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
        <xsl:if
            test="scdh:language-direction(.) eq 'ltr' and scdh:language-direction(parent::*) ne 'ltr' and $ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

    <!-- pass over to tei-ld.xsl, if not in note context -->
    <xsl:template match="(persName | orgName | placeName | geoName)[not(ancestor::note)]"
        mode="editorial-note">
        <xsl:apply-templates select="." mode="tei-ld"/>
    </xsl:template>

</xsl:stylesheet>
