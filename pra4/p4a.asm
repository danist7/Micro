;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	SBM 2016. Practica 4 - Ejercicio4a 						;
;   Daniel Santo-Tomás López								;
;   Lucía Rivas Molina 										;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

codigo SEGMENT
	ASSUME cs : codigo
	
	ORG 256
	

inicio:
	mov cx, ds:[82h]						; Guardamos los posibles parámetros de entrada
	
	mov ax, 0
	mov es, ax
	mov bx, es:[ 57h*4 ]			;Comprobamos si el driver está instalado
	cmp bx, 0h
	je noinst						; Si no está instalado, saltamos	
	
	mov ax,4B4AH					; Comprobamos la firma para saber si está realmente instalado
	cmp ax, cs:[bx-2]
	jne noinst						; Si la firma es incorrecta, saltamos(no está instalado)
	mov dx, OFFSET INST				; Guardamos el mensaje de ya instalado en DX
	
	cmp cl , 2Fh					; Si no hay parámetros de entrada, saltamos a la impresión
	jne texto
	cmp ch, 44h						; Si el parámetro es para desinstalar , saltamos a la rutina	
	jne texto
	jmp desinstalar					; En otro caso , saltamos a la impresión 
	jmp fin
	
	noinst:
		mov dx, OFFSET DINST 		; Guardamos el mensaje de no instalado en DX
		cmp cl , 2Fh				; Si no hay parámetros de entrada, saltamos a la impresión
		jne texto
		cmp ch, 49h					; Si el parámetro es para instalar , saltamos a la rutina	
		jne texto
		jmp instalar
		
		
	texto:
		MOV AH, 9 					;Imprimimos el mensaje de instalado o no instalado
		INT 21h 		
	
		MOV DX, OFFSET MENSAJE 		; Imprimimos el resto y salimos
		MOV AH, 9 					
		INT 21h 			
	
	fin:
		MOV AX, 4C00H
		INT 21H

; Variables globales
INST DB "DRIVER INSTALADO",13,10,'$'
DINST DB "DRIVER NO INSTALADO",13,10,'$'
MENSAJE DB "GRUPO 12, LUCIA RIVAS Y DANIEL SANTO-TOMAS",13,10,"EJECUTAR CON /I PARA INSTALAR EL DRIVER Y CON /D PARA DESINSTALARLO",13,10,'$'
INVERSA DB 256 dup (?)
MATRIZ_POLIBIO DB 'LMNOPQ', 'RSTUVW', 'XYZ012','345678', '9ABCDE', 'FGHIJK'
; Rutina de servicio a la interrupción
rsi PROC FAR
	
	push ax si cx bx dx  							; Guardamos los registros
	
		
	cmp AH, 11H
	je once
	cmp AH, 10h
	jne final
	
	mov bx,dx
	mov dl, ds:[bx]	
	mov dh, 0h
	mov si,dx
	add si, si
	mov dl ,INVERSA[si]
	mov ah, 2 				; Imprimimos el caracter por pantalla
	int 21h

	mov dl ,INVERSA[si+1]
	mov ah, 2 				; Imprimimos el caracter por pantalla
	int 21h
	jmp final
	
	once:
		mov bx,dx
		bucle:
			mov dl, ds:[bx]		; Guardamos los caracteres a traducir
			inc bx
			mov dh, ds:[bx]
			inc bx
			cmp dl, 24h				; Si en dl está el dolar, salta a fin
			je final
			sub dl, 30h				; Pasa los numeros de ascii a decimal
			sub dh, 30h
			dec dl					; restamos uno para hacer los cálculos
			dec dh
			
			mov al, dl				; Multiplicamos la fila por 6 y la sumamos a la columna
			mov cl, 6h
			mul cl
			mov dl, dh
			mov dh, 0h
			add ax, dx				
			mov si, ax				; Se guarda el resultado en si
			
			mov dl, MATRIZ_POLIBIO[si]		; Accedemos a la posición de la matriz dada por si, y guardamos su contenido en dl (es un caracter ascii)
									
			mov ah, 2 				; Imprimimos el caracter por pantalla
			int 21h 
			
			jmp bucle
	final:
	
	pop dx bx cx si ax   
	iret
rsi ENDP


instalar PROC FAR
	
	mov si, 0h
	mov al, 31h
	mov ah, 31h
	bucle2:
		mov bx, 0h
		mov bl, MATRIZ_POLIBIO[si]			; Guardamos la letra cuya codificación vamos a guardar
		add bl, bl							; Multiplicamos por dos, ya que por cada letra hay dos numeros de un byte
		inc si
		
		mov INVERSA[bx], al
		mov INVERSA[bx+1],ah
		inc al
		cmp al, 37h
		jne bucle2
		cmp ah, 36h
		je fuera
		mov al, 31h
		inc ah
		jmp bucle2
		
fuera:
				
	mov ax, 0
	mov es, ax
	mov ax, OFFSET rsi
	mov bx, cs
	cli
	mov es:[57h*4], ax 
	mov es:[57h*4+2], bx
	sti 
	mov dx, OFFSET instalar 
	int 27h ; Acaba y deja residente ; PSP, variables y rutina rsi. 
	
instalar ENDP

desinstalar PROC FAR
	push ax bx cx ds es
	
	mov cx, 0
	mov ds, cx
	mov es, ds:[57h*4+2]
	mov bx, es:[2Ch]
	
	mov ah, 49h
	int 21h
	mov es, bx
	int 21h
	
	cli
	mov ds:[57h*4], cx
	mov ds:[40h*4+2], cx
	sti
	
	pop es ds cx bx ax
	
	MOV AX, 4C00H
	INT 21H
	
	
	
desinstalar ENDP

codigo ENDS 
END inicio