		org 	0x7c00
	
	BaseOfStack	equ 0x7c00
	
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
		
		jmp 	$
		
		
	StartMootMessage:	db 		"Start Boot(by xjc at 2020/12/17)"
	
	;======= 	fill zero until while sector
	
		times 	510 - ( $ - $$ ) 	db 	0
	;=======	Intel 小端模式 所以 0xaa55
		dw 	0xaa55
		