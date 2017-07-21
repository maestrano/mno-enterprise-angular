'use strict';

var fs = require('fs');
var path = require('path');
var gulp = require('gulp');
var conf = require('./conf');

var bowerInfo = require('../bower.json');

var $ = require('gulp-load-plugins')();

var wiredep = require('wiredep').stream;
var _ = require('lodash');

// Scripts to run impac.version in the console (need to refresh first)
// Needs to be called AFTER scripts due to permissions errors
gulp.task('version', ['scripts'], function () {
  var func = '(function () {console.info("' + bowerInfo.description + ' - v' + bowerInfo.version + '"); window["mnoe"] = {"version": "' + bowerInfo.version + '"};}).call();';

  return fs.writeFileSync(path.join(conf.paths.tmp, '/serve', '/app', '/version.js'), func);
});

gulp.task('inject', ['scripts', 'styles', 'version'], function () {
  var injectStyles = gulp.src([
    path.join(conf.paths.tmp, '/serve/app/**/*.css'),
    path.join('!' + conf.paths.tmp, '/serve/app/vendor.css')
  ], { read: false });

  var injectScripts = gulp.src([
    path.join(conf.paths.src, '/app/**/*.module.js'),
    path.join(conf.paths.src, '/app/**/*.js'),
    path.join('!' + conf.paths.src, '/app/**/*.spec.js'),
    path.join('!' + conf.paths.src, '/app/**/*.mock.js'),
    path.join(conf.paths.tmp, '/serve/app/**/*.module.js'),
    path.join(conf.paths.tmp, '/serve/app/**/*.js'),
    path.join('!' + conf.paths.tmp, '/serve/app/**/*.spec.js'),
    path.join('!' + conf.paths.tmp, '/serve/app/**/*.mock.js')
  ])
  .pipe($.angularFilesort()).on('error', conf.errorHandler('AngularFilesort'));

  var injectOptions = {
    ignorePath: [conf.paths.src, path.join(conf.paths.tmp, '/serve')],
    addRootSlash: false
  };

  return gulp.src(path.join(conf.paths.src, '/*.html'))
    .pipe($.inject(injectStyles, injectOptions))
    .pipe($.inject(injectScripts, injectOptions))
    .pipe(wiredep(_.extend({}, conf.wiredep)))
    .pipe(gulp.dest(path.join(conf.paths.tmp, '/serve')));
});
