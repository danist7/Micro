;**************************************************************************
; PROGRAMA PARA CALCULAR EL DETERMINANTE DE UNA MATRIZ
; PRÁCTICA 2
; DANIEL SANTO-TOMÁS LÓPEZ
; LUCIA RIVAS MOLINA
;**************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

A	DB	1, 2, 3, -2, 3, 1, -1, -1, -1
Texto DB "Seleccione una opcion:",13,10, "1) Calcular el determinante con valores por defecto",13,10, "2) Calcular el determinante con valores introducidos por teclado", 13, 10, '$' 
OPCION DB 3 DUP(?) 		; Guarda la opcion escrita por teclado en OPCION[2]
NUMERO DB 3 DUP(?)		; Guarda los dígitos de un número
ESPACIOS DB 32, 32, 32, 32, 32
CONTADOR DB 0H
DATOS ENDS 


; DEFINICION DEL SEGMENTO DE PILA 

PILA    SEGMENT STACK "STACK" 
    DB   40H DUP (0) 
PILA ENDS 


; DEFINICION DEL SEGMENTO EXTRA 

EXTRA     SEGMENT 
    RESULT    DW 0,0                 ; 2 PALABRAS ( 4 BYTES ) 
EXTRA ENDS 


; DEFINICION DEL SEGMENTO DE CODIGO 

CODE    SEGMENT 
    ASSUME CS:CODE, DS:DATOS, ES: EXTRA, SS:PILA 

FACT_DATO_1  DW       0 

; COMIENZO DEL PROCEDIMIENTO PRINCIPAL 

START PROC NEAR
    ;INICIALIZA LOS REGISTROS DE SEGMENTO CON SUS VALORES 
    MOV AX, DATOS 
    MOV DS, AX 

    MOV AX, PILA 
    MOV SS, AX 

    MOV AX, EXTRA 
    MOV ES, AX 

    ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO 
    MOV SP, 64 

    ; FIN DE LAS INICIALIZACIONES 
	
	
	MOV DX, OFFSET Texto 		; DX = offset al inicio del texto a imprimir
	MOV AH, 9 					; Número de función = 9 para imprimir un string
	INT 21h 					; Imprime por pantalla que opcion debe escoger 
	
	MOV DX, OFFSET OPCION 		; Reservamos OPCION para la opcion introducida por teclado
	MOV AH, 0AH 				; Capturamos por teclado la opcion a ejecutar(1 o 2)
	MOV OPCION[0], 3 			; Lectura de caracteres máxima=60
	INT 21H 
	
	CMP BYTE PTR OPCION[2], 31H	; Vemos que opcion hemos elegido
	JE OP1 						; Si es 1 saltamos a OP1 y calculamos el determinante por defecto
			
OP2:

	
OP1:	
	CALL POS                    ; Llamamos a la función que calcula la parte positiva del determinante
	MOV DX, CX					; Copiamos el resultado de POS a DX 
	CALL NEGAT 					; Llamamos a la función que calcula la parte negativa del determinante 
	SUB DX, CX					; Restamos al resultado positivo el resultado negativo
	MOV CX, DX					; Almacenamos el resultado en CX

	
	MOV DX, OFFSET ESPACIOS
	MOV AH, 9
	INT 21H
	
	MOV BX , 00H					; Cargamos 0 en BX para comenzar el bucle de impresión 
	CALL IMPR
	
	
    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H 
	
START ENDP 
;______________________________________________________________________
; SUBRUTINA PARA CALCULAR LOS DÍGITOS DE UN NÚMERO EN ASCII
; ENTRADA AX
; SALIDA NUMERO[0] = SIGNO , NUMERO[1] = PRIMER DIGITO, 
; 		 NUMERO[2] = SEGUNDO DIGITO
;______________________________________________________________________
IMPR PROC NEAR
	MOV AH, 2
	MOV DL, '|'
	INT 21H
	
	MOV AL, 0H
	MOV CONTADOR, AL
	
BUCLE:	
	MOV AX, WORD PTR A[BX]
	CALL NUM
	
	
	MOV AH, 2
	MOV DL, NUMERO[0]			; Imprime el signo
	INT 21H
	
	MOV AH, 2
	MOV DL, NUMERO[1]			; Imprime el primer dígito
	INT 21H
	
	MOV AH, 2
	MOV DL, NUMERO[2]			; Imprime el segundo dígito
	INT 21H
	
	MOV AH, 2
	MOV DL, 32					; Imprime espacio
	INT 21H
	
	INC BX
	INC CONTADOR						; Incrementamos en uno el contador
	CMP CONTADOR, 03H					; Comparamos para ver el fin del bucle
	JNE BUCLE
	
	MOV AH, 2
	MOV DL, '|'					; Imprime la linea final
	INT 21H
	
	MOV AH, 2
	MOV DL, 10					; Salto de linea y return
	INT 21H
	RET
IMPR ENDP
;______________________________________________________________________
; SUBRUTINA PARA CALCULAR LOS DÍGITOS DE UN NÚMERO EN ASCII
; ENTRADA AX
; SALIDA NUMERO[0] = SIGNO , NUMERO[1] = PRIMER DIGITO, 
; 		 NUMERO[2] = SEGUNDO DIGITO
;______________________________________________________________________
NUM PROC NEAR 

	MOV SI, 0AH
	IDIV SI 					; Dividimos el número por 10
	ADD AH, 30H					; Pasamos a ASCII el resto
	MOV NUMERO[2], AH			; Lo copiamos en NUMERO[2]
	
	ADD AL, 30H					; Pasamos a ASCII el cociente
	MOV NUMERO[1], AL 			; Lo copiamos en NUMERO[1]
	RET

NUM ENDP 
;______________________________________________________________________
; SUBRUTINA PARA CALCULAR LA PARTE POSITIVA DEL DETERMINANTE
; ENTRADA 
; SALIDA CX=RESULTADO
;______________________________________________________________________
POS PROC NEAR 
	
    MOV AL, A[0h]				; Empezamos por la diagonal, las posiciones 0h,4h y 8h de la matriz
    IMUL A[4h]					; Multiplicamos A[0h] por A[4h], y se almacena el resultado en AX
	IMUL A[8h]			; Multiplicamos A[8h], casteandolo a word, por el resultado almacenado en AX. 
	MOV CX, AX					; El resultado queda almacenado en AX, con DX = 0 ya que los números son de 5 bits. Lo movemos a CX
	
	MOV AL, A[2h]				; Continuamos por los elementos 2h, 3h y 7h
    IMUL A[3h]					; Multiplicamos A[2h] por A[3h], y se almacena el resultado en AX
	IMUL A[7h]			; Multiplicamos A[7h], casteandolo a word, por el resultado almacenado en AX.
	ADD CX, AX					; Sumamos el resultado a CX, donde guardamos el resultado anterior
	
	MOV AL, A[1h]				; Finalizamos con los elementos 1h, 5h y 6h
    IMUL A[5h]					; Multiplicamos A[1h] por A[5h], y se almacena el resultado en AX
	IMUL A[6h]			; Multiplicamos A[6h], casteandolo a word, por el resultado almacenado en AX.
	ADD CX, AX					; Finalmente sumamos de nuevo a CX el resultado final
	RET
	
	
POS ENDP 

;______________________________________________________________________
; SUBRUTINA PARA CALCULAR LA PARTE NEGATIVA DEL DETERMINANTE
; ENTRADA 
; SALIDA CX=RESULTADO
;______________________________________________________________________
NEGAT PROC NEAR 
	
    MOV AL, A[2h]				; Empezamos por la diagonal, las posiciones 2h,4h y 6h de la matriz
    IMUL A[4h]					; Multiplicamos A[2h] por A[4h], y se almacena el resultado en AX
	IMUL A[6h]					; Multiplicamos A[6h], casteandolo a word, por el resultado almacenado en AX. 
	MOV CX, AX					; El resultado queda almacenado en AX, con DX = 0 ya que los números son de 5 bits. Lo movemos a CX
	
	MOV AL, A[1h]				; Continuamos por los elementos 1h, 3h y 8h
    IMUL A[3h]					; Multiplicamos A[1h] por A[3h], y se almacena el resultado en AX
	IMUL A[8h]					; Multiplicamos A[8h], casteandolo a word, por el resultado almacenado en AX.
	ADD CX, AX					; Sumamos el resultado a CX, donde guardamos el resultado anterior
	
	MOV AL, A[0h]				; Finalizamos con los elementos 0h, 5h y 7h
    IMUL A[5h]					; Multiplicamos A[0h] por A[5h], y se almacena el resultado en AX
	IMUL A[7h]					; Multiplicamos A[7h], casteandolo a word, por el resultado almacenado en AX.
	ADD CX, AX					; Finalmente sumamos de nuevo a CX el resultado final
	RET
	
	
NEGAT ENDP 

;______________________________________________________________________
; SUBRUTINA PARA CONVERTIR UN NÚMERO A ASCII
; ENTRADA 
; SALIDA 
;______________________________________________________________________
ASCII PROC NEAR
	
	

ASCII ENDP

; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END START 

