
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
  console.log stringify tree
  ast = scirpus.transform tree
  fs.writeFile "./test/ast.json", (stringify ast), ->
  res = escodegen.generate ast, opts
  tail = "\n//# sourceMappingURL=./demo.js.map"
  fs.writeFile "./compiled/demo.js", (res.code + tail), ->
  fs.writeFile "./compiled/demo.js.map", (stringify res.map), ->

wrap = ->
  try
    do main
    console.log "done"
  catch err
    console.log err
    console.log err.stack.replace(/\n/, "\n")
  

fs.watchFile source_file, interval: 200, wrap
do wrap