(fn (add a b)  (+ a b)) 
(fn (factorial n) 
  (if (<= n 1) 1 
  (* n (factorial (- n 1))))) 
(= get (fn (id) (document.getElementById id)))


(define get (id) (document.getElementById id))