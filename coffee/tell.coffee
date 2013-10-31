
{grammer} = require "./grammer"
expand = require "./expand"
t = require("./tool")

tell = exports

exports.guess = (exp) ->
  if t.token exp
    tell.from_word exp
  else if t.exp exp
    func = exp[0]
    if t.token func
      tell.from_grammer exp
    else if t.exp func
      callee = tell.guess func
      args = exp[1..].map tell.guess
      expand.call_expression callee, args
    else
      t.error "#{stringify func} not recognized"
  else
    t.error "bad data.. #{exp}"

exports.from_word = (exp) ->
  text = exp.text
  if text.match(/^[a-zA-Z_\$]/)?
    expand.identifier exp
  else if text.match /^[0-9\/]/
    expand.literal exp
  else
    t.error "#{stringify exp} also not identifier.."

exports.from_grammer = (exp) ->
  func = grammer exp[0].text
  if func?
    func exp[1..]
  else
    t.error "#{stringify func.text} not implemented"

exports.statement = (exp) ->
  if t.exp exp
    head = exp[0]
    if t.token head
      console.log "head...", head.text
      if head.text in ["var", "let", "//"]
        tell.guess exp
      else
        type: "ExpressionStatement"
        expression: tell.guess exp
    else
      type: "ExpressionStatement"
      expression: tell.guess exp
  else
    t.error "#{stringify exp} not in grammer"