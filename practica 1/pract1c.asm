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
	MOV AX, 0535h
	MOV DS, AX

	MOV AX, PILA
	MOV SS, AX

	MOV AX, EXTRA
	MOV ES, AX

	MOV SP, 64 ; CARGA EL PUNTERO DE PILA CON EL VALOR MAS ALTO

; FIN DE LAS INICIALIZACIONES

; COMIENZO DEL PROGRAMA

	MOV BX, 0210h	
	MOV DI, 1011H
								
	MOV AX, 12h							
	MOV AX, DS:[1234H]					; Guarda en Al el contenido de la dirección física 06584H
	
	MOV AX, 1234h						;Guarda en AX el contenido de la dirección física 05560H	
	MOV AL, DS:[BX]					
	
	MOV DS:[DI], AL						; Guarda en la dirección de memoria física 06361h el contenido de AL
								
	
	
	

; FIN DEL PROGRAMA
	MOV AX, 4C00H
	INT 21H
INICIO ENDP
; FIN DEL SEGMENTO DE CODIGO
CODE ENDS
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION
END INICIO 