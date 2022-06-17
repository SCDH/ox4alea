<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:alea="http://scdh.wwu.de/oxygen#ALEA"
    xmlns:scdh="http://scdh.wwu.de/xslt#" xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs alea scdh" version="3.0">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:import href="libbetween.xsl"/>
    <xsl:import href="libcommon.xsl"/>
    

    <xsl:param name="app-entries-xpath-internal-parallel-segmentation" as="xs:string*"
        required="false">
        <xsl:text>descendant::app</xsl:text>
        <xsl:text>| descendant::corr</xsl:text>
    </xsl:param>

    <xsl:param name="app-entries-xpath-internal-double-end-point" as="xs:string*" required="false">
        <xsl:text>descendant::app</xsl:text>
        <xsl:text>| descendant::corr</xsl:text>
    </xsl:param>
    
    <!-- whether or not the first text node from a lemma determines the line number of the entry -->
    <xsl:param name="lemma-first-text-node-line-crit" as="xs:boolean" select="true()"
        required="false"/>

    <xsl:param name="debug" as="xs:boolean" select="true()" required="false"/>

    <!-- for convenience this will be '@location-@method' -->
    <xsl:variable name="variant-encoding">
        <xsl:variable name="ve"
            select="/TEI/teiHeader/encodingDesc/variantEncoding | /teiCorpus/teiHeader/encodingDesc/variantEncoding"/>
        <xsl:value-of select="concat($ve/@location, '-', $ve/@method)"/>
    </xsl:variable>

    <!-- select the right XPath for generating apparatus entries -->
    <xsl:variable name="app-entries-xpath">
        <xsl:choose>
            <xsl:when test="$variant-encoding eq 'internal-double-end-point'">
                <xsl:value-of select="string-join($app-entries-xpath-internal-double-end-point, '')"
                />
            </xsl:when>
            <xsl:when test="$variant-encoding eq 'internal-parallel-segmentation'">
                <xsl:value-of
                    select="string-join($app-entries-xpath-internal-parallel-segmentation, '')"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:message terminate="yes">
                    <xsl:text>This variant encoding is not supported: </xsl:text>
                    <xsl:value-of select="$variant-encoding"/>
                </xsl:message>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>

    <!-- entrance for generating the apparatus -->
    <xsl:template name="line-referencing-apparatus">
        <div>
            <!-- we first generate a sequence of all elements that should show up in the apparatus -->
            <xsl:variable name="entries" as="element()*">
                <xsl:evaluate as="element()*" context-item="/" expand-text="true"
                    xpath="$app-entries-xpath"/>
            </xsl:variable>
            <!-- we then group by such entries, that get their lemma (repetition of the base text) from the same set of text nodes,
                because we want to join them into one entry -->
            <xsl:for-each-group select="$entries"
                group-by="scdh:get-lemma-text-node-ids-or-self(.) => string-join('-')">
                <xsl:if test="$debug">
                    <xsl:message>
                        <xsl:text>Generating apparatus entry for </xsl:text>
                        <xsl:value-of select="count(current-group())"/>
                        <xsl:text> element(s) referencing text nodes </xsl:text>
                        <xsl:value-of select="current-grouping-key()"/>
                    </xsl:message>
                </xsl:if>
                <xsl:variable name="lemma-node-for-line" as="node()">
                    <!-- this variable's type is node() and not text(),
                        since we may have had an empty element so scdh:get-lemma-text-node-ids-or-self()
                        may have returned an ID of an element node. -->
                    <xsl:choose>
                        <xsl:when test="$lemma-first-text-node-line-crit">
                            <xsl:sequence
                                select="current-group()/descendant-or-self::node()[generate-id(.) eq tokenize(current-grouping-key(), '-')[1]]"
                            />
                        </xsl:when>
                        <xsl:otherwise>
                            <xsl:sequence
                                select="current-group()/descendant-or-self::node()[generate-id(.) eq tokenize(current-grouping-key(), '-')[last()]]"
                            />
                        </xsl:otherwise>
                    </xsl:choose>
                </xsl:variable>
                <xsl:variable name="line-number" select="alea:line-number($lemma-node-for-line)"/>
                <xsl:if test="$debug">
                    <xsl:message>
                        <xsl:text>Line number for node </xsl:text>
                        <xsl:value-of select="generate-id($lemma-node-for-line)"/>
                        <xsl:text>: </xsl:text>
                        <xsl:value-of select="$line-number"/>
                    </xsl:message>
                </xsl:if>
                
                

            </xsl:for-each-group>
        </div>
    </xsl:template>
    
    <!-- if the element passed in is empty, the ID of the element is returned. This asserts, that we have a grouping key. -->
    <xsl:function name="scdh:get-lemma-text-node-ids-or-self" as="xs:string*">
        <xsl:param name="element" as="element()"/>
        <xsl:variable name="text-node-ids" as="xs:string*" select="scdh:get-lemma-text-node-ids($element)"/>
        <xsl:choose>
            <xsl:when test="empty($text-node-ids)">
                <xsl:value-of select="generate-id($element)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="$text-node-ids"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>

    <xsl:function name="scdh:get-lemma-text-node-ids" as="xs:string*">
        <xsl:param name="element" as="element()"/>
        <xsl:apply-templates select="$element" mode="lemma-text-node-ids"/>
    </xsl:function>

    <!-- the mode lemma-text-node-ids is for grouping apparatus entries by the text repeated from the base text -->
    <xsl:mode name="lemma-text-node-ids" on-no-match="shallow-skip"/>

    <xsl:template mode="lemma-text-node-ids" match="text()[normalize-space(.) eq '']"/>

    <xsl:template mode="lemma-text-node-ids" match="text()[normalize-space(.) ne '']">
        <xsl:value-of select="generate-id(.)"/>
    </xsl:template>

    <!-- things that do not go into the base text -->
    <xsl:template mode="lemma-text-node-ids"
        match="rdg | choice[corr]/sic | choice[reg]/orig | span | index | note | witDetail"/>

    <xsl:template mode="lemma-text-node-ids"
        match="lem[matches($variant-encoding, 'ternal-double-end-point')]"/>

    <xsl:template mode="lemma-text-node-ids"
        match="app[@from and $variant-encoding eq 'internal-double-end-point']">
        <xsl:variable name="limit-id" select="substring(@from, 2)"/>
        <xsl:variable name="limit" select="//*[@xml:id eq $limit-id]"/>
        <xsl:apply-templates mode="#current" select="scdh:subtrees-between-anchors($limit, .)"/>
    </xsl:template>

    <xsl:template mode="lemma-text-node-ids"
        match="app[@to and $variant-encoding eq 'internal-double-end-point']">
        <xsl:variable name="limit-id" select="substring(@to, 2)"/>
        <xsl:variable name="limit" select="//*[@xml:id eq $limit-id]"/>
        <xsl:apply-templates mode="#current" select="scdh:subtrees-between-anchors(., $limit)"/>
    </xsl:template>



</xsl:stylesheet>
