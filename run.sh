#!/bin/bash

check_err(){
	if [[ $? -ne 0 ]];then
		echo -e "\e[31m$1 FAILED ------------------\e[30m"
		cd ..
		exit -1
	fi
}

echo "To run: $ bash run.sh \"\" exampleX.txt"

cd ./src

flex compilador_flex.l
check_err "FLEX"

bison -yd compilador_bison.y $1
check_err "BISON"

gcc lex.yy.c y.tab.c -o compilador -lfl -DYYDEBUG
check_err "GCC"

cd .. 

# Generar PDF
# bison -yg src/compilador_bison.y -b diagrama
# dot -Tpdf diagrama.dot -o diagrama.dot.pdf
# rm diagrama.dot

if [[ $2 = "" ]]; then
	./src/compilador
else
	./src/compilador ./input_files/$2 | tee out.txt
fi