;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; 	SBM 2016. Practica 3 - Ejercicio3b 						;
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
			

PUBLIC _createBarCode    				; Hacer visible y accesible la función desde C
_createBarCode PROC FAR      			; En C es void createBarCode(int countryCode, unsigned int companyCode, unsigned long productCode, 
										;                                             unsigned char controlDigit, unsigned char* out_barCodeASCII)
	
	PUSH BP 							; Salvaguardar BP en la pila para poder modificarle sin modificar su valor
	MOV BP, SP							; Igualar BP el contenido de SP							
	PUSH BX
	PUSH DI
	PUSH DX
	PUSH CX
	
	LES  BX, [BP + 16]					; Guardamos en BX el offset y en ES el segmento de la variable out_barCodeASCII

	MOV AX, [BP + 6]					; Guardamos la variable countryCode en AX
	MOV DI, 2h							; Ponemos el contador a 2
	MOV CX, 0Ah							; Inicializamos CL a 10 para dividir
	
	PAIS:								; Guarda la variable contryCode
		MOV AH, 0h						; Ponemos AH a 0
		DIV CL							; Dividimos AX entre 10
		MOV ES:[BX][DI], AH				; Guardamos el resto en su posición correspondiente
		ADD ES:[BX][DI], 30h			; Pasamos el dígito a ascii
		DEC DI							; Decrementamos el contador
		JNS PAIS						; Si DI no es negativo salta a PAIS y continua el bucle
		
		
	MOV AX, [BP + 8]					; Guardamos la variable companyCode en AX
	MOV DI, 6h							; Ponemos el contador a 6
	
	EMPRESA:							; Guarda la variable companyCode
		MOV DX, 0h						; Ponemos DX a 0
		DIV CX							; Dividimos AX entre 10
		MOV ES:[BX][DI], DL				; Guardamos el resto en su posición correspondiente
		ADD ES:[BX][DI], 30h			; Pasamos el dígito a ascii
		DEC DI							; Decrementamos el contador
		CMP DI, 2h
		JNE EMPRESA						; Si DI no es 2 salta a EMPRESA y continua el bucle
	
	
	MOV AX, [BP + 10]					; Guardamos la parte baja productCode en AX
	MOV DX, [BP + 12]					; Guardamos en DX la parte alta de productCode
	MOV DI, 0Bh							; Ponemos el contador a 11
	
		
	PRODUCTO:							; Guarda la variable productCode
		DIV CX							; Dividimos AX entre 10
		MOV ES:[BX][DI], DL				; Guardamos el resto en su posición correspondiente
		ADD ES:[BX][DI], 30h			; Pasamos el dígito a ascii
		MOV DX, 0h						; Ponemos DX a 0
		DEC DI							; Decrementamos el contador
		CMP DI, 6h
		JNE PRODUCTO					; Si DI no es 7 salta a PRODUCTO y continua el bucle
	
	MOV AL, [BP + 14]					; Guardamos la variable controlDigit en AL
	MOV ES:[BX + 12], AL				; Y lo guardamos en memoria
	
	MOV ES:[BX + 13], 0H				; Ponemos un 0 al final del string
		
	POP CX								; Restauramos los registros
	POP DX
	POP DI
	POP BX
	POP BP
	
	RET
		
_createBarCode ENDP						; Fin de la funcion



_TEXT ENDS
END