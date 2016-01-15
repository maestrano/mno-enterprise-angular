'use strict';

var path = require('path');
var gulp = require('gulp');
var conf = require('./conf');

var browserSync = require('browser-sync');

var $ = require('gulp-load-plugins')();

var wiredep = require('wiredep').stream;
var _ = require('lodash');

// Concatenate all LESS files in one
gulp.task('less-concat', function() {
  return gulp.src([
    path.join(conf.paths.src, '/app/stylesheets/theme.less'),
    path.join(conf.paths.src, '/app/stylesheets/variables.less'),
    path.join(conf.paths.src, '/app/stylesheets/live-previewer.less'),
    path.join(conf.paths.src, '/app/**/*.less')
  ])
  .pipe($.concat('app.less'))
  .pipe(wiredep(_.extend({}, conf.wiredep)))
  .pipe($.replace('../../../bower_components/', '../../bower_components'))
  .pipe(gulp.dest(path.join(conf.paths.dist, '/styles/')))
});

gulp.task('styles', function () {
  var lessOptions = {
    options: [
      'bower_components',
      path.join(conf.paths.src, '/app')
    ]
  };

  // Ensure live-previewer file is loaded *after*
  // the theme and variables ones.
  var injectFiles = gulp.src([
    path.join(conf.paths.src, '/app/stylesheets/theme.less'),
    path.join(conf.paths.src, '/app/stylesheets/variables.less'),
    path.join(conf.paths.src, '/app/stylesheets/live-previewer.less'),
    path.join(conf.paths.src, '/app/**/*.less'),
    path.join('!' + conf.paths.src, '/app/index.less'),
  ], { read: false });

  var injectOptions = {
    transform: function(filePath) {
      filePath = filePath.replace(conf.paths.src + '/app/', '');
      return '@import "' + filePath + '";';
    },
    starttag: '// injector',
    endtag: '// endinjector',
    addRootSlash: false
  };


  return gulp.src([
    path.join(conf.paths.src, '/app/index.less')
  ])
    .pipe($.inject(injectFiles, injectOptions))
    .pipe(wiredep(_.extend({}, conf.wiredep)))
    .pipe($.sourcemaps.init())
    .pipe($.less(lessOptions)).on('error', conf.errorHandler('Less'))
    .pipe($.autoprefixer()).on('error', conf.errorHandler('Autoprefixer'))
    .pipe($.sourcemaps.write())
    .pipe(gulp.dest(path.join(conf.paths.tmp, '/serve/app/')))
    .pipe(browserSync.reload({ stream: true }));
});
