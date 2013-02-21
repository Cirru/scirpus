
{build} = require './build'
{parse} = require './parse'
{convert} = require 'she'

fs = require 'fs'
source_file = '../source/source.sp'

fill = (item) -> not (item.trim() in [';', ''])

compile = (file) ->
  array = parse (convert file)
  # console.log array
  code = build array

path = require 'path'
filename = path.join process.env.PWD, process.argv[2]
unless (path.extname filename) is '.sp'
  throw new Error 'not .sp file'
else
  do redo = ->
    file = fs.readFileSync filename, 'utf8'
    console.log (compile file)
  # fs.watchFile filename, interval: 100, redo