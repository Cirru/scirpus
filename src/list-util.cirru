
= exports.all $ \ list
  return list

= exports.prepend $ \ (a b)
  = c $ a.concat
  c.unshift b
  return c
