;Example 4
(define (leaf? x) (not (list? x)))
  
(define (dfs l good?)
  (call/cc
   (lambda (continue)
     (cond ((null? l) #F)
           ((leaf? l) (if (good? l)
                       (cons l (lambda () (continue #F)))
                          #F))
           (#T (let ((left (dfs (car l) good?)))
                 (if left left (dfs (cdr 1) good?))))))))

(define test1 (dfs '(((1 2) 3 4) 5) (lambda (x) (> x 3)))) 