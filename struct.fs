\ Copyright (2018): Albert van der Horst {by GNU Public License}

\ structs with active fields, in fact objects.

10 CONSTANT ^J
VARIABLE offset

: struct   0 offset ! ;

: end-struct  offset @ CONSTANT ;  \ leaves size of struct

: rema ^J PARSE ;

\ Create field  "name"  with  offset  size  . Leave new  offset  .
\ name execution: turn  struct   into a  field
: field   :  offset @ POSTPONE literal POSTPONE + rema EVALUATE
   POSTPONE ;  offset +! ;

: end-struct  offset @ CONSTANT ;  \ leaves size of struct

1 CELLS CONSTANT cell%

( size -- addr ior )
 : %allocate allocate ;
