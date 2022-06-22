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
    xmlns:map="http://www.w3.org/2005/xpath-functions/map"
    xmlns:alea="http://scdh.wwu.de/oxygen#ALEA" xmlns:scdh="http://scdh.wwu.de/xslt#"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs map alea scdh"
    version="3.1">

    <xsl:output media-type="text/html" method="html" encoding="UTF-8"/>

    <xsl:import href="libbetween.xsl"/>
    <xsl:import href="libcommon.xsl"/>
    <xsl:import href="libwit.xsl"/>


    <xsl:param name="app-entries-xpath-internal-parallel-segmentation" as="xs:string"
        required="false">
        <xsl:variable name="xpath" as="xs:string*">
            <xsl:text>descendant::app</xsl:text>
            <xsl:text>| descendant::corr</xsl:text>
        </xsl:variable>
        <xsl:value-of select="string-join($xpath, '')"/>
    </xsl:param>

    <xsl:param name="app-entries-xpath-internal-double-end-point" as="xs:string*" required="false">
        <xsl:variable name="xpath" as="xs:string*">
            <xsl:text>descendant::app</xsl:text>
            <xsl:text>| descendant::corr[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::sic[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[sic and corr]</xsl:text>
            <xsl:text>| descendant::unclear[not(parent::choice)]</xsl:text>
            <xsl:text>| descendant::choice[unclear]</xsl:text>
        </xsl:variable>
        <xsl:value-of select="string-join($xpath, '')"/>
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
                <xsl:value-of select="$app-entries-xpath-internal-double-end-point"/>
            </xsl:when>
            <xsl:when test="$variant-encoding eq 'internal-parallel-segmentation'">
                <xsl:value-of select="$app-entries-xpath-internal-parallel-segmentation"/>
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
            <xsl:variable name="entry-elements" as="element()*">
                <xsl:evaluate as="element()*" context-item="/" expand-text="true"
                    xpath="$app-entries-xpath"/>
            </xsl:variable>
            <xsl:variable name="entries" as="map(*)*"
                select="$entry-elements ! scdh:mk-entry-map(.)"/>
            <!-- we first group the entries by line number -->
            <xsl:for-each-group select="$entries" group-by="map:get(., 'line-number')">
                <xsl:if test="$debug">
                    <xsl:message>
                        <xsl:text>Apparatus entries for line </xsl:text>
                        <xsl:value-of select="current-grouping-key()"/>
                        <xsl:text> : </xsl:text>
                        <xsl:value-of select="count(current-group())"/>
                    </xsl:message>
                </xsl:if>

                <div class="apparatus-line">
                    <span class="apparatus-line-number">
                        <xsl:value-of select="current-grouping-key()"/>
                    </span>
                    <span>
                        <!-- we then group by such entries, that get their lemma (repetition of the base text)
                            from the same set of text nodes, because we want to join them into one entry -->
                        <xsl:for-each-group select="current-group()"
                            group-by="map:get(., 'lemma-grouping-ids')">
                            <xsl:if test="$debug and count(current-group()) > 1">
                                <xsl:message>
                                    <xsl:text>Joining </xsl:text>
                                    <xsl:value-of select="count(current-group())"/>
                                    <xsl:text> apparatus entries referencing text nodes </xsl:text>
                                    <xsl:value-of select="current-grouping-key()"/>
                                </xsl:message>
                            </xsl:if>
                            <!-- call the template that outputs an apparatus entries -->
                            <xsl:call-template name="scdh:apparatus-entry">
                                <xsl:with-param name="entries" select="current-group()"/>
                            </xsl:call-template>
                        </xsl:for-each-group>
                    </span>
                </div>

            </xsl:for-each-group>
        </div>
    </xsl:template>

    <!-- this generates a map (object) for an apparatus entry
        with all there is needed for grouping and creating the entry -->
    <xsl:function name="scdh:mk-entry-map" as="map(*)">
        <xsl:param name="entry" as="element()"/>
        <xsl:variable name="lemma-text-nodes" as="text()*">
            <xsl:apply-templates select="$entry" mode="lemma-text-nodes-dspt"/>
        </xsl:variable>
        <xsl:variable name="lemma-text-node-ids" as="xs:string*"
            select="$lemma-text-nodes[normalize-space(.) ne ''] ! generate-id(.)"/>
        <xsl:variable name="lemma-grouping-ids" as="xs:string">
            <!-- if the element passed in is empty, the ID of the element is used. This asserts, that we have a grouping key.
                Whitespace text nodes are dropped because they generally interfere with testing where the lemme originates from.
                -->
            <xsl:choose>
                <xsl:when test="empty($lemma-text-node-ids)">
                    <xsl:value-of select="generate-id($entry)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="$lemma-text-node-ids => string-join('-')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="lemma-node-for-line" as="node()">
            <!-- this variable's type is node() and not text(),
                since we may have had an empty element. -->
            <!-- TODO: for external apparatus, we will have to extend
                the logic in case a entry is nested in an external element,
                e.g. a <rdg>. This can be done by introducing another mode analog
                to lemma-text-nodes, that switches to the lemma of the including
                elment. -->
            <xsl:choose>
                <xsl:when test="$lemma-first-text-node-line-crit">
                    <xsl:sequence select="($lemma-text-nodes, $entry)[1]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:sequence select="($entry, $lemma-text-nodes)[last()]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="line-number" select="alea:line-number($lemma-node-for-line)"/>
        <xsl:sequence select="
                map {
                    'entry': $entry,
                    'lemma-text-nodes': $lemma-text-nodes,
                    'lemma-grouping-ids': $lemma-grouping-ids,
                    'line-number': $line-number
                }"/>
    </xsl:function>

    <xsl:function name="scdh:lemma-text-nodes" as="text()*">
        <xsl:param name="element" as="element()"/>
        <xsl:apply-templates select="$element" mode="lemma-text-nodes"/>
    </xsl:function>

    <!-- the mode lemma-text-nodes is for grouping apparatus entries by the text repeated from the base text -->
    <xsl:mode name="lemma-text-nodes" on-no-match="shallow-skip"/>

    <xsl:template mode="lemma-text-nodes" match="text()" as="text()">
        <xsl:sequence select="."/>
    </xsl:template>

    <!-- things that do not go into the base text -->
    <xsl:template mode="lemma-text-nodes"
        match="rdg | choice[corr]/sic | choice[reg]/orig | span | index | note | witDetail"/>

    <xsl:template mode="lemma-text-nodes"
        match="lem[matches($variant-encoding, '^(in|ex)ternal-double-end-point')]"/>


    <!-- mode 'lemma-text-nodes-dspt' is a dispatcher for various element types.
        The templates have to select nodes that go into the lemma. Typically they
        apply the rules from 'lemma-text-nodes' on them. -->
    <xsl:mode name="lemma-text-nodes-dspt"/>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[$variant-encoding eq 'internal-parallel-segmentation']">
        <xsl:apply-templates mode="lemma-text-nodes" select="lem"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[@from and $variant-encoding eq 'internal-double-end-point']">
        <xsl:variable name="limit-id" select="substring(@from, 2)"/>
        <xsl:variable name="limit" select="//*[@xml:id eq $limit-id]"/>
        <xsl:apply-templates mode="lemma-text-nodes"
            select="scdh:subtrees-between-anchors($limit, .)"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[@to and $variant-encoding eq 'internal-double-end-point']">
        <xsl:variable name="limit-id" select="substring(@to, 2)"/>
        <xsl:variable name="limit" select="//*[@xml:id eq $limit-id]"/>
        <xsl:apply-templates mode="lemma-text-nodes"
            select="scdh:subtrees-between-anchors(., $limit)"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[@from and @to and $variant-encoding eq 'external-double-end-point']">
        <xsl:variable name="from-id" select="substring(@from, 2)"/>
        <xsl:variable name="from" select="//*[@xml:id eq $from-id]"/>
        <xsl:variable name="to-id" select="substring(@to, 2)"/>
        <xsl:variable name="to" select="//*[@xml:id eq $to-id]"/>
        <xsl:apply-templates mode="lemma-text-nodes"
            select="scdh:subtrees-between-anchors($from, $to)"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="app[$variant-encoding eq 'internal-location-referenced']">
        <xsl:apply-templates mode="lemma-text-nodes" select="lem"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt" match="corr">
        <xsl:apply-templates mode="lemma-text-nodes"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt" match="choice[corr and sic]">
        <xsl:apply-templates mode="lemma-text-nodes" select="corr"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt"
        match="sic[not(parent::choice)] | unclear[not(parent::choice)]">
        <xsl:apply-templates mode="lemma-text-nodes"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt" match="choice[unclear]">
        <xsl:apply-templates mode="lemma-text-nodes" select="unclear[1]"/>
    </xsl:template>

    <xsl:template mode="lemma-text-nodes-dspt" match="choice[orig and reg]">
        <xsl:apply-templates mode="lemma-text-nodes" select="reg"/>
    </xsl:template>


    <!-- default rule -->
    <xsl:template mode="lemma-text-nodes-dspt" match="*">
        <xsl:message>
            <xsl:text>No matching rule in mode 'lemma-text-nodes-dspt' for apparatus element: </xsl:text>
            <xsl:value-of select="name(.)"/>
        </xsl:message>
        <xsl:apply-templates mode="lemma-text-nodes"/>
    </xsl:template>


    <!-- the template for an entry -->
    <xsl:template name="scdh:apparatus-entry">
        <xsl:param name="entries" as="map(*)*"/>
        <span class="apparatus-entry">
            <!-- TODO: when the lemma is empty
                call a function/template for generating a prefix or suffix from the base text.
                Pass this suffix via tunnel parameters on to mode 'apparatus-reading', so that
                the prefix or suffix can be added in the reading -->
            <xsl:call-template name="scdh:apparatus-lemma">
                <xsl:with-param name="entry" select="$entries[1]"/>
            </xsl:call-template>
            <span class="apparatus-sep" data-i18n-key="lem-rdg-sep">]</span>
            <xsl:for-each select="$entries">
                <xsl:apply-templates mode="apparatus-reading" select="map:get(., 'entry')"/>
                <xsl:if test="position() ne last()">
                    <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                        >;</span>
                </xsl:if>
            </xsl:for-each>
        </span>
    </xsl:template>

    <!-- template for making the lemma text with some logic for handling empty lemmas -->
    <xsl:template name="scdh:apparatus-lemma">
        <xsl:param name="entry" as="map(*)"/>
        <span class="apparatus-lemma">
            <xsl:variable name="full-lemma" as="xs:string"
                select="map:get($entry, 'lemma-text-nodes') => alea:shorten-string()"/>
            <xsl:choose>
                <xsl:when test="$full-lemma ne ''">
                    <xsl:value-of select="$full-lemma"/>
                </xsl:when>
                <xsl:otherwise>
                    <!-- FIXME -->
                    <xsl:text>empty</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </span>
    </xsl:template>


    <!-- The mode apparatus-reading is for the entries after the lemma (readings, etc.).
        It serves as a dispatcher for different types of entries.
        All templates should leave it again to get the text of the reading etc. -->
    <xsl:mode name="apparatus-reading" on-no-match="shallow-skip"/>

    <xsl:template mode="apparatus-reading" match="corr">
        <span class="static-text" data-i18n-key="coniec">&lre;coniec.&pdf;</span>
    </xsl:template>

    <xsl:template mode="apparatus-reading" match="sic[not(parent::choice)]">
        <span class="static-text" data-i18n-key="coniec">&lre;coniec.&pdf;</span>
    </xsl:template>

    <!-- we want corr first and sic second -/->
    <xsl:template mode="apparatus-reading" match="choice[corr and sic]">
        <xsl:apply-templates mode="apparatus-reading" select="corr"/>
        <xsl:apply-templates mode="apparatus-reading" select="sic"/>
    </xsl:template>
    -->

    <xsl:template mode="apparatus-reading" match="choice[corr]/sic">
        <span class="reading">
            <xsl:apply-templates select="." mode="apparatus-reading-text-text"/>
            <xsl:if test="@source">
                <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                    >:</span>
                <xsl:call-template name="witness-siglum-html">
                    <xsl:with-param name="wit" select="@source"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
        </span>
    </xsl:template>

    <xsl:template mode="apparatus-reading" match="app">
        <xsl:apply-templates mode="apparatus-reading" select="rdg | note"/>
        <xsl:apply-templates mode="apparatus-reading" select="witDetail"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading" match="rdg | witDetail">
        <span class="reading">
            <xsl:apply-templates select="node()" mode="apparatus-reading-text"/>
            <xsl:if test="@wit">
                <span class="apparatus-sep" style="padding-left: 3px" data-i18n-key="rdg-siglum-sep"
                    >:</span>
                <xsl:call-template name="witness-siglum-html">
                    <xsl:with-param name="wit" select="@wit"/>
                </xsl:call-template>
            </xsl:if>
            <xsl:if test="position() ne last()">
                <span class="apparatus-sep" style="padding-left: 4px" data-i18n-key="rdgs-sep"
                    >;</span>
            </xsl:if>
        </span>
    </xsl:template>

    <!-- a default rule -->
    <xsl:template mode="apparatus-reading" match="*">
        <xsl:message>
            <xsl:text>WARNING: no rule for generating the lemma for </xsl:text>
            <xsl:value-of select="name(.)"/>
        </xsl:message>
        <xsl:apply-templates mode="apparatus-reading-text" select="."/>
    </xsl:template>


    <!-- The mode apparatus-reading-text is for printing the text of a reading etc.
        Typically it is entred from a template in the mode apparatus-reading -->
    <xsl:mode name="apparatus-reading-text" on-no-match="shallow-skip"/>

    <xsl:template mode="apparatus-reading-text"
        match="app[$variant-encoding eq 'internal-parallel-segmentation']">
        <xsl:apply-templates mode="apparatus-reading-text" select="lem"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-text"
        match="app[matches($variant-encoding, 'ternal-double-end-point')]"/>

    <xsl:template mode="apparatus-reading-text" match="choice[sic and corr]">
        <xsl:apply-templates mode="apparatus-reading-text" select="corr"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-text" match="rdg">
        <xsl:apply-templates mode="apparatus-reading-text"/>
    </xsl:template>

    <xsl:template mode="apparatus-reading-text" match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

</xsl:stylesheet>
