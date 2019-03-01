;**************************************************************************
; EJERCICIO 1A PRÁCTICA 1
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT

CONTADOR	DB	?
TOME		DW	0CAFEH
ERROR1		DB	"Atención: Entrada de datos incorrecta."
TABLA100	DB	100 dup(?)


DATOS ENDS


;**************************************************************************
; DEFINICION DEL SEGMENTO DE PILA

PILA SEGMENT STACK "STACK"
	DB 40H DUP (0) 			;64 bytes inicializados a 0
PILA ENDS

;**************************************************************************
; DEFINICION DEL SEGMENTO EXTRA

EXTRA     SEGMENT 
    RESULT    DW 0,0                 ; 2 PALABRAS ( 4 BYTES ) 
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

	MOV BL, ERROR1[2H]
	MOV TABLA100[63H], BL
	
	MOV BX, TOME
	MOV	TABLA100[23H], BL
	MOV TABLA100[24H], BH
	
	MOV CONTADOR, BH
	

; FIN DEL PROGRAMA
	MOV AX, 4C00H
	INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 