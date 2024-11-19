ORG 0
BITS 16 

CODE_SEG equ gdt_code - gdt_start
DATA_SEG equ gdt_data - gdt_start
_start:
    jmp short start
    nop
 times 33 db 0

start:
	jmp 0:step2
	
step2:
    cli ; Clear Interrupts
    mov ax, 0x00
    mov ds, ax
    mov es, ax
    mov ss, ax
    mov sp, 0x7c00
    sti ; Enables Interrupts
.load_protected:
    cli
    lgdt[gdt_descriptor]
    mov eax, cr0
    or eax, 0x1
    mov cr0, eax
    jmp CODE_SEG:load32
    
; GDT
gdt_start:
gdt_null: ; null descriptor, which is essentially an empty segment descriptor that doesn't point to any valid memory.
    dd 0x0 
    dd 0x0

; offset 0x8

; code segment descriptor for the CPU. It allows execution in protected mode and points to the memory where your code will run.
gdt_code:     ; CS SHOULD POINT TO THIS
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0      ; Base first 0-15 bits
    db 0      ; Base 16-23 bits
    db 0x9a   ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0        ; Base 24-31 bits
; offset 0x10

; data segment descriptor, which is used for accessing variables and data in memory.
gdt_data:      ; DS, SS, ES, FS, GS
    dw 0xffff ; Segment limit first 0-15 bits
    dw 0      ; Base first 0-15 bits
    db 0      ; Base 16-23 bits
    db 0x92   ; Access byte
    db 11001111b ; High 4 bit flags and the low 4 bit flags
    db 0        ; Base 24-31 bits
gdt_end:
gdt_descriptor:
    dw gdt_end - gdt_start-1
    dd gdt_start
 
 ; Get into 32 bit protected mode 
[BITS 32]
load32:
    mov ax, DATA_SEG
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
    mov ebp, 0x00200000
    mov esp, ebp
    jmp $


times 510-($ - $$) db 0
dw 0xAA55

; steps to run

; cd bin, gdb
; remote target | qemu-system-x86_64 -hda boot.bin -S -gdb stdio
; c 
; ctrl + c 
; layout asm


; -S: Tells QEMU to stop execution immediately after loading the guest OS.
; -gdb stdio: Enables GDB debugging and connects it to the standard input/output of QEMU.
; layout asm: This is a GDB command that sets up the display layout to show assembly code. It helps you visualize the assembly code and debug it step-by-step.
