(define match-junk
        (lambda (k frag)
                (call/cc (lambda (cc)  
                (and (<= 0 k)
                         (pair? frag)
                         (cons frag (lambda () cc (match-junk (- k 1) (cdr frag)))))))))
 
(define match-first #t)
(define match-*
  (lambda (matcher frag)
    (call/cc (lambda (cc)
    (if (eq? match-first #t)
    (begin
      (set! match-first #f)
      (cons frag (lambda () cc (match-* matcher frag))))
    (let ((res (matcher frag)))
        (if (eq? res #f)
                #f
                (let ((frag1 (car res)))
                        (and (not (eq? frag1 frag)))
                        (cons frag1 (lambda () cc (match-* matcher frag1)))))))))))
 
(define (carf a) (if (eq? #f a) #f (car a)))
(define (consf a b) (if (eq? #f a) #f (cons a b)))
 
(define make-matcher
  (lambda (pat)
    (cond
      
     ((symbol? pat)
          (lambda (frag)
                (call/cc (lambda (cc)
                (and (pair? frag)
                         (eq? pat (car frag))
                         (cons (cdr frag) (lambda () cc #f)))))))
       
        ((eq? 'or (car pat))
      (let make-or-matcher ((pats (cdr pat)))
        (if (null? pats)
            (lambda (frag) #f)
           
            (let ((head-matcher (make-matcher (car pats)))
                  (tail-matcher (make-or-matcher (cdr pats))))
                        (lambda (frag)
                                (call/cc (lambda (cc)
                                        (let ((res (head-matcher frag)))
                                                (if (eq? res #f)
                                                (tail-matcher frag)
                                                 (cons (car res) (lambda () cc
                                                        (let ((next ((cdr res))))
                                                                (if (eq? next #f)
                                                                        (tail-matcher frag)
                                                                next)))))))))))))
               
               
        ((eq? 'list (car pat))
     (let make-list-matcher ((pats (cdr pat)))
                (if (null? pats)
                (lambda (frag)
                  (call/cc (lambda (cc)
                        (cons frag (lambda () cc #f)))))
               
                (let ((head-matcher (make-matcher (car pats)))
                              (tail-matcher (make-list-matcher (cdr pats))))
                                        (lambda (frag)
                                        (call/cc (lambda (cc)
                                                (let ((res (head-matcher frag)))
                                                        (if (eq? res #f)
                                                        #f
                                                        (let ((tail (tail-matcher (car res))))
                                                        (if (eq? tail #f)
                                                                #f
                                                                (cons (car tail)
                                                                (lambda () cc
                                                                (let ((next ((cdr res))))
                                                                (if (eq? next #f)
                                                                        #f
                                                                        (tail-matcher (car next)))))))))))))))))
                                                               
                                                                               
    ((eq? 'junk (car pat))
      (let ((cc (cadr pat)))
        (lambda (frag)
          (match-junk cc frag))))
 
     ((eq? '* (car pat))
      (let ((matcher (make-matcher (cadr pat))))
        (lambda (frag)
          (match-* matcher frag)))))))