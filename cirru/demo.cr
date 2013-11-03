
func-dec fibo (n)
  block $
    if (binary > n 2)
      return
        binary +
          call fibo $
            binary - n 1
          call fibo $
            binary - n 2
      return 1

expression
  call
    . console log
    (call fibo (12)