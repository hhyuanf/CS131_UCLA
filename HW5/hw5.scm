

(define match-junk
	(lambda (k frag) 
		(call/cc (lambda (continue)
		(if (and (<= 0 k) (pair? frag))
			 (cons frag (lambda () (continue (match-junk (- k 1) (cdr frag)))))
             (cons frag (lambda () (continue #f))))))))

(define match-*
  (lambda (matcher frag)
    (call/cc (lambda (continue)
    (let ((res (matcher frag)))
    (if (eq? res #f)
    (cons frag (lambda () continue #f))
    (let ((frag1 (car res))) 
    (if (eq? frag1 #f)
         #f
         (cons frag1 (lambda () (continue (match-* matcher frag1))))))))))))

(define match-head 
    (lambda  (tailMatcher headRes)
    (and
    (pair? headRes)
    (let ((tail (tailMatcher (car headRes))))
    (if (pair? tail)
    tail
    (match-head tailMatcher ((cdr headRes))))))))


(define make-matcher
  (lambda (pat)
    (cond
      
     ((symbol? pat)
          (lambda (frag)
                (call/cc (lambda (continue)
                (and (pair? frag)
                         (eq? pat (car frag))
                         (cons (cdr frag) (lambda () continue #f)))))))
       
        ((eq? 'or (car pat))
      (let make-or-matcher ((pats (cdr pat)))
        (if (null? pats)
            (lambda (frag) #f)
           
            (let ((head-matcher (make-matcher (car pats)))
                  (tail-matcher (make-or-matcher (cdr pats))))
                        (lambda (frag)
                                (call/cc (lambda (continue)
                                        (let ((res (head-matcher frag)))
                                                (if (eq? res #f)
                                                (tail-matcher frag)
                                                 (cons (car res) (lambda () (continue
                                                        (let ((next ((cdr res))))
                                                                (if (eq? next #f)
                                                                        (tail-matcher frag)
                                                                next))))))))))))))
               
               
        ((eq? 'list (car pat))
     (let make-list-matcher ((pats (cdr pat)))
                (if (null? pats)
                (lambda (frag)
                  (call/cc (lambda (continue)
                        (cons frag (lambda () continue #f)))))
               
                (let ((head-matcher (make-matcher (car pats)))
                              (tail-matcher (make-list-matcher (cdr pats))))
                                        (lambda (frag)
                                                (let ((res (head-matcher frag)))
                                                        (if (eq? res #f)
                                                        #f
                                                        (call/cc (lambda (continue)
                                                        (let ((tail (match-head tail-matcher res)))
                                                        (if (eq? tail #f)
                                                                #f
                                                                (cons (car tail)
                                                                (lambda () (continue
                                                                (let ((next ((cdr res))))
                                                                (if (eq? next #f)
                                                                        #f
                                                                        (match-head tail-matcher next)))))))))))))))))

		
    ((eq? 'junk (car pat))
      (let ((k (cadr pat)))
	(lambda (frag)
	  (match-junk k frag))))

     ((eq? '* (car pat))
      (let ((matcher (make-matcher (cadr pat))))
	(lambda (frag)
	  (match-* matcher frag)))))))
