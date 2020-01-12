
var
  parser $ require :cirru-parser
  generator $ require :@babel/generator
  operations $ require :./operations
  req $ new XMLHttpRequest
  source $ document.querySelector :#source
  compiled $ document.querySelector :#compiled

require :./layout.css

req.open :GET :./test/cirru/cond.cirru
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
  console.log $ . (generator.default result ({}) code) :code

var $ tryRender $ \ (code)
  try
    do $ render code
    err
      var
        message err.message
        stack err.stack
      = compiled.value $ + message ":\n\n" stack
  , undefined

source.addEventListener :input $ \ (event)
  tryRender event.target.value
