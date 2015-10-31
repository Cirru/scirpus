
var
  fs $ require :fs
  assert $ require :assert
  parser $ require :cirru-parser
  Immutable $ require :immutable
  jsondiffpatch $ require :jsondiffpatch

var diffpatcher $ jsondiffpatch.create $ {}
  :objectHash $ \ (obj) (JSON.stringify obj)

var operations $ require :../src/operations

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

var files $ []
  , :array
  , :assignment
  , :binary
  , :chain
  , :comment
  , :compare
  , :cond
  , :detect
  , :empty
  , :keyword
  , :member
  , :object
  , :this
  , :try
  , :unary
  , :values
  , :switch
  , :lambda
  , :destruction

var s JSON.stringify
files.forEach $ \ (file)
  var
    cirruCode $ fs.readFileSync (+ :cirru/ file :.cirru) :utf8
    ast $ require (+ :./ast/ file :.json)
    cirruAST $ parser.pare cirruCode :
    jsAST $ operations.transform cirruAST
    delta $ jsondiffpatch.diff ast jsAST
  if (is delta undefined)
    do
      console.log :test :ok: file
    do
      console.log :failed: file
      fs.writeFileSync :tmp/result.json (s jsAST null 2)
      fs.writeFileSync :tmp/expected.json (s ast null 2)
  , undefined
