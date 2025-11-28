#!/bin/bash 

confFile="$PWD/source/configuration.txt"
int=$(grep "Интервал запуска в секундах:" $confFile | awk -F: '{print $2}' | tr -d ' \t')
errorFlag=0;
defaultValue=60;
if [[ ! "$int" =~ ^-?[0-9]+$ ]]; then
    echo "Установите целое неотрицательное значение."
    echo "Использовано значение по умолчанию $defaultValue сек"
    int=$defaultValue
    echo "$int"
else 
     echo "$int"
fi
