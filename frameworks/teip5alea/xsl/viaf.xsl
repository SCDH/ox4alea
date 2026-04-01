<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="#all" version="3.0"
    default-mode="oxy-action">

    <xsl:import href="../x2tei-transformations/xsl/rdf/viaf.xsl"/>

    <xsl:template mode="oxy-action" match="node()">
        <xsl:call-template name="from-viaf"/>
    </xsl:template>

</xsl:stylesheet>
