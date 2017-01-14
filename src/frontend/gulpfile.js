'use strict';

var gulp = require('gulp');
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

var sass_paths = "sass/**/*.sass"

gulp.task('sass:build', function() {
  return gulp.src(sass_paths)
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
    .pipe(gulp.dest("/build/css"));
});

gulp.task('sass:watch', function() {
    gulp.watch(sass_paths, ['sass:build']);
});

gulp.task('build', ['sass:build']);
gulp.task('watch', ['sass:watch'])
