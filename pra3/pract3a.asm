;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 			SBM 2016. Practica 3 - Ejercicio3a 				;
;   Daniel Santo-Tom�s L�pez								;
;   Luc�a Rivas Molina 										;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DGROUP GROUP _DATA, _BSS				;; Se agrupan segmentos de datos en uno

_DATA SEGMENT WORD PUBLIC 'DATA' 		;; Segmento de datos DATA p�blico


_DATA ENDS

_BSS SEGMENT WORD PUBLIC 'BSS'			;; Segmento de datos BSS p�blico


_BSS ENDS

_TEXT SEGMENT BYTE PUBLIC 'CODE' 		;; Definici�n del segmento de c�digo
	ASSUME CS:_TEXT, DS:DGROUP, SS:DGROUP
			

PUBLIC _computeControlDigit				; Hacer visible y accesible la funci�n desde C
_computeControlDigit PROC FAR 			; En C es unsigned char computeControlDigit(char* barCodeASCII)

	PUSH BP 							; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							; Igualar BP el contenido de SP
	PUSH AX								; Salvamos AX, BX y SI en la pila
	PUSH BX
	PUSH SI
	
	LES  BX, [BP + 6]					; Guardamos en BX el offset y en ES el segmento de la variable
	
	MOV SI, 0h							; Inicializamos un contador a 0
	
	BUCLE:							; BUCLE PARA PASAR LOS VALORES DE ASCII A DECIMAL
		
		MOV AL, ES:[BX][SI]				; Accedemos al valor SI de la variable 
		SUB AL, 30h						; Restamos 30h para pasarlo de ascii a decimal
		
		MOV ES:[BX][SI], AL				; Copiamos el valor en decimal en su lugar 
		INC SI							; Incrementamos SI para la siguiente iteraci�n
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
	MOV BL, 0Ah							; Copiamos en BL un 10 para dividir por �l 
	DIV BL								; Dividimos por 10
	
	SUB BL, AH							; Restamos 10 menos el resto
	CMP BL, 0Ah							; Si la resta es 10 lo pasamos a 0
	JNE SALTO
	
	MOV BL, 0h
	
	SALTO:
	
	MOV AL, BL							; Guardamos el resultado final en AX y salimos
	MOV AH, 0h
		
		
	POP SI								; Restaurar el valor de BP, AX, BX y SI antes de salir
	POP BX
	POP AX
	POP BP								
	RET									; Retorno de la funci�n que nos ha llamado, devolviendo el resultado del factorial en AX
		
_computeControlDigit ENDP				; Fin de la funcion
_TEXT ENDS
END