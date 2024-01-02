all:
	rm -f ./qcm; dune build && ln -s ./_build/default/src/main.exe ./qcm

clean:
	dune clean && rm -f ./qcm

check:
	./qcm -r "x=3,y=0" -t 5 test/addition.qcm
	./qcm -r "x=0,y=3" -t 5 test/addition.qcm
	./qcm -r "x=3,y=0" -r "x=0,y=3" -t 5 test/addition.qcm
	./qcm -u "x" -r "y=1" -t 5 test/addition.qcm
	./qcm -r "res=0,r1=0,x=2,y=1" -t 10 test/exponentiation-nosync.qcm
	./qcm -r "res=0,r1=0,x=2,y=2" -t 15 test/exponentiation-nosync.qcm
	./qcm -r "res=0,r1=0,x=2,y=1" -r "res=0,r1=0,x=2,y=2" -t 10 test/exponentiation-nosync.qcm
	./qcm -r "res=0,r1=0,x=2,y=2,max=2" -t 21 test/exponentiation.qcm
	./qcm -r "res=0,r1=0,x=2,y=1,max=2" -t 21 test/exponentiation.qcm
	./qcm -r "res=0,r1=0,x=2,y=2,max=2" -r "res=0,r1=0,x=2,y=1,max=2" -t 21 test/exponentiation.qcm
	./qcm -r "r1=0,x=3,i=3,c=0" -t 31 test/hadamard.qcm
	./qcm -r "r1=0,r2=0,i=0,x=3" -t 5 test/majorana.qcm
	./qcm -r "r1=0,r2=0,i=1,x=3" -t 14 test/majorana.qcm
