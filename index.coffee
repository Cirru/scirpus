
colors = require 'colors'
esprima = require 'esprima'
escodegen = require 'escodegen'
# {inspect} = require 'util'

global.put = (x...) ->
  console.log  'debug:'.red
  console.log.call console, x
global.show = console.log

to_aray = (require './src/to_aray').to_aray
to_tree = (require './src/to_tree').to_tree
to_code = (require './src/to_code').to_code
to_html = (require './util/to_html').to_html
wrap = (require 'guil').convert

fs = require 'fs'
source_file = 'source/source.sp'

compile = ->
  a = 'compile...'.red
  # show a, b
  file = fs.readFileSync source_file, 'utf8'
  array = to_aray (wrap file)
  show '%%%%%%%%%%%%'.yellow
  show '%%%%%%%%%%%% aray'.red
  show array
  to_html array, 'html/aray.html'
  code = to_code (to_tree array)
  show '%%%%%%%%%%%% code:'.red
  show code
  ret = escodegen.generate (esprima.parse code)
  show '%%%%%%%%%%%% ret:'.red
  show ret
  ret

op = interval: 300
do compile
fs.watchFile source_file, op, ->
  do compile