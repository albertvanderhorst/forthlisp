# DESCRIPTION

# GLOBAL DIVISION
I confined the lisp engine to the file `lisp.frt`.
The technicalities sits in `lispl.frt`.
These are the parsing words,  and auxiliary words like `IMPORT`
`ALIASES and `ENUM`, the extension to the class wordset.
It also loads the extensions for lisp itself in more.frt,
extensions defined in forth, and more.scm , extensions defined in
lisp.
The `lispl.frt` is turned into a turnkey program by ciforth.

# DATA
This lisp is based on objects in ciforth style,
so there is no distinction between fields and methods.
Normally in ciforth style there is a current object of
each type, but in this recursive environment this is of no
use. So fields are defined based on offset, and the
calls are <object method>. For this a `M:r` method is
introduced and used exclusively.

The first field of each lisp object
is a constant tag, that determines the
type. The other fields are dependant on the type.
Based on this tag there are three
actions derived given in a table: `eval` `eq?` `display`.
The tag determines the offset in the table, where the xt
resides, then the xt is executed with the `this` pointer on the stack.
The names of the types are :

    nil pair number builtin symbol special compound


# DYNAMIC ALLOCATION
The original has dynamic allocation of strings. Where there is no
effort to garbage collection this makes no sense. So
all strings are allocated in the normal dictionary.

# THE PARSER
The ciforth model has a unique facility, the PREFIX.
This allows to introduce notations of arbitrary kind.
It is in fact trivial. Instead of having `CHAR A` we now
can declare `CHAR` a `PREFIX` (compare `IMMEDIATE`) and
write `CHARA` . Similarly `1 123` can be written as `1123`.
In ciforth this is used to define numbers, strings, xt's.
The convention is that these must result in a compile time
constant that can be handled by `LITERAL`.
In lisp this is abused by having an empty prefix, that matches
everything. The corresponding procedure interpret the following
string as a symbol. Also the prefix `(` reads a list ending with `)`.
There is one more difference between Forth and lisp.
Look at `(+ (aap noot))` with predefined constants.
Forth sees the seconds operand as `noot))` not `noot`.
So it is not sufficient to have blank space as delimiter.
In this simple case it is sufficient to have delimiters
present in "()".
In ciforth parsing is done by `PARSE-NAME` :
- parse until the parsepointer sits at a non-blank
- parse until the parsepointer sits at a blank
- the two pointers determine a string that is to be looked
  up in the dictionary
  
For lisp the second line must now become
- parse until the parsepointer sits at a blank or delimiter
This is a trivial modification, as seen in the source,
as long as it is easy to revector the parsing word.

# RECURSION
I handle cases of recursion with :F and :R , forward and resolve.
In fact they can be replaced by a call of RECURSE .
This is more resilient to reordering.

# TOWARDS A USABLE LISP
As mentioned in the description of the Probst-lisp it
cannot handle the coins example.
In files included in the main file I have added:
- < =
- or else eval

It awaits the expertise of a scheme expert to extend this
further. I suspect that this lisp with a linear search for
every function call will remain a toy lisp forever.
