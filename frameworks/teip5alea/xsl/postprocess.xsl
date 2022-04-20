<?xml version="1.0" encoding="UTF-8"?>
<!-- This is just a hook to be replaced by a project-specific transformation.

You can replace it using an XML catalog.

This is yust an identity transformation. It is run after
some transformations that produce TEI. You can use this hook
in order to adjust the header or replace expanded XIncludes
by non-expanded XIncludes again. 
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" exclude-result-prefixes="xs" version="3.0">

    <xsl:mode on-no-match="shallow-copy"/>

</xsl:stylesheet>
