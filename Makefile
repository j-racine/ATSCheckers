#
# A Makefile for gtkcairoclock
#

######

PATSHOMEQ="$(PATSHOME)"

######

PATSCC=$(PATSHOMEQ)/bin/patscc
GTKFLAGS=`pkg-config gtk+-2.0 --cflags --libs`

######

all:: test
test: test.dats Checkers.dats
	$(PATSCC) -DATS_MEMALLOC_LIBC -I${PATSHOME}/contrib -o $@ $^ $(GTKFLAGS)

cleanall:: ; $(RMF) test

######

RMF=rm -f

######

clean:: ; $(RMF) *~
clean:: ; $(RMF) *_?ats.o
clean:: ; $(RMF) *_?ats.c

cleanall:: clean

###### end of [Makefile] ######

