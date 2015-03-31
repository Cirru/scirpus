
= parser $ require :cirru-parser
= escodegen $ require :escodegen

= tree $ require :./tree

= req $ new XMLHttpRequest
req.open :GET :./example/assign.cirru
req.send
= req.onload $ \ (res)
  = ast $ parser.pare req.responseText
  console.log :ast: ast
  = result $ tree.resolve (. ast 0)
  console.log :result: $ JSON.stringify result null 2
  console.log :code: $ escodegen.generate result
