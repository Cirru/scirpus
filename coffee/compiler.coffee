
builder = require './builder'
reader = require './reader'
generator = require './generator'
deeper = require './deeper'
tool = require './tool'

xy = tool.findBound

local = {}

exports.compile = (opts) ->
  data = reader.read opts

  local = {}
  ast =
    type: 'Program'
    body: data.ast.map (expr) ->
      extract expr, no # not expression

  generator.write data.info, ast

exports.extract = extract = (expr, isExpr) ->
  # console.log 'extracting', expr, isExpr
  # it could be token
  unless expr instanceof Array
    if expr.text.match /^[\d#]$/
      return builderLiteral expr
    else
      return buildIdentifier expr

  # then it is a array
  [head, body...] = expr

  func = builder[head.text]

  if func?
    return func expr, isExpr

  pattern = head.text.match /^\w+$/
  if pattern?
    if isExpr
      return extract expr, yes
    else
      return buildExpressStatement expr

  pattern = head.text.match /^\w+(\.\w+)+$/
  if pattern?
    transformed = deeper.member head
    if isExpr
      return buildCall [transformed, body...]
    else
      return buildCallStatement [transformed, body...]

  throw new Error "#{head.text} is not found"

buildIdentifier = (expr) ->
  loc: xy expr
  type: 'Identifier'
  name: expr.text

builderLiteral = (expr) ->
  if expr.text is '#t'
    value = true
  else if expr.text is '#f'
    value = false
  else if expr.text.match /\d+(\.\d+)?/
    value = Number expr.text
  loc: xy expr
  type: 'Literal'
  value: value
  raw: expr.text

buildCall = (expr) ->
  [head, body...] = expr
  loc: xy expr
  type: 'CallExpression'
  callee: extract head
  arguments: body.map (child) ->
    extract child, yes

buildCallStatement = (expr) ->
  [head, body...] = expr
  loc: xy expr
  type: 'ExpressionStatement'
  expression:
    loc: xy expr
    type: 'CallExpression'
    callee: extract head, yes
    arguments: body.map (child) ->
      extract child, yes

buildExpressStatement = (expr) ->
  loc: xy expr
  type: 'ExpressionStatement'
  expression: extract expr, yes