;**************************************************************************
; PROGRAMA PARA CALCULAR EL DETERMINANTE DE UNA MATRIZ
; PRÁCTICA 2
; DANIEL SANTO-TOMÁS LÓPEZ
; LUCIA RIVAS MOLINA
;**************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

	A	DB	1, 2, 3, 1, 3, 3, 1, 1, 1
	TEXTO DB "Seleccione una opcion:", 13, 10, "1) Calcular el determinante con valores por defecto",13,10, "2) Calcular el determinante con valores introducidos por teclado", 13, 10, '$' 
	OPCION DB 3 DUP(?) 		; Guarda la opcion escrita por teclado en OPCION[2]
	NUMERO DB 20 DUP(?)		; Guarda los dígitos de un número
	NUM_DIGITOS DW 0H		;
	ESPACIOS DB "     |           |", 13, 10,"|A|= |           |=     ", 13, 10,"     |           |", 13, 10, '$'
	CONTADOR DW 0H
	OPCION2 DB 13, 10, "Introduzca los 9 elementos de la matriz uno por uno, maximo 15 y minimo -16, separandolos con un salto de linea, y empezando de izquierda a derecha y de arriba a abajo :", 13, 10, '$'

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
	
	
	MOV DX, OFFSET TEXTO 		; DX = offset al inicio del texto a imprimir
	MOV AH, 9 					; Número de función = 9 para imprimir un string
	INT 21h 					; Imprime por pantalla que opcion debe escoger 
	
	MOV DX, OFFSET OPCION 		; Reservamos OPCION para la opcion introducida por teclado
	MOV AH, 0AH 				; Capturamos por teclado la opcion a ejecutar(1 o 2)
	MOV OPCION[0], 3 			; Lectura de caracteres máxima=60
	INT 21H 
	
	CMP BYTE PTR OPCION[2], 31H	; Vemos que opcion hemos elegido
	JE OP1 						; Si es 1 saltamos a OP1 y calculamos el determinante por defecto
			
OP2: 

	MOV DX, OFFSET OPCION2 		; DX = offset al inicio del texto a imprimir
	MOV AH, 9 					; Número de función = 9 para imprimir un string
	INT 21h 					; Imprime por pantalla que opcion debe escoger 
	
	MOV BP, 00H					; Inicializamos el contador a 0
	MOV WORD PTR OPCION[2], BP	; Copiamos un 0 en la variable opcion
	
OP2BUCLE:

	MOV DX, OFFSET OPCION 		; Guardamos en opcion el numero introducido
	MOV AH, 0AH 				
	MOV OPCION[0], 3 			
	INT 21H 
	
	MOV BL, OPCION[2]			; Copiamos el numero introducido en BL
	MOV BH, 48
	SUB BH, BL 
	MOV A[BP], BH 		        ; Copiamos en la matriz A el numero introducido
	
	INC BP		                ; Incrementamos el contador
	CMP BP, 09H					; Si el contador es menor que 9 vuelve a OP2BUCLE para capturar el siguiente 
	JNE OP2BUCLE				; elemento de la matriz, sino continua con el determinante
	
OP1:	

	CALL POS                    ; Llamamos a la función que calcula la parte positiva del determinante
	MOV DX, CX					; Copiamos el resultado de POS a DX 
	CALL NEGAT 					; Llamamos a la función que calcula la parte negativa del determinante 
	SUB DX, CX					; Restamos al resultado positivo el resultado negativo
	MOV CX, DX					; Almacenamos el resultado en CX


BUCLE: 	

	MOV BP, CONTADOR		
	MOV AL, A[BP]			 	; Guardamos en AL el valor del número a transformar en ascii
	
	MOV NUMERO[0], " "			; Metemos un espacio en numero[0]
	ADD AL, 0H					; Sumamos 0 al número para ver si es negativo o no
	JNS MAS						; Si es positivo salta a mas

	MOV NUMERO[0], 2DH			; Es negativo, ponemos un menos en ascii
	NEG AL
	
MAS: 
	
	MOV AH, 0H						; Cargamos 00 en Ah para tener todo el numero en AX(numero positivo)
	CALL NUM						; LLamamos a NUM, que guarda en NUMERO los digitos en ascii 
	
	CMP CONTADOR, 0H				; Hacemos una serie de comparaciones con sus respectivos saltos. Dependiendo de
	JE CERO							; por donde vaya el contador, iremos por un número u otro, asi que saltamos al 
									; correspondiente
	CMP CONTADOR, 1H
	JE UNO
	
	CMP CONTADOR, 2H				
	JE DOS
	
	CMP CONTADOR, 3H
	JE TRES
	
	CMP CONTADOR, 4H
	JE CUATRO
	
	CMP CONTADOR, 5H
	JE CINCO
	
	CMP CONTADOR, 6H
	JE SEIS
	
	CMP CONTADOR, 7H
	JE SIETE
	
	CMP CONTADOR, 8H
	JE OCHO

SIGUE:

	MOV AL, NUMERO[0]				; Colocamos el signo en la primera posición correspondiente al número en la matriz
	MOV ESPACIOS[SI], AL
	INC SI						 	; Incrementamos SI
	
	MOV AL, NUMERO[2]				; Colocamos el primer dígito
	MOV ESPACIOS[SI], AL
	INC SI							; Incrementamos SI
	
	MOV AL, NUMERO[1]				; Colocamos el segundo dígito
	MOV ESPACIOS[SI], AL
	INC SI							; Incrementamos SI
	
	INC CONTADOR					; Incrementamos CONTADOR
	CMP CONTADOR, 9H				; Si CONTADOR vale 9, hemos terminado, si no, salta a SIGUE 
	JNE BUCLE
	JMP FIN							; Sino, salta a FIN	

CERO: 								; Una vez en el correspondiente, almacenamos en SI la posición en la que se debe colocar
	MOV SI, 6H						; el numero en la tabla ESPACIOS
	JMP SIGUE
UNO:
	MOV SI, 0AH
	JMP SIGUE
DOS:
	MOV SI, 0EH
	JMP SIGUE
TRES:
	MOV SI, 1AH
	JMP SIGUE
CUATRO:
	MOV SI, 1EH
	JMP SIGUE
CINCO: 
	MOV SI, 22H
	JMP SIGUE
SEIS:
	MOV SI, 34H
	JMP SIGUE
SIETE:
	MOV SI, 38H
	JMP SIGUE
OCHO:
	MOV SI, 3CH
	JMP SIGUE
	
	
	; FINALMENTE IMPRIMIMOS EL RESULTADO 
FIN:
		
	MOV BP, CONTADOR		
	MOV AX, CX			 			; Guardamos en AX el valor del número a transformar en ascii
	
	MOV NUMERO[0], " "				; Metemos un espacio en numero[0]
	ADD AX, 0H						; Sumamos 0 al número para ver si es negativo o no
	JNS MAS2						; Si es positivo salta a mas2

	MOV NUMERO[0], 2DH				; Es negativo, ponemos un menos en ascii
	NEG AX
	
MAS2:

	CALL NUM						; Llamamos a la función NUM para convertirlo a ASCII
	
	MOV SI, 27H						; El resultado comienza en la posición 27h = 39
	MOV AL, NUMERO[0]				; Colocamos el signo en la primera posición correspondiente al número en la matriz
	MOV ESPACIOS[SI], AL
	
	INC SI						 	; Incrementamos SI
	CMP NUMERO[4], 00H
	JE SIG3							; Si el primer digito es un cero no lo copiamos y salta al siguiente
	
	MOV AL, NUMERO[4]				; Sino colocamos el primer dígito
	MOV ESPACIOS[SI], AL
	INC SI							; Incrementamos SI
	
SIG3:
								
	CMP NUMERO[3], 20H
	JE SIG2  						; Si el segundo digito es un espacio no lo copiamos y salta al siguiente
	
	MOV AL, NUMERO[3]				; Colocamos el segundo dígito
	MOV ESPACIOS[SI], AL
	INC SI							; Incrementamos SI
	
SIG2:
								
	CMP NUMERO[2], 20H
	JE SIG1  						; Si el tercer digito es un espacio no lo copiamos y salta al siguiente
	
	MOV AL, NUMERO[2]				; Colocamos el tercer dígito
	MOV ESPACIOS[SI], AL
	INC SI							; Incrementamos SI
	
SIG1:

	MOV AL, NUMERO[1]				; Colocamos el último dígito
	MOV ESPACIOS[SI], AL
	
	
	MOV DX, OFFSET ESPACIOS			; Imprime la matriz
	MOV AH, 9
	INT 21H
	

	
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
NUM PROC NEAR 
	
	MOV SI, 0AH					; Copiamos un 10 en SI para dividir por el
	MOV BP, 0H
	MOV NUM_DIGITOS, BP			;Inicializamos NUM_DIGITOS a 0
	
ASCII:

	MOV DX, 00H
	INC NUM_DIGITOS
	DIV SI 						; Dividimos el número por 10
	ADD DL, 30H					; Pasamos a ASCII el resto
	MOV BP, NUM_DIGITOS
	MOV NUMERO[BP], DL			; Lo copiamos en NUMERO[NUM_DIGITOS]
	
	CMP AX, 0H					; Si el cociente es 0, hemos terminado
	JNE ASCII					; Si no es 0, volvemos al bucle
	
	CMP NUM_DIGITOS, 1H			; Si no tiene un solo digito acaba
	JNE DIGITO
	
	MOV BP, 2H					; Sino copia un espacio en el siguiente
	MOV NUMERO[BP], " "
	
DIGITO:	

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
	IMUL A[8h]					; Multiplicamos A[8h], casteandolo a word, por el resultado almacenado en AX. 
	MOV CX, AX					; El resultado queda almacenado en AX, con DX = 0 ya que los números son de 5 bits. Lo movemos a CX
	
	MOV AL, A[2h]				; Continuamos por los elementos 2h, 3h y 7h
    IMUL A[3h]					; Multiplicamos A[2h] por A[3h], y se almacena el resultado en AX
	IMUL A[7h]					; Multiplicamos A[7h], casteandolo a word, por el resultado almacenado en AX.
	ADD CX, AX					; Sumamos el resultado a CX, donde guardamos el resultado anterior
	
	MOV AL, A[1h]				; Finalizamos con los elementos 1h, 5h y 6h
    IMUL A[5h]					; Multiplicamos A[1h] por A[5h], y se almacena el resultado en AX
	IMUL A[6h]					; Multiplicamos A[6h], casteandolo a word, por el resultado almacenado en AX.
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


; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END START 

