
t = require("./tool")

expand = exports

exports.literal = (x) ->
  guess = Number x.text
  if t.number guess
    type: "Literal"
    value: guess
    raw: x.text
    loc: (t.copy_loc x)
  else
    type: "Literal"
    raw: x.text
    loc: (t.copy_loc x)

exports.identifier = (word) ->
  type: "Identifier"
  name: word.text
  loc: (t.copy_loc word)

exports.assignment_expression = (left, operator, right) ->
  type: "AssignmentExpression"
  operator: operator
  left: left
  right: right

exports.call_expression = (callee, args) ->
  type: "CallExpression"
  callee: callee
  arguments: args

exports.member_expression = (object, property) ->
  type: "MemberExpression"
  object: object
  property: property
  computed: no

exports.variable_declaration = (decs, kind) ->
  type: "VariableDeclaration"
  declarations: decs.map (pair) ->
    expand.variable_declrator pair[0], pair[1]
  kind: kind

exports.variable_declrator = (pattern, init) ->
  type: "VariableDeclarator"
  id: pattern
  init: init or null

exports.empty_statement = ->
  type: "EmptyStatement"
