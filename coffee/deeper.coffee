
exports.member = (token) ->
  expr = undefined
  y = token.y
  start = token.x
  end = token.end.x

  withy = (x) ->
    x: x
    y: y

  word =
    text: ''
    start: withy start
    end: withy start

  for char in token.text
    if char is '.'
      if expr?
        expr.push word
      else
        expr = word
      dotWord =
        text: '.'
        start: withy start
        end: withy (start + 1)
      start += 1
      expr = [dotWord, expr]
      word =
        text: ''
        start: withy start
        end: withy start
    else
      word.text += char
      word.end.x += 1
      start += 1


  expr.push word

  expr