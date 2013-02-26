
{build} = require './build'
{parse} = require './parse'
{wrap} = require 'cirru-parser'

fs = require 'fs'
source_file = '../source/source.sp'

fill = (item) -> not (item.trim() in [';', ''])

compile = (file) ->
  text = wrap file
  console.log text
  array = parse text
  # console.log array
  code = build array

path = require 'path'
filename = path.join process.env.PWD, process.argv[2]
unless (path.extname filename) is '.sp'
  throw new Error 'not .sp file'
else
  do redo = ->
    file = fs.readFileSync filename, 'utf8'
    target = filename.replace(/\.sp/, ".js")
    fs.writeFileSync target, (compile file)
  fs.watchFile filename, interval: 100, redo