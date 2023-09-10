all:	image kernel

pbr.o:	pbr.S
	as -c -mx86-used-note=no pbr.S -o pbr.o

eopbr.o:	eopbr.S
	as -c -mx86-used-note=no eopbr.S -o eopbr.o

kernel.o:	kernel.S
	as -c -mx86-used-note=no kernel.S -o kernel.o

eok.o:	eok.S
	as -c -mx86-used-note=no eok.S -o eok.o

image: 	pbr.o eopbr.o
	ld -T boot_sections.ld pbr.o eopbr.o -o image

kernel: kernel.o eok.o
	ld -T kernel_sections.ld kernel.o eok.o -o kernel

clean:
	rm *.o image
