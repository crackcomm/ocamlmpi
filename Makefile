OCAMLC=ocamlc
OCAMLOPT=ocamlopt
OCAMLDEP=ocamldep

MPI=/usr/local/lib/mpich
CAMLLIB=/usr/local/lib/ocaml

CC=gcc
CFLAGS=-I$(CAMLLIB) -I$(MPI)/include -O -g -Wall

COBJS=init.o comm.o msgs.o collcomm.o
OBJS=mpi.cmo

MPILIBDIR=/usr/local/lib/LINUX/ch_p4

all: libcamlmpi.a mpi.cma mpi.cmxa

libcamlmpi.a: $(COBJS)
	rm -f $@
	ar rc $@ $(COBJS)

mpi.cma: $(OBJS)
	$(OCAMLC) -a -o mpi.cma $(OBJS)

mpi.cmxa: $(OBJS:.cmo=.cmx)
	$(OCAMLOPT) -a -o mpi.cmxa $(OBJS:.cmo=.cmx)

.SUFFIXES: .ml .mli .cmo .cmi .cmx

.ml.cmo:
	$(OCAMLC) -c $<
.mli.cmi:
	$(OCAMLC) -c $<
.ml.cmx:
	$(OCAMLOPT) -c $<

testmpi: test.ml mpi.cma libcamlmpi.a
	ocamlc -custom -o testmpi unix.cma mpi.cma test.ml libcamlmpi.a -ccopt -L$(MPILIBDIR) -cclib -lmpi -cclib -lunix

test: testmpi
	mpirun -np 5 ./testmpi

clean:
	rm -f *.cm* *.o libmpi.a
depend:
	$(OCAMLDEP) *.ml > .depend
	gcc -MM $(CFLAGS) *.c >> .depend

include .depend
