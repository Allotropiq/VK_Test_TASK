#!/bin/bash 
CONFFILE="./source/configuration.txt"                                                                           #Путь к файлу конфигурации 
SITEURL=$(grep "Адрес сайта проверяемого сайта=" $CONFFILE | awk -F'=' '{print $2}' | tr -d ' \t\r\n')          #Вырезка адреса сайта
INT=$(grep "Интервал запуска в секундах=" $CONFFILE | awk -F'=' '{print $2}' | tr -d ' \t\r\n')                 #Вырезка интервала из конф.файла для проверки изменений в процессе работы 
errorFlag=0

#Отработка ошибок: проверка числа 
if [[ ! "$INT" =~ ^[0-9]+$ ]]; then
    echo "Новое значение не применено, будет использовано изначальное. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
    errorFlag=1;
elif [ $1 -eq $INT ]; then 
    INT=$1
else
   exec ./checkscript.sh &
fi

#Отработка ошибок: проверка активности контейнера с приложением
if ! docker ps | grep -q -e mini_server ; then
    pushd ./source/ &&  docker compose up -d && popd;
    echo "Запуск контейнера с приложением $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
else 
    if curl -sI "$SITEURL" | grep -q -e "HTTP/.* 2.." -e "HTTP/.* 3.." ; then                                               #Отработка ошибок: проверка работы сайта по коду ответа
        echo "Сайт доступен! $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
    elif curl -sI "$SITEURL" | grep -q -e "HTTP/.* 4.." ; then                                                              #Отработка ошибок: ошибки клиента
        echo "Неполадки на стороне клиента. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
    else 
        echo "Неполадки на стороне сервера. Попытка перезагрузки. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;    #Отработка ошибок: перезапуск контейнера во всех остальных случаях
        pushd ./source/ &&  docker compose restart && popd  > /dev/null 2>&1;
        sleep 60                                                                                                            #Отработка ошибок: время на запуск контейнера
    fi
fi 
