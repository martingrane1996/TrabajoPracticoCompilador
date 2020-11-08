%{
	#include <stdio.h>
	#include <stdlib.h>
	#include "y.tab.h"
	int stopparser=0;
	FILE *yyin;
	int yylex();
	int yyerror();
	FILE * tablaDeSimbolos;
	FILE * intermedia;

	int pilaIf[50];
	int *punteroPilaIf;

	#define apilar(puntero, valor) (*((puntero)++) = (valor))
	#define desapilar(puntero) (*--(puntero))

	char** polaca;
	int tamanioDePocala;
	int indiceActual;

	void avanzar();
	void insertarEnPolaca(char* valor);
	void insertarEnPolacaConPosicion(char* valor, int pos);
	void guardarPolaca();
	int contarAux;
%}

%union {
char* id;
char* num;
char* hex;
char* bin;
char* real; 
char* string;
}

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
%token DIGITO
%token DIM					  
%token ELSE					   
%token END_IF				 
%token FOREACH_C
%token GET 					  				  
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

%token <id> ID
%token <num> CTE_INT
%token <real> CTE_REAL
%token <string> CTE_STR
%token <hex> CTE_BIN
%token <bin> CTE_HEX 

%%
programa:
	bloque {guardarPolaca(); printf("\n\t\tCompilacion exitosa\n");}
bloque:
	bloque sentencia 			{printf("\n\t\tmas de una sentencia\n");}
	|sentencia 				{printf("\n\t\tsentencia\n");}
	
	;
sentencia:
	asignacion 				{printf("\n\t\t  asig. es sentencia \n");}
	|declaracion 				{printf("\n\t\t   declaracion es sentencia\n");}
	|iteracion 				{printf("\n\t\t iteracion es sentencia\n");}
	|seleccion 				{printf("\n\t\t seleccion  es sentencia\n");}
	|PUT CTE_STR CIERRE_SENT		{printf("\n\t\timprimir cadenas es sentencia\n");}
	|PUT CTE_INT CIERRE_SENT		{printf("\n\t\timprimir INT es sentencia.\n");}
	|PUT CTE_REAL CIERRE_SENT		{printf("\n\t\timprimir REAL es sentencia.\n");}
	|PUT ID CIERRE_SENT			{printf("\n\t\timprimir ID es sentencia.\n");}
	|GET ID CIERRE_SENT			{printf("\n\t\tGET ID es sentencia.\n");}
	;
declaracion: 
	DIM CMP_ME lista_variables CMP_MA AS CMP_ME lista_tipos CMP_MA 		{printf("\n\t\tUNA DECLARACION\n");}
	;
lista_variables:
	lista_variables COMA ID 		{printf("\n\t\tlista_variables,ID es lista_variables\n");}
	|ID 					{printf("\n\t\tlista_variables es ID.\n");}
	;
lista_tipos:
	lista_tipos COMA REAL 			{printf("\n\t\tlista_tipos,REAL es lista_tipos\n");}
	|lista_tipos COMA INTEGER 		{printf("\n\t\tlista_tipos,INTEGER es lista_tipos\n");}
	|lista_tipos COMA STRING 		{printf("\n\t\tlista_tipos,STRING es lista_tipos\n");}
	|REAL 					{printf("\n\t\tlista_tipos es REAL\n");}
	|INTEGER 				{printf("\n\t\tlista_tipos es INTEGER\n");}
	|STRING 				{printf("\n\t\tlista_tipos es STRING\n");}	
	;
seleccion:
	IF_C PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C ELSE LLAVE_A bloque LLAVE_C 	{printf("\n\t\tIF CON ELSE\n");}
	|IF_C  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C 					{printf("\n\t\tIF SIN ELSE\n");}
	|IF_C  PAR_A condicion PAR_C sentencia 							{printf("\n\t\tIF CON UNA SENTENCIA\n");}
	;
iteracion:
	WHILE_C PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C 		{printf("\n\t\twhile(condicion){bloque} es while\n");}
	;
condicion:	
	comparacion CMP_AND comparacion 		{printf("\n\t\tcomparacion AND comparacion  es condicion\n");}
	|comparacion CMP_OR comparacion 		{printf("\n\t\tcomparacion OR comparacion  es condicion\n");}
	|comparacion 					{printf("\n\t\tcomparacion es condicion\n");}
	|CMP_NOT PAR_A comparacion PAR_C 		{printf("\n\t\tcomparacion negada es condicion\n");}
	;
comparacion:
	expresion comparador expresion 			{printf("\n\t\texpresion comparado con expresion es comparacion\n");}
	;
comparador: 
	CMP_MA_IGUAL 		{printf("\n\t\t>=  es un comparador\n");}
	|CMP_ME_IGUAL  		{printf("\n\t\t<=  es un comparador\n");}
	|CMP_ME			{printf("\n\t\t<  es un comparador\n");}
	|CMP_MA			{printf("\n\t\t>  es un comparador\n");}
	|CMP_IGUAL		{printf("\n\t\t==  es un comparador\n");}
	|CMP_AND		{printf("\n\t\tAND  es un comparador\n");}
	|CMP_OR			{printf("\n\t\tOR es un comparador\n");}
	|CMP_DIST		{printf("\n\t\t!= es un comparador\n");}
	;
asignacion:
	ID OP_ASIG expresion CIERRE_SENT 	{printf("\n\t\tID := expresion; es una asignacion\n");}
	;
expresion: 
	expresion OP_SUM termino 		{printf("\n\t\texpresion+termino es expresion\n");}
	|expresion OP_DIF termino 		{printf("\n\t\texpresion-termino es expresion\n");}
	|termino				{printf("\n\t\ttermino es expresion\n");}
termino:
	termino OP_MUL factor  			{printf("\n\t\ttermino * factor es termino\n");}
	|termino OP_DIV factor 			{printf("\n\t\ttermino / factor es termino\n");}
	|factor					{printf("\n\t\tfactor es termino\n");}
	;
factor:
	 ID 					{printf("\n\t\tID es es factor\n"); printf("Probando: %s",$1);}
	|CTE_INT				{printf("\n\t\tCTE_INT ES factor\n"); printf("Probando: %s",$1);}
	|CTE_REAL				{printf("\n\t\tCTE_REAL ES factor\n"); printf("Probando: %s",$1);}
	|CTE_STR				{printf("\n\t\tCTE_STR ES factor\n"); printf("Probando: %s",$1);}
	|CTE_BIN				{printf("\n\t\tCTE_BIN ES factor\n"); printf("Probando: %s",$1);}
	|CTE_HEX				{printf("\n\t\tCTE_HEX ES factor\n"); printf("Probando: %s",$1);}
	|PAR_A expresion PAR_C			{printf("\n\t\t (expresion) ES factor\n");}
	|contar 				{printf("\n\t\tcontar es factor\n");}
	;
contar:
	CONTAR {contarAux = 0; insertarEnPolaca("contar");} PAR_A expresion CIERRE_SENT CORCH_A el CORCH_C PAR_C		{printf("\n\t\tfuncion contar\n");}
el:
	el COMA factor
	|factor
	;
%%

int main(int argc,char *argv[]){
	yyin = fopen(argv[1],"rt");
	if( yyin == NULL){
		printf("\n\t\t No se puede abrir el archivo! ' %s '",argv[1]);
	}else{
		tablaDeSimbolos = fopen ("ts.txt", "w");
		intermedia = fopen ("intermedia.txt", "w");
		indiceActual = 0;
		
		if (tablaDeSimbolos == NULL) {
			printf("\n\t\t No se crear la tabla de simbolos!");
			exit(1);
		}

		fprintf(tablaDeSimbolos, "%-30s\t%-15s\t%-15s\t%-15s\n", "Nombre", "Tipo", "Valor", "Longitud");

		// inicializo las pilas
		punteroPilaIf = pilaIf;
		tamanioDePocala = 1000;
		polaca = malloc(tamanioDePocala * sizeof(*polaca));

		yyparse();
		fclose(tablaDeSimbolos);
		fclose(intermedia);
	}
	fclose(yyin);
	return 0;
}

int yyerror(void){
	printf ("ERROR SINTACTICO! \n");
	exit(1);
	return 0;
}

void avanzar() {
    indiceActual++;
}

void insertarEnPolaca(char* valor) {
	insertarEnPolacaConPosicion(valor, indiceActual);
    indiceActual++;
}

void insertarEnPolacaConPosicion(char* valor, int pos) {
	if (pos >= tamanioDePocala) {
		polaca = realloc(polaca, (2 * tamanioDePocala) * sizeof(*polaca));
	}

	polaca[pos] = valor;
}

void guardarPolaca() {
	int i = 1;
	fprintf(intermedia, "%s ;", polaca[0]);
	int anteUltimo = indiceActual - 1;
	while (i < anteUltimo) {
		fprintf(intermedia, " %s ;", polaca[i]);
		i++;
	}
	fprintf(intermedia, " %s", polaca[indiceActual]);
}


