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
	
	MOV AH,0AH 					; Capturamos por teclado la opcion a ejecutar(1 o 2)
	MOV DX, OFFSET OPCION 		; Reservamos OPCION para la opcion introducida por teclado
	MOV OPCION[0],3 			; Lectura de caracteres máxima=60
	INT 21H 
	
	CMP OPCION[2], 1h			; Vemos que opcion hemos elegido
	JE OP1 						; Si es 1 saltamos a OP1 y calculamos el determinante por defecto
	JMP OP2						; Si no es 1 (es 2) saltamos a OP2 y le pide la matriz por teclado
	
OP2:

	
OP1:	
	CALL POS                    ; Llamamos a la función que calcula la parte positiva del determinante
	MOV DX, CX					; Copiamos el resultado de POS a DX 
	CALL NEGAT 					; Llamamos a la función que calcula la parte negativa del determinante 
	SUB DX, CX					; Restamos al resultado positivo el resultado negativo

    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H 

START ENDP 
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

