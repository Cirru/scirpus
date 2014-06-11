
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

  info.jsFile = path.join dest, jsFile
  info.mapFile = path.join dest, mapFile
  info.relativePath = path.relative dest, info.source

  info

exports.read = (opts) ->

  info = readInfo opts

  code = fs.readFileSync info.source, 'utf8'
  ast = parse code, info.source

  {ast, info}