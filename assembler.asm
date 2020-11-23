include macros2.asm 0
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

fld _0
fstp a
ETIQ_3
fld _5
fld a
CMP
BGE ETIQ_30
ETIQ_9
fld _5
fld b
CMP
BGE ETIQ_22
fld _1
fld c
fadd
fstp @aux0
ffree
fld @aux0
fstp c
BI ETIQ_9
ETIQ_22
fld _1
fld a
fadd
fstp @aux1
ffree
fld @aux1
fstp a
BI ETIQ_3
ETIQ_30
	 mov AX, 4C00h 	 ; Genera la interrupcion 21h HOLAAA
	 int 21h 	 ; Genera la interrupcion 21h
END MAIN
