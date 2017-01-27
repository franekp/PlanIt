'use strict';
var path = require('path');

var gulp = require('gulp')
var node_exec = require('child_process').exec
var plumber = require('gulp-plumber')
var elm = require('gulp-elm')
var gulp_replace = require('gulp-replace')
var sass = require('gulp-sass')
var sourcemaps = require('gulp-sourcemaps')
var postcss = require('gulp-postcss')
var autoprefixer = require('autoprefixer')
var notify = require("gulp-notify")

var minify_html = require("gulp-minify-html")
var minify_css = require("gulp-minify-css")
var uglify = require("gulp-uglify")

var supported_browsers = [
    "Android 2.3",
    "Android >= 4",
    "Chrome >= 20",
    "Firefox >= 24",
    "Explorer >= 9",
    "iOS >= 6",
    "Opera >= 12",
    "Safari >= 6"
]

var source = {
  elm: "elm/**/*.elm",
  elm_preprocessed: "elm_preprocessed",
  html: "index.html",
  sass: "sass/**/*.sass",
  normalize: "sass/**/*.css"
}
var dest = {
  js: "/build/js",
  html: "/build",
  css: "/build/css"
}

gulp.task('elm:preprocess-clean', function(cb) {
  node_exec(
    'mkdir -p elm_preprocessed && rm -rf elm_preprocessed && mkdir -p elm_preprocessed',
    function(err, stdout, stderr) {
      console.log(stdout)
      console.log(stderr)
      cb(err)
    }
  )
})

gulp.task('elm:preprocess', ['elm:preprocess-clean'], function() {
  // remove trailing commas and leading pipes
  // (all '|' preceded by any amount of whitespace and '=')
  return gulp.src(source.elm).pipe(
    // this weird comment below is because unmatched brackets in regexp
    // interfere with bracket matching functionality of some code editors
    gulp_replace(/* {[( */ /,(\s*)(\}|\]|\))/g, '$1$2')
  ).pipe(
    gulp_replace(/=(\s*)\|/g, '$1=')
  ).pipe(gulp.dest(source.elm_preprocessed))
})

gulp.task('elm:build', ['elm:preprocess'], function(cb) {
  node_exec(
    'elm make ' + source.elm_preprocessed + '/Main.elm --output ' + dest.js + '/main.js',
    function (err, stdout, stderr) {
      console.log(stdout)
      console.log(stderr)
      cb(err)
    }
  )
})

gulp.task('elm:watch', function() {
  return gulp.watch(source.elm, ['elm:build'])
})

gulp.task('js:minify', function() {
  return gulp.src(path.join(dest.js, "main.js"))
    .pipe(uglify())
    .pipe(gulp.dest(dest.js))
})

gulp.task('html:build', function() {
  // nothing happens, just copy the files
  return gulp.src(source.html)
    .pipe(gulp.dest(dest.html))
})

gulp.task('html:watch', function() {
  return gulp.watch(source.html, ['html:build'])
})

gulp.task('html:minify', function() {
  return gulp.src(path.join(dest.html, "index.html"))
    .pipe(minify_html())
    .pipe(gulp.dest(dest.html))
})

gulp.task('sass:copy-normalize-css', function () {
  return gulp.src(source.normalize)
    .pipe(gulp.dest(dest.css))
})

gulp.task('sass:build', ["sass:copy-normalize-css"], function() {
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
})

gulp.task('css:minify', function() {
  return gulp.src(path.join(dest.css, "style.css"))
    .pipe(minify_css())
    .pipe(gulp.dest(dest.css))
})

gulp.task('sass:watch', function() {
  return gulp.watch(source.sass, ['sass:build'])
})

gulp.task('build', ['elm:build', 'html:build', 'sass:build'])
gulp.task('watch', ['elm:watch', 'html:watch', 'sass:watch'])
gulp.task('minify', ['js:minify', 'css:minify', 'html:minify'])
