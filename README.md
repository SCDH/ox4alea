# oxygen-framework

oXygen Anpassungen für die Edition Ibn Nubata


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
