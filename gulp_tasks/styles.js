const gulp = require('gulp');
const browserSync = require('browser-sync');
const sourcemaps = require('gulp-sourcemaps');
const less = require('gulp-less');
const postcss = require('gulp-postcss');
const autoprefixer = require('autoprefixer');
const inject = require('gulp-inject');
const replace = require('gulp-replace');
const wiredep = require('wiredep').stream;
const sprity = require('sprity');
const gulpif = require('gulp-if');
const rename = require('gulp-rename');
var _ = require('lodash');

const conf = require('../conf/gulp.conf');

gulp.task('styles', styles);
gulp.task('sprites', sprites);
gulp.task('less-concat', lessConcat);

function styles() {
  var lessOptions = {
    compress: false,
    options: [
      'bower_components',
      conf.path.src('/app')
    ]
  };

  var injectFiles = gulp.src([
    conf.path.src('/app/stylesheets/theme.less'),
    conf.path.src('/app/stylesheets/*.less'),
    conf.path.src('/app/stylesheets/variables.less'),
    conf.path.src('/app/**/*.less'),
    conf.path.src('/fonts/**/*.less'),
    conf.path.src('/images/**/*.less'),
    `!${conf.path.src('/app/index.less')}`,
    `!${conf.path.src('/app/stylesheets/theme-previewer-tmp.less')}`
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

  return gulp.src(conf.path.src('app/index.less'))
    .pipe(inject(injectFiles, injectOptions))
    .pipe(wiredep(_.extend({}, conf.wiredep)))
    .pipe(sourcemaps.init())
    .pipe(less(lessOptions)).on('error', conf.errorHandler('Less'))
    .pipe(postcss([autoprefixer()])).on('error', conf.errorHandler('Autoprefixer'))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(conf.path.tmp()))
    .pipe(browserSync.stream());
}

// generate sprites
function sprites() {
  return sprity.src({
    src: './src/images/sprites/*/*.{png,jpg}',
    style: 'mnoe-sprites.less',
    margin: 0,
    name: 'sprites/mnoe-sprites',
    prefix: 'mnoe-icon',
  })
    .pipe(gulpif('*.png', gulp.dest(conf.path.src('/images/')), gulp.dest(conf.path.src('/images/sprites/'))));
}

// Concatenate all LESS files in one
function lessConcat() {
  var injectFiles = gulp.src([
    conf.path.src('/app/stylesheets/theme.less'),
    conf.path.src('/app/stylesheets/*.less'),
    conf.path.src('/app/stylesheets/variables.less'),
    conf.path.src('/app/**/*.less'),
    conf.path.src('/fonts/**/*.less'),
    conf.path.src('/images/**/*.less'),
    `!${conf.path.src('/app/index.less')}`
  ]);

  var injectOptions = {
    transform: function(filePath,file) {
      return file.contents.toString('utf8');
    },
    starttag: '// injector',
    endtag: '// endinjector',
    addRootSlash: false
  };

  return gulp.src([
    conf.path.src('/app/index.less')
  ])
    .pipe(inject(injectFiles, injectOptions))
    .pipe(wiredep(_.extend({}, conf.wiredep)))
    .pipe(replace('../../../bower_components/', '../bower_components/'))
    .pipe(replace('../../bower_components/', '../bower_components/'))
    .pipe(rename({ basename: 'theme-previewer' }))
    .pipe(gulp.dest(conf.path.dist('/styles/')));
}
