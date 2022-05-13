<?xml version="1.0" encoding="UTF-8"?>
<!-- generate an oxygen plugin download descriptor file from the pom file -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xt="http://www.oxygenxml.com/ns/extension"
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xpath-default-namespace="http://maven.apache.org/POM/4.0.0" version="2.0">
	<xsl:output method="xml" indent="yes"/>

	<xsl:template match="/">
		<xt:extensions
			xsi:schemaLocation="http://www.oxygenxml.com/ns/extension http://www.oxygenxml.com/ns/extension/extensions.xsd">
			<xt:extension id="{/project/artifactId}">
				<xt:location
					href="https://github.com/SCDH/ox4alea/releases/download/{/project/version}/{/project/artifactId}-{/project/version}-package.zip"/>
				<xt:version>
					<xsl:value-of select="/project/version"/>
				</xt:version>
				<xt:oxy_version>23.1+</xt:oxy_version>
				<xt:type>framework</xt:type>
				<xt:author>Christian Lück, Immanuel Normann</xt:author>
				<xt:name>TEI P5 - ALEA</xt:name>
				<xt:description xmlns="http://www.w3.org/1999/xhtml">
					<html>
						<head>
							<title>oXbytei framework</title>
						</head>
						<body>
							<div>
								<p>This is an &lt;oXygen/&gt; author framework for editing TEI P5
									documents, developed for the ALEA (Arabische Literatur
									Elfhundert bis Achtzehnhundert) research group. Thus, it has
									strong support for right-to-left scripts, though is generically
									designed. It was developed at SCDH, Westfälische
									Wilhelms-Universität Münster.</p>
								<p>This framework works on top of <a
										href="https://github.com/scdh/oxbytei">oXbytei</a> and <a
										href="https://github.com/scdh/oxbytao">oXbytao</a>, which
									you must also be installed.</p>
								<p>Visit the <a
										href="https://github.com/SCDH/ox4alea/releases/tag/{/project/version}"
										>release page</a> to see what's new.</p>
								<p>Copyright (c) 2021, 2022 SCDH, University of Münster</p>

								<p>This program is free software: you can redistribute it and/or
									modify it under the terms of the GNU General Public License as
									published by the Free Software Foundation, either version 3 of
									the License, or (at your option) any later version.<br/> This
									program is distributed in the hope that it will be useful, but
									WITHOUT ANY WARRANTY; without even the implied warranty of
									MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
									General Public License for more details.<br/> You should have
									received a copy of the GNU General Public License along with
									this program. If not, see <a href="http://www.gnu.org/licenses/"
										>http://www.gnu.org/licenses/</a></p>
							</div>
						</body>
					</html>
				</xt:description>
				<xt:license>
					<xsl:value-of select="unparsed-text('../LICENSE')"/>
				</xt:license>
			</xt:extension>
		</xt:extensions>
	</xsl:template>

</xsl:stylesheet>
