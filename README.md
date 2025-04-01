# Lisp in Forth
# Original preface by Mark Probst

This is an interpreter for a really simple dynamically scoped Scheme
dialect. It only runs with
[Gforth](https://www.gnu.org/software/gforth/), because it uses
Gforth's structs to implement its data structures. One of the more
involved parts of this interpreter is the reader, where I had to do
quite a lot of stack juggling to keep everything in line. It doesn't
look very involved now but I remember spending quite some time
thinking about the stack layout for the reader routines.

## How to use it

Assuming you have Gforth installed (if you're on MacOS you can get it
via [Brew](https://brew.sh)), start it with

    gforth lisp.fs

There are mainly three words of interest:

* `lisp-load-from-string` reads and evaluates a string.

* `lisp-load-from-file` reads and evaluates a file, given a filename.

* `lisp-display` prints a lisp value.

Example:

    s" (+ 1 2 3)" lisp-load-from-string lisp-display
        => 6 ok

    s" test.scm" lisp-load-from-file lisp-display
        => 4 120 () ok

In this example, `4` and `120` are printed in `test.scm`, and `()` is
the result of the evaluation of the file.

# DEFECT
There was a defect removed in name look up, a spurious `UNLOOP`
that crashed any Forth except gforth.

# Remark AH

In struct.fs I have made the structs more portable and removed
more portability issues.
- The struct's needed are pretty simple and are defined and
understood by most Forth's.
- I replaced all `LOCAL` with `VALUE` (outside the definition).
- I defined the word `ENDIF`
- I also removed the word `%allocate`. Either the Forth knows
`allocate` or it isn't. Renaming is silly.
- the words `CELL` is well established (no `%cell`).
Now you can compile lisp.fs from most ISO-compliant Forth's,
as long as they are case-insensitive, or are put into that mode.

The bottomline is that it now runs on pforth, SwiftForth,
and mpeforth, and of course gforth.
For lina/wina and other version of ciforth you must include
`preambule.frt` first.

# Remark AH
Using `easy.fs` will save you a lot of key strokes in using the three words above.

I added .l "dot L", not .1 

The examples above become

        ev (+1 2 3) OK
        \ stack now contains a lisp object
        .l
        => 6 OK
        inc test.scm
        => 4 120 OK
        \ The stack now contains the empty list, c.q. false.
        .l
        => () OK

I added a function similar to VLIST/WORDS
        .symtab
        ==> eq? cdr car ..

# Remark AH
Even the simple example in `coins.scm` cannot be run by this lisp.
In scheme this calculates the number of ways to change one dollar.

        scheme -load coins.scm

#ADVANCED

The `advanced` subdirectory contains a version that relies on
    - classes/ objects
    - anonymous functions
    - parsing lisp directly
It workes on all versions of ciforth lina/wina 32/64 .

This foregoes the need for any values, locals and variables, except one,
(the ancre for the linked list `env`).
