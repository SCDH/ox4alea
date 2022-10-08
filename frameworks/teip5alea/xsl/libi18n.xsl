<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE stylesheet [
    <!ENTITY lre "&#x202a;" >
    <!ENTITY rle "&#x202b;" >
    <!ENTITY pdf "&#x202c;" >
    <!ENTITY newline "&#xa;" >
]>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xmlns="http://www.w3.org/1999/xhtml" exclude-result-prefixes="xs scdh"
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
    <xsl:param name="translations" select="'translation.json'"/>

    <!-- how to get the default language. E.g. say $locales[1] or 'de' here. -->
    <xsl:param name="default-language-xpath" as="xs:string" select="'/TEI/@xml:lang'"/>

    <xsl:variable name="default-language" as="xs:string">
        <xsl:evaluate as="xs:string" context-item="/" expand-text="true"
            xpath="$default-language-xpath"/>
    </xsl:variable>

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

    <xsl:function name="scdh:language">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="scdh:language($context, $default-language)"/>
    </xsl:function>

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
            <xsl:otherwise>
                <xsl:value-of select="'ltr'"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="scdh:language-direction">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="scdh:language-direction($context, $default-language)"/>
    </xsl:function>

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

    <xsl:function name="scdh:language-align">
        <xsl:param name="context" as="node()"/>
        <xsl:value-of select="scdh:language-align($context, $default-language)"/>
    </xsl:function>

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

    <xsl:template name="i18n-language-chooser-html">
        <xsl:param name="debug" select="false()"/>
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

    <!-- this template makes java script code for lazy loading translation files -->
    <xsl:template name="i18n-language-resources">
        <xsl:for-each select="$locales">
            <xsl:variable name="translation-file"
                select="resolve-uri(concat($locales-directory, '/', ., '/', $translations), static-base-uri())"/>
            <!-- FIXME: why doesn't doc-available() work as expected? -->
            <xsl:if test="true() or doc-available($translation-file)">
                <xsl:text>&newline;import translation</xsl:text>
                <xsl:value-of select="upper-case(.)"/>
                <xsl:text> from '</xsl:text>
                <xsl:value-of select="$translation-file"/>
                <xsl:text>';</xsl:text>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>
            // translations JOSON record
            const resources = {
        </xsl:text>
        <xsl:for-each select="$locales">
            <xsl:value-of select="."/>
            <xsl:text>: {</xsl:text>
            <!-- FIXME: why doesn't doc-available() work as expected? -->
            <xsl:if
                test="true() or doc-available(resolve-uri(concat($locales-directory, '/', ., '/', $translations), static-base-uri()))">
                <xsl:text>translation: translation</xsl:text>
                <xsl:value-of select="upper-case(.)"/>
            </xsl:if>
            <xsl:text>},&newline;</xsl:text>
        </xsl:for-each>
        <xsl:text>dev: {}&newline;</xsl:text>
        <xsl:text>};</xsl:text>
    </xsl:template>

    <!-- this template make java script code for inlining the translation files into a <script> block (strict loading) -->
    <xsl:template name="i18n-language-resources-inline">
        <xsl:text>
            // the translations JSON record
            const resources = {
        </xsl:text>
        <xsl:for-each select="$locales">
            <xsl:variable name="translation-file"
                select="resolve-uri(concat($locales-directory, '/', ., '/', $translations), static-base-uri())"/>
            <xsl:message>
                <xsl:value-of select="$translation-file"/>
            </xsl:message>
            <!-- FIXME: why doesn't doc-available() work as expected? -->
            <xsl:if test="true() or doc-available($translation-file)">
                <xsl:text>&newline;</xsl:text>
                <xsl:value-of select="."/>
                <xsl:text>: {&newline;   translation: </xsl:text>
                <xsl:value-of select="unparsed-text($translation-file)"/>
                <xsl:text>&newline;}</xsl:text>
                <xsl:if test="last()">
                    <xsl:text>,</xsl:text>
                </xsl:if>
            </xsl:if>
        </xsl:for-each>
        <xsl:text>
            };
            const defaultLanguage = 'dev';
            const initialLanguage = '</xsl:text>
        <xsl:value-of select="$default-language"/>
        <xsl:text>';</xsl:text>
    </xsl:template>

    <xsl:template name="i18n-load-javascript">
        <script src="{$i18next}"/>
        <script>
            <xsl:call-template name="i18n-language-resources-inline"/>
        </script>
        <script src="{$i18n}"/>
    </xsl:template>

    <xsl:template name="i18n-load-javascript-lazy">
        <script src="{$i18next}"/>
        <script>
            <xsl:call-template name="i18n-language-resources"/>
        </script>
        <script src="{$i18n}"/>
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
        <xsl:if
            test="$first-direction eq 'ltr' and $then-direction ne 'ltr' and $ltr-to-rtl-extra-space">
            <xsl:text> </xsl:text>
        </xsl:if>
    </xsl:template>

</xsl:stylesheet>
