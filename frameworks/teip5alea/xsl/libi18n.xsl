<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xmlns="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="xs scdh"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    version="2.0">

    <!-- language of the user interface, i.e. static text e.g. in the apparatus -->
    <!--xsl:param name="ui-language" as="xs:string" select="''"/-->

    <!-- If true, this an extra space is added on the end of an ltr-to-rtl changeover. -->
    <xsl:param name="ltr-to-rtl-extra-space" as="xs:boolean" select="true()" required="no"/>

    <xsl:variable name="translations" select="'translation.xml'"/>

    <xsl:function name="scdh:language">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" select="$context/ancestor-or-self::*/@xml:lang"/>
        <xsl:value-of select="if (exists($lang)) then $lang[last()] else $default"/>
    </xsl:function>

    <xsl:function name="scdh:language">
        <xsl:param name="context" as="node()"/>
        <!-- TODO: replace 'ar' with 'en' after @xml:lang is provided throughout ALEA -->
        <xsl:value-of select="scdh:language($context, 'ar')"/>
    </xsl:function>

    <xsl:function name="scdh:language-direction">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" as="xs:string" select="scdh:language($context, $default)"/>
        <xsl:choose>
            <xsl:when test="$lang eq 'ar'"><xsl:value-of select="'rtl'"/></xsl:when>
            <xsl:when test="$lang eq 'he'"><xsl:value-of select="'rtl'"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="'ltr'"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="scdh:language-direction">
        <xsl:param name="context" as="node()"/>
        <!-- TODO: replace 'ar' with 'en' after @xml:lang is provided throughout ALEA -->
        <xsl:value-of select="scdh:language-direction($context, 'ar')"/>
    </xsl:function>

    <xsl:function name="scdh:direction-embedding">
        <xsl:param name="context" as="node()"/>
        <xsl:choose>
            <xsl:when test="scdh:language-direction($context) eq 'rtl'">
                <xsl:value-of select="'&rle;'"/>
            </xsl:when>
            <xsl:otherwise><xsl:value-of select="'&lre;'"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="scdh:language-align">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" as="xs:string" select="scdh:language($context, $default)"/>
        <xsl:choose>
            <xsl:when test="$lang eq 'ar'"><xsl:value-of select="'right'"/></xsl:when>
            <xsl:when test="$lang eq 'he'"><xsl:value-of select="'right'"/></xsl:when>
            <xsl:otherwise><xsl:value-of select="'left'"/></xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="scdh:language-align">
        <xsl:param name="context" as="node()"/>
        <!-- TODO: replace 'ar' with 'en' after @xml:lang is provided throughout ALEA -->
        <xsl:value-of select="scdh:language-align($context, 'ar')"/>
    </xsl:function>

    <xsl:function name="scdh:translate">
        <xsl:param name="language" as="xs:string"/>
        <xsl:param name="key" as="xs:string"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:value-of select="if (doc-available($translations))
            then (let $t:=doc($translations)/*:translation/*:key[@value eq $key]/val[@lang eq $language] return
            (if (exists($t)) then $t else $default))
            else $default"/>
    </xsl:function>

    <xsl:template name="direction-style">
        <style>
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
            td {
            text-align: <xsl:value-of select="scdh:language-align(TEI/text)"/>;
            justify-content: space-between;
            justify-self: stretch;
            }
            @font-face {
            font-family:"Arabic Typesetting";
            /*The location of the loaded TTF font must be relative to the CSS*/
            src:url("arabt100.ttf");
            }
        </style>
    </xsl:template>

    <xsl:template name="i18n-language-chooser-html">
        <xsl:param name="debug" select="false()"/>
        <section class="i18n-language-chooser">
            <button onclick="i18next.changeLanguage('en')">
                English
            </button>
            <button onclick="i18next.changeLanguage('de')">
                German
            </button>
            <button onclick="i18next.changeLanguage('ar')">
                Arabic
            </button>
            <xsl:if test="$debug">
                <button onclick="i18next.changeLanguage('dev')">
                    Dev
                </button>
            </xsl:if>
        </section>
    </xsl:template>

    <xsl:template name="i18n-direction-indicator">
        <span id="i18n-direction-indicator">initial</span>
    </xsl:template>

    <xsl:template name="i18n-language-resources">
        <xsl:param name="locales-directory" as="xs:string" select="locales"/>
        <xsl:text>
            import translationEN from '</xsl:text><xsl:value-of select="$locales-directory"/>/en/translation.json<xsl:text>';
            import translationDE from '</xsl:text><xsl:value-of select="$locales-directory"/>/de/translation.json<xsl:text>';
            import translationAR from '</xsl:text><xsl:value-of select="$locales-directory"/>/ar/translation.json<xsl:text>';

            // the translations JSON record
            const resources = {
                en: {
                    translation: translationEN
                },
                de: {
                    translation: translationDE
                },
                ar: {
                    translation: translationAR
                },
                dev : {}
            };
        </xsl:text>
    </xsl:template>

    <xsl:template name="i18n-language-resources-inline">
        <xsl:param name="locales-directory" as="xs:string" select="locales"/>
        <xsl:text>
            // the translations JSON record
            const resources = {
                en: {
                    translation: </xsl:text><xsl:value-of select="unparsed-text(concat($locales-directory, '/en/translation.json'))"/><xsl:text>
                },
                de: {
                translation: </xsl:text><xsl:value-of select="unparsed-text(concat($locales-directory, '/de/translation.json'))"/><xsl:text>
                },
                ar: {
                translation: </xsl:text><xsl:value-of select="unparsed-text(concat($locales-directory, '/ar/translation.json'))"/><xsl:text>
                }
            };
            const defaultLanguage = 'dev';
            const initialLanguage = 'ar'; // TODO: parse @xml:lang
        </xsl:text>
    </xsl:template>

    <xsl:template name="lang-attributes">
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="lang" select="scdh:language($context)"/>
        <xsl:attribute name="lang" select="$lang"/>
        <xsl:attribute name="xml:lang" select="$lang"/>
    </xsl:template>

    <xsl:template name="ltr-to-rtl-extra-space">
        <xsl:param name="first-direction" as="xs:string"/>
        <xsl:param name="then-direction" as="xs:string"/>
        <xsl:if test="$first-direction eq 'ltr' and $then-direction ne 'ltr' and $ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>