org 	10000h

	mov 	ax,		cs
	mov		ds,		ax
	mov		es, 	ax
	mov 	ax, 	0x00
	mov		ss,		ax
	mov		sp,		0x7c00
	
	
;========		display on screen : Srart Loader......

	mov		ax,		1301h
	mov 	bx,		000fh
	mov		dx,		0200h			;row 2
	mov 	cx,		34
	push 	ax,
	mov		ax,		ds
	mov		es,		ax
	pop		ax
	mov		bp,		StartLoaderMessage
	int 	10h
	
	jmp 	$
	
;=======		display message

StartLoaderMessage:		db		"Srart Loader(by xjc at 2020/12/21)"