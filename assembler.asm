include macros2.asm a
include number.asm
.MODEL	LARGE 
.386
.STACK 200h 
.CODE 
MAIN:


	 MOV AX,@DATA 	;inicializa el segmento de datos
	 MOV DS,AX 
	 MOV ES,AX 
	 FNINIT 

fld _5
fld a
CMP
BGE ETIQ_8
fld _6
fld b
CMP
ETIQ_8
BLT ETIQ_13
BI ETIQ_16
fld _45
fstp a
ETIQ_16
fld _234
fstp b
	 mov AX, 4C00h 	 ; Genera la interrupcion 21h HOLAAA
	 int 21h 	 ; Genera la interrupcion 21h
END MAIN
