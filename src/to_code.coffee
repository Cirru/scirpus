
isStr = (str) -> typeof str is 'string'
isArr = (arr) -> Array.isArray arr
asNum = (x) -> not (isNaN (Number x))

empty = (arr) -> arr.length is 0
single = (arr) -> arr.length is 1
pair = (arr) -> arr.length is 2
last = (arr) -> arr[arr.length-1]

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
    else -> show 'no suitable tpl', arr.join(' ')
  f arr

err = (info) -> throw new Error info
no_paras = -> err 'no paras'
not_arr = -> err 'not arr'
not_str = -> err 'not str'

c = (x) ->
  show 'c::', x
  if isStr x then x
  else if x.length is 0 then 'undefined'
  else if (x.length is 1) and (asNum x[0]) then x[0]
  else
    head = x[0]
    count x, (if tpl[head]? then tpl[head] else run_tpl)

cc = (x) ->
  # show 'c::', x
  if isStr x then x
  else if x.length is 0 then 'undefined'
  else if (x.length is 1) and (asNum x[0]) then x[0]
  else
    head = x[0]
    ret = count x, (if tpl[head]? then tpl[head] else run_tpl)
    "(#{ret})"

cl = (x) -> "#{c x}\n"

run_tpl =
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
    method = (item) -> "#{head} #{func} #{cl item}\n"
    body.map(method).join('')

assign =
  '<1': no_paras
  '=3': (arr) ->
    head = c arr[1]
    body = c arr[2]
    "#{head} = #{body}\n"
compare =
  '<3': no_paras
  '>2': (arr) ->
    func = arr[0]
    body = arr[1..]
    arr = []
    for item, index in body[...-1]
      arr.push [item, body[index+1]]
    method = (item) -> "#{cc item[0]} #{func} #{cc item[1]}"
    ret = arr.map(method).join(' && ')
    ret = "#{ret}"

calculate =
  '<2': no_paras
  '>1': (arr) -> arr[1..].map(c).join(" #{arr[0]} ")

list =
  '>0': (arr) -> "[#{arr[1..].map(c).join(',')}]"

vector =
  '>0': (arr) ->
    method = (item) -> c item[0]
    "[#{arr[1..].map(method).join(',')}]"

json =
  '>0': (arr) ->
    method = (item) -> "#{item[0]}: #{c item[1]}"
    "({#{arr[1..].map(method).join(',\n')}})"

value =
  '>0': (arr) -> arr[0]

do_tpl =
  '=1': no_paras
  '>1': (arr) -> arr[1..].map(cl).join('')

fn_tpl =
  '=2': no_paras
  '>2': (arr) ->
    head = arr[1].join(',')
    body = c arr[2]
    "(function(#{head}){#{body}})"

if_tpl =
  '=3': (arr) ->
    head = c arr[1]
    body = c arr[2]
    "if(#{head}){#{body}}"
  '=4': (arr) ->
    head = c arr[1]
    body = c arr[2]
    more = c arr[3]
    show 'more::::', more
    "if(#{head}){#{body}}else{#{more}}"

while_tpl =
  '<3': no_paras
  '>3': (arr) ->
    head = c arr[1]
    body = arr[2..].map(cl).join('')
    "while(#{head}){#{body}}"

each_tpl =
  '<4': no_paras
  '>3': (arr) ->
    name = cc arr[1]
    head = arr[2]
    body = arr[3..].map(cl).join('')
    value =
      if head[1]? then "#{head[1]} = #{name}[#{head[0]}]\n"
      else ''
    "for(#{head[0]} in #{name}){#{value}\n#{body}}"

try_tpl =
  '<4': no_paras
  '=4': (arr) ->
    head = c arr[1]
    name = arr[2]
    body = c arr[3]
    "try{#{head}}catch (#{name}){#{body}}"

switch_tpl =
  '<3': no_paras
  '>2': (arr) ->
    head = c arr[1]
    method = (item) -> "case #{item[0]}: #{c item[1]};break;"
    body = arr[2...-1].map(method).join('')
    tail =
      if (last arr)[0] is 'else' then "default: #{c (last arr)[1]}"
      else method (last arr)
    "switch(#{head}){#{body}\n#{tail}}"

refer =
  '=1': no_paras
  '=2': (arr) -> cc arr[1]
  '>2': (arr) ->
    head = cc arr[1]
    body = arr[2..]
    while body.length > 0
      take = body.shift()
      head += "[#{c take}]"
    head

slice =
  '<3': no_paras
  '=3': (arr) ->
    head = cc arr[1]
    from = cc arr[2]
    "#{head}.slice(#{from})"
  '=4': (arr) ->
    head = cc arr[1]
    from = cc arr[2]
    end = cc arr[3]
    "#{head}.slice(#{from}, #{end})"

return_tpl =
  '=2' : (arr) -> "return #{cc arr[1]}"

comment =
  '>0': -> ''

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
  '&&': calculate
  '||': calculate
  'undefined': value
  'break': value
  'continue': value
  'true': value
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
  'try': try_tpl
  'switch': switch_tpl
  '.': refer
  '..': slice
  '--': comment

exports.to_code = (tree) ->
  tree.map(cl).join('')