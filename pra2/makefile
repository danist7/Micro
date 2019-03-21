all: det.exe

det.exe: det.obj
	tlink /v det
det.obj: det.asm 
	tasm /zi det.asm,,det.lst
