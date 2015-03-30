
= gulp $ require :gulp

= config $ require :./webpack.config

gulp.task :html $ \ ()
  = html $ require :gulp-cirru-html
  = assets $ require :./assets

  = data $ object
    :main $ ++: config.output.publicPath assets.main

  ... gulp
    :src :./index.cirru
    :pipe $ html $ object (:data data)
    :pipe $ gulp.dest :./

gulp.task :script $ \ ()
  = script $ require :gulp-cirru-script
  = rename $ require :gulp-rename

  ... gulp
    :src :src/*.cirru
    :pipe $ script $ object (:dest :../lib)
    :pipe $ rename $ object (:extname :.js)
    :pipe $ gulp.dest :lib
