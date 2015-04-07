
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
