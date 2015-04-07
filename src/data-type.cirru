
var
  getType $ \ (x)
    var
      str $ Object.prototype.toString.call x
      longType $ str.substring 8 (- str.length 1)
    return $ longType.toLowerCase

= exports.getType getType

= exports.encode $ \ (value)
  switch (getType value)
    :string
      return $ + :: value
    else
      return $ String value

= exports.decode $ \ (text)
  if (text.match /^:)
    do $ return $ text.substr 1

  if (text.match /^[-\d]+)
    do $ return $ Number text

  if (text.match /^\/)
    do
      var
        content $ text.substr 1
      = content $ content.replace /\/ :\/
      return $ new RegExp (text.substr 1)

  switch text
    :true $ return true
    :false $ return false
    :undefined $ return undefined
    :null $ return null
    :Infinity $ return Infinity
    else
      console.log ":Run into" text
      throw $ new Error ":can not decode as value"
      return a
