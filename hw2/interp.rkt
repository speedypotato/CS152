#lang racket

;; Exported methods and structs
(provide evaluate
         sp-val sp-binop sp-if sp-while
         sp-assign sp-var sp-seq)

;; Expressions in the language
(struct sp-val (val))
(struct sp-binop (op exp1 exp2))
(struct sp-if (c thn els))
(struct sp-while (c body))
(struct sp-assign (var exp))
(struct sp-var (varname))
(struct sp-seq (exp1 exp2))

;; Main evaluate method
(define (evaluate prog env)
  (match prog
    [(struct sp-val (v))              (cons v env)] ;; We return a pair of the value and the environment.
    [(struct sp-binop (op exp1 exp2)) (eval-binop op exp1 exp2 env)]
    [(struct sp-if (c thn els))       (eval-if c thn els env)]
    [(struct sp-while (c body))       (eval-while c body env)]
    [(struct sp-assign (var exp))     (eval-assign var exp env)]
    [(struct sp-var (varname))        (cons (hash-ref env varname) env)]
    [(struct sp-seq (exp1 exp2))      (eval-seq exp1 exp2 env)]
    [_                                (error "Unrecognized expression")]))

;; Applies a binary argument to two arguments
(define (eval-binop op e1 e2 env)
  (let* ([r1 (evaluate e1 env)]        ;; Evaluate the lhs expression first
         [v1 (car r1)] [env1 (cdr r1)]
         [r2 (evaluate e2 env1)]       ;; Evaluate the rhs expression second
         [v2 (car r2)] [env2 (cdr r2)])
    (cons (apply op (list v1 v2))      ;; Apply the binary operator to its arguments
          env2)))

;; Evaluates a conditional expression
(define (eval-if c thn els env)
  (let* ([r1 (evaluate c env)]
         [v1 (car r1)]
         [env1 (cdr r1)]
         
         [r2 (evaluate thn env1)]
         [v2 (car r2)]
         [env2 (cdr r2)]
         
         [r3 (evaluate els env2)]
         [v3 (car r3)]
         [env3 (cdr r3)])
    (if (eqv? #t v1)
        (cons v2 env2)
        (cons v3 env3))))

;; Evaluates a loop.
;; When the condition is false, return 0.
;; There is nothing special about zero -- we just need to return something.
(define (eval-while c body env)
  (let* ([r1(evaluate c env)]
         [v1 (car r1)]
         [env1 (cdr r1)]
         
         [body1 (evaluate body env)]
         [env2 (cdr body1)])
    (if v1
        (eval-while c body env2)
        (cons 0 env1))))

;; Handles imperative updates.
(define (eval-assign var exp env)
  (let* ([r1 (evaluate exp env)]
         [v1 (car r1)]
         [env1 (cdr r1)])
    (cons v1 (hash-set env var v1))))

;; Handles sequences of statements
(define (eval-seq e1 e2 env)
  (let* ([r1 (evaluate e1 env)]
         [v1 (car r1)]
         [env1 (cdr r1)]
         
         [r2 (evaluate e2 env1)]
         [v2 (car r2)]
         [env2 (cdr r2)])
    (cons v1 env2)))

