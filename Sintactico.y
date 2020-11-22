%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <ctype.h>
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

	#define apilar(puntero, valor) (*((puntero)++) = (valor))
	#define desapilar(puntero) (*--(puntero))

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
	lista_variables COMA ID 		{printf("\n\t\tlista_variables,ID es lista_variables\n");apilar(ptrVariables, $3); contadorVar++;}
	|ID 							{printf("\n\t\tlista_variables es ID.\n");apilar(ptrVariables, $1); contadorVar++;}
	;
lista_tipos:
	lista_tipos COMA REAL 			{printf("\n\t\tlista_tipos,REAL es lista_tipos\n");apilar(ptrTipos, "real"); contadorTipos++;}
	|lista_tipos COMA INTEGER 		{printf("\n\t\tlista_tipos,INTEGER es lista_tipos\n");apilar(ptrTipos, "int"); contadorTipos++;}
	|lista_tipos COMA STRING 		{printf("\n\t\tlista_tipos,STRING es lista_tipos\n");apilar(ptrTipos, "string"); contadorTipos++;}
	|REAL 							{printf("\n\t\tlista_tipos es REAL\n");apilar(ptrTipos, "real"); contadorTipos++;}
	|INTEGER 						{printf("\n\t\tlista_tipos es INTEGER\n");apilar(ptrTipos, "int"); contadorTipos++;}
	|STRING 						{printf("\n\t\tlista_tipos es STRING\n");apilar(ptrTipos, "string"); contadorTipos++;}	
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
	ID OP_ASIG expresion CIERRE_SENT 	{polaca("=");polaca($1); printf("\n\t\tID := expresion; es una asignacion\n");}
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
	CONTAR PAR_A{polaca("@contador");}  expresion {polaca("=");polaca("@aux");} CIERRE_SENT CORCH_A el
	 CORCH_C PAR_C {polaca("@contador"); printf("\n\t\tfuncion contar\n");} 
	;
el:
	el COMA factor {
		polaca("@aux");
		polaca("CMP");
		polaca("BNE");
		avanzar(); 
		polaca("@contador"); 
		polaca("1"); 
		polaca("+");
		polaca("=");
		polaca("@contador");
		polacaNumericaConPos(indiceActual, indiceActual - 6);
		char *aux_str=malloc(sizeof(char)*4); sprintf(aux_str, "ETIQ_%d",indiceActual);polaca(aux_str);
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
		polaca("=");
		polaca("@contador"); 
		polacaNumericaConPos(indiceActual, indiceActual - 6);
		char *aux_str=malloc(sizeof(char)*4); sprintf(aux_str, "ETIQ_%d",indiceActual);polaca(aux_str);
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
		ptrIf = pilaIf;
		ptrWhile = pilaWhile;
		ptrCondicion = pilaCondicion;
		ptrContar = pilaContar;
		tamanioDePocala = 2000;
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
    sprintf(str, "ETIQ_%d", valor);

	printf("\n------------> GUARDANDO: %d EN POS: %d <------------\n \n", valor, pos);
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
	int i,es_operador=0 ;
	FILE *asm1;
	asm1 = fopen("assembler.asm", "w");
	if(asm1 == NULL){
		printf("Error al generar el asembler \n");
		exit(1);
	}
	fprintf(asm1, "include macros2.asm\n");
	fprintf(asm1, "include number.asm\n");
	fprintf(asm1, ".MODEL	LARGE \n");
	fprintf(asm1, ".386\n");
	fprintf(asm1, ".STACK 200h \n");
	 
	fprintf(asm1, ".CODE \n");
	fprintf(asm1, "MAIN:\n");
	fprintf(asm1, "\n");	 
    fprintf(asm1, "\n");
    fprintf(asm1, "\t MOV AX,@DATA 	;inicializa el segmento de datos\n");
    fprintf(asm1, "\t MOV DS,AX \n");
    fprintf(asm1, "\t MOV ES,AX \n");
    fprintf(asm1, "\t FNINIT \n");;
    fprintf(asm1, "\n");	 
	for( i=0; i < pos;i++){
		if(strcmp(polacaVec[i], "BI")==0 ||   strcmp(polacaVec[i], "BNE")==0 || strcmp(polacaVec[i], "BLE") == 0 ||strcmp(polacaVec[i], "BGT") == 0 || strcmp(polacaVec[i], "BGE") == 0 || strcmp(polacaVec[i], "BLT") == 0){
			fprintf(asm1,"%s ",polacaVec[i]);
			i++;
			fprintf(asm1,"%s\n",polacaVec[i]);
			es_operador =1;
		}		
		
		if(strcmp ("+",polacaVec[i]) == 0){
			es_operador = 1;
			fprintf(asm1,"%s\n","fadd");
		}
		if(strcmp ("*",polacaVec[i]) == 0){
			es_operador = 1;
			fprintf(asm1,"%s\n","fmul");
		}
		if(strcmp ("/",polacaVec[i]) == 0){
			es_operador = 1;
			fprintf(asm1,"%s\n","fdiv");
		}
		if(strcmp ("-",polacaVec[i]) == 0){
			es_operador = 1;
			fprintf(asm1,"%s\n","fdif");
		}
		if(strcmp ("=",polacaVec[i]) == 0){
			es_operador = 1;
			i++;
			fprintf(asm1,"fstp %s\n",polacaVec[i]);
		}		
		
		if(es_operador == 0 ){
			if(atoi(polacaVec[i]) != 0){ 
				fprintf(asm1,"fld _%s\n",polacaVec[i]);
			}else{ 
				fprintf(asm1,"fld %s\n",polacaVec[i]);	
			}
		}
		es_operador = 0;
	}
	fprintf(asm1, "\t mov AX, 4C00h \t ; Genera la interrupcion 21h\n");
	fprintf(asm1, "\t int 21h \t ; Genera la interrupcion 21h\n");
	fprintf(asm1, "END MAIN\n");
	fclose(asm1);
	
}

