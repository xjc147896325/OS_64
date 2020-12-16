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
