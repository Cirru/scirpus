
isStr = (str) -> typeof str is 'string'
isArr = (arr) -> Array.isArray arr
asNum = (x) -> not (isNaN (Number x))

empty = (arr) -> arr.length is 0
single = (arr) -> arr.length is 1
pair = (arr) -> arr.length is 2
last = (arr) -> arr[arr.length-1]

make_space = (n) ->
  str = ""
  i = 0
  while i < n
    str += " "
    i += 1
  str

choose = (arr, choice) ->
  head = arr[0]
  choice = if tpl[head]? then tpl[head] else run_tpl
  len = arr.length
  str = "=#{String len}"
  # show str
  # show len, choice
  f =
    if choice[str]? then choice[str]
    else if (len < 1) and choice['<1']? then choice['<1']
    else if (len < 2) and choice['<2']? then choice['<2']
    else if (len < 3) and choice['<3']? then choice['<3']
    else if (len < 4) and choice['<4']? then choice['<4']
    else if (len > 4) and choice['>4']? then choice['>4']
    else if (len > 3) and choice['>3']? then choice['>3']
    else if (len > 2) and choice['>2']? then choice['>2']
    else if (len > 1) and choice['>1']? then choice['>1']
    else if (len > 0) and choice['>0']? then choice['>0']
    else -> throw new Error 'no suitable tpl'
  f arr

err = (info) -> throw new Error info
no_paras = -> err 'no paras'
not_arr = -> err 'not arr'
not_str = -> err "no str"

code =
  data: ""
  indent: 0
  clear: -> @data = ""
  add: (piece) ->
    # console.log "++", piece
    @data = @data + piece
    # ""
  int: (n) ->
    @indent += n
  new: (n) ->
    @int n
    indentation = make_space @indent
    @data += "\n#{indentation}"
    # console.log "indentation is--:#{indentation}--", n, @indent

read = (x) ->
    # console.log "read:", x
  if isStr x then code.add x
  else if x.length is 0 then code.add 'undefined'
  else if (x.length is 1) and (asNum x[0])
    code.add x[0]
  else choose x

run_tpl =
  '>0': (arr) ->
    code.add arr[0]
    code.add "("
    body = arr[1..]
    body.forEach (item, index) ->
      if isStr item then code.add item
      else read item
      code.add ", " if body[index + 1]?
    code.add ")"

append_tpl =
  '<3': no_paras
  '=3': (arr) ->
    read arr[1]
    code.add " #{arr[0]} "
    read arr[2]

assign =
  '<3': no_paras
  '=3': (arr) ->
    code.add "var "
    read arr[1]
    code.add " = "
    read arr[2]

compare =
  '<3': no_paras
  '=3': (arr) ->
    code.add "("
    read arr[1]
    code.add " #{arr[0]} "
    read arr[2]
    code.add ")"

calculate =
  '<2': no_paras
  '>1': (arr) ->
    head = arr[0]
    body = arr[1..]
    read body.shift()
    while body[0]?
      code.add " #{head} "
      read body.shift()

list =
  '>0': (arr) ->
    # console.log arr
    code.add "["
    body = arr[1..]
    if body[0]? then read body.shift()
    while body[0]?
      code.add ", "
      read body.shift()
    code.add "]"

json =
  '>0': (arr) ->
    code.add "{"
    code.new 2
    body = arr[1..]
    write_pair = ->
      item = body.shift()
      code.add "#{item[0]}: "
      read item[1]
    if body[0]? then write_pair()
    while body[0]?
      code.add ", "
      code.new 0
      write_pair()
    code.new -2
    code.add "}"

value =
  '>0': (arr) -> code.add arr[0]

fn_tpl =
  '<3': no_paras
  '>2': (arr) ->
    head = arr[1]
    body = arr[2..]
    code.add "(function("
    if head[0]? then code.add head.shift()
    while head[0]?
      code.add ", #{head.shift()}"
    code.add "){"
    code.int 2
    body.forEach (line) ->
      code.new 0
      read line
      code.add ";"
    code.new -2
    code.add "})"

call_tpl =
  "<2": no_paras
  ">1": (arr) ->
    read = arr[1]
    body = arr[2..]
    code.add "("
    if body[0]? then code.add body.shift()
    while body[0]?
      code.add ", "
      code.add body.shift()
    code.add ")"

do_tpl =
  "<2": no_paras
  ">1": (arr) ->
    body = arr[1..]
    if body[0]? then read body.shift() 
    body.forEach (line, index) ->
      code.new 0
      read line
      if body[index]? then code.add ";"

if_tpl =
  '=3': (arr) ->
    head = arr[1]
    body = arr[2]
    code.add "if"
    read arr[1]
    code.add "{"
    code.new 2
    read arr[2]
    code.new -2
    code.add "}"
  '=4': (arr) ->
    head = arr[1]
    body = arr[2]
    code.add "if"
    read arr[1]
    code.add "{"
    code.new 2
    read arr[2]
    code.new -2
    code.add "}"
    code.add "else{"
    code.new 2
    read arr[3]
    code.new -2
    code.add "}"

while_tpl =
  '<3': no_paras
  '>2': (arr) ->
    head = arr[1]
    body = arr[2..]
    code.add "while"
    read head
    console.log head
    code.add "{"
    code.int 2
    body.forEach (line) ->
      code.new 0
      read line
      code.add ";"
    code.new -2
    code.add "}"

each_tpl =
  '<4': no_paras
  '>3': (arr) ->
    name = cc arr[1]
    head = arr[2]
    body = arr[3..].map(cl).join(';')
    value =
      if head[1]? then "#{head[1]} = #{name}[#{head[0]}];\n"
      else ''
    "for(#{head[0]} in #{name}){#{value}\n#{body}}"
    code.add "for("
    code.add arr[2]
    code.add "in"
    read arr[1]
    code.add "){"
    code.new 2
    arr[3..].forEach (line) ->
      code.new 0
      read line
      code.add ";"
    code.new -2
    code.add "}"

try_tpl =
  '<4': no_paras
  '=4': (arr) ->
    head = c arr[1]
    name = arr[2]
    body = arr[3..].map(cl).join('')
    "try{#{head}}catch (#{name}){#{body}}"
    code.add "try{"
    code.new 2
    read arr[2]
    code.new -2
    code.add "} catch (#{arr[1]})"
    code.new 2
    read arr[3]
    code.new -2
    code.add "}"

switch_tpl =
  '<3': no_paras
  '>2': (arr) ->
    code.add "switch(#{arr[1]}){"
    code.new 2
    body = arr[2..]
    # console.log body
    while body[1]?
      item = body.shift()
      # console.log item
      code.add "case "
      read item[0]
      code.add ":"
      code.new 2
      read item[1]
      code.add ";"
      code.new 0
      code.add "break;"
      code.new -2
    if body[0]?
      code.add "default:"
      code.new 2
      read body[0][1]
      code.add ";"
      code.new 0
      code.add "break;"
      code.int -2
    code.new -2
    code.add "}"

refer =
  '<3': no_paras
  '>2': (arr) ->
    read arr[1]
    body = arr[2..]
    while body[0]?
      item = body.shift()
      code.add "["
      if item[0] is '"' then code.add item
      else code.add JSON.stringify item
      code.add "]"

slice =
  '<3': no_paras
  '>2': (arr) ->
    code.add read
    code.add ".slice("
    read arr[1]
    if arr[2]?
      code.add ", "
      read arr[2]
    code.add ")"

return_tpl =
  '=2' : (arr) ->
    code.add "return "
    read arr[1]

comment =
  '>0': (arr) -> code.add "//#{arr[1..].join " "}"

new_tpl =
  '=3': (arr) ->
    "new #{arr[1]}(#{c arr[2]});"
    code.add "new "
    code.add arr[1]
    read arr[2]

tpl =
  '=': assign
  '+=': append_tpl
  '-=': append_tpl
  '*=': append_tpl
  '/=': append_tpl
  '%=': append_tpl
  '<': compare
  '>': compare
  '==': compare
  '<=': compare
  '>=': compare
  '+': calculate
  '-': calculate
  '*': calculate
  '/': calculate
  '%': calculate
  'list': list
  '&': json
  '&&': calculate
  '||': calculate
  'undefined': value
  'break': value
  'continue': value
  'true': value
  'null': value
  'false': value
  'typeof': run_tpl
  'not': run_tpl
  '!': run_tpl
  '<-': return_tpl
  'do': do_tpl
  '->': fn_tpl
  'if': if_tpl
  'while': while_tpl
  'each': each_tpl
  'catch': try_tpl
  'switch': switch_tpl
  '.': refer
  '..': slice
  '--': comment
  'new': new_tpl

exports.build = (tree) ->
  code.clear()
  tree.forEach (line) ->
    code.new 0
    read line
    code.add ";"
  code.data