```
 _____ _____ _____ _____     _____             _
|     |   | |     |   __|___|  _  |___ ___ _ _| |___ ___
| | | | | | |  |  |   __|___|     |   | . | | | | .'|  _|
|_|_|_|_|___|_____|_____|   |__|__|_|_|_  |___|_|__,|_|
                                      |___|
```

# MNO Enterprise Angular Frontend

## Gulp tasks

* `gulp` or `gulp build` to build an optimized version of your application in `/dist`
* `gulp serve` to launch a browser sync server on your source files
* `gulp serve:dist` to launch a server on your optimized application
* `gulp test` to launch your unit tests with Karma
* `gulp test:auto` to launch your unit tests with Karma in watch mode
* `gulp protractor` to launch your e2e tests with Protractor
* `gulp protractor:dist` to launch your e2e tests with Protractor on the dist files

## How to build this frontend on a Mno-Enterprise app

In the enterprise app directory:

Install dependencies
* run `npm install gulp gulp-util gulp-load-plugins del gulp-git`

* run `gulp clone-frontend;gulp run-npm-install`

This command will clone the frontend repository in the `.tmp-frontend` directory
and download its npm and bower dependencies.
You can change the **mno-enterprise-angular** frontend repository address and branch
by updating `git_frontend_repo` and `git_frontend_branch` variables in gulpfile.js

* run `gulp copy-custom-files`

Your custom files in the `frontend` directory will be duplicated in `.tmp-frontend` directory.
Your custom files must respect the `mno-enterprise-angular/src` code organization.

(eg. if the file `frontend/src/app/stylesheets/theme.less` is present in the host project, it will replace the one in `.tmp-frontend/src/app/stylesheets/theme.less`)

* run `gulp run-frontend-build;gulp copy-dist-files`

The **mno-enterprise-angular** project will be built with your custom files and duplicated in the `public` folder.

Repeat step 2 & 3, anytime you need to copy your custom files and recompile your frontend project.
