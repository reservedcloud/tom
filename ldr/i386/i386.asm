global TestX86
TestX86:
    BITS 32

    ; disable hardware int
    cli

    ; far jump
    jmp 0x18:.pMode16

.pMode16:
    BITS 16

    ; unset cr0.PE
    mov eax, cr0
    and al, ~1
    mov cr0, eax

    ; real mode jump
    jmp 0x00:.realMode

.realMode:

    ; zero segments
    mov ax, 0
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax

    sti

    mov ah, 0x0E
    mov al, 'D'
    int 0x10
    
loop:
    jmp loop
