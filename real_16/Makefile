all:
	nasm -f bin boot_modify.asm -o boot_modify.bin
	dd if=message.txt >> boot_modify.bin
	dd if=/dev/zero bs=512 count=1 >> boot_modify.bin
