%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "y.tab.h"
	int stopparser=0;
	FILE *yyin;
	int yylex();
	int yyerror();
%}

%token AS 					  
%token CIERRE_SENT
%token CMP_AND				  
%token CMP_DIST				  
%token CMP_IGUAL				  	
%token CMP_MA				  
%token CMP_MA_IGUAL			   
%token CMP_ME				  
%token CMP_ME_IGUAL			  	
%token CMP_NOT
%token CMP_OR				  
%token COMA					  
%token COMENTARIOS
%token CONST 				  
%token CONTAR				  
%token CORCH_A
%token CORCH_C				  
%token CTE_BIN
%token CTE_HEX
%token CTE_INT			    			
%token CTE_REAL				 
%token CTE_STR					 
%token DIGITO
%token DIM					  
%token ELSE					   
%token END_IF				 
%token FOREACH_C
%token GET 					  
%token ID					  
%token IF_C					  	
%token INTEGER				  
%token LETRA
%token LLAVE_A				  	
%token LLAVE_C				  
%token OP_ASIG				  
%token OP_DIF				  
%token OP_DIV				  
%token OP_MUL
%token OP_SUM				  
%token PAR_A					  
%token PAR_C					  
%token PICO_A
%token PICO_C
%token PTO
%token PUT 					  
%token REAL					  
%token STRING				  
%token VAR_STRING
%token VOID					  		
%token WHILE_C				   

%%
programa:
	bloque {printf("\nCompilación exitosa\n");}
bloque:
	sentencia 				{printf("\nsentencia\n");}
	|programa sentencia 			{printf("\nmas de una sentencia\n");}
	;
sentencia:
	asignacion 				{printf("\nsentencia es asig.\n");}
	|declaracion 				{printf("\nsentencia es declaracion\n");}
	|iteracion 				{printf("\nsentencia es iteracion\n");}
	|seleccion 				{printf("\nsentencia es seleccion\n");}
	|PUT CTE_STR CIERRE_SENT		{printf("\nimprimir cadenas es sentencia\n");}
	|PUT CTE_INT CIERRE_SENT		{printf("\nimprimir INT es sentencia.\n");}
	|PUT CTE_REAL CIERRE_SENT		{printf("\nimprimir REAL es sentencia.\n");}
	|PUT ID CIERRE_SENT			{printf("\nimprimir ID es sentencia.\n");}
	|GET ID CIERRE_SENT			{printf("\nGET ID es sentencia.\n");}
	|contar CIERRE_SENT			{printf("\nCONTAR es sentencia.\n");}
	;
declaracion: 
	DIM CMP_ME lista_variables CMP_MA AS CMP_ME lista_tipos CMP_MA 		{printf("\nUNA DECLARACION\n");}
	;
lista_variables:
	lista_variables COMA ID 		{printf("\nlista_variables,ID es lista_variables\n");}
	|ID 					{printf("\nlista_variables es ID.\n");}
	;
lista_tipos:
	lista_tipos COMA REAL 			{printf("\nlista_tipos,REAL es lista_tipos\n");}
	|lista_tipos COMA INTEGER 		{printf("\nlista_tipos,INTEGER es lista_tipos\n");}
	|lista_tipos COMA STRING 		{printf("\nlista_tipos,STRING es lista_tipos\n");}
	|REAL 					{printf("\nlista_tipos es REAL\n");}
	|INTEGER 				{printf("\nlista_tipos es INTEGER\n");}
	|STRING 				{printf("\nlista_tipos es STRING\n");}	
	;
seleccion:
	IF_C PAR_A condicion PAR_C LLAVE_A programa LLAVE_C ELSE LLAVE_A programa LLAVE_C 	{printf("\nIF CON ELSE\n");}
	|IF_C  PAR_A condicion PAR_C LLAVE_A programa LLAVE_C 					{printf("\nIF SIN ELSE\n");}
	|IF_C  PAR_A condicion PAR_C sentencia 							{printf("\nIF CON UNA SENTENCIA\n");}
	;
iteracion:
	WHILE_C PAR_A condicion PAR_C LLAVE_A programa LLAVE_C 		{printf("\nwhile(condicion){programa} es while\n");}
	;
condicion:	
	comparacion CMP_AND comparacion 		{printf("\ncomparacion AND comparacion  es condicion\n");}
	|comparacion CMP_OR comparacion 		{printf("\ncomparacion OR comparacion  es condicion\n");}
	|comparacion 					{printf("\ncomparacion es condicion\n");}
	|CMP_NOT PAR_A comparacion PAR_C 		{printf("\ncomparacion negada es condicion\n");}
	;
comparacion:
	expresion comparador expresion 			{printf("\nexpresion comparado con expresion es comparacion\n");}
	;
comparador: 
	CMP_MA_IGUAL 		{printf("\n>=  es un comparador\n");}
	|CMP_ME_IGUAL  		{printf("\n<=  es un comparador\n");}
	|CMP_ME			{printf("\n<  es un comparador\n");}
	|CMP_MA			{printf("\n>  es un comparador\n");}
	|CMP_IGUAL		{printf("\n==  es un comparador\n");}
	|CMP_AND		{printf("\nAND  es un comparador\n");}
	|CMP_OR			{printf("\nOR es un comparador\n");}
	|CMP_DIST		{printf("\n!= es un comparador\n");}
	;
asignacion:
	ID OP_ASIG expresion CIERRE_SENT 	{printf("\nID := expresion; es una asignacion\n");}
	;
expresion: 
	expresion OP_SUM termino 		{printf("\nexpresion+termino es expresion\n");}
	|expresion OP_DIF termino 		{printf("\nexpresion-termino es expresion\n");}
	|termino				{printf("\ntermino es expresion\n");}
	|funcion				{printf("\nfuncion es expresion\n");}
funcion:
	VOID ID PAR_A parametros PAR_C 		{printf("\nfuncion retornar VOID\n");}
	|STRING ID PAR_A parametros PAR_C	{printf("\nfuncion retornar STRING\n");}
	|REAL ID PAR_A parametros PAR_C		{printf("\nfuncion retornar REAL\n");}
	|INTEGER ID PAR_A parametros PAR_C 	{printf("\nfuncion retornar INTEGER\n");}
	;
parametros:
	parametros COMA factor 			{printf("\nparametros,factor  son parametros\n");}
	|factor					{printf("\nfactor es parametro\n");}
	;
termino:
	termino OP_MUL factor  			{printf("\ntermino * factor es termino\n");}
	|termino OP_DIV factor 			{printf("\ntermino / factor es termino\n");}
	|factor					{printf("\nfactor es termino\n");}
	;
factor:
	 ID 					{printf("\nID es es factor\n");}
	|CTE_INT				{printf("\nCTE_INT ES factor\n");}
	|CTE_REAL				{printf("\nCTE_REAL ES factor\n");}
	|CTE_STR				{printf("\nCTE_STR ES factor\n");}
	|CTE_BIN				{printf("\nCTE_BIN ES factor\n");}
	|CTE_HEX				{printf("\nCTE_HEX ES factor\n");}
	|PAR_A expresion PAR_C			{printf("\nCTE_STR ES factor\n");}
	|contar 				{printf("\ncontar es factor\n");}
	;
contar:
	CONTAR PAR_A expresion CIERRE_SENT CORCH_A el CORCH_C PAR_C		{printf("\nfuncion contar\n");}
el:
	el COMA factor
	|factor
	;
%%

int main(int argc,char *argv[]){
	yyin = fopen(argv[1],"rt");
	if( yyin == NULL){
		printf("\n No se puede abrir el archivo! ' %s '",argv[1]);
	}else{
		yyparse();
	}
	fclose(yyin);
	return 0;
}

int yyerror(void){
	printf ("ERROR SINTACTICO! \n");
	exit(1);
	return 0;
}

