
tool = require './tool'
compiler = require './compiler'

xy = tool.findBound

exports.var = (expr, isExpr) ->
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
    init: compiler.extract value, yes
  ]

exports.number = (expr) ->
  head = expr[0]
  value = expr[1]

  loc: xy value
  type: 'Literal'
  value: Number value.text
  raw: value.text

exports.string = (expr) ->
  head = expr[0]
  value = expr[1]

  loc: xy value
  type: 'Literal'
  value: value.text
  raw: value.text

exports.set = (expr, isExpr) ->
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
    right: compiler.extract value, yes

exports.bool = (expr) ->
  head = expr[0]
  value = expr[1]

  loc: xy value
  type: 'Literal'
  value: value.text in ['yes', 'true']
  row: value.text

exports.literal = (expr) ->
  if expr.text is 'true'
    return \
      type: 'Literal'
      value: true
      raw: expr.text
  if expr.text is 'false'
    return \
      type: 'Literal'
      value: false
      raw: expr.text
  if expr.text.match /\d+(\.\d+)?/
    number = Number expr.text
    return \
      type: 'Literal'
      value: number
      raw: expr.text

exports['.'] = (expr) ->
  [object, property] = expr[1..]
  loc: xy expr
  type: 'MemberExpression'
  computed: no
  object: compiler.extract object, yes
  property: compiler.extract property, yes