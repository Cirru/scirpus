
# helpers

type = (x) ->
  raw = Object::toString.call x
  raw[8...-1].toLowerCase()

is_number = (x) ->
  x >= 0 or x < 0

is_string = (x) ->
  (type x) is "string"

stringify = (x) ->
  JSON.stringify x

copy_loc = (word) ->
  if word.start? and word.end?
    start:
      line: word.start.y + 1
      column: word.start.x
    end:
      line: word.end.y + 1
      column: word.end.x
  else
    null

is_token = (x) ->
  ((type x) is "object") and (is_string x.text)

is_exp = (x) ->
  (type x) is "array"

# grammers

grammers =
  ">": (args...) ->

  if: (args...) ->

  ":": (args) ->
    left = expand_identifier args[0]
    right = expand args[1]
    expand_assignment_expression left, "=", right

  ".": (args) ->
    object = expand_identifier args[0]
    property = expand_identifier args[1]
    expand_member_expression object, property

# expands

expand_literal = (x) ->
  guess = Number x.text
  if is_number guess
    type: "Literal"
    value: guess
    raw: x.text
    loc: (copy_loc x)
  else
    type: "Literal"
    raw: x.text
    loc: (copy_loc x)

expand_identifier = (word) ->
  type: "Identifier"
  name: word.text
  loc: (copy_loc word)

expand_assignment_expression = (left, operator, right) ->
  type: "AssignmentExpression"
  operator: operator
  left: left
  right: right

expand_call_expression = (callee, args) ->
  type: "CallExpression"
  callee: callee
  arguments: args

expand_member_expression = (object, property) ->
  type: "MemberExpression"
  object: object
  property: property
  computed: no

# main expand feature

expand = (exp) ->
  if is_token exp
    expand_literal exp
  else if is_exp exp
    func = exp[0]
    if is_token func
      if grammers[func.text]?
        grammers[func.text] exp[1..]
      else
        throw new Error "#{stringify func.text} not implemented"
    else if is_exp func
      callee = expand func
      args = exp[1..].map expand
      expand_call_expression callee, args
    else
      throw new Error "#{stringify func} not recognized"

transform = (tree) ->
  type: "Program"
  body: tree.map (exp) ->
    type: "ExpressionStatement"
    expression: (expand exp)

exports.transform = transform
