
= getType $ \ (x)
  = str $ Object.prototype.toString.call x
  = longType $ str.substring 8 (- str.length 1)
  longType.toLowerCase

= exports.getType getType

= exports.encode $ \ (value)
  switch (getType value)
    :string $ ++: :: value
    else $ String value

= exports.decode $ \ (text)
  if (text.match /^:)
    do $ return $ text.substr 1

  if (text.match /^[-\d]+)
    do $ return $ Number text

  switch text
    :true true
    :false false
    :undefined undefined
    :null null
    :Infinity Infinity
    else
      console.log ":Run into" text
      throw $ new Error ":can not decode as value"
      return a
