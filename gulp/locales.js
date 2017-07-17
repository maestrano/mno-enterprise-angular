'use strict';

var gulp   = require('gulp');
var $ = require('gulp-load-plugins')();

gulp.task('locales', function () {
  gulp.src('bower_components/impac-angular/dist/locales/*')
  .pipe($.rename(function (filename) {
    filename.basename = filename.basename.slice(0, 2);
  }))
  .pipe(gulp.dest('src/locales/impac'))
});
