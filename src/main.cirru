
= parser $ require :cirru-parser
= escodegen $ require :escodegen

= tree $ require :./tree

= req $ fetch :./example/demo.cirru

... req
  :then $ \ (response)
    response.text
  :then $ \ (body)
    = ast $ parser.pare body
    console.log :ast: ast
    = result $ tree.resolve (. ast 0)
    console.log :result: result
    console.log :code: $ escodegen.generate result