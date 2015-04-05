
= exports.all $ \ list
  return list

= exports.prepend $ \ (a b)
  = c $ a.concat
  c.unshift b
  return c

= exports.append $ \ (a b)
  = c $ a.concat
  c.push b
  return c
