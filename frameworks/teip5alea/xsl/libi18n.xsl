<?xml version="1.0" encoding="UTF-8"?>
<!-- This generic XSLT module provides UI translation for TEI to HTML transsforamtions using i18next.

The translations must be in i18next JSON files . Their path is given by parameters:

- $locales-directory:  absulute URI or relative  path relative to this stylesheet

- $locales: a sequence of locales

- $translations: the name of the file containing the translationns for a locale

The  path is concatenated from $locales-directory/LOCALE/$translations where LOCALE is one of the locales.

The default language is determined by the $default-language-xpath parameter.

Put the language chooser and the tmeplate  i18n-load-javascript in the back of your HTML file.

Then put <span data-i18n-key="MY-KEY">my default</span> into your templates for using translations.

See i18next documentation for more info: https://www.i18next.com

-->
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY newline "&#xa;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    exclude-result-prefixes="xs scdh"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" version="3.0">

    <!-- language of the user interface, i.e. static text e.g. in the apparatus -->
    <!--xsl:param name="ui-language" as="xs:string" select="''"/-->

    <!-- If true, this an extra space is added on the end of an ltr-to-rtl changeover. -->
    <xsl:param name="ltr-to-rtl-extra-space" as="xs:boolean" select="true()" required="no"/>

    <!-- path to i18next.js -->
    <xsl:param name="i18next" select="'https://unpkg.com/i18next/i18next.min.js'" as="xs:string"/>

    <!-- path to your i18n.js with setup for i18next-->
    <xsl:param name="i18n" select="'i18n.js'" as="xs:string"/>

    <!-- path to the translation files, relative to this stylesheet or absolute -->
    <xsl:param name="locales-directory" select="'locales'" as="xs:string"/>

    <!-- languages offered in the UI. The translation files must be available in the $locales-directory -->
    <xsl:param name="locales" as="xs:string*" select="('ar', 'de', 'en')"/>

    <!-- name of i18next JSON translations file in $locales-directory/LOCALE/ -->
    <xsl:param name="i18n-default-namespace" select="'translation'"/>

    <!-- how to get the default language. E.g. say $locales[1] or 'de' here. -->
    <xsl:param name="default-language-xpath" as="xs:string" select="'/TEI/@xml:lang'"/>

    <xsl:param name="debug" as="xs:boolean" select="false()"/>


    <xsl:variable name="default-language" as="xs:string">
        <xsl:evaluate as="xs:string" context-item="/" expand-text="true"
            xpath="$default-language-xpath"/>
    </xsl:variable>



    <!-- tempates for generating java script needed for i18next -->

    <!-- this template makes java script code for inlining the translation files into a <script> block (strict loading) -->
    <xsl:template name="i18n-language-resources-inline">
        <xsl:param name="directory" as="xs:string"/>
        <xsl:param name="namespace" as="xs:string"/>
        <xsl:text>&newline;</xsl:text>
        <xsl:text>//import i18next from 'i18next';&newline;</xsl:text>
        <xsl:for-each select="$locales">
            <xsl:variable name="translation-file"
                select="resolve-uri(concat($directory, '/', ., '/', $namespace, '.json'), static-base-uri())"/>
            <!-- FIXME: why doesn't doc-available() work as expected? -->
            <xsl:if test="true() or doc-available($translation-file)">
                <xsl:text>&newline;</xsl:text>
                <xsl:text>i18next.addResourceBundle('</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>', '</xsl:text>
                <xsl:value-of select="$namespace"/>
                <xsl:text>', </xsl:text>
                <xsl:value-of select="unparsed-text($translation-file)"/>
                <xsl:text>);&newline;</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>i18next.addResourceBundle('dev', '</xsl:text>
        <xsl:value-of select="$namespace"/>
        <xsl:text>', {});&newline;</xsl:text>
    </xsl:template>

    <xsl:template name="i18n-initialisation">
        <xsl:text>&newline;</xsl:text>
        <xsl:text>const defaultNamespace = '</xsl:text>
        <xsl:value-of select="$i18n-default-namespace"/>
        <xsl:text>';&newline;</xsl:text>
        <xsl:text>const defaultLanguage = 'dev';&newline;</xsl:text>
        <xsl:text>const initialLanguage = '</xsl:text>
        <xsl:value-of select="$default-language"/>
        <xsl:text>';&newline;</xsl:text>
    </xsl:template>

    <!-- do everything needed for i18next -->
    <xsl:template name="i18n-load-javascript">
        <script src="{$i18next}"/>
        <script>
            <xsl:call-template name="i18n-initialisation"/>
        </script>
        <script src="{$i18n}">
            <!--xsl:value-of select="unparsed-text(resolve-uri($i18n, static-base-uri()))"/-->
        </script>
        <script type="module">
            <xsl:call-template name="i18n-language-resources-inline">
                <xsl:with-param name="directory" select="$locales-directory"/>
                <xsl:with-param name="namespace" select="$i18n-default-namespace"/>
            </xsl:call-template>
        </script>
    </xsl:template>

    <!-- language chooser  -->
    <xsl:template name="i18n-language-chooser-html">
        <section class="i18n-language-chooser">
            <xsl:for-each select="$locales">
                <button onclick="i18next.changeLanguage('{.}')">
                    <xsl:value-of select="."/>
                </button>
                <xsl:text> </xsl:text>
            </xsl:for-each>
            <xsl:if test="$debug">
                <button onclick="i18next.changeLanguage('dev')"> Dev </button>
            </xsl:if>
        </section>
    </xsl:template>

    <xsl:template name="i18n-direction-indicator">
        <span id="i18n-direction-indicator">initial</span>
    </xsl:template>



    <!-- functions and templates to get language and script specific things done -->

    <!-- better use standard XPath function instead -->
    <xsl:function name="scdh:language">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" select="$context/ancestor-or-self::*/@xml:lang"/>
        <xsl:value-of select="
                if (exists($lang)) then
                    $lang[last()]
                else
                    $default"/>
    </xsl:function>

    <!-- better use standard XPath function instead -->
    <xsl:function name="scdh:language">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="scdh:language($context, $default-language)"/>
    </xsl:function>

    <!-- get the direction CSS code for the context's language -->
    <xsl:function name="scdh:language-direction">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" as="xs:string" select="scdh:language($context, $default)"/>
        <xsl:choose>
            <xsl:when test="$lang eq 'ar'">
                <xsl:value-of select="'rtl'"/>
            </xsl:when>
            <xsl:when test="$lang eq 'he'">
                <xsl:value-of select="'rtl'"/>
            </xsl:when>
            <!-- TODO: add other languages as needed -->
            <xsl:otherwise>
                <xsl:value-of select="'ltr'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="scdh:language-direction">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="scdh:language-direction($context, $default-language)"/>
    </xsl:function>

    <!-- get a Unicode bidi embedding for the language at context. You should pop directional formatting (pdf) afterwards! -->
    <xsl:function name="scdh:direction-embedding">
        <xsl:param name="context" as="node()"/>
        <xsl:choose>
            <xsl:when test="scdh:language-direction($context) eq 'rtl'">
                <xsl:value-of select="'&rle;'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'&lre;'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- deprecated -->
    <xsl:function name="scdh:language-align">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="default" as="xs:string"/>
        <xsl:variable name="lang" as="xs:string" select="scdh:language($context, $default)"/>
        <xsl:choose>
            <xsl:when test="$lang eq 'ar'">
                <xsl:value-of select="'right'"/>
            </xsl:when>
            <xsl:when test="$lang eq 'he'">
                <xsl:value-of select="'right'"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'left'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <!-- deprecated -->
    <xsl:function name="scdh:language-align">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="scdh:language-align($context, $default-language)"/>
    </xsl:function>

    <!-- make HTML5 and XHTML language attributes reflecting the language at $context -->
    <xsl:template name="lang-attributes">
        <xsl:param name="context" as="node()"/>
        <xsl:variable name="lang" select="scdh:language($context)"/>
        <xsl:attribute name="lang" select="$lang"/>
        <xsl:attribute name="xml:lang" select="$lang"/>
    </xsl:template>

    <!-- make HTML5 and XHTML language attributes reflecting the language at current dynamic context -->
    <xsl:template name="lang-attributes-here">
        <xsl:variable name="lang" select="scdh:language(.)"/>
        <xsl:attribute name="lang" select="$lang"/>
        <xsl:attribute name="xml:lang" select="$lang"/>
    </xsl:template>

    <!-- make an extra space text node when changing from ltr to rtl script -->
    <xsl:template name="ltr-to-rtl-extra-space">
        <xsl:param name="first-direction" as="xs:string"/>
        <xsl:param name="then-direction" as="xs:string"/>
        <xsl:if
            test="$first-direction eq 'ltr' and $then-direction ne 'ltr' and $ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>


    <!-- CSS templates (deprecated) -->

    <xsl:template name="direction-style">
        <style>
            body {
            direction: <xsl:value-of select="scdh:language-direction(TEI/text)"/>;
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
        </style>
    </xsl:template>

</xsl:stylesheet>
