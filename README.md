# ALEA &lt;oXygen/> Framework

&lt;oXygen/> Anpassungen für die Edition Ibn Nubata

## Installation

The framework can be installed from the following URL, which must
therefore be entered to &lt;oXygen/>'s framework locations.

TODO

As an alternative, the framework be packaged locally for installation
or it can be installed for hacking.

## Packaging

Packaging is done with [`maven`](https://maven.apache.org/).

	$ mvn package
	
This will create a `scdh-alea-oxygen-extension-<VERSION>.jar` in the
`target` folder. This jar-File contains the framework (and its
dependencies) and can be distributed to users.

## Hacking

Installing the framework as an &lt;oXygen/> package will make it
read-only. For hacking on it's code you can install it by registering
the path to the cloned repository in &lt;oXygen/>'s settings.

- 1) Clone this repository, e.g. to a subfolder called `alea
	oxygen-framework` in a folder called `src` in your home directory.

- 2) Start &lt;oXygen/> and select `Options` -> `Preferences` from the
  menu. Expand `Document Type Association` on the left and select
  `Locations [P]` under it. Click `Add` to add a new additional
  framework directory.  Enter
  `${homeDir}/src/alea-oxygen-framework/frameworks/teip5alea` as
  directory and click `OK`.
  
- 3) Close and restart &lt;oXygen/>. The framework is now present as an
  extension to the default TEI P5 framework throughout all your
  projects.

Notice that `${homeDir}` is a so called editor variable. &lt;oXygen/>
expands it to the path of your home directory. This method should be
portable.


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

	<path-to/xspec.sh> test/xspec/*.xspec

This requires `XSpec` and `Saxon-HE` installed. The test result is in
`test/xspec/xspec/*-review.html`.
