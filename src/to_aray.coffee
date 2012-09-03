
q = "'"
qq = '"'

err = (info) ->
  console.log 'error in to_aray'
  throw new Error info

split = (source) ->
  source = "(#{source})"
  mode = 'none'
  reg_esc = off
  qq_esc = off
  q_esc = off
  tokens = []
  word = ''

  for c in source
    # show c
    match = (char) -> char is c
    # show 'watch::', tokens
    if mode is 'none'
      if match '(' then tokens.push '('
      else if match ')'
        tokens.push word
        word = ''
        tokens.push ')'
      else if (match ' ') or (match '\n')
        tokens.push word if word.length > 0
        word = ''
      else if match qq
        mode = qq
        word += qq
      else if match q
        mode = q
        word += q
      else if match '/'
        mode = '/'
        word += '/'
      else word += c
    else if mode is '/'
      word += c
      unless reg_esc
        if match '/'
          # tokens.push word
          # word = ''
          mode = 'none'
      reg_esc = off
      if match '\\' then reg_esc = on
    else if mode is qq
      word += c
      unless qq_esc
        if match qq
          tokens.push word
          word = ''
          mode = 'none'
      qq_esc = off
      if match '\\' then qq_esc = on
    else if mode is q
      word += c
      unless q_esc
        if match q
          mode= 'none'
          tokens.push word
          word = ''
      q_esc = off
      if match '\\' then q_esc = on

  if reg_esc then err 'reg error'
  if qq_esc then err 'qq error'
  if q_esc then err 'q error'
  # show 'tokens:', tokens.join ''
  tokens = tokens.filter (item) -> item.length > 0
  # show 'tokens::', tokens
  tokens

parse = (tokens) ->
  len = tokens.length
  pos = 1
  busy = ->
    tree = []
    while pos <= len
      if pos is len then err 'pos reach len'
      # show pos, len, tree
      c = tokens[pos]
      pos += 1
      if c is '(' then tree.push busy()
      else if c is ')' then return tree
      else tree.push c
  ret = busy()
  # show 'ret:', ret
  ret

exports.to_aray = (source) ->
  parse (split source)