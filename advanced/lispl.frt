\ $Id: lispl.frt,v 1.34 2023/06/01 14:53:34 albert Exp $
\ Copyright (2022): Albert van der Horst {by GNU Public License}

\ This is a lisp parser to complement the lisp interpreter original
\ from Mark Probst, modified for ciforth, i.e. class.

\ NOTE: Charles Moore convention for parameters.

WANT INCLUDE SET-CURRENT
WANT 0<> <= $=
WANT VALUE R/O 2>R
WANT SEE H.
WANT ALIAS { :F
WANT class
WANT REGRESS CASE-INSENSITIVE DO-DEBUG
\ Import remainder of line
    : GET-NAME SAVE NAME RESTORE ;
: IMPORT    ^J PARSE SAVE SET-SRC
    BEGIN GET-NAME DUP WHILE FOUND ALIAS REPEAT 2DROP
    RESTORE  ;
\ ciforth specific debugging,
\ WANT decorated DUMP SEE LOCATE

\ Addition to class, Probst uses (object method) system.
: M:r   BLD} HERE DP-MARKER @ - >R SWAP-DP : R> "%d  +" FORMAT&EVAL ;

CASE-INSENSITIVE  NO-DEBUG

NAMESPACE lisp-namespace
'lisp-namespace >WID CONSTANT lisp-ns
'FORTH >WID CONSTANT FORTH-WORDLIST

' THEN ALIAS endif

\ ( 0 r1 r2 r3  -- ) Create a table r1 , r2 , ..
: (create-table)   0 >R BEGIN ?DUP WHILE >R REPEAT
    HERE BEGIN R> ?DUP WHILE , REPEAT ;

\ ------------------------------

\ Debugging tool, prints name and stack.
\ : .deb R@ 0 >PHA CELL+ - ID. .S ;
\ : .deb ; IMMEDIATE
\ ------------------------------

\ ---------------- REBUILD OF PARSING ENGINE -----------

DATA delimiters 0 , 128 ALLOT
: lisp-delimiters ":[](){};" ;

\ For a   char  return : a token   may   start with this.
: ?START  delimiters $@ ROT $^ 0<> ;
REGRESS lisp-delimiters delimiters $! S:
REGRESS  BL ?START   &A ?START    &( ?START S: FALSE FALSE TRUE
REGRESS 0 delimiters ! S:

\ Start parsing using the sealed wordlist `lisp-ns defined.
\ Those words define what actually happens.
: lisp-on   lisp-delimiters delimiters $! ;
\ And off again.
: lisp-off 0 delimiters ! ;

\ A name now starts with the next non-blank, but ends on a blank
\ or delimiter. Leaves  name  (a string constant).
: TOKEN
   _ BEGIN DROP PP@@ ?BLANK OVER SRC CELL+ @ - AND 0= UNTIL ( -- start)
   _ _ BEGIN 2DROP PP@@ DUP ?BLANK OVER ?START OR UNTIL ( -- s e del)
   ?START PP +!    OVER - ;

'TOKEN 'NAME  2 CELLS MOVE

: aliases:
    ^J PARSE SAVE   SET-SRC   BEGIN DUP 'ALIAS CATCH UNTIL 2DROP   RESTORE ;

: ENUM 1+ 0 DO I CONSTANT LOOP ;

: inc 'INCLUDE CATCH DUP -32 <> AND THROW ;
\ ------------------------------

INCLUDE lisp.frt
INCLUDE more.frt
\ ------------------------------
\ niceties
  : .l lisp-display ;
  : .symtab env @
    BEGIN ?DUP WHILE DUP binding-name type CR binding-next REPEAT ;
  : .S .S RSP@ H. ;
\   : .l DROP ; : .S ;
\ ------------------------------
: lisp-number  -1 PP +! TOKEN string>num BUILD-number ; PREFIX
: lisp-symbol  TOKEN string-new BUILD-symbol ;

2 ENUM #_ #list #single

\ : INTERPRET &* EMIT .S INTERPRET &$ EMIT .S ;
: lisp-list   #list INTERPRET   \ #list is used as a sentinel.
    0 BEGIN OVER #list <> WHILE BUILD-pair REPEAT NIP ;

lisp-ns SET-CURRENT
\  An empty prefix matches everything, sealing the `lisp-ns namespace.
: catch-all lisp-symbol ; PREFIX  "" LATEST >NFA @ $!
'lisp-number  aliases: 0 1 2 3 4 5 6 7 8 9
: (   lisp-list ; PREFIX
'EXIT ALIAS )  PREFIX
IMPORT FORTH .l .S .symtab inc lisp-off

FORTH-WORDLIST SET-CURRENT
: (   CONTEXT @ >R
    lisp-ns CONTEXT !
    lisp-list
    lisp-eval
    R> CONTEXT !
; PREFIX
: .. lisp-eval lisp-display ;

: lisp-load-from-file lisp-on INCLUDED lisp-off ;

\ ------------------------------
"more.scm" lisp-load-from-file
: l lisp-ns CONTEXT ! ;
: doit   'ERROR RESTORED lisp-on QUIT ;
