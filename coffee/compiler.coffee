
b = require './builder'
reader = require './reader'
generator = require './generator'
tool = require './tool'
deeper = require './deeper'

local = {}

exports.compile = (opts) ->
  data = reader.read opts

  local = {}
  ast =
    type: 'Program'
    body: data.ast.map extract

  generator.write data.info, ast

extract = (expr) ->
  head = expr[0]
  func = s[head.text]
  if func?
    return func expr

  pattern = head.text.match /(\w+)(\.\w+)+/
  if pattern?
    deeper.member head
    console.log
  throw new Error "#{head.text} is not found"

xy = (expr) ->
  tool.findBound expr

s.var = (expr) ->
  head = expr[0]
  name = expr[1]
  value = expr[2]

  loc: xy expr
  type: 'VariableDeclaration'
  kind: 'var'
  declarations: [
    loc: xy head
    type: 'VariableDeclarator'
    id:
      loc: xy name
      type: 'Identifier'
      name: name.text
    init: extract value
  ]

s.number = (expr) ->
  head = expr[0]
  value = expr[1]

  loc: xy value
  type: 'Literal'
  value: Number value.text
  raw: value.text

s.string = (expr) ->
  head = expr[0]
  value = expr[1]

  loc: xy value
  type: 'Literal'
  value: value.text
  raw: value.text

s.set = (expr) ->
  head = expr[0]
  name = expr[1]
  value = expr[2]

  loc: xy expr
  type: 'ExpressionStatement'
  expression:
    loc: xy head
    type: 'AssignmentExpression'
    operator: '='
    left:
      loc: xy name
      type: 'Identifier'
      name: name.text
    right: extract value

s.bool = (expr) ->
  head = expr[0]
  value = expr[1]

  loc: xy value
  type: 'Literal'
  value: value.text in ['yes', 'true']
  row: value.text