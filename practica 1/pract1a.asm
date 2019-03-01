;**************************************************************************
; EJERCICIO 1A PRÁCTICA 1
;**************************************************************************
; DEFINICION DEL SEGMENTO DE DATOS
DATOS SEGMENT

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
	MOV AX, 6000h
	MOV DS, AX

	MOV AX, PILA
	MOV SS, AX

	MOV AX, 5000h
	MOV ES, AX

	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO

; FIN DE LAS INICIALIZACIONES

; COMIENZO DEL PROGRAMA

	MOV AX, 15h
	MOV BX, 0BBh
	MOV CX, 3412h	
	MOV DX, CX
	MOV BH, DS:[5536h]
	MOV BL, DS:[5537h]
	MOV ES:[5h], CH
	MOV	AX, [SI]
	MOV BX, [BP + 0Ah]
	

; FIN DEL PROGRAMA
	MOV AX, 4C00H
	INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 