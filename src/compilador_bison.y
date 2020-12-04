%{
/*
Procesadores de Lenguaje: Práctica 04 - Compilador Ascendente.

Autor: Jorge Ruiz Gómez

Analizador Sintáctico. 

Consideraciones:
*/

#include <stdlib.h>
#include <stdio.h>

//DEFINES
//color output:
#define RED     "\033[31m"
#define RESET   "\033[0m"

//DEBUG:
//gcc ... -lfl -DYYDEBUG
int yydebug = 1;

//File:
extern FILE *yyin;

// Declaración de funciones:
void yyerror(const char*);
int yylex();


int label_count = 0;

int get_next_label(){
	return label_count++;
}



%}

%token NUM IF ELSE END_IF WHEN COMPUTE MOVE EVALUATE END_EVAL PERFORM END_PERF UNTIL DISPLAY TO EQUALS ADD SUB MULT DIV ID PAR_OP PAR_CL
%left ADD SUB
%left MULT DIV

%%

axioma: sentences;

sentences: sentences sent | sent;


sent: 		  assig 
			| proc
			;

assig:		  COMPUTE ID EQUALS arithexp
			| MOVE idornum TO ID
			;


idornum:	  ID
			| NUM;

proc: 		  IF arithexp sentences elseopt
			| EVALUATE ID whenclauses END_EVAL
			| PERFORM UNTIL arithexp sentences END_PERF
			| DISPLAY arithexp
			;

whenclauses: /*empty*/
			| whenclauses whenclause
			;

elseopt: 	  ELSE sentences END_IF
			| END_IF
			;

whenclause:   WHEN arithexp sentences
			;

arithexp: 	  arithexp ADD multexp
			| arithexp SUB multexp
			| multexp
			;

multexp: 	  multexp MULT value
			| multexp DIV value
			| value
			;

value: 		  NUM 
			| ID 
			| PAR_OP arithexp PAR_CL
			;


%%

void yyerror(const char * s){
	fprintf(stderr,RED "ERROR: %s\n" RESET,s );
	exit(-1);	
}


int main(int argc, char** argv){

	if(argc > 1) {
		FILE *file;
		file = fopen(argv[1], "r");
		if(!file) {
			fprintf(stderr, "Can't open %s, please, check if the file exists.\n", argv[1]);
			exit(1);
		}
		printf("Loading File...\n");
		yyin = file;
    }
    else{
        yyin = stdin;
		printf("Type the code bellow:\n");
    }
	
	yyparse();
}