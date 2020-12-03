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


//File:
extern FILE *yyin;

// Declaración de funciones:
void yyerror(const char*);
int yylex();


int label_count = 0;

int get_next_label(){
	return label_count ++;
}



%}

%token NUM IF ELSE END_IF WHEN COMPUTE MOVE EVALUATE END_EVAL PERFORM END_PERF UNTIL DISPLAY TO EQUALS ADD SUB MULT DIV ID
%%

axioma: NUM ;


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
		yyin = file;
    }
    else{
        yyin = stdin;
		printf("Type the code bellow:\n");
    }
	yyparse();
}