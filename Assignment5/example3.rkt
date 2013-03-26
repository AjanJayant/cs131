;Example 3
(define product
  (lambda (l)
    (call/cc
         (lambda (break)
           (let f((ls l))
              (cond
                ((null? ls) 1)
                ((= (car ls) 0) (break 0))
                (else (* (car ls) (f cdr ls)))))))))

(product '(4 5 6))