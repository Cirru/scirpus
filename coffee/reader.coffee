
path = require 'path'
fs = require 'fs'
{parse} = require 'cirru-parser'

readInfo = (opts) ->

  info = {}

  if opts.base?
    info.base = opts.base
    info.source = path.join opts.base, opts.from
    dest = path.join opts.base, opts.to
  else
    info.base = process.env.PWD
    info.source = opts.from
    dest = opts.to

  filename = path.basename info.source
  sourceDir = path.dirname info.source
  jsFile = filename.replace '.cirru', '.js'
  mapFile = filename.replace '.cirru', '.js.map'

  info.mapFile = mapFile
  info.jsPath = path.join dest, jsFile
  info.mapPath = path.join dest, mapFile
  info.relativePath = path.relative dest, info.source

  info

hideFile = (ast) ->
  if ast instanceof Array
    ast.map hideFile
  else
    delete ast.file
    ast

exports.read = (opts) ->

  info = readInfo opts

  code = fs.readFileSync info.source, 'utf8'
  ast = parse code, info.source

  ast = hideFile ast

  {ast, info}