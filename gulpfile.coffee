'use-strict'

## DEFAULTS
gulp              = require('gulp')
del               = require('del')
plumber           = require('gulp-plumber')
notify            = require('gulp-notify')
rename            = require('gulp-rename')
gutil             = require('gulp-util')
connect           = require('gulp-connect')

## COFFEE & BOWER
coffee            = require('gulp-coffee')
concat            = require('gulp-concat')
jshint            = require('gulp-jshint')
uglify            = require('gulp-uglify')
bower             = require('bower')
mainBowerFiles    = require('main-bower-files');

## JADE
pug               = require('gulp-pug');
puginheritance    = require('gulp-pug-inheritance');
filter            = require('gulp-filter');
changed           = require('gulp-changed');
cached            = require('gulp-cached');
gulpif            = require('gulp-if');

## LESS
less              = require('gulp-less')
autoprefixer      = require('gulp-autoprefixer')
sourcemaps        = require('gulp-sourcemaps')
cleanCSS          = require('gulp-clean-css')



### SETTINGS ==================================================================
=========================================================================== ###

notifier =
  served: 'Served "<%= file.path %>"'
  copied: 'Copied "<%= file.path %>"'

root =
  src : './src/'
  dest: './dist'

settings =
  server:
    root: 'dist'
    livereload: true
    port: 8888

  path:
    src:
      coffee: root.src + 'coffee/**/*.coffee'
      pug:    root.src + 'jade/**/*.pug'
      less:   root.src + 'less/'
    dest:
      js:     root.dest + '/js'
      css:    root.dest + '/css'



### HELPER FUNCTIONS ==========================================================
=========================================================================== ###

copy = (src, dist) ->
  gulp.src src
  .pipe plumber (error) ->
    gutil.log error.message
    @emit 'end'
    return
  .pipe gulp.dest settings.path.dest.js
  .pipe notify {message: notifier.served }
  .pipe connect.reload()



### CLEAN TASK ================================================================
=========================================================================== ###

gulp.task 'app:clean', () ->
  del [
    root.dest + '/**/*.html',
    settings.path.dest.js + '/**/*.js',
    settings.path.dest.css + '/**/*.css',
  ]



### COFFEE SKRIPT TASK ========================================================
=========================================================================== ###

gulp.task 'app:coffee', () ->
  gulp.src settings.path.src.coffee
  .pipe plumber (error) ->
    gutil.log error.message
    @emit 'end'
    return
  .pipe coffee({bare: true}).on 'error', gutil.log
  .pipe jshint '.jshintrc'
  .pipe gulp.dest settings.path.dest.js
  .pipe notify {message: notifier.served }
  .pipe rename {suffix: '.min'}
  .pipe uglify()
  .pipe gulp.dest settings.path.dest.js
  .pipe notify {message: notifier.served }
  .pipe connect.reload()



### JADE TASK =================================================================
=========================================================================== ###

gulp.task 'jade', () ->
  gulp.src settings.path.src.pug
  .pipe plumber (error) ->
    gutil.log error.message
    @emit 'end'
    return
  .pipe changed 'dist', {extension: '.html'}
  .pipe gulpif global.isWatching, cached('jade')
  .pipe puginheritance {basedir: 'src/jade', extension: '.pug', skip:'node_modules'}
  .pipe filter (file) ->
    return !/\/_/.test(file.path) && !/^_/.test(file.relative)
  .pipe pug {pretty: true}
  .pipe gulp.dest root.dest
  .pipe notify {message: notifier.served }
  .pipe connect.reload()

gulp.task 'setWatch', () ->
  global.isWatching = true;
  return



### LESS TASK =================================================================
=========================================================================== ###

lessTask = (src, dist, minify, note) ->
  min = if minify then true else false
  gulp.src src
  .pipe plumber (error) ->
    gutil.log error.message
    @emit 'end'
    return
  .pipe sourcemaps.init()
  .pipe less()
  .pipe autoprefixer {
    browsers: [
      "Android 2.3",
      "Android 4",
      "Android >= 4",
      "Chrome >= 20",
      "ChromeAndroid >= 20",
      "Firefox >= 24",
      "Explorer >= 8",
      "iOS >= 6",
      "Opera >= 12",
      "Safari >= 6"
    ],
    cascade: true
  }
  .pipe gulpif min, rename({suffix: '.min'})
  .pipe gulpif min, cleanCSS({compatibility: 'ie8'})
  .pipe sourcemaps.write('./')
  .pipe gulp.dest(dist)
  .pipe notify({ message: note })
  .pipe connect.reload()

gulp.task 'app:less:normal', () ->
  lessTask settings.path.src.less + 'index.less', settings.path.dest.css, false, notifier.served
gulp.task 'app:less:minified', () ->
  lessTask settings.path.src.less + 'index.less', settings.path.dest.css, true, notifier.served
gulp.task 'app:less', ['app:less:normal', 'app:less:minified']



### WATCH AND SERVER TASKS =====================================================
=========================================================================== ###

gulp.task 'app:server', () ->
  connect.server settings.server
  return

gulp.task 'app:watch', ['app:server', 'setWatch', 'jade'], () ->
  gulp.watch settings.path.src.coffee, ['app:coffee']
  gulp.watch settings.path.src.pug, ['jade']
  gulp.watch settings.path.src.less + '**/*.less', ['app:less']
  return



### BUILD TASKS ===============================================================
=========================================================================== ###

gulp.task 'build', ['app:coffee', 'jade', 'app:less']



### BOWER TASKS ===============================================================
=========================================================================== ###

gulp.task 'bower:get', (cb) ->
  bower.commands.install [], {save: true}, {}
  .on 'end', (installed) ->
    cb()
    return
  return

gulp.task 'bower:javascript', () ->
  gulp.src mainBowerFiles '**/*.js'
  .pipe plumber (error) ->
    gutil.log error.message
    @emit 'end'
    return
  .pipe jshint '.jshintrc'
  .pipe concat 'libs.js'
  .pipe gulp.dest settings.path.dest.js
  .pipe notify {message: notifier.served }
  .pipe rename {suffix: '.min'}
  .pipe uglify()
  .pipe gulp.dest settings.path.dest.js
  .pipe notify {message: notifier.served }

gulp.task 'bower', ['bower:get'], () ->
  gulp.start 'bower:javascript'
