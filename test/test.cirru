
-- "Test file, compares AST generate from Cirru to pre-generated AST files"

var
  fs $ require :fs
  path $ require :path
  assert $ require :assert
  parser $ require :cirru-parser
  jsondiffpatch $ require :jsondiffpatch
  equal $ require :fast-deep-equal
  chalk $ require :chalk
  sortJson $ require :sort-json

var diffpatcher $ jsondiffpatch.create $ {}
  :objectHash $ \ (obj) (JSON.stringify obj)

var operations $ require :../src/operations

var files $ require :./files-index

var s JSON.stringify
files.forEach $ \ (file)
  var
    cirruCode $ fs.readFileSync (path.join __dirname :cirru/ (+ file :.cirru)) :utf8
    ast $ require (+ :./ast/ (+ file :.json))
    cirruAST $ parser.pare cirruCode :
    jsAST $ operations.transform cirruAST
  if (equal ast jsAST)
    do
      console.log $ chalk.gray :OK file
    do
      console.log :failed: file
      var delta $ jsondiffpatch.diff ast jsAST
      console.log :delta: (JSON.stringify delta)
      fs.writeFileSync (path.join __dirname :tmp/result.json) (s (sortJson jsAST) null 2)
      fs.writeFileSync (path.join __dirname :tmp/expected.json) (s (sortJson ast) null 2)
      console.log $ chalk.red ":Failed test" file
      process.exit 1
  , undefined
