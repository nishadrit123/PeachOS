ORG 0x7c00 ; make starting address of the program to that of boot loader (7c00 by default)
BITS 16 ; use 16 bit (real mode where on 1 MB of RAM is accessible with no security)

start:
    mov si, message ; pointer to data in memory (hello world in this case)
    call print
    jmp $ ; An infinite loop to avoid halt after printing hello world on qemu screen

print:
    mov bx, 0
.loop:
    lodsb ; loads next char(byte) from memory address pointed to by SI register into al register and increment SI by 1
    cmp al, 0 ; compares al with 0 (null terminator \0) to check end of string
    je .done ; exit loop is above condition is true 	
    call print_char 
    jmp .loop ; jump back to .loop to process next char 
.done:
    ret

print_char:
    mov ah, 0eh ; used to create chars in text mode to the screen 
    int 0x10 ; invokes BIOS interrupt to print chars 
    ret

message: db 'Hello World from "NISHAD"', 0 ; define byte (db) used to declare data

times 510-($ - $$) db 0 
; We use 16 bit (2 byte) mode here and a std bootloader file is 512 bytes large, this line ensures to fill remaining 510 bytes with 0x00 ($: current address $$: start address)


dw 0xAA55
; data write (dw) bootloader signature 55AA at the end of 512 sector to help BIOS identiy that the disk as bootable device
; Since little endian is used by intel, AA55 will actually be written as 55AA





; TO RUN: 
	; nasm -f bin boot.asm -o boot.bin
	; qemu-system-x86_64 -hda boot.bin
	
	; -f bin (flat binary) to load binary file directly into the memory without special parsing or reloacation
	; -hda to tell QEMU to treat boot.bin as a hard disk image 
