%{
/*
Procesadores de Lenguaje: Práctica 04 - Compilador Ascendente.

Autor: Jorge Ruiz Gómez

Analizador Léxico

Consideraciones:

*/

#include "y.tab.h"

%}

DIG [0-9]
CHAR [a-zA-Z]

%%
({DIG})+		{yylval.num = atoi(yytext);}	return NUM;
"IF"											return IF;
"ELSE"											return ELSE;
"END-IF"										return END_IF;
"WHEN"											return WHEN;
"COMPUTE"										return COMPUTE;
"MOVE"											return MOVE;
"EVALUATE"										return EVALUATE;
"END-EVALUATE"									return END_EVAL;
"PERFORM"										return PERFORM;
"END-PERFORM"									return END_PERF;
"UNTIL"											return UNTIL;
"DISPLAY"										return DISPLAY;
"TO"											return TO;

"="												return EQUALS;
"+"												return ADD;
"-"												return SUB;
"*"												return MULT;
"/"												return DIV;

"("												return PAR_OP;
")"												return PAR_CL;
{CHAR}({CHAR}|{DIG})*	{yylval.id=yytext;}		return ID;




[ \t\r\n]	;
"**".*		;

%%
