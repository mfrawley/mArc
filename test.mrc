define (factorial n)
  if (<= n 1) 1
    * n (factorial (- n 1))

define (add a b)
  (+ a b)
  
= get (fn (id)
  document.getElementById id)