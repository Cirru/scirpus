
= a (# 1 24 53 45 3  4  56 578 89 56 56)
= sort
  -> (start end list)
    if (>= end a.length) (<- list)
      if (>= start end)
        <- (sort 0 (+ end 1) list)
        do
          = small (. list start)
          = big (. list (+ start 1))
          if (> small big)
            do
              = t small
              = small big
              = big t
          = (. list start) small
          = (. list (+ start 1)) big
          <- (sort (+ start 1) end list)
console.log (sort 0 0 a)