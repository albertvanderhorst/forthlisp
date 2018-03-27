# Makefile for testing Probst lisp interpreter

test : test.scm lisp.fs
	echo .symtab inc test.scm | gforth lisp.fs easy.fs
