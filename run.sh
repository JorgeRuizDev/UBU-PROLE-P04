#!/bin/bash

check_err(){
	if [[ $? -ne 0 ]];then
		echo -e "\e[31m$1 FAILED ------------------\e[30m"
		cd ..
		exit -1
	fi
}

cd ./src

flex compilador_flex.l
check_err "FLEX"

bison -yd compilador_bison.y
check_err "BISON"

gcc lex.yy.c y.tab.c -o compilador -lfl
check_err "GCC"

cd .. 

./src/compilador ./input_files/$1