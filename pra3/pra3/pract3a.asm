;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2016. Practica 3 - Ejercicio3a 				;
;   Daniel Santo-Tomás López								;
;   Lucía Rivas Molina 										;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA público


_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS público


_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definición del segmento de código
	ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
			

PUBLIC _computeControlDigit				; Hacer visible y accesible la función desde C
_computeControlDigit PROC FAR 			; En C es unsigned char computeControlDigit(char* barCodeASCII)

	PUSH BP 							; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							; Igualar BP el contenido de SP							
	PUSH BX								; Salvamos AX, BX y SI en la pila
	PUSH SI
	PUSH ES
	
	LES  BX, [BP + 6]					; Guardamos en BX el offset y en ES el segmento de la variable
	
	
	MOV SI, 2h							; Inicializamos el contador a 2 para acceder a la posicion 3
	MOV AL, ES:[BX]						; Cargamos el primer valor en AL y lo pasamos a decimal
	SUB AL, 30H
	
	
	IMPAR:							; BUCLE PARA CALCULAR LA SUMA DE LOS DIGITOS IMPARES
	
		ADD AL, ES:[BX][SI]				; Sumamos en AL los digitos impares
		SUB AL, 30H						; Pasamos el último numero sumado a decimal
		INC SI							; Incrementamos SI 2 veces
		INC SI
		
		CMP SI, 0Ch						; Si SI vale 12 hemos acabado y continuamos
		JNE IMPAR						; Sino salta a impar y continua con la siguiente iteracion
		
		
	MOV SI, 1h							; Inicializamos el contador a 1 para acceder a la posicion 2
	
	
	PAR: 							; BUCLE PARA MULTIPLICAR LOS VALORES PARES POR 3 Y SUMARLOS 
		
		ADD AL, ES:[BX][SI]				; Sumamos 3 veces cada numero en AL que es donde teniamos la suma de impares
		SUB AL, 30H						; pasando después cada dígito a decimal
		ADD AL, ES:[BX][SI]	
		SUB AL, 30H			
		ADD AL, ES:[BX][SI]	
		SUB AL, 30H	
	
		INC SI							; Incrementamos SI 2 veces
		INC SI
		
		CMP SI, 0Dh						; Si SI vale 13 hemos acabado y continuamos
		JNE PAR							; Sino salta a par y continua con la siguiente iteracion
		
		
	MOV AH, 0h							; Nos aseguramos de que AH vale 0
	MOV BL, 0Ah							; Copiamos en BL un 10 para dividir por él 
	DIV BL								; Dividimos por 10
	
	SUB BL, AH							; Restamos 10 menos el resto
	CMP BL, 0Ah							; Si la resta es 10 lo pasamos a 0
	JNE SALTO
	
	MOV BL, 0h
	
	SALTO:
	
	MOV AL, BL							; Guardamos el resultado final, pasado a ASCII, en AX y salimos
	ADD AL, 30H
	MOV AH, 0h
		
	POP ES
	POP SI								; Restaurar el valor de BP, AX, BX y SI antes de salir
	POP BX
	POP BP								
	RET									; Retorno de la función que nos ha llamado, devolviendo el resultado del factorial en AX
		
_computeControlDigit ENDP				; Fin de la funcion


PUBLIC _decodeBarCode				; Hacer visible y accesible la función desde C
_decodeBarCode PROC FAR 			; En C es void decodeBarCode(unsigned char* in_barCodeASCII, unsigned int* countryCode, 
									;							 unsigned int* companyCode, unsigned long* productCode, unsigned char* controlDigit);

										
	PUSH BP 							; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							; Igualar BP el contenido de SP							
	PUSH BX
	PUSH ES
	PUSH SI
	PUSH DS
	PUSH DI
	PUSH CX
	
	MOV AX, 0H							; Nos aseguramos de que AX vale 0 antes de darle cualquier uso
	
	LES  BX, [BP + 6]					; Guardamos en BX el offset y en ES el segmento de la variable in_barCodeASCII
	
	LDS SI, [BP + 10]					; Guardamos en SI el offset y en DS el segmento de la variable countryCode
	
		
	MOV DI, 1H							; Inicializamos el contador a 1
	MOV CL, 0AH							; Cargamos en CL un 10, para multiplicar
	MOV AL, ES:[BX]						; Cargamos en AL el primer dígito, y lo pasamos de ASCII a decimal
	SUB AL, 30H
	
	PAIS:
		
		MUL CL							; Multiplicamos el contenido de AL por CL (usamos la múltiplicación por byte, ya que al ser 3 dígitos, no hay problema)
		ADD AL, ES:[BX][DI]				; Sumamos el siguiente dígito a AL (siempre se añade en la parte baja del registro, ya que es sumar un digito)
		SUB AL, 30H						; Y lo pasamos a decimal
		INC DI							; Incrementamos el contador, y si es 3, salimos de bucle
		CMP DI, 3H
		JNE PAIS
	
	MOV DS:[SI], AX						; Guardamos el resultado en la dirección de memoria correspondiente
	
	MOV AX, 0H							; Volvemos a poner AX a 0 para los nuevos cálculos
	
	LDS SI, [BP + 14]					; Guardamos en SI el offset y en DS el segmento de la variable companyCode
	
	MOV DI, 4H							; Inicializamos el contador a 4
	MOV CX, 0AH							; Cargamos en CX un 10, para multiplicar
	MOV AL, ES:[BX + 3]					; Cargamos en AL el primer dígito, y lo pasamos de ASCII a decimal
	SUB AL, 30H
	
	EMPRESA:
		
		MUL CX							; Multiplicamos el contenido de AX por CX 
		ADD AL, ES:[BX][DI]				; Sumamos el siguiente dígito a AL (siempre se añade en la parte baja del registro, ya que es sumar un digito)
		SUB AL, 30H						; Y lo pasamos a decimal
		INC DI							; Incrementamos el contador, y si es 7, salimos de bucle
		CMP DI, 7H
		JNE EMPRESA					
	
	MOV DS:[SI], AX						; Guardamos el resultado en la dirección de memoria correspondiente
	
	MOV AX, 0H							; Volvemos a poner AX a 0 para los nuevos cálculos
	
	LDS SI, [BP + 18]					; Guardamos en SI el offset y en DS el segmento de la variable productCode
	
	MOV DI, 8H							; Inicializamos el contador a 8
	MOV CX, 0AH							; Cargamos en CX un 10, para multiplicar
	MOV AL, ES:[BX + 7]					; Cargamos en AL el primer dígito, y lo pasamos de ASCII a decimal
	SUB AL, 30H
	
	PRODUCTO:
		
		MUL CX							; Multiplicamos el contenido de AX por CX 
		ADD AL, ES:[BX][DI]				; Sumamos el siguiente dígito a AL (siempre se añade en la parte baja del registro, ya que es sumar un digito)
		SUB AL, 30H						; Y lo pasamos a decimal
		
		
		
		INC DI							; Incrementamos el contador, y si es 12, salimos de bucle
		CMP DI, 0CH
		JNE PRODUCTO					
	
	MOV DS:[SI], AX						; Guardamos la parte baja del resultado en la dirección de memoria correspondiente
	MOV DS:[SI + 2], DX					; Guardamos la parte alta del resultado en la dirección de memoria correspondiente
	
		
	LDS SI, [BP + 22]					; Guardamos en SI el offset y en DS el segmento de la variable controlDigit
	
	MOV AL, ES:[BX + 12]				; Guardamos el caracter en la posición de memoria correspondiente
	MOV DS:[SI], AL
	
	
		
	
	
	POP CX 
	POP DI
	POP DS
	POP SI	
	POP ES								; Restaurar el valor de los registros antes de salir
	POP BX
	POP BP								
	RET									; Retorno de la función que nos ha llamado
		
_decodeBarCode ENDP

_TEXT ENDS
END