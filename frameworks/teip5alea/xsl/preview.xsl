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
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xmlns:scdhx="http://scdh.wwu.de/xslt#" exclude-result-prefixes="xs scdh"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0" default-mode="preview">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:include href="libtext.xsl"/>
    <xsl:include href="librend.xsl"/>
    <xsl:import href="libnote.xsl"/>
    <xsl:import href="libapp2.xsl"/>
    <xsl:include href="libmeta.xsl"/>
    <xsl:import href="libwit.xsl"/>
    <xsl:import href="libi18n.xsl"/>
    <xsl:import href="libcommon.xsl"/>
    <xsl:import href="libbiblio.xsl"/>

    <!-- URI of witness catalogue. -->
    <xsl:param name="witness-cat" select="'WitnessCatalogue.xml'" as="xs:string"/>

    <!-- URI of bibliography -->
    <xsl:param name="biblio" as="xs:string" select="'../samples/biblio.xml'"/>

    <xsl:param name="i18n" select="'i18n.js'" as="xs:string"/>
    <xsl:param name="i18next" select="'https://unpkg.com/i18next/i18next.min.js'" as="xs:string"/>
    <xsl:param name="locales-directory" select="'./locales'" as="xs:string"/>

    <xsl:param name="debug" select="true()" as="xs:boolean"/>

    <!-- language of the user interface, i.e. static text e.g. in the apparatus -->
    <xsl:param name="ui-language" as="xs:string" select="''"/>

    <xsl:param name="font-css" as="xs:string" select="''"/>
    <xsl:param name="font-name" as="xs:string" select="'Arabic Typesetting'"/>

    <xsl:function name="scdh:ui-language">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:value-of select="
                if ($ui-language eq '') then
                    scdh:language($context, $default)
                else
                    $ui-language"/>
    </xsl:function>

    <xsl:function name="scdh:ui-language">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="
                if ($ui-language eq '') then
                    scdh:language($context, 'ar')
                else
                    $ui-language"/>
    </xsl:function>

    <xsl:template match="/ | TEI">
        <xsl:text disable-output-escaping="yes">&lt;!DOCTYPE html&gt;&lb;</xsl:text>
        <html lang="{scdh:language(/*)}">
            <head>
                <meta charset="utf-8"/>
                <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
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
                    span.apparatus-line-number {
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
                    <xsl:call-template name="line-referencing-comments"/>
                </section>
                <hr/>
                <xsl:call-template name="i18n-language-chooser-html">
                    <xsl:with-param name="debug" select="$debug"/>
                </xsl:call-template>
                <!--xsl:call-template name="i18n-direction-indicator"/-->
                <script src="{$i18next}"/>
                <script>
                    <xsl:call-template name="i18n-language-resources-inline">
                        <xsl:with-param name="locales-directory" select="$locales-directory"/>
                    </xsl:call-template>
                </script>
                <script src="{$i18n}"/>
            </body>
        </html>
    </xsl:template>

</xsl:stylesheet>
