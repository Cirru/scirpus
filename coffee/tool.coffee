
exports.findBound = findBound = (expr) ->
  sx = undefined
  sy = undefined
  ex = undefined
  ey = undefined
  empty = yes

  compare = (item) ->
    if empty
      sx = item.x
      sy = item.y
      ex = item.end.x
      ey = item.end.y
      empty = no
    else
      if item.x < sx and item.y < sy
        sx = item.x
        sy = item.y
      if item.end.x > ex and item.end.y > ey
        ex = item.end.x
        ey = item.end.y

  if expr instanceof Array
    for child in expr
      res = findBound child
      compare res
  else
    compare expr

  if empty
    console.log expr
    throw new Error 'cant be empty'

  start:
    column: sx
    line: sy + 1
  end:
    column: ex
    line: ey + 1