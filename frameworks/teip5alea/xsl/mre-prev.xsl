<?xml version="1.0" encoding="UTF-8"?>
<!-- XSLT for resetting the MRE:
    sets 'current' to the previous recension in the sequence of recensions
    sets 'othertarget' ato all recension before the next one or to the first if we're currently at the last one
    sets 'visible' to all recensions
    sets 'fading' to all recensions but the next one
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns="http://www.tei-c.org/ns/1.0"
    xmlns:oxy="http://www.oxygenxml.com/ns/author/xpath-extension-functions"
    xpath-default-namespace="http://www.tei-c.org/ns/1.0" exclude-result-prefixes="xs oxy"
    version="3.0">

    <xsl:import href="mre-common.xsl"/>

    <xsl:variable name="recension-to-become-current" as="xs:integer" select="
            if ($current-index eq 1) then
                count($recensions)
            else
                $current-index - 1"/>

</xsl:stylesheet>
