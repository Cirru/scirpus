
= a 1
+= a 2
*= a 3 4 5
+ a 6
= b (+ a 7)
< a b
< 1 a b 100
= list (# 1 2 3 4 5)
= len
  . list 'length'
= str
  . list ('join' ',') ('split')
= str2
  list.join ','

& (a 1) (b 2)
  c (& (a 5))
  d
    &
      a 1
      b (# 1 2 3 4)

= f1 (-> () 1)
= f2 (-> (x) x)
= f3 (-> (x) (<- x))
= f4
  -> (x y)
    <- (+ x y)

&& (> 4 2) (> 5 4 6)
if (&& (> 4 3) (|| (< 2 3))) (show 'right')
if
  && (> 4 3) (|| (< 2 3))
  show 'right'
  show 'wrong'

= x "a \" b c / d / ' e"
= x 'a \' b c / d / " e'
= x /a \' b c \/ d \/ \" e/

show (typeof show)
undefined
true
show null

= f5
  -> (x)
    do
      show x
      show (+ x 1)
      show x
      <- x

show true

= a 'bug of js show(true)(function...)'

= ret
  .
    -> (x) (<- x)
    ('call')

= a 3
while (< a 100)
  do
    show a
    show 'line'

try
  show 'try'
  err
  show xx

switch (+ 1 2)
  1 'one'
  2 'two'
  3 'three'
  else 'else'

each obj (key value)
  show key value

each list (index value)
  show index value

each oo (xx)
  show xx

. obj (method) attr (func para)
. obj 'log'
.. list start end