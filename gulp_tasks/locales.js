const gulp = require('gulp');
const fs = require('fs');
const path = require('path');
const merge = require('merge-stream');
const merge_json = require('gulp-merge-json');

const conf = require('../conf/gulp.conf');
const localesPath = 'bower_components/impac-angular/dist/locales/';

// Return a list of locales file from a folder
function getLocales(dir) {
  return fs.readdirSync(dir)
    .filter(function(file) {
      return file.substr(-5) === '.json';
    });
}

// Append their locale to our locale
function mergeLocales(our, their) {
  return gulp.src([
    conf.path.src('locales/', our),
    path.join(localesPath, their)
  ], {allowEmpty: true})
    .pipe(merge_json({fileName: our}))
    .pipe(gulp.dest(conf.path.tmp('locales')))
}

// Get the locales from impac-angular and append them to our locales
// Only in dev are we are generating the locales from YAML for prod build
function locales() {
  var locales = getLocales(localesPath);

  // Executes the function once per file and returns the async stream
  // This will append 'en-AU.json' to 'en-AU.json'
  var tasks = locales.map(function(file) {
    return mergeLocales(file, file)
  });

  // Default 2 letter locales
  // Append 'zh-HK' to 'zh'
  var tasks_def = ['en-AU', 'zh-HK'].map(function(locale) {
    var short = locale.slice(0, 2);
    return mergeLocales(short + '.json', locale + '.json');
  });

  // Combines the streams and ends only when all streams emitted end
  return merge(tasks, tasks_def);
}

gulp.task('locales', locales);
