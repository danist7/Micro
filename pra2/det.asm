;**************************************************************************
; PROGRAMA PARA CALCULAR EL DETERMINANTE DE UNA MATRIZ
; PRÁCTICA 2
; DANIEL SANTO-TOMÁS LÓPEZ
; LUCIA RIVAS MOLINA
;**************************************************************************

; DEFINICION DEL SEGMENTO DE DATOS 

DATOS SEGMENT 

	A	DB	-16, 2, 3, 1, -16, 3, 1, -16, 1
	TEXTO DB "Seleccione una opcion:", 13, 10, "1) Calcular el determinante con valores por defecto",13,10, "2) Calcular el determinante con valores introducidos por teclado", 13, 10, '$' 
	OPCION DB 3 DUP(?) 		; Guarda la opcion escrita por teclado en OPCION[2]
	NUMERO DB 20 DUP(0)		; Guarda los dígitos de un número
	NUM_DIGITOS DW 0H		;
	ESPACIOS DB "     |           |", 13, 10,"|A|= |           |=     ", 13, 10,"     |           |", 13, 10, '$'
	CONTADOR DW 0H
	OPCION2 DB 13, 10, "Introduzca los 9 elementos de la matriz uno por uno, maximo 15 y minimo -16, separandolos con un salto de linea, y empezando de izquierda a derecha y de arriba a abajo :", 13, 10, '$'
	ERRORM DB 13, 10, "error", 13, 10,'$'
	BARRAENE DB 13, 10, '$'
	
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
	
ARRIBA:	
	
	MOV DX, OFFSET TEXTO 		; DX = offset al inicio del texto a imprimir
	MOV AH, 9 					; Número de función = 9 para imprimir un string
	INT 21h 					; Imprime por pantalla que opcion debe escoger 
	
	MOV DX, OFFSET OPCION 		; Reservamos OPCION para la opcion introducida por teclado
	MOV AH, 0AH 				; Capturamos por teclado la opcion a ejecutar(1 o 2)
	MOV OPCION[0], 3 			; Lectura de caracteres máxima=60
	INT 21H 
	
	CMP BYTE PTR OPCION[2], 31H	; Vemos que opcion hemos elegido
	JE OP1 						; Si es 1 saltamos a OP1 y calculamos el determinante por defecto
	CMP BYTE PTR OPCION[2], 32H	
	JNE ARRIBA
	CALL OP2					; Si introducimos la opcion 2 llama a la funcion OP2 para introducir la matriz por pantalla
 

	
OP1:	

	CALL POS                    ; Llamamos a la función que calcula la parte positiva del determinante
	MOV BP, CX					; Copiamos el resultado de POS a DX 
	CALL NEGAT 					; Llamamos a la función que calcula la parte negativa del determinante 
	SUB BP, CX					; Restamos al resultado positivo el resultado negativo
	MOV CX, BP					; Almacenamos el resultado en CX


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
	
	ADD SI, NUM_DIGITOS				; Vamos a imprimir de atrás a delante , asi que inicializamos SI a la posición del
	MOV BP, 0						; último dígito, y BP a 1
	
	
BUCLE2:
	
	INC BP
	MOV AL, NUMERO[BP]				; Movemos a AL el dígito correspondiente
	MOV ESPACIOS[SI], AL			; Y ponemos el dígito en su posición
	SUB SI, 1H						; Decrementamos SI y BP
	CMP BP, NUM_DIGITOS				; Si BP es distinto de NUM_DIGITOS, salta al bucle2
	JNE BUCLE2


	
	
	
	MOV DX, OFFSET ESPACIOS			; Imprime la matriz
	MOV AH, 9
	INT 21H
	

	
    ; FIN DEL PROGRAMA 
    MOV AX, 4C00H 
    INT 21H 
	
START ENDP 
;______________________________________________________________________
; SUBRUTINA PARA LEER POR PANTALLA
; ENTRADA 
; SALIDA
;______________________________________________________________________

OP2 PROC NEAR

MOV DX, OFFSET OPCION2 		; DX = offset al inicio del texto a imprimir
	MOV AH, 9 					; Número de función = 9 para imprimir un string
	INT 21h 					; Imprime por pantalla que opcion debe escoger 
	
	MOV BP, 00H					
	MOV WORD PTR NUMERO[2], BP	; Copiamos un 0 en la variable opcion

	
OP2BUCLE:

	MOV DX, OFFSET NUMERO 		; Llamamos a la funcion 0A para coger los numeros de la matriz
	MOV AH, 0AH 				; y los guardamos en numero
	MOV NUMERO[0], 10 			
	INT 21H 
	
	CMP NUMERO[1], 1			; Si el numero de caracteres escritos es 1 salta a UNOD
	JE UNOD
	
	CMP NUMERO[1], 2			; Si el numero de caracteres escritos es 2 salta a DOSD
	JE DOSD
	
	CMP NUMERO[1], 3			; Si el numero de caracteres escritos es 3 salta a TRESD
	JE TRESD
	
ERRORS:

	MOV DX, OFFSET ERRORM		; Sino es que ha introducido mas de tres caracteres por lo que
	MOV AH, 9 					; esta mal introducido e imprime error
	INT 21h 			
	
	JMP OP2						; En caso de error vuelve a OP2 para empezar de nuevo

UNOD:
								; HEMOS INTRODUCIDO SOLO UN CARACTER (es decir, un numero del 0 al 9)
	SUB NUMERO[2], 30H			; Restamos 30h al numero para pasarlo de ASCII a decimal
	MOV BL, NUMERO[2]			; Lo copiamos en BL
	MOV A[BP], BL				; Lo copiamos en la matriz A en la posición BP que es el contador
	JMP CONTINUA				; Salta a continua para seguir con la siguiente iteracion


DOSD: 							; HEMOS INTRODUCIDO DOS CARACTERES (es decir, un menos con un numero del 0 al 9
								; o un numero del 10 al 15
	CMP NUMERO[2], 2DH			; Si numero[2] es un "-" saltamos a DOSNUM
	JNE DOSNUM
	
	SUB NUMERO[3], 30H			; Si no es un "-" le restamos 30h al numero para pasarlo a decimal
	MOV BL, NUMERO[3]			; Lo copiamos en BL
	NEG BL						; Y lo negamos para pasarlo a negativo
	MOV A[BP], BL				; Finalmente lo copiamos en la matriz y continuamos
	JMP CONTINUA
	
	
DOSNUM:							; CASO EL NUMERO DE DOS CARACTERES NO ES NEGATIVO(es decir, es un numero del 10 al 15)
	
	SUB NUMERO[3], 30H			; Le restamos 30h para pasarlo a decimal y lo copiamos en BL
	MOV BL, NUMERO[3]
	MOV AL, 0AH					; Copiamos un 10 en AL
	SUB NUMERO[2], 30H			; Restamos 30h a numero[2] para pasarlo a decimal
	MUL NUMERO[2]				; Multiplicamos numero[2] por 10 porque es la parte alta del numero
	ADD BL, AL					; Le sumamos 10*numero[2] a numero[3] y lo copiamos en la matriz
	MOV A[BP], BL
	
	CMP BL, 0FH					; Si el numero introducido es mayor que 15 entonces saltamos a error y vuelve a iniciarse todo
	JG ERRORS
	
	JMP CONTINUA				; Continuamos
	

TRESD:							; CASO METEMOS TRES CARACTERES (es decir, un numero negativo del -10 al -16)
	
	CMP NUMERO[2], 2DH			; Si numero[2] no es un "-" salta a error porque se habra introducido un numero de 
	JNE ERRORS					; tres caracteres y no se puede
	
	SUB NUMERO[4], 30H			; Lo pasamos de ascii a decimal 
	MOV BL, NUMERO[4]			; Lo copiamos en BL (=numero[4])
	MOV AL, 0AH					; Copiamos un 10 en AL
	SUB NUMERO[3], 30H			; Pasmos numero[3] a decimal 
	MUL NUMERO[3]				; Multiplicamos numero[3]*10 porque es la parte alta del numero
	ADD BL, AL					; Sumamos numero[3]*10 + numero[4]
	CMP BL, 10H					; Si es mayor que 16 salta a error porque no podemos poner tal numero
	JG ERRORS
	NEG BL						; Convertimos el numero en negativo
	MOV A[BP], BL				; Y lo copiamos en la matriz A
	
	
	
	JMP CONTINUA				; Salta a continua	
	
	
CONTINUA: 	

	MOV DX, OFFSET BARRAENE		; Imprime un salto de linea
	MOV AH, 9 					
	INT 21h 
	
	INC BP		                ; Incrementamos el contador
	CMP BP, 09H					; Si el contador es menor que 9 vuelve a OP2BUCLE para capturar el siguiente 
	JE FINAL					; elemento de la matriz, sino continua con el determinante
	JMP OP2BUCLE
	
FINAL:
	
	RET
	
OP2 ENDP
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
	
	MOV BL, A[8H]
	MOV BH, 0H		
	ADD BL, 0H					; Si es positicvo, saltamos, si es negativo, extendemos el signo
	JNS M00
	MOV BH, 0FFH		
	
M00:
	IMUL BX						; Multiplicamos A[8h],guardado como WORD en BX, por el resultado almacenado en AX. 
	MOV CX, AX					; El resultado queda almacenado en AX, con DX = 0 ya que los números son de 5 bits. Lo movemos a CX
	
	MOV AL, A[2h]				; Continuamos por los elementos 2h, 3h y 7h
    IMUL A[3h]					; Multiplicamos A[2h] por A[3h], y se almacena el resultado en AX
	
	MOV BL, A[7H]
	MOV BH, 0H		
	ADD BL, 0H					; Si es positicvo, saltamos, si es negativo, extendemos el signo
	JNS M01
	MOV BH, 0FFH	
	
M01:
	IMUL BX						; Multiplicamos A[7h], guardado como WORD en BX, por el resultado almacenado en AX.
	ADD CX, AX					; Sumamos el resultado a CX, donde guardamos el resultado anterior
	
	MOV AL, A[1h]				; Finalizamos con los elementos 1h, 5h y 6h
    IMUL A[5h]					; Multiplicamos A[1h] por A[5h], y se almacena el resultado en AX
	
	MOV BL, A[6H]
	MOV BH, 0H		
	ADD BL, 0H					; Si es positicvo, saltamos, si es negativo, extendemos el signo
	JNS M02
	MOV BH, 0FFH	
	
M02:
	IMUL BX						; Multiplicamos A[6h], guardado como WORD en BX, por el resultado almacenado en AX.
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
	
	MOV BL, A[6H]
	MOV BH, 0H
	ADD BL, 0H					; Si es positicvo, saltamos, si es negativo, extendemos el signo
	JNS M10
	MOV BH, 0FFH
	
M10:	
	IMUL BX						; Multiplicamos A[6h], guardado como WORD en BX, por el resultado almacenado en AX. 
	MOV CX, AX					; El resultado queda almacenado en AX, con DX = 0 ya que los números son de 5 bits. Lo movemos a CX
	
	MOV AL, A[1h]				; Continuamos por los elementos 1h, 3h y 8h
    IMUL A[3h]					; Multiplicamos A[1h] por A[3h], y se almacena el resultado en AX
	
	MOV BL, A[8H]
	MOV BH, 0H	
	ADD BL, 0H					; Si es positicvo, saltamos, si es negativo, extendemos el signo
	JNS M11
	MOV BH, 0FFH
M11:
	
	IMUL BX						; Multiplicamos A[8h], guardado como WORD en BX, por el resultado almacenado en AX.
	ADD CX, AX					; Sumamos el resultado a CX, donde guardamos el resultado anterior
	
	MOV AL, A[0h]				; Finalizamos con los elementos 0h, 5h y 7h
    IMUL A[5h]					; Multiplicamos A[0h] por A[5h], y se almacena el resultado en AX
	
	MOV BL, A[7H]
	MOV BH, 0H
	ADD BL, 0H					; Si es positicvo, saltamos, si es negativo, extendemos el signo
	JNS M12
	MOV BH, 0FFH	

M12:	
	IMUL BX						; Multiplicamos A[7h], guardado como WORD en BX, por el resultado almacenado en AX.
	ADD CX, AX					; Finalmente sumamos de nuevo a CX el resultado final
	RET
	
	
NEGAT ENDP 


; FIN DEL SEGMENTO DE CODIGO 
CODE ENDS 
; FIN DEL PROGRAMA INDICANDO DONDE COMIENZA LA EJECUCION 
END START 

