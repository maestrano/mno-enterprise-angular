const gulp = require('gulp');
const rename = require('gulp-rename');

gulp.task('locales', locales);

function locales() {
  return gulp.src('bower_components/impac-angular/dist/locales/*')
    .pipe(rename(function (filename) {
      filename.basename = filename.basename.slice(0, 2);
    }))
    .pipe(gulp.dest('src/locales/impac'))
}
