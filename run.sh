#!/bin/sh
make

#qemu-system-i386 -fda image

qemu-system-i386 -s -S -fda image &
gdb -ex 'target remote localhost:1234' \
    -ex 'set tdesc filename target.xml' \
    -ex 'set architecture i8086' \
    -ex 'b *0x7c00' \
    -ex 'display /45i 0x7c19'

