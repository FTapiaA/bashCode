#!/bin/bash

if [ "$1" == "-h" ]
then
    echo "Este comando calcula el tiempo se sesion a partir de un archivo con resistros de sesiones individuales"
    echo "Por favor ejecuta algunos de estos 3 comandos"
    echo "./<Nombre de archivo> -h"
    echo -e "\tPara desplegar la ayuda"
    echo "./<Nombre de archivo> -f <Archivo de texto.txt>"
    echo -e "\tPara mostrar el tiempo de sesion de todos los usuarios en el archivo"
    echo "./<Nombre de archivo> -u <usuario> -f <Archivo de texto.txt>"
    echo -e "\tPara mostrar el timepo de sesion del usuario con la cuenta especificada"
    
elif [ "$#" > "1" ]

     
then

    if [ "$1" == "-f" ]

    then

	declare -A logedtimes

	while IFS='' read -r line || [[ -n "$line" ]];

	do
	    line_set=$( echo  "$line" | tr -s ' ' | tr ' ' ',' | tr -d '\n')

	    IFS=',' read -ra array <<< "$line_set"
	    
	    if [ ${#array[@]} == 10 ] && [ "${array[0]}" != "reboot" ]
	    then
		account=$array[0]
		read -r horas mins <<<$(echo ${array[9]} | tr -d '(' | tr -d ')' | tr ':' ' ')

		horas=$((10#$horas))
		mins=$((10#$mins))
		tiempo=$((mins + (horas * 60)))

		if [ -v logedtimes[$account] ]
		then
		    logedtimes[$account]=$(( ${logedtimes[$account]} + $tiempo ))
		    
		else
		    logedtimes+=([$account]=$(($tiempo)))
		fi
		    
	    fi

	done < "$2"

	echo -e "USUARIO\t| TIEMPO"
	for key in "${!logedtimes[@]}"; do
	    account=${key%"[0]"}
	    tiempo=$((${logedtimes[$key]}))
	    dias=$(( tiempo/1440 ))
	    horas=$(( (tiempo%1440)/60 ))
	    mins=$((tiempo%60))

	    echo -e "$account\t| $dias:$horas:$mins"
	done

	
    elif [ "$1" == "-u" ]

    then

	#vartemp=$( grep $2 $4 | sed -e 's/ /_/g') #Para guardar resutlado en variable

	vartemp=$( grep $2 $4 | tr -s ' ' | tr ' ' ',' | tr '\n' ';')

	IFS=';' read -ra array <<< "$vartemp"
	
	logedtime=$((0))

	for eder in "${array[@]}";

	do

	    #echo ${array[0]} ${array[8]}

	    #echo $eder
	    
	    IFS=',' read -ra array2 <<< "$eder"

	    read -r horas mins <<<$(echo ${array2[9]} | tr -d '(' | tr -d ')' | tr ':' ' ')
	    horas=$((10#$horas))
	    mins=$((10#$mins))
	    
	    logedtime=$((logedtime + mins + (horas * 60)))


	done <<< "$vartemp"
	
	dias=$(( logedtime/1440 ))
	horas=$(( (logedtime%1440)/60 ))
	mins=$((logedtime%60))
	
	echo -e "USUARIO\t| TIEMPO"
	echo -e "$2\t| $dias:$horas:$mins"
	
    fi

fi
