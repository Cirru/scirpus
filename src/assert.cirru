
= _ $ require :lodash

= exports.string $ \ (x comment)
  if
    not $ _.isString x
    do
      console.log comment x
      throw $ new Error ":suppose to be string"
      return

= exports.array $ \ (x comment)
  if
    not $ _.isArray x
    do
      console.log comment x
      throw $ new Error ":suppose to be array"
      return

= exports.func $ \ (x comment)
  if
    not $ _.isFunction x
    do
      console.log comment x
      throw $ new Error ":suppose to be function"
      return

