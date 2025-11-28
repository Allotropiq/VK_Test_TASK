#!/bin/bash 

CONFFILE="./source/configuration.txt"                                                                                  #Путь к файлу конфигурации 
INTERVALSEC=$(grep "Интервал запуска в секундах=" $CONFFILE | awk -F'=' '{print $2}' | tr -d ' \t\r\n')                #Вырезка интервала из конф.файла      
REPOURL=$(grep "Репозиторий скрипта=" $CONFFILE | awk -F'=' '{print $2}' | tr -d ' \t\r\n')                            #Вырезка ссылки удаленного репозитория
errorFlag=0;

#Проверка обновлений скрипта для проверки доступности
wget -q -O "./source/UPD_monitoring.sh" "$REPOURL"
if ! diff "./source/monitoring.sh" "./source/UPD_monitoring.sh" > /dev/null; then
    mv "./source/UPD_monitoring.sh" "./source/monitoring.sh"
    chmod +rx "./source/monitoring.sh"
    rm -f "./source/UPD_monitoring.sh"
    echo "Произведено автоматческое обновление скрипта. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
fi

#Отработка ошибок: наличие docker
if ! docker > /dev/null 2>&1; then
    echo "Для продолжения работы требуется Docker. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
    errorFlag=1;
fi

#Отработка ошибок: проверка числа
if [[ ! "$INTERVALSEC" =~ ^[0-9]+$ ]]; then
    echo "Задайте целое положительное значение. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
    errorFlag=1;
fi

#Отработка ошибок: наличие записи в кронтаб
if [ "$errorFlag" -eq 0 ]; then
    crontab -l > ./source/tempcron
    if ! grep -q "@reboot nohup ./source/checkscript.sh &" ./source/tempcron ; then
        echo "@reboot nohup ./source/checkscript.sh &" >> ./source/tempcron
        crontab ./source/tempcron
        echo "Внесена запись в таблицы cron. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
    fi
    rm ./source/tempcron
fi

#Цикл запускающий проверяющий скрипт, с регулируемым через конф.файл временем.
while [ "$errorFlag" -eq 0 ]; do 
    ./source/monitoring.sh $INTERVALSEC &
    sleep "$INTERVALSEC"
done