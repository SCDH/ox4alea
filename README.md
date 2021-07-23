# ALEA &lt;oXygen/> Framework

An &lt;oXygen/> extension for the edition of the works of Ibn Nubata
al Misri.

## Installation

The framework can be installed with &lt;oXygen/>'s installation and
update mechanism. Therefore, the following URL has to be entered into
the form "Show addons from:" of the dialogue box from "Help" -> "Install
new addons...".

[https://scdh.zivgitlabpages.uni-muenster.de/hees-alea/oxygen-framework/descriptor.xml](https://scdh.zivgitlabpages.uni-muenster.de/hees-alea/oxygen-framework/descriptor.xml)

As an alternative, the framework can be packaged locally for
installation or it can be installed for hacking.

There must be some [customization](#customization) in the edition's
&lt;oXygen/> project.

## Packaging

Packaging is done with [`maven`](https://maven.apache.org/).

	$ mvn package
	
This will create a `scdh-alea-oxygen-extension-<VERSION>-package.zip`
and `scdh-alea-oxygen-extension-<VERSION>.jar` in the `target`
folder. Both files contain the framework. The zip-File is the same as
the one distributed under the above mentioned URL.

## Hacking

Installing the framework as an &lt;oXygen/> package will make it
read-only. For hacking on it's code you can install it by registering
the path to the cloned repository in &lt;oXygen/>'s settings.

- 1) Clone this repository into a subfolder of an &lt;oXygen/>
  project, e.g. `teip5alea`. (It may also be sym-linked there.)

- 2) Start &lt;oXygen/> and select `Options` -> `Preferences` from the
  menu. Expand `Document Type Association` on the left and select
  `Locations [P]` under it. Click `Add` to add a new additional
  framework directory.  Enter `${pd}/teip5alea` as directory and click
  `OK`. (Note: `${pd}` is an [editor
  variable](https://www.oxygenxml.com/doc/versions/22.1/ug-editor/topics/editor-variables.html)
  and points to the root folder of the current project.
  
- 3) Close and restart &lt;oXygen/>. The framework is now present as an
  extension to the default TEI P5 framework throughout all your
  projects.


## Unit Tests

There are unit tests for the XSL transformations based on
[`XSpec`](https://github.com/xspec/xspec) in `test/xspec`. The tests
can easily be run with maven from the root directory of the
repository:

	mvn test

Maven will install all required packages for running the tests,
e.g. `XSpec` and `Saxon-HE`. A detailed test report can be viewed with
the browser in `target/xspec-reports/index.html`.

The test suite or single tests can also be run from the root of this
repository with

	<path-to/xspec.sh> -catalog catalog.xml test/xspec/*.xspec

This requires `XSpec` and `Saxon-HE` and the [XML
Resolver](https://mvnrepository.com/artifact/xml-resolver/xml-resolver)
installed. Provided that you've run maven before and maven caches its
downloads under the `~/.m2/repository` folder you can set an
environment variable as follows:

	export SAXON_CP=~/.m2/repository/net/sf/saxon/Saxon-HE/9.9.1-6/Saxon-HE-9.9.1-6.jar:~/.m2/repository/xml-resolver/xml-resolver/1.2/xml-resolver-1.2.jar

The test result is in `test/xspec/xspec/*-review.html`.

## Customization ##

The framework can and should be adapted to your project's needs by
customization. Customization includes:

- redirect to a bibliography through an XML catalog
- redirect to a catalog of witnesses through an XML catalog 
- redirect to local CSS with font definitions etc. through an XML catalog
- insert a taxonomy of named objects (plants, animals, etc.) into the
  `<encodingDesc>` of each TEI documents header (by means of XInclude)
- also insert a taxonomy of segment types in there

Take a look at the folder
[`frameworks/teip5alea/samples`](frameworks/teip5alea/samples) for
sample resources, especially at the XML catalog. Without
customization, the files from this folder are used.
