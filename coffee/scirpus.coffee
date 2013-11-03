
# base on Mozilla Parsing API
# https://developer.mozilla.org/en-US/docs/SpiderMonkey/Parser_API

exports.transform = (code) ->
  new Program code

# tools

isString = (x) ->
  (typeof x) is "string"

isToken = (code) ->
  hasText = isString code.text
  hasLine = hasLineInfo code
  hasText and hasLine

isExpression = (code) ->
  not (isToken code)

hasLineInfo = (code) ->
  hasStart = code.start? and code.start.x?
  hasEnd = code.end? and code.end.x?
  hasStart and hasEnd

# Grammers for Cirru

registry = {}

translate = (code) ->
  name = code[0].text
  if name? and registry[name]?
    constructor = registry[name]
    new constructor code
  else
    null

# Node objects

class $Node
  type: "Node"
  loc: null

  copyLoc: (code) ->
    if isToken code
      @loc = new SourceLocation code

class SourceLocation
  constructor: (code) ->
    @source = code.text
    @start = new Position code.start
    @end = new Position code.end

class Position
  constructor: (pos) ->
    @line = pos.y + 1
    @column = pos.x

# Programs

class Program extends $Node
  constructor: (code) ->
    @type = "Program"
    @body = code.map (x) ->
      translate x # Statement

# Functions

registry.function = class $Function extends $Node
  constructor: (code) ->
    @defaults = [] # not sure what it is
    @rest = null
    @generator = no
    @expression = no
    @id = translate code[1] # Identifier
    @params = code[2].map (x) ->
      translate x # Pattern
    @body = code[3].map (x) ->
      translate x # Expression


# Statements

class Statement extends $Node

registry.empty = class EmptyStatement extends Statement
  constructor: (code) ->
    @type = "EmptyStatement"

registry.block = class BlockStatement extends Statement
  constructor: (code) ->
    @type = "BlockStatement"
    @body = code.map (x) ->
      translate x # Statement

registry.expression = class ExpressionStatement extends Statement
  constructor: (code) ->
    @type = "ExpressionStatement"
    @expression = translate code[1] # Expression

registry.if = class IfStatement extends Statement
  constructor: (code) ->
    @type = "IfStatement"
    @test = translate code[1] # Expression
    @consequent = translate code[2] # Statement
    @alternate = translate code[3] # Statement

registry.label = class LabeledStatement extends Statement
  constructor: (code) ->
    @type = "LabeledStatement"
    @label = translate code[1] # Identifier
    @body = translate code[2] # Statement

registry.break = class BreakStatement extends Statement
  constructor: (code) ->
    @type = "BreakStatement"
    @label = translate code[1] # Identifier

registry.continute = class ContinuteStatement extends Statement
  constructor: (code) ->
    @type = "ContinuteStatement"
    @label = translate code[1] # Identifier

registry.with = class WithStatement extends Statement
  constructor: (code) ->
    @type = "WithStatement"
    @object = translate code[1] # Expression
    @body = translate code[2] # Statement

registry.switch = class SwitchStatement extends Statement
  constructor: (code) ->
    @type = "SwitchStatement"
    @lexical = yes
    @discriminant = translate code[1] # Expression
    @cases = code[2].map (x) ->
      translate x # SwitchCase

registry.return = class ReturnStatement extends Statement
  constructor: (code) ->
    @type = "ReturnStatement"
    @argument = translate code[1] # Expression

registry.throw = class ThrowStatement extends Statement
  constructor: (code) ->
    @type = "ThrowStatement"
    @argument = translate code[1] # Expression

registry.try = class TryStatement extends Statement
  constructor: (code) ->
    @type = "TryStatement"


# ...

# Declarations

# Expressions

class Expression extends $Node

# Patterns

# Clauses

# Miscellaneous

registry.identifier = class Identifier extends Expression
  constructor: (code) ->
    @type = "Identifier"
    @copyLoc code[1]
    @name = code[1].text

registry.literal = class Literal extends Expression
  constructor: (code) ->
    @type = "Literal"
    @copyLoc code[1]
    @raw = code[1].text
    guess = Number @raw
    @value = if isNaN guess then @raw else guess