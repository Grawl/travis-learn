'use strict'
// global
const gulp = require('gulp')
const browserify = require('browserify')
const $ = require('gulp-load-plugins')()
// local
const path = {
    scriptsToCompile: [
        './*.js',
		'!./*.min.js',
        '!./gulpfile.js'
    ],
	dest: './'
}
// public tasks
gulp.task('default', ['scripts'])
gulp.task('scripts', ()=> {
	// some strange code because of gulp team think there is not necessary to have a plugin to just `.pipe(browserify())`, you have to build bicycles instead: https://github.com/gulpjs/plugins/issues/47
	return gulp.src(path.scriptsToCompile, {read: false})
		.pipe(
			// transform file objects
			$.tap(file=> {
				$.util.log('bundling ' + file.path)
				// replace file contents with Browserify bundle stream
				file.contents = browserify(
					file.path,
					// Babel is plugged in package.json
					{
						debug: true
					}
					).bundle()
			})
		)
		// transform streaming contents into buffer contents (because gulp-sourcemaps does not support streaming contents)
		.pipe($.buffer())
		// non-bycicle gulp pipeline starts here
		.pipe($.rename({
			suffix: '.min'
		}))
		.pipe($.sourcemaps.init({loadMaps: true}))
		.pipe($.sourcemaps.write('./'))
		.pipe(gulp.dest(path.dest))
})
