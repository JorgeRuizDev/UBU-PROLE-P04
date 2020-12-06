%{
/*
Procesadores de Lenguaje: Práctica 04 - Compilador Ascendente.

Autor: Jorge Ruiz Gómez

Analizador Sintáctico. 

Consideraciones:

No he conseguido realizar el WhenClauses usando la pila, 
ya que la posición de la etiqueta EndEvaluate varía dependiendo del
número de sentencias WHEN.

Por ejemplo, con una sentencia when, la etitqueta puede estar en $-3
Pero con 2, puede estar en $-5.

Por eso he usado variables globales para resolver esa parte del analizador sintáctico. 

Traza con los diferentes accesos: 
Reducing stack by rule 24 (line 198):
   $1 = nterm whenclauses ()
   $2 = nterm whenclause ()
-> $$ = nterm whenclauses ()
Stack now 0 4 22 35

*/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

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


//Labels:
int label_count = 0;		// Current Label Count

/*
	Method that returns the next available label.
*/
int get_next_label(){
	return label_count++;
}


// EVALUATE / WHEN globals:
int END_EVAL_LABEL = -1;	// END-EVAL label id
char EVAL_ID_VALUE [100];   // Current ID that it's being check by each WHEN

%}

/*
BISON UNION

num: Integer, represents an INT (DIG)+ 

id: String, represents a variable name ({CHAR}({CHAR}|{DIG})*)

str: String, fancier way to append a string to Bison's Stack: $<str>$ = "asigna";
*/
%union{
	int num;
	char* id;
	char* str;
}

//FLEX tokens:
%token <num>NUM IF ELSE END_IF WHEN COMPUTE MOVE EVALUATE END_EVAL PERFORM END_PERF UNTIL DISPLAY TO EQUALS ADD SUB MULT DIV <id>ID PAR_OP PAR_CL

//Operator precedence: (Closer elements to %% have a higher precedence.)
%left ADD SUB
%left MULT DIV

%%

/*
AXIOM: 

program -> sentences
*/
axioma: sentences;


/*
One or many sent

(sent)+
*/
sentences:

			sentences sent 
		| 	sent;


/*
Sentences of the language:

sent -> assig | pro
*/
sent: 		  
	  	assig 
	| 	proc		
	;


/*
Variable assignment
*/
assig:		 

	/*
		'COMPUTE' ID '=' arithexp
	*/
		COMPUTE
		ID 
		{
			printf("\tvalori %s\n", $<id>2); 
		}
		EQUALS 
		arithexp
		{ 
			printf("\tasigna\n");
		}



	/*
	|    'MOVE (NUM | ID) 'TO' ID
	*/
	| 	MOVE
		idornum 
		TO 
		ID
		{
			printf("\tvalori %s\n", $<id>4); 
			printf("%s\n", $<id>2);
			printf("\tasigna\n");
		} 
	;

/*
ID or NUM statement.

(ID | NUM)
*/	
idornum:	  
		ID	
		{
			char out [100];

			sprintf(out, "\tvalord %s", $<id>1);
			//export the formatted string
			$<str>$ = out;
		}
	| 	NUM	
		{
			char out [100];
			sprintf(out, "\tmete %d", $<num>1);

			//Export the formatted string
			$<str>$ = out;
		}

	;

/*
Matches one of the many procedures of the language.
*/
proc: 		  
		
	/*
		IF STATEMENT

		'IF' arithexp sentences elseopt
	*/
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



	/*
		EVALUATE STATEMENT


        |  'EVALUATE' ID (whenclause)+ 'END-EVALUATE'
	*/
	|	EVALUATE 
		ID //$2 , $- if accessing from whenclauses -> whenclause
		{
			//$3
			//$- if accessing from whenclauses -> whenclause:

			//END-EVALUATE jump LABEL:
			END_EVAL_LABEL = get_next_label();
			strcpy(EVAL_ID_VALUE, $<id>2);
		}
		whenclauses
		END_EVAL
		{
			//$5
			printf("LBL%d\n", END_EVAL_LABEL);
		}



	/*
		PERFORM STATEMENT

        |  'PERFORM' 'UNTIL' arithexp sentences 'END-PERFORM'
	*/
	|	PERFORM 
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



	/*
		DISPLAY STATEMENT

        |  'DISPLAY' arithexp
	*/
	|	DISPLAY 
		arithexp
		{
			printf("\tprint\n");
		}
	;


/*
ELSE -> ENDIF or Just ENDIF

elseopt -> 'ELSE' sentences 'END-IF'
		|  'END-IF'
*/
elseopt: 	  
		ELSE
		sentences
		END_IF
	|	END_IF
	;


/*
One or many WHEN clauses

(whenclause)+
*/
whenclauses: 
		/*empty*/
	|	whenclauses
		whenclause
	;


/*
WHEN Clause

whenclause -> 'WHEN' arithexp sentences
*/
whenclause:   
		{
			//$1
			// Evaluate X:
			printf("\tvalord %s\n", EVAL_ID_VALUE);
		}
		WHEN 
		arithexp
		{
			//$4
			// Check if the "Case" is True:
			int next_when_label = get_next_label();
			printf("\tsub\n");
			printf("\tsifalsovea LBL%d\n", next_when_label);
			// export the label:
			$<num>$ = next_when_label;
		} 
		sentences
		{
			//$6
			// Skip the rest of the WHEn statements, jump to END-EVALUATE
			printf("\tvea LBL%d\n", END_EVAL_LABEL);

			// Next "Case" label:
			printf("LBL%d\n", $<num>4);
		}
	;


/*
Arithmetic Expresion:

ADDITION or SUBSTRACTION

arithexp -> arithexp '+' multexp
		|  arithexp '-' multexp
		|  multexp
*/
arithexp:
		arithexp ADD multexp {printf("\tsum\n");}
	|	arithexp SUB multexp {printf("\tsub\n");}
	|	multexp
	;


/*
Multiply or Divide expresions:

multexp -> multexp '*' value
       |  multexp '/' value
       |  value
*/
multexp:
		multexp MULT value {printf("\tmul\n");}
	|	multexp DIV value  {printf("\tdiv\n");}
	| 	value
	;


/*
	A Value
	Recognizes:
	- An INT
	- A String that starts with a letter
	- An arithmetic expresion.

value -> NUM | ID | '(' arithexp ')'
*/
value:
		NUM {printf("\tmete %d\n", $<num>1);} 
	|	ID  {printf("\tvalord %s\n", $<id>1);}
	|	PAR_OP arithexp PAR_CL
	;


%%
/*
C Code:
*/

/*
	yyerror()
	s: A String
*/
void yyerror(const char * s){
	fprintf(stderr,RED "ERROR: %s\n" RESET, s);
	exit(-1);	
}

/*

Main Function

*/
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