<?xml version="1.0" encoding="UTF-8"?>
<!-- Functions for getting subtrees between anchors or other nodes. -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:scdh="http://scdh.wwu.de/xslt#"
    exclude-result-prefixes="xs" version="3.0">

    <xsl:param name="debug" select="false()" as="xs:boolean" required="false"/>

    <!-- helper function:
        for given a sequence of nodes, filter away (drop) those nodes,
        that are descendants of other nodes in the sequence -->
    <xsl:function name="scdh:drop-descendants" as="node()*">
        <xsl:param name="nodes" as="node()*"/>
        <xsl:variable name="ids" as="xs:string*" select="
                for $n in $nodes
                return
                    generate-id($n)"/>
        <xsl:if test="$debug">
            <xsl:message>
                <xsl:text>Nodes in set: </xsl:text>
                <xsl:value-of select="$ids"/>
            </xsl:message>
        </xsl:if>
        <!-- TODO: what if ./parent::* is () ? -->
        <xsl:sequence select="
                $nodes[let $parent-id := generate-id(./parent::*)
                return
                    every $id in $ids
                        satisfies $id ne $parent-id]"/>
    </xsl:function>

    <!-- get sequence of subtrees between start and end anchors given by ID -->
    <xsl:function name="scdh:subtrees-between-anchors" as="node()*">
        <xsl:param name="context" as="node()"/>
        <xsl:param name="start-id" as="xs:string"/>
        <xsl:param name="end-id" as="xs:string"/>
        <xsl:variable name="root" select="root($context)"/>
        <xsl:variable name="start" as="node()" select="$root//*[@xml:id eq substring($start-id, 2)]"/>
        <xsl:variable name="end" as="node()" select="$root//*[@xml:id eq substring($end-id, 2)]"/>
        <xsl:sequence select="scdh:subtrees-between-anchors($start, $end)"/>
    </xsl:function>

    <!-- get sequence of subtrees between start and end anchors given as nodes -->
    <xsl:function name="scdh:subtrees-between-anchors" as="node()*">
        <xsl:param name="start-node" as="element()"/>
        <xsl:param name="end-node" as="element()"/>
        <xsl:sequence
            select="($start-node/following::node() intersect $end-node/preceding::node()) => scdh:drop-descendants()"
        />
    </xsl:function>

</xsl:stylesheet>
