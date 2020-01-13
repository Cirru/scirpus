
-- "File to try generating code from Cirru files"

var
  fs $ require :fs
  parser $ require :cirru-parser
  generator $ require :@babel/generator
  es2015 $ require :babel-preset-es2015

  operations $ require :../src/operations

var files $ require :./files-index

files.forEach $ \ (file)
  var
    cirruCode $ fs.readFileSync (+ :cirru/ file :.cirru) :utf8
    cirruAST $ parser.pare cirruCode file
    ast $ operations.transform cirruAST
    result $ generator.default ast ({} (:presets $ [])) :
  fs.writeFileSync (+ :generated/ file :.js) result.code
  console.log :done: file
