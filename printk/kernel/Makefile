all: system
	objcopy -I elf64-x86-64 -S -R ".eh_frame" -R ".comment" -O binary system kernel.bin
	
system:	head.o main.o printk.o
	ld -b elf64-x86-64 -z muldefs -o system head.o main.o printk.o -T Kernel.lds 
	
main.o: main.c
	gcc -mcmodel=large -fno-builtin -m64 -c main.c

head.o: head.S
	gcc -E head.S > head123.s
	as --64 -o head.o head123.s
		
printk.o: printk.c
	gcc  -mcmodel=large -fno-stack-protector -m64 -c printk.c
	
clean:
	rm -rf *.o *.s *.S~ *.c~ .h~ system Makefile~ Kernel.lds~ kernel.bin
