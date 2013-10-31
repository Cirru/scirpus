
fs = require "fs"
cirru = require "cirru-parser"
scirpus = require "../coffee/scirpus"
escodegen = require "escodegen"

source_file = "./cirru/demo.cr"

stringify = (x) ->
  JSON.stringify x, null, 2

opts =
  sourceMap: "../cirru/demo.cr"
  sourceMapRoot: "./"
  sourceMapWithCode: yes

main = ->
  source = fs.readFileSync source_file, "utf8"
  tree = cirru.parse source
  ast = scirpus.transform tree
  console.log "@@@@ AST @@@@"
  console.log (stringify ast)
  fs.writeFile "./test/ast.json", (stringify ast), ->
  res = escodegen.generate ast, opts
  tail = "\n//# sourceMappingURL=./demo.js.map"
  fs.writeFile "./compiled/demo.js", (res.code + tail), ->
  fs.writeFile "./compiled/demo.js.map", (stringify res.map), ->

fs.watchFile source_file, interval: 200, main

do main