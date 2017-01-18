'use strict';

/*(function() {
    var childProcess = require("child_process");
    var oldSpawn = childProcess.spawn;
    function mySpawn() {
        console.log('spawn called');
        console.log(arguments);
        var result = oldSpawn.apply(this, arguments);
        return result;
    }
    childProcess.spawn = mySpawn;
})();*/

var gulp = require('gulp');
var exec = require('child_process').exec;
var plumber = require('gulp-plumber');
var elm = require('gulp-elm');
var sass = require('gulp-sass');
var sourcemaps = require('gulp-sourcemaps');
var postcss = require('gulp-postcss');
var autoprefixer = require('autoprefixer');
var notify = require("gulp-notify");
var supported_browsers = [
    "Android 2.3",
    "Android >= 4",
    "Chrome >= 20",
    "Firefox >= 24",
    "Explorer >= 9",
    "iOS >= 6",
    "Opera >= 12",
    "Safari >= 6"
];

var source = {
  elm: "elm/**/*.elm",
  html: "html/**/*.html",
  sass: "sass/**/*.sass"
}
var dest = {
  js: "/build/js",
  html: "/build/html",
  css: "/build/css"
}

gulp.task('elm:init', elm.init);

gulp.task('elm:build', ['elm:init'], function(cb) {
  exec('elm make elm/Main.elm --output /build/js/main.js', function (err, stdout, stderr) {
      console.log(stdout);
      console.log(stderr);
      cb(err);
    });
});

gulp.task('elm:watch', function() {
  gulp.watch(source.elm, ['elm:build'])
})

gulp.task('html:build', function() {
  // nothing happens, just copy the files
  gulp.src(source.html)
  .pipe(gulp.dest(dest.html));
})

gulp.task('html:watch', function() {
  gulp.watch(source.html, ['html:build'])
})

gulp.task('sass:build', function() {
  return gulp.src(source.sass).pipe(plumber())
    .pipe(sourcemaps.init())
    .pipe(sass({
      includePaths: ["./node_modules"]
    }))
    .on('error', notify.onError(function(error) {
      return {
          title: "Sass error",
          message: error
      }
    }))
    .pipe(postcss([autoprefixer({browsers: supported_browsers})]))
    .pipe(sourcemaps.write())
    .pipe(gulp.dest(dest.css))
});

gulp.task('sass:watch', function() {
    gulp.watch(source.sass, ['sass:build'])
});

gulp.task('build', ['elm:build', 'html:build', 'sass:build'])
gulp.task('watch', ['elm:watch', 'html:watch', 'sass:watch'])
