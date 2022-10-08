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
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xi="http://www.w3.org/2001/XInclude"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA" xmlns:scdhx="http://scdh.wwu.de/xslt#"
    exclude-result-prefixes="xs xi scdh scdhx" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="3.0" default-mode="preview">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:include href="libtext.xsl"/>
    <xsl:include href="librend.xsl"/>
    <xsl:import href="libnote2.xsl"/>
    <xsl:import href="libapp2.xsl"/>
    <xsl:include href="libmeta.xsl"/>
    <xsl:import href="libwit.xsl"/>
    <xsl:import href="libi18n.xsl"/>
    <xsl:import href="libcommon.xsl"/>
    <xsl:import href="libbiblio.xsl"/>

    <xsl:param name="font-css" as="xs:string" select="''"/>
    <xsl:param name="font-name" as="xs:string" select="'Arabic Typesetting'"/>

    <xsl:template match="/ | TEI">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&lb;</xsl:text>
        <xsl:for-each select="//xi:include">
            <xsl:message>
                <xsl:text>WARNING: </xsl:text>
                <xsl:text>XInclude element not expanded! @href="</xsl:text>
                <xsl:value-of select="@href"/>
                <xsl:text>" @xpointer="</xsl:text>
                <xsl:value-of select="@xpointer"/>
                <xsl:text>"</xsl:text>
            </xsl:message>
        </xsl:for-each>
        <html lang="{scdh:language(/*)}">
            <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
                <xsl:variable name="work-id" as="xs:string">
                    <!-- we evaluate the XPath again in the context of the current item.
                        This is required for composition in preview-recension.xsl -->
                    <xsl:evaluate as="xs:string" context-item="." xpath="$work-id-xpath"
                        expand-text="true"/>
                </xsl:variable>
                <title>
                    <xsl:value-of select="$work-id"/>
                    <xsl:text> :: ALEA Vorschau</xsl:text>
                </title>
                <style>
                    <xsl:if test="$font-css ne ''">
                        <xsl:value-of select="unparsed-text($font-css)"/>
                    </xsl:if>
                    .title {
                        color:red;
                    }
                    body {
                        direction: <xsl:value-of select="scdh:language-direction(/TEI/text)"/>;
                        font-family:"<xsl:value-of select="$font-name"/>";
                    }
                    .metadata {
                        direction: ltr;
                        text-align: right;
                        margin: 0 2em;
                    }
                    .variants {
                        direction: <xsl:value-of select="scdh:language-direction(/TEI/text)"/>;
                    }
                    .comments {
                        direction: <xsl:value-of select="scdh:language-direction(/TEI/text)"/>;
                    }
                    hr {
                        margin: 1em 2em;                    }
                    td {
                        text-align: <xsl:value-of select="scdh:language-align(/TEI/text)"/>;
                        justify-content: space-between;
                        justify-self: stretch;
                    }
                    td.line-number, td.apparatus-line-number, td.editorial-note-number {
                        vertical-align:top;
                        padding-left: 10px;
                        }
                    .line-number, .apparatus-line-number, .editor-note-number {
                        text-align:right;
                        font-size: 0.7em;
                        padding-top: 0.3em;
                    }
                    div.apparatus-line,
                    div.editorial-note {
                        padding: 2px 0;
                    }
                    /*
                    section > p {
                        padding-right: 3em;
                        padding-left: 3em;
                        text-indent: -3em;
                    }
                    */
                    span.line-number {
                        display: inline-block;
                        min-width: 3em;
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
                    .lemma-gap {
                        font-size:.8em;
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
                <section class="metadata">
                    <xsl:apply-templates select="/TEI/teiHeader" mode="metadata"/>
                </section>
                <hr/>
                <section class="content">
                    <xsl:apply-templates select="/TEI/text/body" mode="text"/>
                </section>
                <hr/>
                <section class="variants">
                    <xsl:call-template name="scdhx:apparatus-for-context">
                        <xsl:with-param name="app-context" select="/"/>
                    </xsl:call-template>
                </section>
                <hr/>
                <section class="comments">
                    <xsl:call-template name="scdhx:editorial-notes">
                        <xsl:with-param name="notes"
                            select="scdhx:editorial-notes(//text/body, 'descendant::note')"/>
                    </xsl:call-template>
                </section>
                <hr/>
                <xsl:call-template name="i18n-language-chooser-html"/>
                <!--xsl:call-template name="i18n-direction-indicator"/-->
                <xsl:call-template name="i18n-load-javascript"/>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
