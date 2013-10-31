
tool = exports

exports.type = (x) ->
  raw = Object::toString.call x
  raw[8...-1].toLowerCase()

exports.number = (x) ->
  x >= 0 or x < 0

exports.string = (x) ->
  (tool.type x) is "string"

exports.stringify = (x) ->
  JSON.stringify x

exports.copy_loc = (word) ->
  if word.start? and word.end?
    start:
      line: word.start.y + 1
      column: word.start.x
    end:
      line: word.end.y + 1
      column: word.end.x
  else
    null

exports.token = (x) ->
  ((tool.type x) is "object") and (tool.string x.text)

exports.exp = (x) ->
  (tool.type x) is "array"

exports.error = (msg) ->
  throw new Error msg
