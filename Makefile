# Makefile for testing Probst lisp interpreter

test : test.scm lisp.fs
	echo .symtab inc test.scm | gforth lisp.fs easy.fs

testlina : prelude.frt lisp.fs
	 echo ' "prelude.frt" INCLUDED INCLUDE lisp.fs "test.scm" lisp-load-from-file '|\
	 lina64ex -a
	 echo
