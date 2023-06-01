(define twice
  (lambda (x)
    (+ x x)))

(display (twice (twice 1)))

(define fak
  (lambda (n)
    (cond ((eq? n 1)
           1)
          (t
           (* n (fak (- n 1)))))))

(display (fak 5))

(define (count-change amount) (cc amount 5))
(define (cc amount kinds-of-coins)
   (cond ((eq? amount 0) 1)
         ((< amount 0) 0)
         ((eq? kinds-of-coins 0) 0)
         (1 (+ (cc amount
                   (- kinds-of-coins 1))
               (cc (- amount
                     (first-denomination kinds-of-coins))
   kinds-of-coins)))))
(define (first-denomination kinds-of-coins)
   (cond ((eq? kinds-of-coins 1) 1)
         ((eq? kinds-of-coins 2) 5)
         ((eq? kinds-of-coins 3) 10)
         ((eq? kinds-of-coins 4) 25)
         ((eq? kinds-of-coins 5) 50)))

\ A 64 it Forth could handle 100, return stack overflow.
(display (count-change 50) )
(newline)
(display count-change)
(newline)
(display +)
(newline)
(display cond)
