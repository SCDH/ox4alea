<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for resetting the MRE:
    sets 'visible' to all recensions
    sets 'fading' and 'othertarget' to all recensions but the current one
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs" version="3.0">

    <xsl:import href="mre-common.xsl"/>

    <xsl:variable name="recension-to-become-current" as="xs:integer" select="$current-index"/>

</xsl:stylesheet>
