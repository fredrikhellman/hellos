	.intel_syntax noprefix
	.code32
	.text
_start:
	// stack pointer not set up
	call _serial_init
	mov al, 'O'
	call _serial_write_char
	
	.set PORT, 0x3f8
_serial_init:
	pushf
	push ax
	push dx

	// Disable serial port interrupts
	mov al, 0x00
	mov dx, PORT + 1
	out dx, al

	// Set baud rate to maximum
	mov al, 0x80
	mov dx, PORT + 3
	out dx, al
	
	mov al, 0x01
	mov dx, PORT
	out dx, al

	mov al, 0x00
	mov dx, PORT + 1
	out dx, al

	// Set 8N1
	mov al, 0x03
	mov dx, PORT + 3
	out dx, al

	// Not sure what this is
	mov al, 0x0F
	mov dx, PORT + 4
	out dx, al

	pop dx
	pop ax
	popf
	ret
	
	// Read until the EOK message arrives
_serial_write_char:
	push ax
	push bx
	push dx
	mov bl, al
	
	mov dx, PORT + 5
_serial_write_wait:
	inb al, dx
	test al, 0xe
	jnz _error
	test al, 0x20
	jz _serial_write_wait

	// Data can be transmitted
	mov al, bl
	mov dx, PORT
	outb dx, al

	pop dx
	pop bx
	pop ax
	ret
	
_error:	
_infloop:
	jmp _infloop
