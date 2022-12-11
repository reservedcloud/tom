CC=gcc -O2 -m32 -fno-stack-protector -fno-builtin -fno-asynchronous-unwind-tables \
         -nostdlib -nostdinc -fno-PIC -fno-PIE -Wall -Wextra -I.
AS = nasm
LD=ld -m elf_i386

KERNEL := build/FNKLDR.SYS

OBJ := ldr

CFILES := $(shell find ldr/ -type f -name '*.c')
ASMFILES = $(shell find ldr/ -type f -name '*.asm' -not -path "ldr/i386/Stage.asm")

OBJ = $(CFILES:.c=.o)
OBJ += $(ASMFILES:.asm=_asm.o)

.PHONY: all

all: Stage $(KERNEL) boot clean

boot: $(KERNEL)
	$(AS) boot/boot.asm -o build/boot.bin

Stage:
	$(AS) -felf32 ldr/i386/Stage.asm -o ldr/i386/Stage_asm.o

$(KERNEL): $(OBJ)
	$(LD) -T build/linker.ld -o $(KERNEL) ldr/i386/Stage_asm.o $(OBJ)
	objcopy -j .text -O binary $(KERNEL) $(KERNEL)

%.o: %.c
	$(CC) -c $< -o $@

%_asm.o: %.asm
	$(AS) $^ -f elf32 -o $@

clean: $(KERNEL)
	rm -f build/*.SYS
	#rm -f build/*.bin
	rm -f ldr/*.o
	rm -f ldr/i386/*.o
	rm -f ldr/*.SYS
