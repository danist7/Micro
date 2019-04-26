;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	SBM 2016. Practica 4 - Ejercicio4c						;
;   Daniel Santo-Tomás López								;
;   Lucía Rivas Molina 										;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

codigo SEGMENT
	ASSUME cs : codigo
	
	ORG 256
	

inicio:
	jmp instalar

; Variables globales
INST DB "DRIVER INSTALADO",13,10,'$'
DINST DB "DRIVER NO INSTALADO",13,10,'$'
MENSAJE DB "GRUPO 26, LUCIA RIVAS Y DANIEL SANTO-TOMAS",13,10,"EJECUTAR CON /I PARA INSTALAR EL DRIVER Y CON /D PARA DESINSTALARLO",13,10,'$'
INVERSA DB 256 dup (?) 
CONTADOR DB 0H
CARACTER DW 0H
ENTRADA DB 'PO','$'
MATRIZ_POLIBIO DB 'LMNOPQ', 'RSTUVW', 'XYZ012','345678', '9ABCDE', 'FGHIJK'
; Rutina de servicio a la interrupción
rsi PROC FAR
	
	push ax si cx bx dx  							; Guardamos los registros
	
	cmp CONTADOR,12H
	je traduce
	
	inc CONTADOR
	jmp final	
	
traduce:
	mov al, 0h
	mov CONTADOR, al
	
	mov si, CARACTER
	
	mov bh, 0h	
	mov bl, ENTRADA[si]
	inc CARACTER
	cmp bl, 24h				; Si en dl está el dolar, salta a desinstalar
	je desinstalar
	add bx, bx				; Multiplicamos por 2, hay dos elementos por posición
		
	mov dl, INVERSA[bx+1]		; Accedemos al primer número y lo imprimimos
	mov ah, 2 				; Imprimimos el caracter por pantalla
	int 21h 
		
	mov dl, INVERSA[bx]	; Accedemos al segundo número y lo imprimimos
	mov ah, 2 				; Imprimimos el caracter por pantalla
	int 21h 
	
final:

	pop dx bx cx si ax   
	iret	
	
desinstalar:
		
	mov cx, 0
	mov ds, cx
	mov es, ds:[1Ch*4+2]
	mov bx, es:[2Ch]
	
	mov ah, 49h
	int 21h
	mov es, bx
	int 21h
	
	cli
	mov ds:[1Ch*4], cx
	mov ds:[1Ch*4+2], cx
	sti
	
	pop dx bx cx si ax  
	
	
	

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
	mov es:[1Ch*4], ax 
	mov es:[1Ch*4+2], bx
	sti 
	mov dx, OFFSET instalar 
	int 27h ; Acaba y deja residente ; PSP, variables y rutina rsi. 
	
instalar ENDP

	



codigo ENDS 
END inicio