all:	image

pbr.o:	pbr.S
	as -c -mx86-used-note=no pbr.S -o pbr.o

eopbr.o:	eopbr.S
	as -c -mx86-used-note=no eopbr.S -o eopbr.o

image: 	pbr.o eopbr.o
	ld -T sections.ld pbr.o eopbr.o -o image

clean:
	rm *.o image
