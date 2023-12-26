\ Copyright (2018): Albert van der Horst {by GNU Public License}

\ structs with active fields, in fact objects.

VARIABLE offset

: struct   0 offset ! ;

\ Create field  "name"  with  offset  size  . Leave new  offset  .
\ name execution: turn  struct   into a  field
: field   :  offset @ POSTPONE literal POSTPONE +
   POSTPONE ;  offset +! ;

: end-struct  offset @ CONSTANT ;  \ leaves size of struct

: ENDIF POSTPONE THEN ; IMMEDIATE

1 CELLS CONSTANT cell
