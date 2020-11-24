include macros2.asm
include number.asm
include macros.asm
.MODEL	LARGE 
.386
.STACK 200h 
.DATA 

contador                      	dd             	?              
promedio                      	dd             	?              
actual                        	dd             	?              
suma                          	dd             	?              
_String__1                    	db             	"String  1"    ,'$', 11 dup (?)
_String2                      	db             	"String2"      ,'$', 9 dup (?)
_0                            	dd             	0.0            
_02_5                         	dd             	02.5           
_0xA2B0                       	dd             	41648.0        
_92                           	dd             	92.0           
_1                            	dd             	1.0            
_0_342                        	dd             	0.342          
@contador                     	dd             	?              
__0                           	dd             	0.0            
__1                           	dd             	1.0            
@aux_contar                   	dd             	?              
_256                          	dd             	256.0          
_0b10                         	dd             	2              
_52                           	dd             	52.0           
_4                            	dd             	4.0            
_String3                      	db             	"String3"      ,'$', 9 dup (?)
_String4                      	db             	"String4"      ,'$', 9 dup (?)
_0b111010                     	dd             	58             
_String5                      	db             	"String5"      ,'$', 9 dup (?)
@aux0                         	dd             	?              
@aux1                         	dd             	?              
@aux2                         	dd             	?              
@aux3                         	dd             	?              
@aux4                         	dd             	?              
@aux5                         	dd             	?              
@aux6                         	dd             	?              
@aux7                         	dd             	?              
@aux8                         	dd             	?              
@aux9                         	dd             	?              
@aux10                        	dd             	?              

.CODE 
MAIN:


	 MOV AX,@DATA 	;inicializa el segmento de datos
	 MOV DS,AX 
	 MOV ES,AX 
	 FNINIT 

displayString _String__1
displayString _String2
getString actual
fld __0
fstp contador
fld _0xA2B0
fld _02_5
fadd
fstp @aux0
ffree
fld @aux0
fstp suma
ETIQ_14:
fld _92
fld contador
fcomp
fstsw ax
sahf
JA ETIQ_95
fld __1
fld contador
fadd
fstp @aux1
ffree
fld @aux1
fstp contador
fld _0_342
fld contador
fdiv
fstp @aux2
ffree
fld __0
fstp @contador
fld contador
fld actual
fmul
fstp @aux3
ffree
fld @aux3
fstp @aux_contar_256
fld @aux_contar
fld _256
fcomp
fstsw ax
sahf
JNE ETIQ_48
fld __1
fld @contador
fadd
fstp @aux4
ffree
fld @aux4
fstp @contador
ETIQ_48:
fld @aux_contar
fld _0b10
fcomp
fstsw ax
sahf
JNE ETIQ_59
fld __1
fld @contador
fadd
fstp @aux5
ffree
fld @aux5
fstp @contador
ETIQ_59:
fld @aux_contar
fld _52
fcomp
fstsw ax
sahf
JNE ETIQ_70
fld __1
fld @contador
fadd
fstp @aux6
ffree
fld @aux6
fstp @contador
ETIQ_70:
fld @aux_contar
fld _4
fcomp
fstsw ax
sahf
JNE ETIQ_81
fld __1
fld @contador
fadd
fstp @aux7
ffree
fld @aux7
fstp @contador
ETIQ_81:
fld @contador
fld contador
fmul
fstp @aux8
ffree
fld contador
fld @aux8
fadd
fstp @aux9
ffree
fld @aux9
fstp actual
fld actual
fld suma
fadd
fstp @aux10
ffree
fld @aux10
fstp suma
JE ETIQ_14
ETIQ_95:
displayString _String3
displayString suma
fld _0b10
fld actual
fcomp
fstsw ax
sahf
JNA ETIQ_108
fld __0
fld actual
fcomp
fstsw ax
sahf
JA ETIQ_112
ETIQ_108:
JE ETIQ_117
ETIQ_112:
displayString _String4
JE ETIQ_127
ETIQ_117:
fld _0b111010
fld actual
fcomp
fstsw ax
sahf
JAE ETIQ_126
displayString _String5
ETIQ_126:
ETIQ_127:

	 mov AX, 4C00h 	 ; Genera la interrupcion 21h HOLAAA
	 int 21h 	 ; Genera la interrupcion 21h
END MAIN
