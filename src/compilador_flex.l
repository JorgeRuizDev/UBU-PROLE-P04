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
({DIG})+	return NUM;
"IF"		return IF;
"ELSE"		return ELSE;
"ENDIF"		return END_IF;
"WHEN"		return WHEN;
"COMPUTE"	return COMPUTE;
"MOVE"		return MOVE;
"EVALUATE"	return EVALUATE;
"ENDEVAL"	return END_EVAL;
"PERFORM"	return PERFORM;
"ENDPERF"	return END_PERF;
"UNTIL"		return UNTIL;
"DISPLAY"	return DISPLAY;
"TO"		return TO;
"EQUALS"	return EQUALS;

"+"			return ADD;
"-"			return SUB;
"*"			return MULT;
"/"			return DIV;
{CHAR}({CHAR}|{DIG})*	return ID;




[ \t\r\n]	;
"#".*		;

%%
