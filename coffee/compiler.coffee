
b = require './builder'
reader = require './reader'

exports.compile = (opts) ->
  data = reader.read opts

  console.log data