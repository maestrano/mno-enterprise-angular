```
 _____ _____ _____ _____     _____             _
|     |   | |     |   __|___|  _  |___ ___ _ _| |___ ___
| | | | | | |  |  |   __|___|     |   | . | | | | .'|  _|
|_|_|_|_|___|_____|_____|   |__|__|_|_|_  |___|_|__,|_|
                                      |___|
```

[![Code Climate](https://codeclimate.com/github/maestrano/mno-enterprise-angular/badges/gpa.svg)](https://codeclimate.com/github/maestrano/mno-enterprise-angular)

# MNO Enterprise Angular Frontend

## How to run in development mode

### Prerequisite

Create and setup a Rails project to bootstrap an instance of Maestrano Enterprise Express as describe in the [mno-enterprise Github repository](https://github.com/maestrano/mno-enterprise).

Run this Maestrano Enterprise Express project, it should now be available at http://localhost:7000.

This project will serve as a backend for our mno-enterprise-angular development environment.

### Install & run mno-enterprise-angular

* Clone this repository, and `cd mno-enterprise-angular`
* Run `npm install && bower install`
* To start the project, run `gulp serve`

A new browser tab should be open at address http://localhost:7001, with Browsersync enabled, waiting to auto-refresh in case template or CoffeeScript code is changed, or inject any modified styles.

## List of gulp tasks

* `gulp` or `gulp build` to build an optimized version of your application in `/dist`
* `gulp serve` to launch a browser sync server on your source files
* `gulp serve:dist` to launch a server on your optimized application
* `gulp test` to launch your unit tests with Karma
* `gulp test:auto` to launch your unit tests with Karma in watch mode
* `gulp protractor` to launch your e2e tests with Protractor
* `gulp protractor:dist` to launch your e2e tests with Protractor on the dist files
