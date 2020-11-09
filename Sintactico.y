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

	int pilaWhile[50];
	int *punteroPilaWhile;

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
%type <string> expresion
%type <string> termino
%type <string> factor

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
	lista_variables COMA ID 		{insertarEnPolaca($1);insertarEnPolaca($2);printf("\n\t\tlista_variables,ID es lista_variables\n");}
	|ID 							{insertarEnPolaca($1);printf("\n\t\tlista_variables es ID.\n");}
	;
lista_tipos:
	lista_tipos COMA REAL 			{insertarEnPolaca($2);insertarEnPolaca($3);printf("\n\t\tlista_tipos,REAL es lista_tipos\n");}
	|lista_tipos COMA INTEGER 		{insertarEnPolaca($2);insertarEnPolaca($3);printf("\n\t\tlista_tipos,INTEGER es lista_tipos\n");}
	|lista_tipos COMA STRING 		{insertarEnPolaca($2);insertarEnPolaca($3);printf("\n\t\tlista_tipos,STRING es lista_tipos\n");}
	|REAL 							{insertarEnPolaca($1);printf("\n\t\tlista_tipos es REAL\n");}
	|INTEGER 						{insertarEnPolaca($1);printf("\n\t\tlista_tipos es INTEGER\n");}
	|STRING 						{insertarEnPolaca($1);printf("\n\t\tlista_tipos es STRING\n");}	
	;
seleccion:
	IF_C PAR_A condicion PAR_C LLAVE_A 
	{apilar(punteroPilaIf, indiceActual); avanzar();} 
	bloque 
	LLAVE_C {insertarEnPolacaConPosicion(indiceActual + 1, desapilar(punteroPilaIf)); apilar(punteroPilaIf, indiceActual); avanzar();} 
	ELSE LLAVE_A bloque LLAVE_C 	{printf("\n\t\tIF CON ELSE\n"); insertarEnPolacaConPosicion(indiceActual + 1, desapilar(punteroPilaIf));}


	|IF_C  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C 							{printf("\n\t\tIF SIN ELSE\n");}
	|IF_C  PAR_A condicion PAR_C sentencia 											{printf("\n\t\tIF CON UNA SENTENCIA\n");}
	;
iteracion:
	WHILE_C {apilar(punteroPilaWhile, indiceActual); insertarEnPolaca("ET");} PAR_A condicion {apilar(punteroPilaWhile, indiceActual); avanzar();} PAR_C LLAVE_A 
	bloque {insertarEnPolaca("BI"); insertarEnPolacaConPosicion(indiceActual + 1, desapilar(punteroPilaWhile)); insertarEnPolaca(desapilar(punteroPilaWhile));} 
	LLAVE_C 		{printf("\n\t\twhile(condicion){bloque} es while\n");}
	;
condicion:	
	comparacion CMP_AND comparacion 		{insertarEnPolaca($2);printf("\n\t\tcomparacion AND comparacion  es condicion\n");}
	|comparacion CMP_OR comparacion 		{insertarEnPolaca($2);printf("\n\t\tcomparacion OR comparacion  es condicion\n");}
	|comparacion 							{printf("\n\t\tcomparacion es condicion\n");}
	|CMP_NOT PAR_A comparacion PAR_C 		{insertarEnPolaca($1);printf("\n\t\tcomparacion negada es condicion\n");}
	;
comparacion:
	expresion comparador expresion 			{insertarEnPolaca($1);insertarEnPolaca($3);printf("\n\t\texpresion comparado con expresion es comparacion\n");}
	;
comparador: 
	CMP_MA_IGUAL 		{insertarEnPolaca("CMP");insertarEnPolaca("BLT");printf("\n\t\t>=  es un comparador\n");}
	|CMP_ME_IGUAL  		{insertarEnPolaca("CMP");insertarEnPolaca("BGT");printf("\n\t\t<=  es un comparador\n");}
	|CMP_ME				{insertarEnPolaca("CMP");insertarEnPolaca("BGE");printf("\n\t\t<  es un comparador\n");}
	|CMP_MA				{insertarEnPolaca("CMP");insertarEnPolaca("BLE");printf("\n\t\t>  es un comparador\n");}
	|CMP_IGUAL			{insertarEnPolaca("CMP");insertarEnPolaca("BNE");printf("\n\t\t==  es un comparador\n");}
	|CMP_DIST			{insertarEnPolaca("CMP");insertarEnPolaca("BEQ");printf("\n\t\t<> es un comparador\n");}
	;
asignacion:
	ID OP_ASIG expresion CIERRE_SENT 	{printf("\n\t\tID := expresion; es una asignacion\n");}
	;
expresion: 
	expresion OP_SUM termino 		{insertarEnPolacainsertarEnPolaca("+");printf("\n\t\texpresion+termino es expresion\n");}
	|expresion OP_DIF termino 		{insertarEnPolaca("-");printf("\n\t\texpresion-termino es expresion\n");}
	|termino						{printf("\n\t\ttermino es expresion\n");}
termino:
	termino OP_MUL factor  			{insertarEnPolaca("*");printf("\n\t\ttermino * factor es termino\n");}
	|termino OP_DIV factor 			{insertarEnPolaca("/");printf("\n\t\ttermino / factor es termino\n");}
	|factor							{printf("\n\t\tfactor es termino\n");}
	;
factor:
	 ID 					{$$=$1;insertarEnPolaca($1);printf("\n\t\tID es es factor\n");}
	|CTE_INT				{$$=$1;insertarEnPolaca($1);printf("\n\t\tCTE_INT ES factor\n");}
	|CTE_REAL				{$$=$1;insertarEnPolaca($1);printf("\n\t\tCTE_REAL ES factor\n");}
	|CTE_STR				{$$=$1;insertarEnPolaca($1);printf("\n\t\tCTE_STR ES factor\n");}
	|CTE_BIN				{$$=$1;insertarEnPolaca($1);printf("\n\t\tCTE_BIN ES factor\n");}
	|CTE_HEX				{$$=$1;insertarEnPolaca($1);printf("\n\t\tCTE_HEX ES factor\n");}
	|PAR_A expresion PAR_C	{$$=$2;insertarEnPolaca($2);printf("\n\t\t (expresion) ES factor\n");}
	|contar 				{insertarEnPolaca($1);printf("\n\t\tcontar es factor\n");}
	;
contar:
	CONTAR {contarAux = 0;} PAR_A expresion {contarAux=$3;} CIERRE_SENT CORCH_A el {contarAux = aux_contador[contarAux];} CORCH_C PAR_C {printf("\n\t\tfuncion contar\n");insertarEnPolaca(contarAux);$$=contarAux}
el:
	el COMA factor {aux_contador[$3]++;}
	|factor {aux_contador[$1]++;}
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
		punteroPilaWhile = pilaWhile;
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

/*
void insertar_en_polaca (char* valor){
	FILE *fp;
	fp = fopen ("intermedia.txt", "a");
	if (fp==NULL) {printf ("File error",stderr); exit (1);}
	fwrite(tabla1, 4, sizeof(, mihandle);
	
	fclose ( fp );
}*/


