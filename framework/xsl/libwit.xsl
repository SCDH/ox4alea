<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:scdh="http://scdh.wwu.de/oxygen#ALEA"
    xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="xs"
    version="3.0">

    <xsl:function name="scdh:getWitnessSiglum" as="xs:string">
        <xsl:param name="pdu" as="xs:string"/>
        <xsl:param name="witnessCat" as="xs:string"/>
        <xsl:param name="id" as="xs:string"/>
	<xsl:value-of select="scdh:getWitnessSiglum($pdu, $witnessCat, $id, ' ')"/>
    </xsl:function>

    <!-- TODO: This function does not use sep yet, due to issue in
         get-witness-siglum-seq. See tests. -->
    <xsl:function name="scdh:getWitnessSiglum">
        <xsl:param name="pdu" as="xs:string"/>
        <xsl:param name="witnessCat" as="xs:string"/>
        <xsl:param name="id" as="xs:string"/>
	<xsl:param name="sep" as="xs:string"/>
        <xsl:value-of select="string-join(scdh:get-witness-siglum-seq($pdu, $witnessCat, $id), $sep)"/>
    </xsl:function>

    <!-- TODO: make this function return a sequence of strings. See tests -->
    <xsl:function name="scdh:get-witness-siglum-seq" as="xs:string*">
        <xsl:param name="pdu" as="xs:string"/>
        <xsl:param name="witnessCat" as="xs:string"/>
        <xsl:param name="id" as="xs:string"/>
        <xsl:variable name="witnessFile" select="concat($pdu, '/', $witnessCat)"/>
        <xsl:sequence select="if (doc-available($witnessFile))
			      then let $witnesses := doc($witnessFile)/TEI/text//witness return
			           for $i in tokenize($id, '\s+') return 
				       if (exists($witnesses[@xml:id=scdh:normalize-id($i)])) 
				       then $witnesses[@xml:id=scdh:normalize-id($i)]//abbr[@type='siglum'][1]
				       else $i
			      else ($id)"/>
    </xsl:function>

    <xsl:function name="scdh:get-witness-id">
        <xsl:param name="pdu" as="xs:string"/>
        <xsl:param name="witnessCat" as="xs:string"/>
        <xsl:param name="siglum" as="xs:string"/>
        <xsl:variable name="witnessFile" select="concat($pdu, '/', $witnessCat)"/>
        <xsl:value-of select="if (doc-available($witnessFile)) 
            then (normalize-space(string-join((
            for $s in tokenize($siglum, '[,،\s]+') return
                    let $sig := doc($witnessFile)/TEI/text//witness//abbr[@type='siglum' and . = $s]
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
