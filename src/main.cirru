
var
  parser $ require :cirru-parser
  escodegen $ require :escodegen
  babel $ require :babel-core/browser
  operations $ require :./operations
  req $ new XMLHttpRequest
  source $ document.querySelector :#source
  compiled $ document.querySelector :#compiled

require :./layout.css

req.open :GET :./examples/lambda.cirru
= req.onload $ \ (res)
  var $ code req.responseText
  = source.value code
  tryRender code

req.send

var $ render $ \ (code)
  var
    ast $ parser.pare code
    result $ operations.transform ast
    display $ JSON.stringify result null 2
  console.log :ast: ast

  = compiled.value display
  console.log :result: display
  console.log ":generated code:"
  console.log $ . (babel.fromAst result null (object)) :code
  -- console.log $ escodegen.generate result

var $ tryRender $ \ (code)
  try
    do $ render code
    err
      var
        message err.message
        stack err.stack
      = compiled.value $ + message ":\n\n" stack

source.addEventListener :input $ \ (event)
  tryRender event.target.value

