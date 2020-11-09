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

	int pilaContar[50];
	int *punteroPilaContar;

	#define apilar(puntero, valor) (*((puntero)++) = (valor))
	#define desapilar(puntero) (*--(puntero))

	char** polacaVec;
	int tamanioDePocala;
	int indiceActual;

	void avanzar();
	void polaca(char* valor);
	void polacaConPos(char* valor, int pos);
	void guardarPolaca();
	int contarAux;
	int aux_contador[];
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
	lista_variables COMA ID 		{polaca(",");polaca($3);printf("\n\t\tlista_variables,ID es lista_variables\n");}
	|ID 							{polaca($1);printf("\n\t\tlista_variables es ID.\n");}
	;
lista_tipos:
	lista_tipos COMA REAL 			{polaca(",");polaca("REAL");printf("\n\t\tlista_tipos,REAL es lista_tipos\n");}
	|lista_tipos COMA INTEGER 		{polaca(",");polaca("INTEGER");printf("\n\t\tlista_tipos,INTEGER es lista_tipos\n");}
	|lista_tipos COMA STRING 		{polaca(",");polaca("STRING");printf("\n\t\tlista_tipos,STRING es lista_tipos\n");}
	|REAL 							{polaca("REAL");printf("\n\t\tlista_tipos es REAL\n");}
	|INTEGER 						{polaca("INTEGER");printf("\n\t\tlista_tipos es INTEGER\n");}
	|STRING 						{polaca("STRING");printf("\n\t\tlista_tipos es STRING\n");}	
	;
seleccion:
	IF_C PAR_A condicion PAR_C LLAVE_A 
	bloque 
	LLAVE_C {polacaConPos(indiceActual + 1, desapilar(punteroPilaIf)); polaca("BI"); apilar(punteroPilaIf, indiceActual); avanzar();} 
	ELSE LLAVE_A bloque LLAVE_C 	{printf("\n\t\tIF CON ELSE\n"); polacaConPos(indiceActual + 1, desapilar(punteroPilaIf));}


	|IF_C  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C 							{printf("\n\t\tIF SIN ELSE\n");}
	|IF_C  PAR_A condicion PAR_C sentencia 											{printf("\n\t\tIF CON UNA SENTENCIA\n");}
	;
iteracion:
	WHILE_C {apilar(punteroPilaWhile, indiceActual); polaca("ET");} PAR_A condicion {apilar(punteroPilaWhile, indiceActual); avanzar();} PAR_C LLAVE_A 
	bloque {polaca("BI"); polacaConPos(indiceActual + 1, desapilar(punteroPilaWhile)); polaca(desapilar(punteroPilaWhile));} 
	LLAVE_C 		{printf("\n\t\twhile(condicion){bloque} es while\n");}
	;
condicion:	
	comparacion CMP_AND comparacion 		{printf("\n\t\tcomparacion AND comparacion  es condicion\n");}
	|comparacion CMP_OR {polacaConPos(indiceActual + 1, desapilar(punteroPilaIf)); apilar(punteroPilaIf, indiceActual); avanzar();} comparacion 		{printf("\n\t\tcomparacion OR comparacion  es condicion\n");}
	|comparacion 							{printf("\n\t\tcomparacion es condicion\n");}
	|CMP_NOT PAR_A comparacion PAR_C 		{printf("\n\t\tcomparacion negada es condicion\n");}
	;
comparacion:
	expresion comparador expresion 			{printf("\n\t\texpresion comparado con expresion es comparacion\n");}
	;
comparador: 
	CMP_MA_IGUAL 		{polaca("CMP");polaca("BLT"); apilar(punteroPilaIf, indiceActual); avanzar();printf("\n\t\t>=  es un comparador\n");}
	|CMP_ME_IGUAL  		{polaca("CMP");polaca("BGT"); apilar(punteroPilaIf, indiceActual); avanzar();printf("\n\t\t<=  es un comparador\n");}
	|CMP_ME				{polaca("CMP");polaca("BGE"); apilar(punteroPilaIf, indiceActual); avanzar();printf("\n\t\t<  es un comparador\n");}
	|CMP_MA				{polaca("CMP");polaca("BLE"); apilar(punteroPilaIf, indiceActual); avanzar();printf("\n\t\t>  es un comparador\n");}
	|CMP_IGUAL			{polaca("CMP");polaca("BNE"); apilar(punteroPilaIf, indiceActual); avanzar();printf("\n\t\t==  es un comparador\n");}
	|CMP_DIST			{polaca("CMP");polaca("BEQ"); apilar(punteroPilaIf, indiceActual); avanzar();printf("\n\t\t<> es un comparador\n");}
	;
asignacion:
	ID {polaca($1);} OP_ASIG expresion CIERRE_SENT 	{polaca("="); printf("\n\t\tID := expresion; es una asignacion\n");}
	;
expresion: 
	expresion OP_SUM termino 		{polaca("+");printf("\n\t\texpresion+termino es expresion\n");}
	|expresion OP_DIF termino 		{polaca("-");printf("\n\t\texpresion-termino es expresion\n");}
	|termino						{printf("\n\t\ttermino es expresion\n");}
termino:
	termino OP_MUL factor  			{polaca("*");printf("\n\t\ttermino * factor es termino\n");}
	|termino OP_DIV factor 			{polaca("/");printf("\n\t\ttermino / factor es termino\n");}
	|factor							{printf("\n\t\tfactor es termino\n");}
	;
factor:
	 ID 					{$$=$1;polaca($1);printf("\n\t\tID es es factor\n");}
	|CTE_INT				{$$=$1;polaca($1);printf("\n\t\tCTE_INT ES factor\n");}
	|CTE_REAL				{$$=$1;polaca($1);printf("\n\t\tCTE_REAL ES factor\n");}
	|CTE_STR				{$$=$1;polaca($1);printf("\n\t\tCTE_STR ES factor\n");}
	|CTE_BIN				{$$=$1;polaca($1);printf("\n\t\tCTE_BIN ES factor\n");}
	|CTE_HEX				{$$=$1;polaca($1);printf("\n\t\tCTE_HEX ES factor\n");}
	|PAR_A expresion PAR_C	{$$=$2;polaca($2);printf("\n\t\t (expresion) ES factor\n");}
	|contar 				{printf("\n\t\tcontar es factor\n");}
	;
contar:
	CONTAR {polaca("@contador");polaca("0");polaca("=");polaca("@aux");} PAR_A expresion {polaca("=");} CIERRE_SENT CORCH_A el
	 CORCH_C PAR_C {printf("\n\t\tfuncion contar\n");}
el:
	el COMA factor {
		polaca("@aux");
		polaca($3);
		polaca("CMP");
		polaca("BNE");
		apilar(punteroPilaContar, indiceActual); avanzar(); 
		polaca("@contador"); 
		polaca("1"); 
		polaca("+");
		polacaConPos(indiceActual, desapilar(punteroPilaContar));
	} 
	|factor { 
		polaca("@aux");
		polaca($1);
		polaca("CMP");
		polaca("BNE");
		apilar(punteroPilaContar, indiceActual); avanzar(); 
		polaca("@contador"); 
		polaca("1"); 
		polaca("+");
		polacaConPos(indiceActual, desapilar(punteroPilaContar));
		} 
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
		punteroPilaContar = pilaContar;
		tamanioDePocala = 1000;
		polacaVec = malloc(tamanioDePocala * sizeof(*polacaVec));

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

void polaca(char* valor) {
	polacaConPos(valor, indiceActual);
    indiceActual++;
}

void polacaConPos(char* valor, int pos) {
	if (pos >= tamanioDePocala) {
		polacaVec = realloc(polacaVec, (2 * tamanioDePocala) * sizeof(*polacaVec));
	}

	polacaVec[pos] = valor;
}

void guardarPolaca() {
	int i = 0;
	while (i < indiceActual) {
		fprintf(intermedia, "%s ; ", polacaVec[i]);
		i++;
	}
}

/*
void insertar_en_polaca (char* valor){
	FILE *fp;
	fp = fopen ("intermedia.txt", "a");
	if (fp==NULL) {printf ("File error",stderr); exit (1);}
	fwrite(tabla1, 4, sizeof(, mihandle);
	
	fclose ( fp );
}*/


