
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
  console.log "@@@@ ast:", (stringify ast)
  res = escodegen.generate ast, opts
  console.log "@@@@ generated", (stringify res)
  head = "\n//# sourceMappingURL=data:application/json;base64,"
  buffer = new Buffer (JSON.stringify res.map)
  base64_code = buffer.toString "base64"
  file = res.code + head + base64_code
  console.log file
  fs.writeFile "./compiled/demo.js", file, "utf8", ->

fs.watchFile source_file, interval: 200, main

do main