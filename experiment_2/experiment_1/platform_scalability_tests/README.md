# Scalability tests for Smart City Platform

Source code of scalability tests of
[Smart City Software Platform](gitlab.com/groups/smart-city-software-platform).
This project uses the [Scalability Explorer Framework]() for 
scalability testing. We develop this code based on 
[Mezuro Scalability Tests](https://github.com/mezuro/scalability_tests).

## Setup

Follow this steps to run this suite of tests:

* Install java jdk 1.8
* Install maven 3.3.9
* Clone the repository and its submodules:
`git clone --recursive git@github.com:arthurmde/platform_scalability_test.git`
* Enter in projects directory:
`cd platform_scalability_test`
* Enter in submodule scalability_explorer install dependencies:
`cd scalability_explorer && mvn install`

## Change your classpath variables

If the installation run correctly, you should have a .m2/repository/
directory on your home. You have to include it on your Build Path. If you 
are using Eclipse, go to
```
Window -> Preferences -> Java -> Build Path -> Classpath Variables
```
Click on New, insert some name (M2_REPO, for instance) and insert the path. 
Should be ~/.m2/repository/. You will probably need to build your project 
for these changes to take effect.


