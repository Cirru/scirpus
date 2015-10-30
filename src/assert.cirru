
var
  _ $ require :lodash

var fmt $ \ (x)
  return $ JSON.stringify x

= exports.string $ \ (x comment)
  if
    not $ _.isString x
    do
      throw $ new Error $ + ":expects string but got " (fmt x) ": at " comment
      return
  , undefined

= exports.array $ \ (x comment)
  if
    not $ _.isArray x
    do
      throw $ new Error $ + ":expects array but got " (fmt x) ": at " comment
      return
  , undefined

= exports.func $ \ (x comment)
  if
    not $ _.isFunction x
    do
      throw $ new Error $ + ":expects function but got " (fmt x) ": at " comment
      return
  , undefined

= exports.oneOf $ \ (x xs comment)
  if
    not $ in xs x
    do
      throw $ new Error $ + (fmt x) ": is not oneOf " (fmt xs) ": at " comment
      return
  , undefined

= exports.result $ \ (x comment)
  if (not x) $ do
    throw $ new Error $ + ":expects true but got " (fmt x) ": at " comment
    return
  , undefined

= exports.defined $ \ (x comment)
  if (not (? x)) $ do
    throw $ new Error $ + ":value not defined at " comment
    return
  , undefined
