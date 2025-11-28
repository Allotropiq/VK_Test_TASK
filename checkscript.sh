#!/bin/bash 

confFile="$PWD/source/configuration.txt"
intervalSec=$(grep "Интервал запуска в секундах:" $confFile | awk -F: '{print $2}' | tr -d ' \t')
errorFlag=0;


if ! docker > /dev/null 2>&1; then
    echo "Для продолжения работы требуется Docker" | tee -a monitoring.log;
    errorFlag=1;
fi

if [[ ! "$intervalSec" =~ ^[0-9]+$ ]]; then
    echo "Установите целое неотрицательное значение." | tee -a monitoring.log;
    errorFlag=1;
fi

if $errorFlag -eq 0; then
    if crontab -l > ./source/tempcron | grep "@reboot ./source/monitoring.sh"; then
        echo "@reboot ./source/monitoring.sh" >> ./source/tempcron
        crontab tempcron
        rm tempcron
    fi

while [ $errorFlag -eq 0 ]; do 
    
done

