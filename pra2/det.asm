;**************************************************************************
; PROGRAMA PARA CALCULAR EL DETERMINANTE DE UNA MATRIZ
; PRÁCTICA 2
; DANIEL SANTO-TOMÁS LÓPEZ
; LUCIA RIVAS MOLINA
;**************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

A	DB	1, 2, 3, -2, 3, 1, -1, -1, -1

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
	
	CALL POS

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
	MOV CX, AX							; El resultado queda almacenado en AX, con DX = 0 ya que los números son de 5 bits. Lo movemos a CX
	RET
	
	
POS ENDP 

; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END START 

