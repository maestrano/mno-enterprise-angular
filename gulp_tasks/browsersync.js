const gulp = require('gulp');
const browserSync = require('browser-sync');
const spa = require('browser-sync-spa');

const browserSyncConf = require('../conf/browsersync.conf');
const browserSyncDistConf = require('../conf/browsersync-dist.conf');

const proxyMiddleware = require('http-proxy-middleware');

browserSync.use(spa());

gulp.task('browsersync', browserSyncServe);
gulp.task('browsersync:dist', browserSyncDist);

// Rewrite url after the proxy
var dashboardRewriteMiddleware = function (req, res, next) {
  // Remove the optional locale (en, en-GB) part
  req.url = req.url.replace(/^\/[A-Za-z]{2}(-[A-Z]{2})?\//, "/");

  // Rewrite /dashboard/xxx => /xxx
  req.url = req.url.replace(/^\/dashboard\//, "/");
  next();
};

const middleware = [
  proxyMiddleware(
    '!/?([A-Za-z][A-Za-z]?(-[A-Za-z][A-Za-z])/)(dashboard|bower_components)/**',
    {target: 'http://localhost:7000'}
  ),
  dashboardRewriteMiddleware
];

function browserSyncServe(done) {
  var conf = browserSyncConf();
  conf.server.middleware = middleware;

  browserSync.init(conf);
  done();
}

function browserSyncDist(done) {
  var conf = browserSyncDistConf();
  conf.server.middleware = middleware;

  browserSync.init(conf);
  done();
}
