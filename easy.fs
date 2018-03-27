\ niceties
  : ev 10 PARSE -TRAILING lisp-load-from-string ;
  : inc 10 PARSE -TRAILING lisp-load-from-file ;
  : .l lisp-display ;

: .symtab
    symtab-first @
    BEGIN DUP WHILE
        DUP symtab-namea @ OVER symtab-nameu @ TYPE  CR
        symtab-next @
    REPEAT ;
