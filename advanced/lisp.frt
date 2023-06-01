\ $Id: lisp.frt,v 1.38 2020/08/26 17:15:23 albert Exp $
\ Copyright (C) 1999 Mark Probst
\ Ansification (2018): Albert van der Horst
\ Copyright by GPL: quality by no warranty.
\ See the obligatory blurb at the end.
\   -*- forth -*-

\ utilities
\ A Lisp interpreter in Forth

\ In a garbage collection version this string must be allocated.
: string-new $, $@ ;

: string>num ( a u -- n )
    0. 2SWAP >NUMBER 2DROP DROP ;

\ : :  : POSTPONE .deb ;

\ symbol table

variable env      0 env !

"" _ _ class    binding
  M:r binding-lisp @ M;     ,
  M:r binding-name 2@ M;  2,
  M:r binding-next @ M;  env @  ,
endclass

: binding-lookup
    env @
    begin >r
        r@ 0= IF TYPE " is unfindable " TYPE 1001 THROW THEN
        2dup r@ binding-name $= not while
    r> binding-next repeat
    2DROP r> binding-lisp ;

\ Add  sc  lisp  at the front of the symbol table.
: binding-add   BUILD-binding env ! ;

\ Add  "name"  lisp  at the front of the symbol table.
: binding-add:  >R NAME string-new R>  binding-add ;

\ lisp interpreter

7 ENUM #nil #pair #number #builtin #symbol #special #compound #max-tag

_ VALUE eval-dispatch
_ VALUE display-dispatch
_ VALUE eq?-dispatch

\ Kind of base object, the dispatch provides polymorphism
_ class    lisp
  M:r lisp-tag  DUP IF @ THEN M;   \ Special case ()/nil/false
  M:r lisp-eval      DUP lisp-tag ( this,tag) CELLS eval-dispatch + @ EXECUTE M;
  M:r lisp-display   DUP lisp-tag CELLS display-dispatch + @ EXECUTE M;
  M:r lisp-eq?       DUP lisp-tag CELLS eq?-dispatch + @ EXECUTE M;
  M:r symbol?   @ #symbol = M;
  ( tag) ,
endclass
\ Tag an object with  tag  implying it inherits from `lisp.
: tagged    BUILD-lisp DROP ;

0 constant lisp-false   \ The only lisp-object without tag.



_ _ ( car cdr ) class pair       #pair tagged
    M:r car  @ M;   SWAP ,
    M:r cdr  @ M;   ,
endclass

_ class number                   #number tagged
  M:r number-num @ M;     ,
endclass

_ class builtin                  #builtin tagged
  M:r builtin-xt @ M;     ,
endclass

_ _ class symbol                 #symbol tagged
  M:r symbol-name 2@ M;     2,
endclass

_ class special                  #special tagged
  M:r special-xt @ M;     ,
endclass

_ _ ( args body ) class compound #compound tagged
  M:r compound-args @ M;     SWAP ,
  M:r compound-body @ M;     ,
endclass

: symbol-new ( namea nameu -- lisp )
    string-new BUILD-symbol ;

: lisp-display-pair ( lisp -- )
    "(" type
    begin
        dup car lisp-display
    cdr dup lisp-tag #pair = while
        " " type
    repeat
    dup if " . " type lisp-display else drop endif
    ")" type ;

:F lisp-eval-list ;
:R lisp-eval-list ( lisp -- lisp )
    dup 0<> if
        dup car lisp-eval swap cdr lisp-eval-list BUILD-pair
    endif ;

: lisp-bind-var ( name value -- )
    >r symbol-name  r> binding-add ;

: lisp-bind-vars ( names values -- )
    swap
    begin
        dup 0<>
    while
        2dup car swap car lisp-bind-var
        cdr swap cdr swap
    repeat
    2drop ;

: lisp-apply-compound ( func args -- lisp )
    env @ >r
    swap
    over compound-args swap lisp-bind-vars
    compound-body lisp-eval
    r> env ! ;


\ specials

: lisp-special-quote ( lisp -- lisp )
    car ;

' lisp-special-quote BUILD-special binding-add: quote

: lisp-special-lambda ( lisp -- lisp )
    dup car swap cdr car BUILD-compound ;

' lisp-special-lambda BUILD-special binding-add: lambda

\ Define a constant with a name
: lisp-special-defined1 ( lisp -- lisp )
    dup car swap cdr car lisp-eval lisp-bind-var 0 ;

\ Define a function with a parameter list
: lisp-special-defined2 ( lisp -- lisp )
  DUP car car SWAP   DUP car cdr SWAP   cdr car BUILD-compound
  lisp-bind-var 0 ;

: lisp-special-define ( lisp -- lisp )
    DUP car symbol? if lisp-special-defined1 else lisp-special-defined2 endif ;

' lisp-special-define BUILD-special binding-add: define

0 0 BUILD-pair constant lisp-true

: lisp-flag   if lisp-true else lisp-false then ;

lisp-true binding-add: t

:F lisp-special-cond ;
:R lisp-special-cond ( lisp -- lisp )
    dup car car lisp-eval 0<> if
        car cdr car lisp-eval
    else
        cdr dup 0<> if
            lisp-special-cond
        endif
    endif ;

' lisp-special-cond BUILD-special binding-add:  cond

\ builtins

: lisp-builtin-+ ( lisp -- lisp )
    0 swap
    begin
        dup 0<>
    while
        dup car number-num rot + swap cdr
    repeat
    drop BUILD-number ;

' lisp-builtin-+ BUILD-builtin binding-add: +

: lisp-builtin-- ( lisp -- lisp )
    dup car number-num swap cdr dup 0= if
        drop negate BUILD-number
    else
        swap
        begin
            over car number-num - swap cdr swap
            over 0=
        until
        nip BUILD-number
    endif ;

' lisp-builtin-- BUILD-builtin binding-add: -

: lisp-builtin-* ( lisp -- lisp )
    1 swap
    begin
        dup 0<>
    while
        dup car number-num rot * swap cdr
    repeat
    drop BUILD-number ;

' lisp-builtin-* BUILD-builtin binding-add: *

: lisp-builtin-cons ( lisp -- lisp )
    dup car swap cdr car BUILD-pair ;

' lisp-builtin-cons BUILD-builtin binding-add: cons

: lisp-builtin-car ( lisp -- lisp )
    car car ;

' lisp-builtin-car BUILD-builtin binding-add: car

: lisp-builtin-cdr ( lisp -- lisp )
    car cdr ;

' lisp-builtin-cdr BUILD-builtin binding-add: cdr

: lisp-builtin-eq? ( lisp -- lisp )
    dup car swap cdr car     ( -- lisp1 lisp2)
    over lisp-tag over lisp-tag = IF
       lisp-eq?
    else
       2drop lisp-false
    endif ;

' lisp-builtin-eq? BUILD-builtin binding-add: eq?

0  \ nil pair number builtin symbol special compound
{ drop "()" type }
' lisp-display-pair
{ number-num . }
{ &# EMIT builtin-xt CRACKED }  \ without decompiler : { "#" type builtin-xt . }
{ symbol-name type }
{ &$ EMIT special-xt CRACKED }  \ without decompiler : { "$" type special-xt . }
{ "(lambda " TYPE  DUP compound-args lisp-display compound-body lisp-display
 ")" TYPE } \ without decompiler : { "&" type compound-args . }
(create-table)  TO display-dispatch

0  \ nil pair number builtin symbol special compound
{ }
{ DUP cdr SWAP car lisp-eval lisp-eval }
{ }
{ swap lisp-eval-list swap builtin-xt execute }
{ symbol-name binding-lookup }
{ special-xt execute }
{ swap lisp-eval-list swap lisp-apply-compound }
(create-table)  TO eval-dispatch

0  \ nil pair number builtin symbol special compound
{ = lisp-flag }
{ = lisp-flag }
{ number-num swap number-num = lisp-flag }
{ = lisp-flag }
{ >R symbol-name  R> symbol-name $= lisp-flag }
{ = lisp-flag }
{ = lisp-flag }
(create-table)  TO eq?-dispatch

: lisp-builtin-display ( lisp -- lisp )
    car lisp-display  0 ;

' lisp-builtin-display BUILD-builtin binding-add: display

\ Obligatory GPL blurb:
\ This program is free software; you can redistribute it and/or
\ modify it under the terms of the GNU General Public License
\ as published by the Free Software Foundation; either version 2
\ of the License, or (at your option) any later version.
\
\ This program is distributed in the hope that it will be useful,
\ but WITHOUT ANY WARRANTY; without even the implied warranty of
\ MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
\ GNU General Public License for more details.
\
\ You should have received a copy of the GNU General Public License
\ along with this program; if not, write to the Free Software
\ Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
