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
int yydebug = 0;

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

%union{
	int num;
	char* id;
	char* str;
}

%token <num>NUM IF ELSE END_IF WHEN COMPUTE MOVE EVALUATE END_EVAL PERFORM END_PERF UNTIL DISPLAY TO EQUALS ADD SUB MULT DIV <id>ID PAR_OP PAR_CL
%left ADD SUB
%left MULT DIV

%%

axioma: sentences;

sentences: sentences sent | sent;


sent: 		  assig 
			| proc
			;

assig:		  //COMPUTE statement		
			  COMPUTE
			  ID 
			  { printf("\tvalori %s\n", $<id>2); }
			  EQUALS 
			  arithexp
			  { printf("\tasigna\n");}

			//MOVE statement
			| MOVE
			  idornum 
			  TO 
			  ID
			  { printf("\tvalori %s\n%s\n\tasigna\n", $<id>4, $<id>2); } 
			;

			/*
				ID or NUM statement.
			*/	
idornum:	  
			  ID	
			  {
				char out [100];
				sprintf(out, "\tvalord %s", $<id>1);

				$<str>$ = out;
			  }
			| NUM	
			  {
				char out [100];
				sprintf(out, "\tmete %d", $<num>1);

				$<str>$ = out;
			  }

			;

proc: 		  
			  // If Statement
			  IF 
			  arithexp 
			  {
				//$3
				// If FALSE (0) - Jump to "ELSE"

				int else_label = get_next_label();
				printf("\tsifalsovea LBL%d\n",else_label);
				$<num>$ = else_label;
			  }
			  sentences 
			  {
				//$5
				// End of the IF statement: jump to "END-IF";

				int endif_label = get_next_label();
				printf("\tvea LBL%d\n", endif_label);
				$<num>$ = endif_label;
			  }
			  {
				  //$6
				  //ELSE landing point:
				  printf("LBL%d\n",$<num>3);
			  }
			  elseopt
			  {
				//$8
				//END-IF landing point:
				printf("LBL%d\n", $<num>5);
			  }

			| EVALUATE ID whenclauses END_EVAL

			| PERFORM 
			  {
				//$2
				int perform_label = get_next_label();
				printf("LBL%d\n", perform_label);
				$<num>$ = perform_label;
			  }
			  UNTIL 
			  arithexp 
			  {
				//$5
				int perform_end_label = get_next_label();
				printf("\tsiciertovea LBL%d\n", perform_end_label);
				$<num>$ = perform_end_label;
			  }
			  sentences
			  END_PERF
			  {
				//$8
				printf("\tvea LBL%d\n",$<num>2 );
				printf("LBL%d\n", $<num>5);
			  }

			| DISPLAY 
			  arithexp
			  { printf("\tprint\n"); }
			;

whenclauses: /*empty*/
			| whenclauses whenclause
			;

elseopt: 	  ELSE
			  sentences
			  END_IF
			| END_IF
			;

whenclause:   WHEN arithexp sentences
			;

arithexp: 	  arithexp ADD multexp {printf("\tsum\n");}
			| arithexp SUB multexp {printf("\tsub\n");}
			| multexp
			;

multexp: 	  multexp MULT value {printf("\tmul\n");}
			| multexp DIV value  {printf("\tdiv\n");}
			| value
			;

value: 		  NUM {printf("\tmete %d\n", $<num>1);} 
			| ID  {printf("\tvalord %s\n", $<id>1);}
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