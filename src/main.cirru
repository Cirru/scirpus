
= parser $ require :cirru-parser
= escodegen $ require :escodegen
= babel $ require :babel/browser

= operations $ require :./operations

require :./layout.css

= req $ new XMLHttpRequest
req.open :GET :./examples/lambda.cirru
= req.onload $ \ (res)
  = code req.responseText
  = source.value code
  render code

req.send

= source $ document.querySelector :#source
= compiled $ document.querySelector :#compiled

= render $ \ (code)
  try
    do
      = ast $ parser.pare code
      console.log :ast: ast
      = result $ operations.transform ast
      = display $ JSON.stringify result null 2

      = compiled.value display
      console.log :result: display
      console.log ":generated code:"
      console.log $ babel.fromAst result null (object)
      -- "console.log $ escodegen.generate result"
    , err
    do
      = message err.message
      = stack err.stack
      = compiled.value $ + message ":\n\n" stack

source.addEventListener :input $ \ (event)
  render event.target.value

