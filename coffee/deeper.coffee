
exports.member = (token) ->
  expr = []
  y = token.y
  start = token.x
  end = token.end.x

  word =
    text: ''
    start: start
    end: start
  for char in token
    if char is '.'
      # TODO
    else
      # TODO

  expr