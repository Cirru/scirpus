
= parser $ require :cirru-parser
= escodegen $ require :escodegen

= operations $ require :./operations

= req $ new XMLHttpRequest
req.open :GET :./example/binary.cirru
req.send
= req.onload $ \ (res)
  = ast $ parser.pare req.responseText
  console.log :ast: ast
  = result $ operations.transform ast
  console.log :result: $ JSON.stringify result null 2
  console.log ":generated code:"
  console.log $ escodegen.generate result
