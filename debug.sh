#!/bin/sh

gdb -ex 'target remote localhost:1234' \
    -ex 'set tdesc filename target.xml' \
    -ex 'set architecture i386' \
    -ex 'set disassembly-flavor intel'
