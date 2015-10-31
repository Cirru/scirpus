
var
  fs $ require :fs
  parser $ require :cirru-parser
  babel $ require :babel-core

  operations $ require :../src/operations

var
  files $ []
    , :array
    , :assignment
    , :binary
    , :chain
    , :comment
    , :compare
    , :cond
    , :destruction
    , :detect
    , :empty
    , :keyword
    , :lambda
    , :member
    , :object
    , :switch
    , :this
    , :try
    , :unary
    , :values

files.forEach $ \ (file)
  var
    cirruCode $ fs.readFileSync (+ :cirru/ file :.cirru) :utf8
    cirruAST $ parser.pare cirruCode file
    ast $ operations.transform cirruAST
    result $ babel.transformFromAst ast :
      {}
        :presets $ [] :es2015
  fs.writeFileSync (+ :generated/ file :.js) result.code
  console.log :done: file
