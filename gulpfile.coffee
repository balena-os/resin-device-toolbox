gulp = require('gulp')
gutil = require('gulp-util')
coffee = require('gulp-coffee')

OPTIONS =
	files:
		coffee: [ 'lib/**/*.coffee', 'tests/**/*.coffee', 'gulpfile.coffee' ]
		app: 'lib/**/*.coffee'
		tests: 'tests/**/*.coffee'

gulp.task 'coffee', ->
	gulp.src(OPTIONS.files.app)
		.pipe(coffee(bare: true)).on('error', gutil.log)
		.pipe(gulp.dest('build/'))

gulp.task 'build', [ 'coffee' ]
