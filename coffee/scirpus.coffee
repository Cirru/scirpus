
# base on Mozilla Parsing API
# https://developer.mozilla.org/en-US/docs/SpiderMonkey/Parser_API

tell = require "./tell"

t = require("./tool")

# export function

transform = (tree) ->
  type: "Program"
  body: tree.map tell.statement

exports.transform = transform
