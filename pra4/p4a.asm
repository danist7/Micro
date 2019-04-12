;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	SBM 2016. Practica 4 - Ejercicio4a 						;
;   Daniel Santo-Tomás López								;
;   Lucía Rivas Molina 										;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
codigo SEGMENT
	ASSUME cs : codigo
	
	ORG 256
	
inicio: jmp instalador

; Variables globales
MATRIZ_POLIBIO DB 'LMNOPQ', 'RSTUVW', 'XYZ012','345678', '9ABCDE', 'FGHIJK'








; Rutina de servicio a la interrupción
rsi PROC FAR
	
	push 							; Guardamos los registros
	
	mov si, 4CH						; Movemos a si la L en ascii
	cmp AH, 11H
	je once
	
	 ; CODIFICACION A POLIBIO
	
		cmp ax, 41h					; Comparamos el valor con la A
		jl numero					; Si el valor es menor quiere decir que es un numero, luego salta a numero
		
		sub ax, si   				; Restamos a la posicion la L
		jns noneg					; Si la resta es positiva (ax > si) salta a noneg
		neg ax						; Si es negativa (ax < si) niega ax para que sea positivo		
		
	noneg:
		
		mov cl, 6h
		div cl					; Dividimos entre 6 para ver la columna (ah, resto) y fila (al, cociente)
		inc al						; Incrementamos la posición para imprimirlo bien
		inc ah 
		
	numero:
		
		mov si, 30h					; Inicializamos si a 0 porque estamos empezando por los numeros					
		sub ax, si					; Restamos el valor menos el 0
		mov cl, 6h
		div cl						; Dividimos entre 6 guardando fila en al y columna en ah 
		add al, 3h
		add ah, 3h
		
		div 
		
		
	; DECODIFICACION
	
	once:
		mov si, 0h
		bucle:
			mov bl, ds:[dx][si]		; Guardamos los caracteres a traducir
			inc si
			mov bh, ds:[dx][si]
			inc si 
			cmp bl, 24h				; Si en bl está el dolar, salta a fin
			je fin
			sub bl, 30h				; Pasa los numeros de ascii a decimal
			sub bh, 30h
			dec bl					; restamos uno para hacer los cálculos
			dec bh
			
			mov al, bl				; Multiplicamos la fila por 6 y la sumamos a la columna
			mov cl, 6h
			mul cl
			add ax, bh				
			mov bx, ax				; Se guarda el resultado en bx
			
			mov dl, MATRIZ_POLIBIO[bx]		; Accedemos a la posición de la matriz dada por bx, y guardamos su contenido en dl (es un caracter ascii)
									
			mov ah, 2 				; Imprimimos el caracter por pantalla
			int 21h 
			
			jmp bucle
	fin:
	
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