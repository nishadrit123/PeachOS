ORG 0
BITS 16 

_start:
	jmp short start 
	nop
	
times 33 db 0 ; bios paramter block (33) to fill 33 bytes with 0 after short jump to avoid data corruption 

start:
	jmp 0x7c0: step2
	
; play around with IVT (interrupt vector table) 
handle_zero:
	mov ah, 0eh
	mov al, '0'
	mov bx, 0x00
	int 0x10
	iret 
handle_one:
	mov ah, 0eh
	mov al, '1'
	mov bx, 0x00
	int 0x10
	iret 

step2: 	
	cli ; clear interrupts
	
	mov ax, 0x7c0
	mov ds, ax
	mov es, ax
	mov ax, 0x00
	mov ss, ax
	mov sp, 0x7c00	
	
	sti ; enable interrupts
	
	; IVT start from 0x00 (int 0)with first 2 bytes for offset and next 2 for segment and so on..
	mov word[ss: 0x00], handle_zero
	mov word[ss: 0x02], 0x7c0
	
	mov word[ss: 0x04], handle_one
	mov word[ss: 0x06], 0x7c0
	
	; call the interrupt
	int 0
	int 1
	
	; Read from Hard Disk 
	mov ah, 2 ; read sector command
	mov al, 1 ; read 1 sector
	mov ch, 0 ; cylinder low 8 bits
	mov cl, 2 ; read sector 2
	mov dh, 0 ; head number
	mov bx, buffer
	int 0x13 ; interrupt to read from a hard disk sector
	jc error ; jmp in case of any error
	mov si, buffer
	call print
	jmp $
	
error:
	mov si, error_message
	call print
	jmp $

print:
    mov bx, 0
.loop:
    lodsb 
    cmp al, 0 
    je .done 
    call print_char 
    jmp .loop 
.done:
    ret

print_char:
    mov ah, 0eh
    int 0x10 
    ret

error_message: db 'Error reading from hard disk', 0 

times 510-($ - $$) db 0 
dw 0xAA55

buffer:

; here all the segment registers (ds, ex, ss) are initialised to ensure proper memory management making the code more robust and sp provides bootloader with a known stack area
; bless ./boot_modify.bin to see the message from txt file written to the disk sector 2
