	org 0x7c00
	
Baseofstack 	equ 	0x7c00
BaseofLoader	equ 	0x1000
OffsetOfLoader	equ 	0x00

RootDirSectors 				equ 	14
SectorNumOfRootDirStart		equ 	19
SectorNumOfFAT1Srart		equ		1
SectorBalance				equ		17

	jmp 	short Label_Start
	nop
	BS_OEMName			db	'MINEBOOT'
	BPB_BytesPersec		dw	512
	BPB_SecPerClus 		db 	1
	BPB_RsvdSecCnt 		dw 	1
	BPB_NumFATs			db	2
	BPB_RootEntCnt		dw	224	
	BPB_TotSec16		dw	2880
	BPB_Media			db	0xf0
	BPB_FATSz16			dw 	9
	BPB_SecPerTrk		dw 	18
	BPB_NumHeads		dw 	2
	BPB_hiddSec			dd	0
	BPB_TotSec32		dd	0
	BS_DrvNum			db 	0
	BS_Reserved1		db	0
	BS_BootSig			db	29h
	BS_VolID			dd	0
	BS_VolLab			db	'boot loader'
	BS_fileSysType		db	'FAT12	'

;=======		read one sector from floppy
Func_ReadOneSector:
	
	push 			bp
	mov				bp,			sp
	sub 			esp, 		2
;=======		以byte为单位将cl给[bp-2]地址的数据 栈是从栈顶（sp）开始的压入了一个bp 但是后面又push 没看懂
	mov 	byte	[bp - 2],	cl
	push 			bx
	mov				bl,			[BPB_SecPerTrk]
	div				bl
	inc 			ah
	mov 			cl,			ah
	mov 			dh,			al
	shr				al,			1
	mov				ch,			al
	and 			dh,			1
	pop				bx
	mov				dl,			[BS_DrvNum]
	
Label_Go_On_Reading:
;=======						
	mov				ah,			2
	mov				al,	byte	[bp - 2]
	int 			13h
	jc				Label_Go_On_Reading
	add				esp,		2
	pop				bp
	ret