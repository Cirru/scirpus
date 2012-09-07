
esprima = require 'esprima'
escodegen = require 'escodegen'

global.show = console.log

to_aray = (require './src/to_aray').to_aray
to_tree = (require './src/to_tree').to_tree
to_code = (require './src/to_code').to_code
to_html = (require './util/to_html').to_html
wrap = (require 'guil').convert

fs = require 'fs'
source_file = 'source/source.sp'

fill = (item) -> not (item.trim() in [';', ''])

convert = (file) ->
  array = to_aray (wrap file)
  to_html array, 'html/aray.html'
  code = (to_code (to_tree array))
  ret = escodegen.generate (esprima.parse code),
    format: indent: {style: '  ',base: 0}
  ret.split('\n').filter(fill).join('\n')

path = require 'path'
filename = path.join process.env.PWD, process.argv[2]
unless (path.extname filename) is '.sp'
  throw new Error 'not .sp file'
else
  file = fs.readFileSync filename, 'utf8'
  ret = convert file
  target = filename[...-3] + '.js'
  fs.writeFileSync target, ret, 'utf8'