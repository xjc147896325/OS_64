	org 	0x7c00

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

Label_Start:

	mov 	ax, 	cs
	mov		ds, 	ax
	mov 	es, 	ax
	mov 	ss, 	ax
	mov 	sp,		BaseOfStack
	
;======  	clear screen

	mov 	ax, 	0600h
	
; It doesn't work
	mov 	bx, 	0700h
	mov 	cx, 	0
	mov 	dx, 	8484h
; finish
	int 	10h

;=======	set foucs

	mov 	ax, 	0200h
	mov 	bx,		0000h
	mov 	dx, 	0000h
	int 	10h
	
;=======	display on screen : Start Booting......

	mov 	ax, 	1301h
; flash
	mov 	bx, 	000fh
	mov 	dx, 	0000h
	mov 	cx, 	32
	push 	ax
	mov 	ax, 	ds
	mov 	es,		ax
	pop 	ax
	mov 	bp, 	StartMootMessage
	int 	10h
	
;=======	reset floopy
	
	xor 	ah, 	ah
	xor 	dl, 	dl
	int 	13h
	
;=======		search loader.bin
	mov		word	[SectorNo],	SectorNumOfRootDirStart
	
Label_Search_In_Boot_Dir_Begin:
	
	cmp 	word	[RootDirSizeForLoop],	0
	jz				Label_No_LoaderBin
	dec		word	[RootDirSizeForLoop]
	mov				ax,						00h
	mov				es,						ax
	mov				bx,						8000h
	mov				ax,						[SectorNo]
	mov				cl,						1
	call 			Func_ReadOneSector
	mov				si,						LoaderFileName
	mov				di,						8000h
	cld
	mov				dx,						10h
	
Label_Search_For_LoaderBin:

	cmp				dx,			0
	jz				Label_Goto_Next_Sector_In_Root_Dir
	dec				dx
	mov				cx,			11
	
Label_Cmp_FileName:

	cmp				cx,			0
	jz				Label_FileName_Found
	dec				cx
	lodsb
;		以es为基址，di为偏移量的地址指向的数据与al比较
	cmp				al,	byte	[es:di]
	jz 				Label_Go_On
	jmp				Label_Different
	
Label_Go_On:

	inc				di;
	jmp				Label_Search_For_LoaderBin
	
Label_Different:

	and				di,			0ffe0h
	add				di,			20h
	mov				si,			LoaderFileName
	jmp				Label_Search_For_LoaderBin

Label_Goto_Next_Sector_In_Root_Dir:
	
	add 	word	[SectorNo],	1
	jmp				Label_Search_In_Boot_Dir_Begin
	
;=======	display on screen ; ERROR: No LOADER Found

Label_No_LoaderBin:
	
	mov				ax,			1301h
	mov				bx,			008ch
	mov				cx,			22
	mov				dx,			0100h
	push 			ax
	mov				ax,			ds
	mov				es,			ax
	pop				ax
	mov				bp,			NoLoaderMessage
	int				10h
	jmp				$
	
;=======	found loader.bin name in root director struct
Label_FileName_Found:
	
	mov				ax,			RootDirSectors
	and				di,			0ffe0h
	add				di,			01ah
	mov				cx,	word	[es:di]
	push 			cx
	add				cx,			ax
	add				cx,			SectorBalance
	mov				ax,			BaseofLoader
	mov				es,			ax
	mov				bx,			OffsetOfLoader
	mov				ax,			cx
	
Label_Go_On_Loading_File:
	push			ax
	puah			bx
	mov				ah,			0eh
	mov				al,			'%'
	mov				bl,			0fh
	int				10h
	pop				bx
	pop				ax
	
	mov				cl,			1
	call			Func_ReadOneSector
	pop				ax
	call			Func_GetFATEntry
	cmp				ax,			0fffh
	jz				Label_File_Loaded
	push 			ax
	mov				dx,			RootDirSectors
	add				ax,			dx
	add				ax,			SectorBalance
	add				bx,			[BPB_BytesPersec]
	jmp				Label_Go_On_Loading_File
	
Label_File_Loaded:

	jmp				$

;=======		read one sector from floppy
Func_ReadOneSector:
	
	push 			bp
	mov				bp,			sp
;		sub 减法 dec 减法 inc加法 （1）
	sub 			esp, 		2
;		以byte为单位将cl给[bp-2]地址的数据 栈是从栈顶（sp）开始的压入了一个bp 但是后面又push 没看懂
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

;=======	get FAT Entry

Func_GetFATEntry:
	
	push 			es
	push			bx
	push			ax
	mov				ax,			00
	mov				es,			ax
	pop				ax
	mov		byte	[Odd],		0
	mov				bx,			3
	mul				bx
	mov				bx,			2
	div				bx
	cmp				dx,			0
	jz				Label_Even
	mov		byte	[Odd],		1

Label_Even:
;======= 	清零dx，以及进位标志等 
	xor				dx,			dx
	mov				bx,			[BPB_BytesPersec]
	div				bx
	push			dx
	mov				bx,			8000h
	add				ax,			SectorNumOfFAT1Srart
	mov				cl,			2
	call			Func_ReadOneSector
	
	pop				dx
	add				bx,			dx
	mov				ax,			[es:bx]
	cmp		byte	[Odd],		1
	jnz				Label_Even_2
	shr				ax,			4
	
Label_Even_2:
	and				ax,			0fffh
	pop				bx
	pop				es
	ret
;========= 希望下次看到的时候可以把吃屎的FAT12换成更好的FAT16

	
;=========	tmp variable

RootDirSizeForLoop	dw	RootDirSectors
SectorNo			dw	0
Odd					db	0

;=========	display messages

StartMootMessage:	db 		"Start Boot(by xjc at 2020/12/17)"
NoLoaderMessage:	db		"ERROR: No LOADER Found"
LoaderFileName:		db		"LOADER  Bin",0

;======= 	fill zero until while sector

	times 	510 - ( $ - $$ ) 	db 	0
;=======	Intel 小端模式 所以 0xaa55
	dw 	0xaa55
