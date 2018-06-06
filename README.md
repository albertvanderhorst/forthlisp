# Original preface
# Lisp in Forth

This is an interpreter for a really simple dynamically scoped Scheme
dialect. It only runs with
[Gforth](https://www.gnu.org/software/gforth/), because it uses
Gforth's structs to implement its data structures. One of the more
involved parts of this interpreter is the reader, where I had to do
quite a lot of stack juggling to keep everything in line. It doesn't
look very involved now but I remember spending quite some time
thinking about the stack layout for the reader routines.

# Remark AH

The struct's needed are pretty simple and are separated out
in a a file that will be understood by most Forth's. 

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

# Remark AH
You can compile lisp.fs from most ISO-compliant Forth's.
Using easy.fs will save you a lot of key strokes in using the three words above.
