all:	image kernel

pbr.o:	pbr.S
	as -c -mx86-used-note=no pbr.S -o pbr.o

eopbr.o:	eopbr.S
	as -c -mx86-used-note=no eopbr.S -o eopbr.o

%.o: %.c
	gcc -c -m32 -fno-stack-protector -fno-pie -nostdlib $^ -o $@

eok.o:	eok.S
	as -c --32 -mx86-used-note=no eok.S -o eok.o

image: 	pbr.o eopbr.o
	ld -T boot_sections.ld pbr.o eopbr.o -o image

kernel: kernel.o eok.o serial.o panic.o
	ld -melf_i386 --orphan-handling=discard -T kernel_sections.ld $^ -o $@

clean:
	rm *.o image kernel
