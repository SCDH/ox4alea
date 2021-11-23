<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs scdh"
    version="3.0">

    <!-- URI of witness catalogue. -->
    <xsl:param name="witness-cat" select="'WitnessCatalogue.xml'" as="xs:string"/>

    <xsl:function name="scdh:getWitnessSiglum" as="xs:string">
        <xsl:param name="id" as="xs:string"/>
	<xsl:value-of select="scdh:getWitnessSiglum($id, ' ')"/>
    </xsl:function>

    <xsl:function name="scdh:getWitnessSiglum">
        <xsl:param name="id" as="xs:string"/>
        <xsl:param name="sep" as="xs:string"/>
        <xsl:value-of select="string-join(scdh:get-witness-siglum-seq($id), $sep)"/>
    </xsl:function>

    <xsl:function name="scdh:get-witness-siglum-seq" as="xs:string*">
        <xsl:param name="id" as="xs:string"/>
        <xsl:sequence select="if (doc-available($witness-cat))
			      then let $witnesses := doc($witness-cat)/TEI/text//witness return
			           for $i in tokenize($id, '\s+') return 
				       if (exists($witnesses[@xml:id=scdh:normalize-id($i)])) 
				       then $witnesses[@xml:id=scdh:normalize-id($i)]//abbr[@type='siglum'][1]
				       else $i
			      else ($id)"/>
    </xsl:function>

    <xsl:template name="witness-siglum-html">
        <xsl:param name="wit" as="xs:string"/>
        <span class="siglum">
            <xsl:for-each select="scdh:get-witness-siglum-seq($wit)">
                <xsl:value-of select="."/>
                <xsl:if test="position() ne last()">
                    <span data-i18n-key="witness-sep">, </span>
                </xsl:if>
            </xsl:for-each>
        </span>
    </xsl:template>

    <xsl:function name="scdh:get-witness-id">
        <xsl:param name="siglum" as="xs:string"/>
        <xsl:value-of select="if (doc-available($witness-cat))
            then (normalize-space(string-join((
            for $s in tokenize($siglum, '[,،\s]+') return
                    let $sig := doc($witness-cat)/TEI/text//witness//abbr[@type='siglum' and . = $s]
                        return
                            if ($sig)
                                then ($sig/ancestor::witness/concat('#', @xml:id))
                                else ($s)), ' ')))
            else ($siglum)"/>
    </xsl:function>

    <xsl:function name="scdh:normalize-id">
        <xsl:param name="in" as="xs:string"/>
        <xsl:value-of select="replace(normalize-space($in), '#', '')"/>
    </xsl:function>
    
    <xsl:function name="scdh:tokenize-wit">
        <xsl:param name="witnesses" as="xs:string"/>
        <xsl:value-of select="tokenize($witnesses, '[,،\s]+')"/>
    </xsl:function>

</xsl:stylesheet>
