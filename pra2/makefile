all: det.exe prueba.exe

det.exe: det.obj
	tlink /v det
det.obj: det.asm 
	tasm /zi det.asm,,det.lst
	
prueba.exe: prueba.obj
	tlink /v prueba
prueba.obj: prueba.asm 
	tasm /zi prueba.asm,,prueba.lst