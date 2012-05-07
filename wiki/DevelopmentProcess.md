# Build

The build tool used is Maven,
Please ensure that you have maven installed.
The erlang-maven-plugin version used is 2.2.0

## Build goals
Here are the main build goals used
*  mvn compile: To compile the source code
*  mvn test: To run the eunit tests
*  mvn site: To generate the maven site. The pom.xml file configures the site to contain the edoc, eunit and  coverage reports.
*  mvn license:check: Ensure that all the source code files contains a license disclaimer.
*  mvn license:format: Add the license to every files