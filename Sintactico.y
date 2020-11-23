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
	char *str;
	void actualizarTS();
    int buscarIndice(char* lexema);
	int esConstante(char* lexema);
	void insertarEtiqueta();
	void insertarEtiquetaConIndice(int indice);
	int insertarEnTablaDeSimbolos(char* lexema, char* tipo, char* valor, int longitud);
	char* traducirCondicion(char* condicion);
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
	|sentencia 					{printf("\n\t\tsentencia\n");}
	
	;
sentencia:
	asignacion 						{printf("\n\t\t  asig. es sentencia \n");}
	|declaracion 					{printf("\n\t\t   declaracion es sentencia\n");}
	|iteracion 						{printf("\n\t\t iteracion es sentencia\n");}
	|seleccion 						{printf("\n\t\t seleccion  es sentencia\n");}
	|PUT CTE_STR CIERRE_SENT		{polaca("PUT"); polaca($2); printf("\n\t\timprimir cadenas es sentencia\n");}
	|PUT CTE_INT CIERRE_SENT		{polaca("PUT"); polaca($2); printf("\n\t\timprimir INT es sentencia.\n");}
	|PUT CTE_REAL CIERRE_SENT		{polaca("PUT"); polaca($2); printf("\n\t\timprimir REAL es sentencia.\n");}
	|PUT ID CIERRE_SENT				{polaca("PUT"); polaca($2); printf("\n\t\timprimir ID es sentencia.\n");}
	|GET ID CIERRE_SENT				{polaca("GET"); polaca($2); printf("\n\t\tGET ID es sentencia.\n");}
	;
declaracion: 
    DIM CMP_ME lista_variables CMP_MA AS CMP_ME lista_tipos CMP_MA      {actualizarTS();printf("\n\t\tUNA DECLARACION\n");}
    ;
lista_variables:
    lista_variables COMA ID         {printf("\n\t\tlista_variables,ID es lista_variables\n");apilar(ptrVariables, $3); contadorVar++;}
    |ID                             {printf("\n\t\tlista_variables es ID.\n");apilar(ptrVariables, $1); contadorVar++;}
    ;
lista_tipos:
    lista_tipos COMA REAL           {printf("\n\t\tlista_tipos,REAL es lista_tipos\n");apilar(ptrTipos, "real"); contadorTipos++;}
    |lista_tipos COMA INTEGER       {printf("\n\t\tlista_tipos,INTEGER es lista_tipos\n");apilar(ptrTipos, "int"); contadorTipos++;}
    |lista_tipos COMA STRING        {printf("\n\t\tlista_tipos,STRING es lista_tipos\n");apilar(ptrTipos, "string"); contadorTipos++;}
    |REAL                           {printf("\n\t\tlista_tipos es REAL\n");apilar(ptrTipos, "real"); contadorTipos++;}
    |INTEGER                        {printf("\n\t\tlista_tipos es INTEGER\n");apilar(ptrTipos, "int"); contadorTipos++;}
    |STRING                         {printf("\n\t\tlista_tipos es STRING\n");apilar(ptrTipos, "string"); contadorTipos++;}  
    ;
seleccion:
	IF_C PAR_A condicion PAR_C LLAVE_A 
	bloque 
	LLAVE_C {polaca("BI"); polacaNumericaConPos(indiceActual, desapilar(ptrCondicion)); apilar(ptrIf, indiceActual); avanzar(); insertarEtiquetaConIndice(indiceActual - 1);} ELSE LLAVE_A bloque LLAVE_C 	{printf("\n\t\tIF CON ELSE\n"); polacaNumericaConPos(indiceActual, desapilar(ptrIf)); insertarEtiqueta();}


	|IF_C  PAR_A condicion PAR_C LLAVE_A bloque LLAVE_C 							{polacaNumericaConPos(indiceActual, desapilar(ptrCondicion)); insertarEtiqueta(); printf("\n\t\tIF SIN ELSE\n");} 
	|IF_C  PAR_A condicion PAR_C sentencia 											{polacaNumericaConPos(indiceActual, desapilar(ptrCondicion));  insertarEtiqueta(); printf("\n\t\tIF CON UNA SENTENCIA\n");}
	;
iteracion:
	WHILE_C {apilar(ptrWhile, indiceActual); insertarEtiqueta();} PAR_A condicion PAR_C LLAVE_A 
	bloque {polaca("BI"); polacaNumericaConPos(indiceActual + 1, desapilar(ptrCondicion)); polacaNumerica(desapilar(ptrWhile));} 
	LLAVE_C 		{insertarEtiqueta();("\n\t\twhile(condicion){bloque} es while\n");}
	;
condicion:	
	comparacion CMP_AND {polaca($1); apilar(ptrCondicion, indiceActual); avanzar();} comparacion 		{polacaNumericaConPos(indiceActual, desapilar(ptrCondicion)); polaca(invertirCondicion($1)); polacaNumerica(indiceActual + 3); insertarEtiquetaConIndice(indiceActual - 2); polaca("BI"); apilar(ptrCondicion, indiceActual); avanzar(); insertarEtiquetaConIndice(indiceActual - 1);
	printf("\n\t\tcomparacion AND comparacion  es condicion\n");}

	|comparacion CMP_OR {polaca(invertirCondicion($1)); apilar(ptrCondicion, indiceActual); avanzar();} comparacion 		{polaca($1); polacaNumericaConPos(indiceActual, desapilar(ptrCondicion)); apilar(ptrCondicion, indiceActual); avanzar(); insertarEtiquetaConIndice(indiceActual - 1); printf("\n\t\tcomparacion OR comparacion  es condicion\n");}

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
	CONTAR PAR_A{insertarEnTablaDeSimbolos("@contador", "real", "", 0); insertarEnTablaDeSimbolos("@aux-contar", "real", "", 0); polaca("0"); polaca("="); polaca("@contador");}  expresion {polaca("=");polaca("@aux-contar");} CIERRE_SENT CORCH_A el
	CORCH_C PAR_C {polaca("@contador"); printf("\n\t\tfuncion contar\n");} 
	;
el:
	el COMA factor {
		polaca("@aux-contar");
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
	
		polaca("@aux-contar");
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


char* traducirCondicion(char* condicion) {
	if (strcmp(condicion, "BLT") == 0) {
		return "JB";
	}

	if (strcmp(condicion, "BGE") == 0) {
		return "JAE";
	}

	if (strcmp(condicion, "BGT") == 0) {
		return "JA";
	}

	if (strcmp(condicion, "BLE") == 0) {
		return "JNA";
	}

	if (strcmp(condicion, "BNE") == 0) {
		return "JNE";
	} else {
		return "JE";
	}
}

void generarAssembler(int pos){
	int i,es_operador=0 ;
	FILE *asm1;
	asm1 = fopen("assembler.asm", "w");
	if(asm1  == NULL){
		printf("Error al generar el asembler \n");
		exit(1);
	}
	fprintf(asm1, "include macros2.asm %s\n",polacaVec[0]);
	fprintf(asm1, "include number.asm\n");
	fprintf(asm1, "include macros.asm\n");
	fprintf(asm1, ".MODEL	LARGE \n");
	fprintf(asm1, ".386\n");
	fprintf(asm1, ".STACK 200h \n");


	char* pilaASM[50];
	char** ptrASM;
	ptrASM = pilaASM;
	
	char** ASMVec = malloc(tamanioDePocala * 4 * sizeof(char));
	int ASMIndex = 0;
	int operandosAux = 0;
	char* operacion;

	for(i = 0; i < pos; i++){
		if (strcmp(polacaVec[i], "CMP") == 0) {
			// ffree

			for (int a = 0; a < 2 ; a++) {
				ASMVec[ASMIndex] = malloc(sizeof(char)*10);
				char* operando = desapilar(ptrASM);
				if (esConstante(operando)) {
					sprintf(ASMVec[ASMIndex], "fld _%s", operando);
				} else {
					sprintf(ASMVec[ASMIndex], "fld %s", operando);
				}
				ASMIndex++;
			}

			ASMVec[ASMIndex] = "fcomp";
			ASMIndex++;

			ASMVec[ASMIndex] = "fstsw ax";
			ASMIndex++;

			ASMVec[ASMIndex] = "sahf";
			ASMIndex++;

			es_operador =1;

		} else if (strstr(polacaVec[i], "ETIQ_") != NULL) {
			ASMVec[ASMIndex] = polacaVec[i];
			ASMIndex++;
			es_operador =1;
		} else if (strstr(polacaVec[i], "PUT") != NULL) {
			i++;
			ASMVec[ASMIndex] = malloc(sizeof(char)*20);
			char* operando = polacaVec[i];
				if (esConstante(operando)) {
					sprintf(ASMVec[ASMIndex], "displayString _%s", operando);
				} else {
					sprintf(ASMVec[ASMIndex], "displayString %s", operando);
			}
			ASMIndex++;
		} else if (strstr(polacaVec[i], "GET") != NULL) {
			i++;
			ASMVec[ASMIndex] = malloc(sizeof(char)*20);
			sprintf(ASMVec[ASMIndex], "getString %s", polacaVec[i]);
			ASMIndex++;
		} else if(strcmp(polacaVec[i], "BI") == 0 || strcmp(polacaVec[i], "BNE") == 0 || strcmp(polacaVec[i], "BLE") == 0 || strcmp(polacaVec[i], "BGT") == 0 || strcmp(polacaVec[i], "BGE") == 0 || strcmp(polacaVec[i], "BLT") == 0){

			ASMVec[ASMIndex] = malloc(sizeof(char)*10);
			sprintf(ASMVec[ASMIndex], "%s %s", traducirCondicion(polacaVec[i]), polacaVec[i + 1]);
			ASMIndex++;
			es_operador =1;
			i++;
			
		} else if(strcmp ("+", polacaVec[i]) == 0){

			// OPERACION 
			es_operador = 2;
			operacion = "fadd";

			// OPERACION 

		} else if(strcmp ("*",polacaVec[i]) == 0){
			
			// OPERACION 
			es_operador = 2;
			operacion = "fmul";
			// OPERACION 

		} else if(strcmp ("/",polacaVec[i]) == 0){
			
			// OPERACION 
			es_operador = 2;
			operacion = "fdiv";
			// OPERACION 

		} else if(strcmp ("-",polacaVec[i]) == 0){
			
			// OPERACION 
			es_operador = 2;
			operacion = "fdif";
			// OPERACION 

		} else if(strcmp ("=",polacaVec[i]) == 0){
			es_operador = 1;
			i++;

			ASMVec[ASMIndex] = malloc(sizeof(char)*10);
			char* operando = desapilar(ptrASM);
			if (esConstante(operando)) {
				sprintf(ASMVec[ASMIndex], "fld _%s", operando);
			} else {
				sprintf(ASMVec[ASMIndex], "fld %s", operando);
			}
			ASMIndex++;
			
			ASMVec[ASMIndex] = malloc(sizeof(char)*10);
			sprintf(ASMVec[ASMIndex], "fstp %s", polacaVec[i]);
			ASMIndex++;
		}		
		
		if(es_operador == 0){
			if(esConstante(polacaVec[i])){ 
				char* var = malloc(sizeof(char)*10);
				sprintf(var, "_%s", polacaVec[i]);
				apilar(ptrASM, var);
			}else{ 
				apilar(ptrASM, polacaVec[i]);
			}
		} else if (es_operador == 2) {

			for (int a = 0; a < 2 ; a++) {
				ASMVec[ASMIndex] = malloc(sizeof(char)*10);
				char* operando = desapilar(ptrASM);
				if (esConstante(operando)) {
					sprintf(ASMVec[ASMIndex], "fld _%s", operando);
				} else {
					sprintf(ASMVec[ASMIndex], "fld %s", operando);
				}
				ASMIndex++;
			}

			ASMVec[ASMIndex] = malloc(sizeof(char)*10);
			ASMVec[ASMIndex] = operacion;
			ASMIndex++;

			ASMVec[ASMIndex] = malloc(sizeof(char)*10);
			char* var = malloc(sizeof(char)*10);
			sprintf(var, "@aux%d", operandosAux);
			insertarEnTablaDeSimbolos(var, "real", "", 0);
			sprintf(ASMVec[ASMIndex], "fstp %s", var);
			ASMIndex++;

			operandosAux++;
			apilar(ptrASM, var);

			ASMVec[ASMIndex] = "ffree";
			ASMIndex++;

		}
		es_operador = 0;
	}


	// Guardo tabla de simbolos en archivo ts
	for (i = 0; i < indiceActualTs; i++) {
        fprintf(tablaDeSimbolos, "%-30s\t%-15s\t%-15s\t%-15d\n", nombreTS[i], tipoTS[i], valorTS[i], longitudTS[i]);
    }

	
	fprintf(asm1, ".DATA \n\n");

	for (i = 0; i < indiceActualTs; i++) {
		char* valor = valorTS[i];
		int longitud = longitudTS[i];
		char* nombre;

		if(esConstante(nombreTS[i])){ 
			nombre = malloc(sizeof(char)*10);
			sprintf(nombre, "_%s", nombreTS[i]);
		} else {
			nombre = nombreTS[i];
		}

		if (strcmp(tipoTS[i], "int") == 0) {
			sprintf(valor, "%s.0", valor);
			longitud = strlen(valor);
		}

        fprintf(asm1, "%-30s\t%-15s\t%-15s\t%-15d\n", nombre, "dd", valor, longitud);
    }


	fprintf(asm1, "\n.CODE \n");
	fprintf(asm1, "MAIN:\n");
	fprintf(asm1, "\n");	 
    fprintf(asm1, "\n");
    fprintf(asm1, "\t MOV AX,@DATA 	;inicializa el segmento de datos\n");
    fprintf(asm1, "\t MOV DS,AX \n");
    fprintf(asm1, "\t MOV ES,AX \n");
    fprintf(asm1, "\t FNINIT \n");
    fprintf(asm1, "\n");

	for (int a = 0; a < ASMIndex; a++) {
		fprintf(asm1, "%s\n", ASMVec[a]);
	}

	fprintf(asm1, "\n\t mov AX, 4C00h \t ; Genera la interrupcion 21h %s\n","HOLAAA");
	fprintf(asm1, "\t int 21h \t ; Genera la interrupcion 21h\n");
	fprintf(asm1, "END MAIN\n");
	fclose(asm1);
	
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


int esConstante(char* lexema) {
    int i = 0;

    while (i < indiceActualTs) {
        if (strcmp(lexema, nombreTS[i]) == 0) {
			if (strcmp("", valorTS[i]) != 0) {
				return 1;
			} else {
				return 0;
			}
        }
        i++;
    }
	return 0;
}

void insertarEtiqueta() {
	insertarEtiquetaConIndice(indiceActual);
}

void insertarEtiquetaConIndice(int indice) {
	char *aux_str=malloc(sizeof(char)*4); 
	sprintf(aux_str, "ETIQ_%d", indice);
	polaca(aux_str);
}