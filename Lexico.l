%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	FILE *yyin;
	char *yyltext;
	int TK_INVALID_STRING;
	int validarTamano(char*, int);
	FILE * tablaDeSimbolos;
	int insertarEnTablaDeSimbolos(char* lexema, char* tipo, char* valor, int longitud);
	int verificarEnTablaDeSimbolos(char* lexema, char* tipo);

// tabla de simbolos
	char** nombreTS;
	char** tipoTS;
	char** valorTS;
	int* longitudTS;
	int indiceActualTs;

	void removerComillas(char* str);
	char* reemplazarCaracter(char* str, char c, char r);
	int hexadecimalADecimal(char *cadenaHexadecimal, int longitud);
	int caracterHexadecimalADecimal(char caracter);
	int binarioADecimal(char *cadenaBinaria, int longitud);
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


					char* stringDecimal = malloc(sizeof(char)*30);
					sprintf(stringDecimal, "%s", yytext+2);
					
					int binario = binarioADecimal(stringDecimal, strlen(stringDecimal));
					char* nueva = malloc(sizeof(char)*30);

					sprintf(nueva, "%d", binario);

					printf ("\nDetecto CTE_BIN ' %s ' en linea %d\n",yytext,yylineno); 
					insertarEnTablaDeSimbolos(yytext, "bin", nueva, strlen(yytext));
					yylval.bin=strdup(yytext);
					return (CTE_BIN);
				}  
{CTE_HEX}		{
					if (validarTamano(yytext, 6)) {
						printf ("\nDetecto CTE_HEX demasiado larga\n"); 
						exit(1);
					}

					printf ("\nDetecto CTE_HEX ' %s ' en linea %d\n",yytext,yylineno);

					char* stringDecimal = malloc(sizeof(char)*30);
					sprintf(stringDecimal, "%s", yytext+2);
					
					int decimal = hexadecimalADecimal(stringDecimal, strlen(stringDecimal));
					char* nueva = malloc(sizeof(char)*30);

					sprintf(nueva, "%d", decimal);
					insertarEnTablaDeSimbolos(yytext, "int", nueva, strlen(yytext));
					yylval.hex=strdup(yytext);
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
					insertarEnTablaDeSimbolos(yytext, "int", yytext, strlen(yytext));
					yylval.num=strdup(yytext);
					return (CTE_INT);
				} 		 	
{CTE_REAL}		{
					char* algo;
					long result = strtol(yytext, &algo, 10);
					if (result > 4294967296) {
						printf ("\nDetecto CTE_REAL demasiado larga\n"); 
						exit(1);
					} else if (result < -4294967296) {
						printf ("\nDetecto CTE_REAL demasiado chica\n"); 
						exit(1);
					}

					printf ("\nDetecto CTE_REAL ' %s ' en linea %d\n",yytext,yylineno);
					char* sinPuntos = malloc(sizeof(char) * 30);
					strcpy(sinPuntos, yytext);
					sinPuntos = reemplazarCaracter(sinPuntos, '.', '_');
					insertarEnTablaDeSimbolos(sinPuntos, "real", yytext, strlen(yytext));
					yylval.real=strdup(sinPuntos);
					return (CTE_REAL);
				}
{CTE_STR}		{
					if (validarTamano(yytext, 30)) {
						printf ("\nDetecto CTE_STR demasiado larga\n"); 
						exit(1);
					}

					printf ("\nDetecto CTE_STR ' %s ' en linea %d\n",yytext,yylineno);
					char* sinComillas = malloc(sizeof(char) * 30);
					strcpy(sinComillas, yytext);
					removerComillas(sinComillas);
					sinComillas = reemplazarCaracter(sinComillas, ' ', '_');
					insertarEnTablaDeSimbolos(sinComillas, "string", yytext, strlen(yytext));
					yylval.string=strdup(sinComillas);
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
						insertarEnTablaDeSimbolos(yytext, "", "", 0);
						yylval.id=strdup(yytext);
					
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

int insertarEnTablaDeSimbolos(char* lexema, char* tipo, char* valor, int longitud) {
	int verificacion = verificarEnTablaDeSimbolos(lexema, tipo);
	if (verificacion == 2) {
		nombreTS[indiceActualTs] = malloc(sizeof(char)*4);
		tipoTS[indiceActualTs] = malloc(sizeof(char)*4);
		valorTS[indiceActualTs] = malloc(sizeof(char)*4);
		strcpy(nombreTS[indiceActualTs], lexema);
		strcpy(tipoTS[indiceActualTs], tipo);
		strcpy(valorTS[indiceActualTs], valor);
		longitudTS[indiceActualTs] = longitud;
		indiceActualTs++;
	} else if (verificacion == 1) {
		printf("Variable declarada con dos tipos diferentes %s %s", lexema, tipo);
		exit(1);
	}

   
   return 0;
}

/*
	devuelve 0 si es valido, 1 si el nombre ya existe pero es de otro tipo y 2 si no existe
*/
int verificarEnTablaDeSimbolos(char* lexema, char* tipo) {

	int i = 0;

	while (i < indiceActualTs) {
		if (strcmp(lexema, nombreTS[i]) == 0) {
			return 0;
		}
		i++;
	}

	return 2;

}


void removerComillas(char* str) {
	char *pr = str, *pw = str;
	while (*pr) {
		*pw = *pr++;
		pw += (*pw != '"');
	}

	*pw = '\0';

}

char* reemplazarCaracter(char* str, char c, char r) {
    char *current_pos = strchr(str,c);
    while (current_pos){
        *current_pos = r;
        current_pos = strchr(current_pos, c);
    }
    return str;
}