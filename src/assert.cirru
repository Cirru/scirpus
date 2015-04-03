
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

= exports.oneOf $ \ (x xs comment)
  if
    not $ in xs x
    do
      console.log comment xs x
      throw $ new Error ":did not match oneOf"
      return

= exports.result $ \ (x comment)
  if (not x) $ do
    console.log comment x
    throw $ new Error ":result if not true"
    return
