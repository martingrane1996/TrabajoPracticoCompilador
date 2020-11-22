%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include "y.tab.h"
	int stopparser=0;
	FILE *yyin;
	int yylex();
	int yyerror();
	FILE * tablaDeSimbolos;
	FILE * intermedia;

	int pilaIf[50];
	int *ptrIf;

	int pilaWhile[50];
	int *ptrWhile;

	int pilaCondicion[50];
	int *ptrCondicion;

	int pilaContar[50];
	int *ptrContar;

	char* pilaDeVariables[50];
	char* *ptrVariables;
	int contadorVar;

	char* pilaDeTipos[50];
	char* *ptrTipos;
	int contadorTipos;

	#define apilar(puntero, valor) (*((puntero)++) = (valor))
	#define desapilar(puntero) (*--(puntero))

	// tabla de simbolos
	char** nombreTS;
	char** tipoTS;
	char** valorTS;
	int* longitudTS;

	int indiceActualTs;

	char** polacaVec;
	int tamanioDePocala;
	int indiceActual;

	void avanzar();
	void polaca(char* valor);
	void polacaNumerica(int valor);
	void polacaNumericaConPos(int valor, int pos);
	void polacaConPos(char* valor, int pos);
	char* invertirCondicion(char* condicion);
	void guardarPolaca();
	void generarAssembler();
	void actualizarTS();
	int buscarIndice(char* lexema);
	char *str;
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
%type <string> comparador
%type <string> contar
%type <string> comparacion

%%
programa:
	bloque {printf("\n\t\tCompilacion exitosa\n"); guardarPolaca(); generarAssembler(indiceActual);}
bloque:
	bloque sentencia 			{printf("\n\t\tmas de una sentencia\n");}
	|sentencia 				{printf("\n\t\tsentencia\n");}
	
	;
sentencia:
	asignacion 				{printf("\n\t\t  asig. es sentencia \n");}
	|declaracion 				{printf("\n\t\t   declaracion es sentencia\n");}
	|iteracion 				{printf("\n\t\t iteracion es sentencia\n");}
	|seleccion 				{printf("\n\t\t seleccion  es sentencia\n");}
	|PUT CTE_STR CIERRE_SENT		{polaca("PUT"); polaca($2); printf("\n\t\timprimir cadenas es sentencia\n");}
	|PUT CTE_INT CIERRE_SENT		{polaca("PUT"); polaca($2); printf("\n\t\timprimir INT es sentencia.\n");}
	|PUT CTE_REAL CIERRE_SENT		{polaca("PUT"); polaca($2); printf("\n\t\timprimir REAL es sentencia.\n");}
	|PUT ID CIERRE_SENT			{polaca("PUT"); polaca($2); printf("\n\t\timprimir ID es sentencia.\n");}
	|GET ID CIERRE_SENT			{polaca("GET"); polaca($2); printf("\n\t\tGET ID es sentencia.\n");}
	;
declaracion: 
	DIM CMP_ME lista_variables CMP_MA AS CMP_ME lista_tipos CMP_MA 		{actualizarTS();printf("\n\t\tUNA DECLARACION\n");}
	;
lista_variables:
	lista_variables COMA ID 		{polaca(",");polaca($3);printf("\n\t\tlista_variables,ID es lista_variables\n");apilar(ptrVariables, $3); contadorVar++;}
	|ID 							{polaca($1);printf("\n\t\tlista_variables es ID.\n");apilar(ptrVariables, $1); contadorVar++;}
	;
lista_tipos:
	lista_tipos COMA REAL 			{polaca(",");polaca("REAL");printf("\n\t\tlista_tipos,REAL es lista_tipos\n");apilar(ptrTipos, "real"); contadorTipos++;}
	|lista_tipos COMA INTEGER 		{polaca(",");polaca("INTEGER");printf("\n\t\tlista_tipos,INTEGER es lista_tipos\n");apilar(ptrTipos, "int"); contadorTipos++;}
	|lista_tipos COMA STRING 		{polaca(",");polaca("STRING");printf("\n\t\tlista_tipos,STRING es lista_tipos\n");apilar(ptrTipos, "string"); contadorTipos++;}
	|REAL 							{polaca("REAL");printf("\n\t\tlista_tipos es REAL\n");apilar(ptrTipos, "real"); contadorTipos++;}
	|INTEGER 						{polaca("INTEGER");printf("\n\t\tlista_tipos es INTEGER\n");apilar(ptrTipos, "int"); contadorTipos++;}
	|STRING 						{polaca("STRING");printf("\n\t\tlista_tipos es STRING\n");apilar(ptrTipos, "string"); contadorTipos++;}	
	;
seleccion:
	IF_C PAR_A condicion PAR_C LLAVE_A 
	bloque 
	LLAVE_C {polaca("BI"); polacaNumericaConPos(indiceActual + 1, desapilar(ptrCondicion)); apilar(ptrIf, indiceActual); avanzar();} ELSE LLAVE_A bloque LLAVE_C 	{printf("\n\t\tIF CON ELSE\n"); polacaNumericaConPos(indiceActual, desapilar(ptrIf));}


	|IF_C  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C 							{polacaNumericaConPos(indiceActual, desapilar(ptrCondicion)); printf("\n\t\tIF SIN ELSE\n");} 
	|IF_C  PAR_A condicion PAR_C sentencia 											{polacaNumericaConPos(indiceActual, desapilar(ptrCondicion)); printf("\n\t\tIF CON UNA SENTENCIA\n");}
	;
iteracion:
	WHILE_C {apilar(ptrWhile, indiceActual); polaca("ET");} PAR_A condicion PAR_C LLAVE_A 
	bloque {polaca("BI"); polacaNumericaConPos(indiceActual + 1, desapilar(ptrCondicion)); polacaNumerica(desapilar(ptrWhile));} 
	LLAVE_C 		{printf("\n\t\twhile(condicion){bloque} es while\n");}
	;
condicion:	
	comparacion CMP_AND {polaca($1); apilar(ptrCondicion, indiceActual); avanzar();} comparacion 		{polacaNumericaConPos(indiceActual + 2, desapilar(ptrCondicion)); polaca(invertirCondicion($1)); polacaNumerica(indiceActual + 3); polaca("BI"); apilar(ptrCondicion, indiceActual); avanzar();printf("\n\t\tcomparacion AND comparacion  es condicion\n");}
	|comparacion CMP_OR {polaca(invertirCondicion($1)); apilar(ptrCondicion, indiceActual); avanzar();} comparacion 		{polaca($1); polacaNumericaConPos(indiceActual + 1, desapilar(ptrCondicion)); apilar(ptrCondicion, indiceActual); avanzar(); printf("\n\t\tcomparacion OR comparacion  es condicion\n");}
	|comparacion 							{polaca($1); apilar(ptrCondicion, indiceActual); avanzar(); printf("\n\t\tcomparacion es condicion\n");}
	|CMP_NOT PAR_A comparacion PAR_C 		{polaca(invertirCondicion($3)); apilar(ptrCondicion, indiceActual); avanzar(); printf("\n\t\tcomparacion negada es condicion\n");}
	;
comparacion:
	expresion comparador expresion 			{$$=$2; polaca("CMP"); printf("\n\t\texpresion comparado con expresion es comparacion\n");}
	;
comparador: 
	CMP_MA_IGUAL 		{$$="BLT"; printf("\n\t\t>=  es un comparador\n");}
	|CMP_ME_IGUAL  		{$$="BGT"; printf("\n\t\t<=  es un comparador\n");}
	|CMP_ME				{$$="BGE"; printf("\n\t\t<  es un comparador\n");}
	|CMP_MA				{$$="BLE"; printf("\n\t\t>  es un comparador\n");}
	|CMP_IGUAL			{$$="BNE"; printf("\n\t\t==  es un comparador\n");}
	|CMP_DIST			{$$="BEQ"; printf("\n\t\t<> es un comparador\n");}
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
	 CORCH_C PAR_C {polaca("@contador"); printf("\n\t\tfuncion contar\n");}
el:
	el COMA factor {
		polaca("@aux");
		polaca("CMP");
		polaca("BNE");
		avanzar(); 
		polaca("@contador"); 
		polaca("1"); 
		polaca("+");
		polacaNumericaConPos(indiceActual, indiceActual - 4);
	} 
	|factor { 
		polaca("@aux");
		polaca("CMP");
		polaca("BNE");
		apilar(ptrContar, indiceActual); 
		avanzar(); 
		polaca("@contador"); 
		polaca("1"); 
		polaca("+");
		polacaNumericaConPos(indiceActual, indiceActual - 4);
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
		indiceActualTs = 0;
		contadorTipos = 0;
		contadorVar = 0;
		
		if (tablaDeSimbolos == NULL) {
			printf("\n\t\t No se crear la tabla de simbolos!");
			exit(1);
		}

		fprintf(tablaDeSimbolos, "%-30s\t%-15s\t%-15s\t%-15s\n", "Nombre", "Tipo", "Valor", "Longitud");

		// inicializo las pilas
		ptrIf = pilaIf;
		ptrWhile = pilaWhile;
		ptrCondicion = pilaCondicion;
		ptrContar = pilaContar;
  		ptrVariables = pilaDeVariables;
		ptrTipos = pilaDeTipos;

		tamanioDePocala = 2000;
		polacaVec = malloc(tamanioDePocala * sizeof(*polacaVec));
		nombreTS = malloc(tamanioDePocala * 4 * sizeof(char));
		tipoTS = malloc(tamanioDePocala * 4 * sizeof(char));
		valorTS = malloc(tamanioDePocala * 4 * sizeof(char));
		longitudTS = malloc(tamanioDePocala * 4 * sizeof(char));

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

	//printf("\n------------> GUARDANDO: %s EN POS: %d <------------\n\n", valor, pos);

	polacaVec[pos] = valor;
	
}


void polacaNumerica(int valor) {
	polacaNumericaConPos(valor, indiceActual);
    indiceActual++;
}


void polacaNumericaConPos(int valor, int pos) {
	if (pos >= tamanioDePocala) {
        polacaVec = realloc(polacaVec, (2 * tamanioDePocala) * sizeof(*polacaVec));
    }

	str = malloc(sizeof(char)*4);
    sprintf(str, "%d", valor);

	printf("\n------------> GUARDANDO: %d EN POS: %d <------------\n \n", valor, pos);;
	polacaVec[pos] = malloc(sizeof(char)*4);

	strcpy(polacaVec[pos], str);
	free(str);
}

void guardarPolaca() {
	int i = 0;

	// /*
	//	printeo los casilleros para verificar los branch más fácil
	/*
	for ( i = 0; i < indiceActual; i++) {
		fprintf(intermedia, "%-10d ; ", i);	
	} 
 	fprintf(intermedia, "\n");*/	
	// */

	for ( i = 0; i < indiceActual; i++) {
		fprintf(intermedia, "%s\n", polacaVec[i]);	
	} 

	for (i = 0; i < indiceActualTs; i++) {
		fprintf(tablaDeSimbolos, "%-30s\t%-15s\t%-15s\t%-15d\n", nombreTS[i], tipoTS[i], valorTS[i], longitudTS[i]);
	}
	fclose(intermedia);
	
}

char* invertirCondicion(char* condicion) {
	if (strcmp(condicion, "BLT") == 0) {
		return "BGE";
	}

	if (strcmp(condicion, "BGE") == 0) {
		return "BLT";
	}

	if (strcmp(condicion, "BGT") == 0) {
		return "BLE";
	}

	if (strcmp(condicion, "BLE") == 0) {
		return "BGT";
	}

	if (strcmp(condicion, "BNE") == 0) {
		return "BEQ";
	} else {
		return "BNE";
	}
}

void generarAssembler(int pos){
	int pos1 = 0,i,cont_aux=0,tamanioDePocala = 2000,es_operador=0 ;
	char **pila = malloc(tamanioDePocala * sizeof(*pila));
	char **aux=malloc(tamanioDePocala * sizeof(*pila));
		for( i=0; i < pos;i++){
			//printf("valores de mi pila: %s \n",polacaVec[i]);
			pila[pos1] = malloc(sizeof(char)*4);
			if(strcmp ("+",polacaVec[i]) == 0){
				es_operador = 1;
				pila[pos1] = "fadd";
			}
			if(strcmp ("*",polacaVec[i]) == 0){
				es_operador = 1;
				pila[pos1] = "fmul";
			}
			if(strcmp ("/",polacaVec[i]) == 0){
				es_operador = 1;
				pila[pos1] = "fdiv";
			}
			if(strcmp ("-",polacaVec[i]) == 0){
				es_operador = 1;
				pila[pos1] = "fdif";
			}
			if(strcmp ("=",polacaVec[i]) == 0){
				es_operador = 1;
				cont_aux = pos1 - cont_aux;
				pila[pos1] = "fstp";
				strcat(pila[pos1],polacaVec[cont_aux]);
			}			
			
			if(es_operador == 0){
				cont_aux++;
				strcpy(pila[pos1],polacaVec[i]);
				
			}
			pos1++;
			es_operador = 0;
		}
		
		for( i=0; i < pos1;i++){
			printf("valores de mi pila: %s \n",pila[i]);
		}
		
	
}

void actualizarTS() {
	while (contadorVar > 0) {
		int indice = buscarIndice(desapilar(ptrVariables));
		char* tipo = desapilar(ptrTipos);
		strcpy(tipoTS[indice], tipo);

		printf("ACTUALIZANDO TS indice %d, %s\n", indice, tipo);
		contadorVar--;
		contadorTipos--;
	}

	if (contadorTipos != 0) {
		printf("Error en la cantidad de elementos en la declaración");
		exit(1);
	}
	
}


int buscarIndice(char* lexema) {
	int i = 0;

	while (i < indiceActualTs) {
		if (strcmp(lexema, nombreTS[i]) == 0) {
			return i;
		}
		i++;
	}

	printf("Elemento no encontrado en tabla de simbolos");
	exit(1);
}