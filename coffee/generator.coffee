
fs = require 'fs'
escodegen = require 'escodegen'

exports.write = (info, ast) ->
  opts =
    sourceMap: info.relativePath
    sourceMapRoot: info.base
    sourceMapWithCode: yes
  {code, map} = escodegen.generate ast, opts
  jsonMap = JSON.stringify map, null, 2
  code += "\n//# sourceMappingURL=./#{info.mapFile}"
  fs.writeFileSync info.jsPath, code
  fs.writeFileSync info.mapPath, jsonMap