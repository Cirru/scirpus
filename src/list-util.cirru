
= exports.prepend $ \ (a b)
  var
    c $ a.concat
  c.unshift b
  return c

= exports.append $ \ (a b)
  var
    c $ a.concat
  c.push b
  return c

var foldPair $ \ (list result)
  cond (> list.length 0)
    foldPair (list.slice 2)
      result.concat $ [] $ [] (. list 0) (. list 1)
    , result

= exports.foldPair $ \ (list)
  if (isnt 0 (% list.length 2)) $ do
    throw ":object entried not paired"
  foldPair list ([])
