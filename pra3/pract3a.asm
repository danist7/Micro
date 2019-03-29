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
	
	MOV SI, 0h							; Inicializamos un contador a 0
	
	BUCLE:							; BUCLE PARA PASAR LOS VALORES DE ASCII A DECIMAL
		
		MOV AL, ES:[BX][SI]				; Accedemos al valor SI de la variable 
		SUB AL, 30h						; Restamos 30h para pasarlo de ascii a decimal
		
		MOV ES:[BX][SI], AL				; Copiamos el valor en decimal en su lugar 
		INC SI							; Incrementamos SI para la siguiente iteración
		CMP SI, 0Ch						; Si SI vale 12 quiere decir que hemos acabado el bucle y ya estan todos en decimal 
		
		JNE BUCLE						; Si SI no vale 12 salta a bucle para la siguiente iteracion

		
	MOV SI, 2h							; Inicializamos el contador a 2 para acceder a la posicion 3
	MOV AL, ES:[BX]						; Cargamos el primer valor en AL
	
	
	IMPAR:							; BUCLE PARA CALCULAR LA SUMA DE LOS DIGITOS IMPARES
	
		ADD AL, ES:[BX][SI]				; Sumamos en AL los digitos impares
		INC SI							; Incrementamos SI 2 veces
		INC SI
		
		CMP SI, 0Ch						; Si SI vale 12 hemos acabado y continuamos
		JNE IMPAR						; Sino salta a impar y continua con la siguiente iteracion
		
		
	MOV SI, 1h							; Inicializamos el contador a 1 para acceder a la posicion 2
	
	
	PAR: 							; BUCLE PARA MULTIPLICAR LOS VALORES PARES POR 3 Y SUMARLOS 
		
		ADD AL, ES:[BX][SI]				; Sumamos 3 veces cada numero en AL que es donde teniamos la suma de impares
		ADD AL, ES:[BX][SI]				
		ADD AL, ES:[BX][SI]				
	
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
	
	MOV AL, BL							; Guardamos el resultado final en AX y salimos
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
	
	MOV CL, 0H							; Inicializamos a cero el valor del int a devolver
	MOV DS:[SI], CL
	
	MOV AL, ES:[BX + 2]					; Sumamos el dígito de las unidades		
	SUB AL, 30H							; Lo pasamos a int antes de sumarlo
	ADD DS:[SI], AL
	
	MOV AL, ES:[BX + 1]					; Movemos el digito en ascii a AL
	SUB AL, 30H							; Lo pasamos a int
	MOV CL, 0AH							; Lo multiplicamos por 10,quedando el resultado guardado en AL,
	MUL CL								; ya que el resultado siempre es de menos de un byte
	ADD DS:[SI], AL						; Sumamos el dígito de las decenas
	
	MOV AL, ES:[BX]						; Movemos el digito en ascii a AL
	SUB AL, 30H							; Lo pasamos a int
	MOV CL, 64H							; Lo multiplicamos por 100,quedando el resultado guardado en AX
	MUL CL								
	ADD DS:[SI], AX						; Sumamos el dígito de las centenas
	
	
	LDS SI, [BP + 14]					; Guardamos en SI el offset y en DS el segmento de la variable companyCode
	
						
	MOV DS:[SI], 0H						; Inicializamos a cero el valor del int a devolver
	
	MOV AL, ES:[BX + 6]					; Sumamos el dígito de las unidades		
	SUB AL, 30H							; Lo pasamos a int antes de sumarlo
	ADD DS:[SI], AL
	
	MOV AL, ES:[BX + 5]					; Movemos el digito en ascii a AL
	SUB AL, 30H							; Lo pasamos a int
	MOV CL, 0AH							; Lo multiplicamos por 10,quedando el resultado guardado en AL,
	MUL CL								; ya que el resultado siempre es de menos de un byte
	ADD DS:[SI], AL						; Sumamos el dígito de las decenas
	
	MOV AL, ES:[BX + 4]					; Movemos el digito en ascii a AL
	SUB AL, 30H							; Lo pasamos a int
	MOV CL, 64H							; Lo multiplicamos por 100,quedando el resultado guardado en AX
	MUL CL								
	ADD DS:[SI], AX						; Sumamos el dígito de las centenas
	
	MOV AL, ES:[BX + 3]					; Movemos el digito en ascii a AL
	SUB AL, 30H							; Lo pasamos a int
	MOV CL, 3E8H						; Lo multiplicamos por 1000,quedando el resultado guardado en AX
	MUL CL								
	ADD DS:[SI], AX						; Sumamos el dígito de las centenas	de millar

	
	LDS SI, [BP + 18]					; Guardamos en SI el offset y en DS el segmento de la variable productCode
	
						
	MOV DS:[SI], 0H						; Inicializamos a cero el valor del int a devolver
	
	MOV AL, ES:[BX + 11]				; Sumamos el dígito de las unidades		
	SUB AL, 30H							; Lo pasamos a int antes de sumarlo
	ADD DS:[SI], AL
	
	MOV AL, ES:[BX + 10]				; Movemos el digito en ascii a AL
	SUB AL, 30H							; Lo pasamos a int
	MOV CL, 0AH							; Lo multiplicamos por 10,quedando el resultado guardado en AL,
	MUL CL								; ya que el resultado siempre es de menos de un byte
	ADD DS:[SI], AL						; Sumamos el dígito de las decenas
	
	MOV AL, ES:[BX + 9]					; Movemos el digito en ascii a AL
	SUB AL, 30H							; Lo pasamos a int
	MOV CL, 64H							; Lo multiplicamos por 100,quedando el resultado guardado en AL
	MUL CL								
	ADD DS:[SI], AX						; Sumamos el dígito de las centenas
	
	MOV AL, ES:[BX + 8]					; Movemos el digito en ascii a AL
	SUB AL, 30H							; Lo pasamos a int
	MOV CL, 3E8H						; Lo multiplicamos por 1000,quedando el resultado guardado en AX
	MUL CL								
	ADD DS:[SI], AX						; Sumamos el dígito de las centenas	de millar
	
	MOV AL, ES:[BX + 7]					; Movemos el digito en ascii a AL
	SUB AL, 30H							; Lo pasamos a int
	MOV CL, 2710H						; Lo multiplicamos por 10000, quedando el resultado guardado en DX y AX
	MUL CL								
	ADD DS:[SI], AX						; Sumamos el dígito de las centenas	de millar
	
	
	
	
		
	
	
	POP CX 
	POP DI
	POP DS
	POP SI	
	POP ES								; Restaurar el valor de BP, AX, BX y SI antes de salir
	POP BX
	POP BP								
	RET									; Retorno de la función que nos ha llamado
		
_decodeBarCode ENDP

_TEXT ENDS
END