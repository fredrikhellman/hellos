	.intel_syntax noprefix
	.code16
	.text
_start:
	call _free_mem
	mov ax, 0x1000
	mov es, ax
	mov di, 0x0
	call _read_kernel
	mov eax, 0x10000
	jmp _protected_mode
	
// print ASCII char in al
_print_char:
	push ax
	push bx
	mov ah, 0xe
	mov bh, 0
	mov bl, 1
	int 0x10
	pop bx
	pop ax
	ret

// print null terminated ASCII string in ds:si
_print_string:
	push ax
	push si
	cld
_print_string_loop:	
	lodsb
	test al, al
	jz _print_string_end
	call _print_char
	jmp _print_string_loop
_print_string_end:
	pop si
	pop ax
	ret

// print the word in ax as a hexadecimal number
_print_byte_hex:
	pusha
	mov bl, al
	mov cx, 2
_print_word_hex_next:
	rol bl, 4
	mov al, bl
	and al, 0xF
	cmp al, 0xA
	jle _print_word_hex_digit
	add al, 0x27
_print_word_hex_digit:	
	add al, 0x30
	call _print_char
	loop _print_word_hex_next
	popa
	ret

_print_word_hex:
	push ax
	rol ax, 8
	call _print_byte_hex
	rol ax, 8
	call _print_byte_hex
	pop ax
	ret

_print_dword_hex:
	push eax
	rol eax, 16
	call _print_word_hex
	rol eax, 16
	call _print_word_hex
	pop eax
	ret
	
_free_mem:
	pushad
	push es
	
	// Clear ebx for first call
	xor ebx, ebx
_free_mem_next:
	mov eax, 0xe820
	// Setup "magic" numbers for the call
	mov edx, 0x534d4150
	mov cx, ds
	mov es, cx
	mov ecx, 24
	mov di, offset _free_mem_address
	int 0x15
	// Check for error
	jc _error
	cmp eax, 0x534d4150
	jne _error
	jmp _free_mem_ok
_free_mem_address:
	.skip 8
_free_mem_size:
	.skip 8
_free_mem_type:
	.skip 4
_free_mem_acpi3:
	.skip 4
_free_mem_ok:
	// ebx tells if this is the last entry in the list, keep it
	// Print addr
	mov si, offset _free_mem_msg_addr
	call _print_string
	mov eax, _free_mem_address+4
	call _print_dword_hex
	mov eax, _free_mem_address
	call _print_dword_hex
	mov al, ' '
	call _print_char

	// Print size
	mov si, offset _free_mem_msg_size
	call _print_string
	mov eax, _free_mem_size+4
	call _print_dword_hex
	mov eax, _free_mem_size
	call _print_dword_hex
	mov al, ' '
	call _print_char
	
	// Print type
	mov si, offset _free_mem_msg_type
	call _print_string
	mov eax, _free_mem_type
	call _print_byte_hex
	
	mov al, '\r'
	call _print_char
	mov al, '\n'
	call _print_char

	// Check for next entry
	test ebx, ebx
	jnz _free_mem_next
	
_free_mem_nonzero:
	pop es
	popad
	ret
_free_mem_msg_addr:
	.ascii "a: "
	.byte 0
_free_mem_msg_size:
	.ascii "s: "
	.byte 0
_free_mem_msg_type:
	.ascii "t: "
	.byte 0

	.set PORT, 0x3f8
_read_kernel:
	pushad

	// ebx is byte count
	mov ebx, 0
	
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

	// Read until the EOK message arrives
_read_kernel_reset_eok:
	mov cl, 0x30
_read_kernel_wait:
	mov dx, PORT + 5
	inb al, dx
	test al, 0xe
	jnz _error
	test al, 1
	jz _read_kernel_wait

	// Data is waiting
	mov dx, PORT
	inb al, dx

	inc ebx
	
	// Store byte in ds:di
	stosb

	// Check for EOK message
	// Need to restore DS register temporarily
	cmp al, cl
	je _read_kernel_is_eok
	jmp _read_kernel_reset_eok
_read_kernel_is_eok:
	inc cl
	cmp cl, 0x3a
	je _read_kernel_done
	jmp _read_kernel_wait
_read_kernel_done:
	// Print byte
	mov si, offset _read_kernek_msg
	call _print_string
	
	mov eax, ebx
	call _print_word_hex
	popad
	ret
_read_kernek_msg:
	.ascii "kernel size: "
	.byte 0
	
_protected_mode:
	mov si, offset _protected_mode_msg
	call _print_string
	
	cli
	mov dword ptr [_gdtr_address], offset _gdt
	lgdt [_gdtr]

	push eax
	mov eax, cr0 
	or al, 1
	mov cr0, eax
	pop eax
	
	jmp 0x8:_protected_mode_jump
	.code32
	.align 8
_protected_mode_jump:
	mov bx, 0x10
	mov ds, bx
	mov es, bx
	mov fs, bx
	mov gs, bx
	mov ss, bx
	jmp eax
	.code16
 	
_gdtr:
_gdtr_limit:
	.word _gdt_end - _gdt
_gdtr_address:
	.long 0
_gdt:
	.long 0
	.long 0
	// 0x00|c|f 9b|00  0000 ffff
	//   ba|f|l ab|ba  base  lim
	//      P  DPL  S E DC? RW A
	// ab = 1  0 0  1 1  0  1  1 = 9b
	//      G DB L R
	//  g = 1 1  0 1 = d
	// lim = 0xfffff
	.long 0x0000ffff
	.long 0x00cf9b00
	// 0x00|c|f 9b|00  0000 ffff
	//   ba|f|l ab|ba  base  lim
	//      P  DPL  S E DC? RW A
	// ab = 1  0 0  1 0  0  1  1 = 93
	//      G DB L R
	//  g = 1 1  0 1 = d
	// lim = 0xfffff
	.long 0x0000ffff
	.long 0x00cf9300
_gdt_end:

_protected_mode_msg:
	.ascii "\n\rpm\n\r"
	.byte 0
	
_error:
	mov si, offset _msg_fail
	call _print_string
	jmp _infloop
	
_msg_fail:
	.ascii "fail"
	.byte 0
	
_infloop:
	jmp _infloop
