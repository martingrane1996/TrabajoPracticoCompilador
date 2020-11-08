%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	FILE *yyin;
	int yylval;
	char *yyltext;
	int TK_INVALID_STRING;
	int validarTamano(char*, int);
	FILE * tablaDeSimbolos;
	int insertarEnTablaDeSimbolos(char* lexema, char* tipo);
%}

%option noyywrap
%option yylineno

DIGITO 		[0-9]
LETRA 		[a-zA-Z]

AS 		"AS" 
CIERRE_SENT 	";" 
CMP_AND		"AND"|"and"
CMP_DIST	"!="|"<>"
CMP_IGUAL	"=="
CMP_MA		">"
CMP_MA_IGUAL 	">="
CMP_ME		"<"
CMP_ME_IGUAL	"<="
CMP_NOT		"NOT"|"not"
CMP_OR		"OR"|"or"
COMA 		","
COMENTARIOS 	"*-".*."-*"
CONST 		"CONST"
CONTAR		"contar"|"CONTAR"			
CORCH_A 	"["
CORCH_C 	"]"
CTE_BIN		0"b"(0|1)+
CTE_HEX		0"x"({DIGITO}|[A-F])+
CTE_INT  	"-"?{DIGITO}+
CTE_REAL 	"-"?{DIGITO}*{PTO}{DIGITO}+|{DIGITO}+{PTO}{DIGITO}*
CTE_STR 	"\"".*."\""
DIM 		"DIM"|"dim"
ELSE		"else"|"ELSE"|"Else"
END_IF		"ENDIF"|"endif" 
FOREACH_C 	"foreach"|"FOREACH"
GET 		"GET"|"get"
ID		{LETRA}({LETRA}|{DIGITO})*
IF_C		"if"|"IF"|"If"
INTEGER		"integer"|"int"|"Integer"|"INTEGER"
LLAVE_A		"{"
LLAVE_C		"}"
OP_ASIG		":="|":"
OP_DIF		"-"
OP_DIV		"/"
OP_MUL		"*"
OP_SUM		"+"
PAR_A		"("
PAR_C		")"
PTO			"."
PUT 		"PUT"|"put"
REAL		"real"|"float"|"Float"|"FLOAT"
STRING		"string"|"String"|"STRING"
VOID		"void"
WHILE_C 	"while"|"WHILE"|"While"

%%
{AS} 				{printf ("\nDetecto AS ' %s ' en linea %d\n",yytext,yylineno); return (AS);}
{CIERRE_SENT}			{printf ("\nDetecto CIERRE_SENT ' %s ' en linea %d\n",yytext,yylineno); return (CIERRE_SENT);}
{CMP_AND}			{printf ("\nDetecto CMP_AND ' %s ' en linea %d\n",yytext,yylineno); return (CMP_AND);}
{CMP_DIST}			{printf ("\nDetecto CMP_DIST ' %s ' en linea %d\n",yytext,yylineno); return (CMP_DIST);}
{CMP_IGUAL}			{printf ("\nDetecto CMP_IGUAL ' %s ' en linea %d\n",yytext,yylineno);} return (CMP_IGUAL);	
{CMP_MA_IGUAL}			{printf ("\nDetecto CMP_MA_IGUAL ' %s ' en linea %d\n",yytext,yylineno); return (CMP_MA_IGUAL);}  
{CMP_MA}			{printf ("\nDetecto CMP_MA ' %s ' en linea %d\n",yytext,yylineno); return (CMP_MA);}
{CMP_ME_IGUAL}			{printf ("\nDetecto CMP_ME_IGUAL ' %s ' en linea %d\n",yytext,yylineno); return (CMP_ME_IGUAL);} 	
{CMP_ME}			{printf ("\nDetecto CMP_ME ' %s ' en linea %d\n",yytext,yylineno); return (CMP_ME);}
{CMP_NOT}			{printf ("\nDetecto NOT ' %s ' en linea %d\n",yytext,yylineno); return (CMP_NOT);}
{CMP_OR}			{printf ("\nDetecto CMP_OR ' %s ' en linea %d\n",yytext,yylineno); return (CMP_OR);}
{COMA}				{printf ("\nDetecto COMA ' %s ' en linea %d\n",yytext,yylineno); return (COMA);}
{COMENTARIOS}
{CONST} 			{printf ("\nDetecto CONST ' %s ' en linea %d\n",yytext,yylineno); return (CONST);}
{CORCH_A}			{printf ("\nDetecto CORCH_A ' %s ' en linea %d\n",yytext,yylineno); return (CORCH_A);}
{CORCH_C}			{printf ("\nDetecto CORCH_C ' %s ' en linea %d\n",yytext,yylineno); return (CORCH_C);}
{CTE_BIN}		{
					// el tamaño es 10 porque son dos caracteres para 0b y 8 para unos y ceros
					if (validarTamano(yytext, 10)) {
						printf ("\nDetecto CTE_BIN demasiado larga\n"); 
						exit(1);
					}
					printf ("\nDetecto CTE_BIN ' %s ' en linea %d\n",yytext,yylineno); 
					insertarEnTablaDeSimbolos(yytext, "bin");
					return (CTE_BIN);
				}  
{CTE_HEX}		{
					if (validarTamano(yytext, 6)) {
						printf ("\nDetecto CTE_HEX demasiado larga\n"); 
						exit(1);
					}

					printf ("\nDetecto CTE_HEX ' %s ' en linea %d\n",yytext,yylineno);
					insertarEnTablaDeSimbolos(yytext, "hex");
					return (CTE_HEX);
				}  
{CTE_INT}		{
					int valor = atoi(yytext);
					if (valor > 65536) {
						printf ("\nDetecto CTE_INT demasiado grande\n"); 
						exit(1);
					} else if (valor < -65536) {
						printf ("\nDetecto CTE_INT demasiado chica\n"); 
						exit(1);
					}

					printf ("\nDetecto CTE_INT ' %s ' en linea %d\n",yytext,yylineno);
					insertarEnTablaDeSimbolos(yytext, "int");
					return (CTE_INT);
				} 		 	
{CTE_REAL}		{
					long result = strtol(yytext, &yytext, 10);
					if (result > 4294967296) {
						printf ("\nDetecto CTE_REAL demasiado larga\n"); 
						exit(1);
					} else if (result < -4294967296) {
						printf ("\nDetecto CTE_REAL demasiado chica\n"); 
						exit(1);
					}

					printf ("\nDetecto CTE_REAL ' %s ' en linea %d\n",yytext,yylineno);
					insertarEnTablaDeSimbolos(yytext, "real");
					return (CTE_REAL);
				}
{CTE_STR}		{
					if (validarTamano(yytext, 30)) {
						printf ("\nDetecto CTE_STR demasiado larga\n"); 
						exit(1);
					}

					printf ("\nDetecto CTE_STR ' %s ' en linea %d\n",yytext,yylineno);
					insertarEnTablaDeSimbolos(yytext, "string");
					return (CTE_STR); 	
				}  
{DIM}				{printf ("\nDetecto DIM ' %s ' en linea %d\n",yytext,yylineno); return (DIM);}
{ELSE}				{printf ("\nDetecto ELSE ' %s ' en linea %d\n",yytext,yylineno); return (ELSE);}
{END_IF}			{printf ("\nDetecto END_IF ' %s ' en linea %d\n",yytext,yylineno); return (END_IF);}
{FOREACH_C}			{printf ("\nDetecto FOREACH_C ' %s ' en linea %d\n",yytext,yylineno); return (FOREACH_C);}  
{GET} 				{printf ("\nDetecto GET ' %s ' en linea %d\n",yytext,yylineno); return (GET);}
{CONTAR} 			{printf ("\nDetecto contar ' %s ' en linea %d\n",yytext,yylineno); return (CONTAR);}
{IF_C}				{printf ("\nDetecto IF_C ' %s ' en linea %d\n",yytext,yylineno);} return (IF_C);	
{INTEGER}			{printf ("\nDetecto INTEGER ' %s ' en linea %d\n",yytext,yylineno); return (INTEGER);}
{LLAVE_A}			{printf ("\nDetecto LLAVE_A ' %s ' en linea %d\n",yytext,yylineno); return (LLAVE_A);} 	
{LLAVE_C}			{printf ("\nDetecto LLAVE_C ' %s ' en linea %d\n",yytext,yylineno); return (LLAVE_C);}
{OP_ASIG}			{printf ("\nDetecto OP_ASIG ' %s ' en linea %d\n",yytext,yylineno); return (OP_ASIG);}
{OP_DIF}			{printf ("\nDetecto OP_DIF ' %s ' en linea %d\n",yytext,yylineno); return (OP_DIF);}
{OP_DIV}			{printf ("\nDetecto OP_DIV ' %s ' en linea %d\n",yytext,yylineno); return (OP_DIV);}
{OP_MUL}			{printf ("\nDetecto OP_MUL ' %s ' en linea %d\n",yytext,yylineno); return (OP_MUL);}
{OP_SUM}			{printf ("\nDetecto OP_SUM ' %s ' en linea %d\n",yytext,yylineno); return (OP_SUM);}
{PAR_A}				{printf ("\nDetecto PAR_A ' %s ' en linea %d\n",yytext,yylineno); return (PAR_A);}
{PAR_C}				{printf ("\nDetecto PAR_C ' %s ' en linea %d\n",yytext,yylineno); return (PAR_C);}
{PTO}				{printf ("\nDetecto PTO ' %s ' en linea %d\n",yytext,yylineno); return (PTO);}
{PUT} 				{printf ("\nDetecto PUT ' %s ' en linea %d\n",yytext,yylineno); return (PUT);}
{REAL}				{printf ("\nDetecto REAL ' %s ' en linea %d\n",yytext,yylineno); return (REAL);}
{STRING}			{printf ("\nDetecto STRING ' %s ' en linea %d\n",yytext,yylineno); return (STRING);}
{VOID}				{printf ("\nDetecto VOID ' %s ' en linea %d\n",yytext,yylineno); return (VOID);}	 	
{WHILE_C}			{printf ("\nDetecto WHILE_C ' %s ' en linea %d\n",yytext,yylineno); return (WHILE_C);}  
{ID}				{
						printf ("\nDetecto ID ' %s ' en linea %d\n",yytext,yylineno); 
						insertarEnTablaDeSimbolos(yytext, "id");
					
						return (ID);
					}

"\n"
"\t"
"\n\t"
"\r\n"
" "
. 				{printf("\nERROR! en linea %d CARACTER NO DETECTADO: %s",yylineno,yytext);}
%%

int validarTamano(char* texto, int tamano){
	if (strlen(texto) > tamano) {
		return 1;
	}

	return 0;
}

int insertarEnTablaDeSimbolos(char* lexema, char* tipo) {
   fprintf(tablaDeSimbolos, "%-30s\t%-15s\n", lexema, tipo);
   return 0;
}
