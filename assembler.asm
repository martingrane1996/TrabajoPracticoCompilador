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

fld 0
fstp @contador
fld _5
fstp @aux-contar_3
fld @aux-contar
fld _3
CMP
BNE ETIQ_16
fld 1
fld @contador
fadd
fstp @aux0
ffree
fld @aux0
fstp @contador
ETIQ_16
fld @aux-contar
fld _4
CMP
BNE ETIQ_27
fld 1
fld @contador
fadd
fstp @aux1
ffree
fld @aux1
fstp @contador
ETIQ_27
fld @aux-contar
fld _5
CMP
BNE ETIQ_38
fld 1
fld @contador
fadd
fstp @aux2
ffree
fld @aux2
fstp @contador
ETIQ_38
fld @contador
fstp a
	 mov AX, 4C00h 	 ; Genera la interrupcion 21h HOLAAA
	 int 21h 	 ; Genera la interrupcion 21h
END MAIN
