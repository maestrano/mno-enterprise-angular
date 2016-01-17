'use strict';

var path = require('path');
var gulp = require('gulp');
var conf = require('./conf');

var browserSync = require('browser-sync');

var $ = require('gulp-load-plugins')();

var wiredep = require('wiredep').stream;
var _ = require('lodash');
var rename = require("gulp-rename");

// Concatenate all LESS files in one
gulp.task('less-concat', function() {
  var injectFiles = gulp.src([
    path.join(conf.paths.src, '/app/stylesheets/theme.less'),
    path.join(conf.paths.src, '/app/stylesheets/variables.less'),
    path.join(conf.paths.src, '/app/stylesheets/live-previewer.less'),
    path.join(conf.paths.src, '/app/stylesheets/live-previewer-tmp.less'),
    path.join(conf.paths.src, '/app/**/*.less'),
    path.join('!' + conf.paths.src, '/app/index.less'),
  ])

  var injectOptions = {
    transform: function(filePath,file) {
      return file.contents.toString('utf8')
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
    .pipe($.replace('../../../bower_components/', '../bower_components/'))
    .pipe($.replace('../../bower_components/', '../bower_components/'))
    .pipe(rename({ basename: "theme-previewer" }))
    .pipe(gulp.dest(path.join(conf.paths.dist, '/styles/')))
});

gulp.task('styles', function () {
  var lessOptions = {
    options: [
      'bower_components',
      path.join(conf.paths.src, '/app')
    ]
  };

  // Ensure live-previewer files are loaded *after*
  // the theme and variables ones.
  // The live-previewer file is used for published changes
  // The live-previewer-tmp file is used for pending changes (ignored here
  // as it should not be used for published style - only used by the less-concat
  // task)
  var injectFiles = gulp.src([
    path.join(conf.paths.src, '/app/stylesheets/theme.less'),
    path.join(conf.paths.src, '/app/stylesheets/variables.less'),
    path.join(conf.paths.src, '/app/stylesheets/live-previewer.less'),
    path.join(conf.paths.src, '/app/**/*.less'),
    path.join('!' + conf.paths.src, '/app/stylesheets/live-previewer-tmp.less'),
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
