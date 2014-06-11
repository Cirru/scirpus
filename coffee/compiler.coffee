
b = require './builder'
reader = require './reader'
generator = require './generator'
s = {}

local = {}

exports.compile = (opts) ->
  data = reader.read opts

  ast =
    type: 'Program'
    body: data.ast.map extract

  generator.write data.info, ast

extract = (expr) ->
  head = expr[0].text
  func = s[head]
  if func? then func expr
  else throw new Error "#{head} is not found"

xy = (start, end) ->
  if start? and end?
    start:
      column: start.x
      line: start.y + 1
    end:
      column: end.x
      line: end.y + 1
  else null

s.var = (expr) ->
  head = expr[0]
  name = expr[1]
  value = expr[2]

  loc: xy head, name.end
  type: 'VariableDeclaration'
  kind: 'var'
  declarations: [
    loc: xy head, head.end
    type: 'VariableDeclarator'
    id:
      loc: xy name, name.end
      type: 'Identifier'
      name: name.text
    init: extract value
  ]

s.number = (expr) ->
  head = expr[0]
  value = expr[1]

  loc: xy value, value.end
  type: 'Literal'
  value: Number value.text
  raw: value.text

s.string = (expr) ->
  head = expr[0]
  value = expr[1]

  loc: xy value, value.end
  type: 'Literal'
  value: value.text
  raw: value.text

s.set = (expr) ->
  head = expr[0]
  name = expr[1]
  value = expr[2]

  loc: xy head, name.end
  type: 'ExpressionStatement'
  expression:
    loc: xy head, head.end
    type: 'AssignmentExpression'
    operator: '='
    left:
      loc: xy name, name.end
      type: 'Identifier'
      name: name.text
    right: extract value

s.bool = (expr) ->
  head = expr[0]
  value = expr[1]

  loc: xy value, value.end
  type: 'Literal'
  value: value.text in ['yes', 'true']
  row: value.text