#!/bin/sh

make || exit 1

#qemu-system-i386 -fda image

#qemu-system-i386 -s -S -fda image -serial chardev:io -chardev pipe,id=io,path=io &
#cat kernel > io.in
#gdb -ex 'target remote localhost:1234' \
#    -ex 'set tdesc filename target.xml' \
#    -ex 'set architecture i8086'

cat kernel /dev/stdin | qemu-system-i386 -fda image -serial chardev:char0 -chardev stdio,id=char0 
