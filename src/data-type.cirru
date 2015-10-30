
var
  getType $ \ (x)
    var
      str $ Object.prototype.toString.call x
      longType $ str.substring 8 (- str.length 1)
    return $ longType.toLowerCase

= exports.getType getType

= exports.encode $ \ (value)
  case (getType value)
    :string
      + :: value
    else
      String value

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

  case text
    :true true
    :false false
    :undefined undefined
    :null null
    :Infinity Infinity
    else
      throw $ new Error $ + ":not a valid value: "
        JSON.stringify text
      , a
