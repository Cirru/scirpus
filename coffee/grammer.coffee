
expand = require "./expand"
tell = require "./tell"

t = require("./tool")

exports.grammer = (name) ->

  return undefined unless t.string name

  if name is ">" then (args...) ->
    console.log "todo: >"

  else if name is "if" then (args...) ->
    console.log "todo: if"

  else if name is "//" then ->
    expand.empty_statement()

  else if name is ":" then (args) ->
    left = expand.identifier args[0]
    right = tell.guess args[1]
    expand.assignment_expression left, "=", right

  else if name is "." then (args) ->
    object = expand.identifier args[0]
    property = expand.identifier args[1]
    expand.member_expression object, property

  else if name is "var" then (args) ->
    kind = "var"
    decs = args[1..].map (pair) ->
      pair.map tell.guess
    expand.variable_declaration decs, kind

  else if name in BinaryOperator then (args) ->
    type: "BinaryExpression"
    operator: name
    left: tell.guess args[0]
    right: tell.guess args[1]

  else
    console.log "not ready"

BinaryOperator = [
  "==", "!=", "===", "!=="
  "<", "<=", ">", ">="
  "<<", ">>", ">>>"
  "+", "-", "*", "/", "%"
  "|", "^", "&", "in"
  "instanceof", ".."
]