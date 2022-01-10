<?xml version="1.0" encoding="UTF-8"?>
<!-- generate an oxygen plugin download descriptor file from the pom file -->
<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xt="http://www.oxygenxml.com/ns/extension"
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xpath-default-namespace="http://maven.apache.org/POM/4.0.0"
    version="2.0">
    <xsl:output method="xml" indent="yes"/>

    <xsl:template match="/">
    	<xsl:variable name="oxbytei-version" select="/project/properties/oxbytei.version"/>
    	<xsl:variable name="teip5alea-version" select="/project/version"/>
    	<xt:extensions
	    xsi:schemaLocation="http://www.oxygenxml.com/ns/extension http://www.oxygenxml.com/ns/extension/extensions.xsd">
	    <xt:extension id="{/project/artifactId}">
		<xt:location href="https://scdh.zivgitlabpages.uni-muenster.de/hees-alea/oxygen-framework/{/project/artifactId}-{$teip5alea-version}-package.zip"/>
		<xt:version><xsl:value-of select="$teip5alea-version"/></xt:version>
		<xt:oxy_version>15.1+</xt:oxy_version>
		<xt:type>framework</xt:type>
		<xt:author>Christian Lück, Immanuel Normann</xt:author>
		<xt:name>TEI P5 - ALEA-Extension</xt:name>
		<xt:description xmlns="http://www.w3.org/1999/xhtml">
		    An &lt;oXygen/&gt; author framework extending TEI P5,
		    developed at SCDH, Westfälische Wilhelms-Universität
		    Münster. It is developed for the ALEA (Arabische
		    Literatur Elfhundert bis Achtzehnhundert) research
		    group and has support for right-to-left scripts,
		    though is generically designed.
		</xt:description>
		<xt:license>
		    <xsl:value-of select="unparsed-text('../LICENSE')"/>
		</xt:license>
	    </xt:extension>
		<xt:extension id="oxbytei">
			<xt:location href="https://github.com/SCDH/oxbytei/releases/download/{$oxbytei-version}/oxbytei-{$oxbytei-version}-package.zip"/>
			<xt:version><xsl:value-of select="$oxbytei-version"/></xt:version>
			<xt:oxy_version>23.1+</xt:oxy_version>
			<xt:type>framework</xt:type>
			<xt:author>Christian Lück</xt:author>
			<xt:name>oXbytei</xt:name>
			<xt:description>oXbytei is required by the ALEA Extension. Please install both frameworks!</xt:description>
			<xt:license>
				<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
				<xsl:value-of select="unparsed-text('https://raw.githubusercontent.com/SCDH/oxbytei/main/LICENSE')"/>
				<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>
			</xt:license>
		</xt:extension>
	</xt:extensions>
    </xsl:template>

</xsl:stylesheet>


