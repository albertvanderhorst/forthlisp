# $Id: Makefile,v 1.14 2023/06/01 14:53:34 albert Exp $
# Copyright (2023): Albert van der Horst {by GNU Public License}

# The source lisp.frt is supposed to run on lina and gforth
# Here is the wrapper for lina.
FORTH=lina

SRC= \
  lispl.frt \
  lisp.frt \
  more.frt \
  more.scm

TEST= \
   test.scm \
   testall.scm \
   coins.scm

.phony : zip

zip : lisp_ciforth.tgz

# build a turnkey lisp with lina.
lispl : lispl.frt lisp.frt more.frt more.scm
	$(FORTH) -c lispl.frt

test: lispl test.scm ; echo inc test.scm BYE | lispl

testall: lispl testall.scm ; echo inc testall.scm BYE | lispl

testoriginal : lispl coins.scm
	echo inc coins.scm BYE | lispl

lisp_ciforth.tgz : $(SRC) $(TEST) Makefile
	tar cfz $@  $+
