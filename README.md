# ALEA &lt;oXygen/> Framework #

![release](https://github.com/scdh/ox4alea/actions/workflows/release.yml/badge.svg)
![tests](https://github.com/scdh/ox4alea/actions/workflows/test-main.yml/badge.svg)


An &lt;oXygen/> extension developed for the edition of the works of
Ibn Nubata al Misri by the ALEA research group.

## Installation

Install from [https://scdh.github.io/ox4alea/descriptor.xml](https://scdh.github.io/ox4alea/descriptor.xml).

The framework can be installed with &lt;oXygen/>'s installation and
update mechanism. Therefore, the above URL has to be entered into
the form "Show addons from:" of the dialogue box from "Help" ->
"Install new addons...".

This framework works on top of oXbytei and oXbytao, which must also be
installed.

- [oXbytei](https://github.com/SCDH/oxbytei)
- [oXbytao](https://github.com/SCDH/oxbytoa)

Alternative installation methods are explained in [oXbytei's
documentation](https://github.com/SCDH/oxbytei#installation) and can
be applied analogously.


## Features and Usage ##

This framework adds only a thin layer of additional functions on top
of oXbytei and oXbytao.

- shortcut actions for encoding
  - verbatim citations from the holy text and other sources
  - references to encyclopedia articles: this simply collects
    bibliographic entries marked with `type="encyclopedia"` from your
    bibliography and presents them for selection
  - etc.
  
- an HTML preview with a line-referencing critical apparatus and two
  column text presentation for verses with caesura

- transformations useful for editing multiple recensions of the same text

### Project specific CSS ###

In order to get nice rendering in author mode, you should provide CSS
for the used languages through the project specific CSS file (see
[oXbytao](https://github.com/scdh/oxbytao#css)). Here is an example:

```{css}
@namespace xml "http://www.w3.org/XML/1998/namespace";

[xml|lang="ar"] {
    direction: rtl !important;
}

[xml|lang="de"] {
    direction: ltr !important;
}

[xml|lang="en"] {
    direction: ltr !important;
}

[xml|lang="ar-DE"] {
    direction: ltr !important;
}
```


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


# License #

GPL v3

Some icons where taken from the web:

- [Encyclopedia icons created by Freepik - Flaticon](https://www.flaticon.com/free-icons/encyclopedia)
