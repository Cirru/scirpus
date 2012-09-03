
isStr = (str) -> typeof str is 'string'
isArr = (arr) -> Array.isArray arr
asNum = (x) -> not (isNaN (Number x))

empty = (arr) -> arr.length is 0
single = (arr) -> arr.length is 1
pair = (arr) -> arr.length is 2

count = (arr, choice) ->
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
    else -> show 'xxxx'
  f arr

err = (info) -> throw new Error info
no_paras = -> err 'no paras'
not_arr = -> err 'not arr'
not_str = -> err 'not str'

c = (x) ->
  # show 'c::', x
  if isStr x then x
  else if x.length is 0 then 'undefined'
  else if (x.length is 1) and (asNum x[0]) then x[0]
  else
    head = x[0]
    count x, (if tpl[head]? then tpl[head] else func_tpl)

cc = (x) -> "(#{c x})"
cl = (x) -> "#{c x}\n"

func_tpl =
  '>0': (arr) ->
    head = arr[0]
    body = arr[1..].map(cc).join(',')
    "#{head}(#{body})"

append_tpl =
  '=1': no_paras
  '=2': (arr) -> cc arr[1]
  '>2': (arr) ->
    func = arr[0]
    head = arr[1]
    body = arr[2..]
    method = (item) -> "#{head} #{func} #{cc item}\n"
    body.map(method).join('')

assign =
  '<1': no_paras
  '=3': (arr) ->
    if isStr arr[1]
      head = arr[1]
      body = cc arr[2]
      "#{head} = #{body}\n"
    else assign['>1'] arr
  '>1': (arr) ->
    unless arr[1..].every isArr then not_arr()
    first_str = (item) -> isStr item[0]
    unless arr[1..].every first_str then not_str()
    method = (item) -> "#{item[0]} = (#{c item[1]})\n"
    arr[1..].map(method).join('')

compare =
  '<3': no_paras
  '>2': (arr) ->
    func = arr[0]
    body = arr[1..]
    arr = []
    for item, index in body[...-1]
      arr.push [item, body[index+1]]
    method = (item) -> "(#{item[0]} #{func} #{item[1]})"
    ret = arr.map(method).join(' && ')
    ret = "(#{ret})"

calculate =
  '<2': no_paras
  '>1': (arr) -> arr[1..].map(cc).join(" #{arr[0]} ")

list =
  '>0': (arr) -> "[#{arr[1..].map(cc).join(',')}]"

vector =
  '>0': (arr) ->
    method = (item) -> cc item[0]
    "[#{arr[1..].map(method).join(',')}]"

json =
  '>0': (arr) ->
    method = (item) -> "#{item[0]}: #{c item[1]}"
    "$_json={#{arr[1..].map(method).join(',\n')}}"

json_name =
  '>0': (arr) ->
    name = arr[1]
    method = (item) -> "#{item[0]}: #{c item[1]}"
    "#{name}={#{arr[2..].map(method).join(',\n')}}"

value = (arr) -> arr[0]

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
  '#': list
  '##': list
  '&': json
  '&=': json_name
  '&&': calculate
  '||': calculate
  'undefined': value
  'break': value
  'continue': value
  'typeof': func_tpl
  'return': func_tpl
  'not': func_tpl
  '!': func_tpl

exports.to_code = (tree) ->
  tree.map(cl).join('')