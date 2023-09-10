	.intel_syntax noprefix
	.code16
	.text
_start:
	mov si, offset _free_mem_msg
	call _print_string
	call _free_mem
	jmp _infloop
	
	xor ch, ch
	mov ax, cx
	call _print_word_hex
	mov ax, bx
	call _print_word_hex
	mov si, offset _free_mem_kb_msg
	call _print_string
	jmp _infloop
	
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
	pushf
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
	popf
	ret

// print the word in ax as a hexadecimal number
_print_byte_hex:
	pushf
	push ax
	push bx
	push cx
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
	pop cx
	pop bx
	pop ax
	popf
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
	rol eax,16
	call _print_word_hex
	rol eax,16
	call _print_word_hex
	pop eax
	ret
	
_free_mem:
	pushf
	push eax
	push ebx
	push ecx
	push edx
	push es
	push di

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
	jc _free_mem_error
	cmp eax, 0x534d4150
	jne _free_mem_error
	jmp _free_mem_ok
_free_mem_error:
	mov si, offset _free_mem_msg_error
	call _print_string
	jmp _infloop
_free_mem_msg_error:
	.ascii "Failed to get free mem."
	.byte 0
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
	pop di
	pop es
	pop edx
	pop ecx
	pop ebx
	pop eax
	popf
	ret
_free_mem_msg_addr:
	.ascii "addr: "
	.byte 0
_free_mem_msg_size:
	.ascii "size: "
	.byte 0
_free_mem_msg_type:
	.ascii "type: "
	.byte 0
	
_free_mem_msg:
	.ascii "memory:\r\n"
	.byte 0

_free_mem_kb_msg:
	.ascii " kiB"
	.byte 0
	
_infloop:
	jmp _infloop
