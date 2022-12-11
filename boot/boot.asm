BITS 	16
ORG 	7C00h			; BootSector placed at 0x7C00

AsmExec:

	cli			; Disable Hardware Interrupts (PIT Issues)
	
LoadStage2:

	; if (DiskPacket.Sector == Stage2SectorsCount) goto SetupX86;
	mov	al, [DiskPacket.Count]
	cmp 	al, [DiskPacket.Sector]
	je	SetupX86

	mov	si, DiskPacket
	mov	ah, 42h
	int 	13h

	inc 	word [DiskPacket.Sector]
	add 	dword [DiskPacket.Address], 200h

	jmp 	LoadStage2	; Loop until break

SetupX86:

	; Fast A20 Line

	in 	al, 92h
	or 	al, 2
	out 	92h, al

	; Global Descriptor Table

	lgdt	[g_GDTDesc]

	; Enable Protection Mode
	
	mov 	eax, cr0
	or 	al, 1
	mov	cr0, eax

	; Far Jump to 16 * 8 + X86Entry

	jmp	8h:X86Entry


; 16-bit Globals

g_GDT:      ; NULL descriptor
            dq 0
        ; 0x08
            ; 32-bit code segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF for full 32-bit range
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10011010b                ; access (present, ring 0, code segment, executable, direction 0, readable)
            db 11001111b                ; granularity (4k pages, 32-bit pmode) + limit (bits 16-19)
            db 0                        ; base high
        ; 0x10
            ; 32-bit data segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF for full 32-bit range
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10010010b                ; access (present, ring 0, data segment, executable, direction 0, writable)
            db 11001111b                ; granularity (4k pages, 32-bit pmode) + limit (bits 16-19)
            db 0                        ; base high
        ; 0x18
            ; 16-bit code segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10011010b                ; access (present, ring 0, code segment, executable, direction 0, readable)
            db 00001111b                ; granularity (1b pages, 16-bit pmode) + limit (bits 16-19)
            db 0                        ; base high

            ; 16-bit data segment
            dw 0FFFFh                   ; limit (bits 0-15) = 0xFFFFF
            dw 0                        ; base (bits 0-15) = 0x0
            db 0                        ; base (bits 16-23)
            db 10010010b                ; access (present, ring 0, data segment, executable, direction 0, writable)
            db 00001111b                ; granularity (1b pages, 16-bit pmode) + limit (bits 16-19)
            db 0                        ; base high

g_GDTDesc:  dw g_GDTDesc - g_GDT - 1    ; limit = size of GDT
            dd g_GDT                    ; address of GDT


DiskPacket:
		db	10h
		db	0
		dw 	1
.Address:	dw	7E00h	; Modifiable data
		dw 	0
.Sector:	dd	1	; Modifiable data
		dd	0
.Count:	dw	(Stage2End - Stage2) / 512 + 1 + 1 ; Second +1 is added bcz of broken loop code


; X86 Code

BITS 32
X86Entry:
	
	; Fix segmentation
	
	mov ax, 0x10
    mov ds, ax
    mov es, ax
    mov fs, ax
    mov gs, ax
    mov ss, ax
	
	mov 	esp, 0xFFF0

	; Far Jump to C Code Stub
	jmp 	7E00h

times 510 - ($-$$) db 0
dw 0xAA55


Stage2: incbin './build/FNKLDR.SYS'
Stage2End:
times 512 - ($-$$) % 512 db 0