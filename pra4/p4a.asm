codigo SEGMENT
	ASSUME cs : codigo
	
	ORG 256
	
inicio: jmp instalador

; Variables globales
PB1 DB 'L M N O P Q'
PB2 DB 'R S T U V W'
PB3 DB 'X Y Z 0 1 2' 
PB4 DB '3 4 5 6 7 8'
PB5 DB '9 A B C D E'
PB6 DB 'F G H I J K'



; Rutina de servicio a la interrupción
rsi PROC FAR
	; Salva registros modificados
	push ... ; Instrucciones de la rutina ... ; Recupera registros modificados
	
	mov si, 4CH						; Movemos a si la L en ascii
	cmp AH, 11H
	je once
	
	bucle: 
		
	
	
	
	once: ; CODIFICACION A POLIBIO
	
		sub ax, si   				; Restamos a la posicion la L
		jns noneg					; Si la resta es positiva (ax > si) salta a noneg
		neg ax						; Si es negativa (ax < si) niega ax para que sea positivo		
		
	noneg:
		div 6h						; Dividimos entre 6 para ver la columna (ah, resto) y fila (al, cociente)
		inc al						; Incrementamos la posición para imprimirlo bien
		inc ah
		; aqui saltara para que continue el bucle pero primero hay que implementar lo demas
	
	diez: ; DECODIFICACION
	
		; para esto si vamos a necesitar la tabla je
	
	
	pop ... iret
rsi ENDP


instalador PROC
	mov ax, 0
	mov es, ax
	mov ax, OFFSET rsi
	mov bx, cs
	cli
	mov es:[ 57h*4 ], ax 
	mov es:[ 57h*4+2 ], bx
	sti mov dx, OFFSET instalador 
	int 27h ; Acaba y deja residente ; PSP, variables y rutina rsi. 
	
instalador ENDP
codigo ENDS 
END inicio