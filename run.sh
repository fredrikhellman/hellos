#!/bin/sh

make || exit 1

cat kernel /dev/stdin | qemu-system-i386 -fda image -serial chardev:char0 -chardev stdio,id=char0 

#gdb -ex 'target remote localhost:1234' \
#    -ex 'set tdesc filename target.xml' \
#    -ex 'set architecture i8086'
