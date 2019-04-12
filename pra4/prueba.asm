;**************************************************************************
; SBM 2019. ESTRUCTURA BÁSICA DE UN PROGRAMA EN ENSAMBLADOR
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT
	MATRIZ_POLIBIO DB 'LMNOPQ', 'RSTUVW', 'XYZ012','345678', '9ABCDE', 'FGHIJK'
	DATO DB '15141164536414'
DATOS ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA
PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) ;ejemplo de inicialización, 64 bytes inicializados a 0
PILA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA
EXTRA SEGMENT
	RESULT DW 0,0 ;ejemplo de inicialización. 2 PALABRAS (4 BYTES)
EXTRA ENDS
;**************************************************************************
; DEFINICION DEL SEGMENTO DE CODIGO
CODE SEGMENT
	ASSUME CS: CODE, DS: DATOS, ES: EXTRA, SS: PILA
; COMIENZO DEL PROCEDIMIENTO PRINCIPAL
INICIO PROC
; INICIALIZA LOS REGISTROS DE SEGMENTO CON SU VALOR
	MOV AX, DATOS
	MOV DS, AX
	MOV AX, PILA
	MOV SS, AX
	MOV AX, EXTRA
	MOV ES, AX
	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO
; FIN DE LAS INICIALIZACIONES
; COMIENZO DEL PROGRAMA
mov si, 0h
	bucle:
		mov bl, DATO[si]		; Guardamos los caracteres a traducir
		inc si
		mov bh, DATO[si]
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
		mov bl, bh
		mov bh, 0h
		add ax, bx				
		mov bx, ax				; Se guarda el resultado en bx
			
		mov dl, MATRIZ_POLIBIO[bx]		; Accedemos a la posición de la matriz dada por bx, y guardamos su contenido en dl (es un caracter ascii)
									
		mov ah, 2 				; Imprimimos el caracter por pantalla
		int 21h 
			
		jmp bucle
	fin:
	
; FIN DEL PROGRAMA
	MOV AX, 4C00H
	INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 