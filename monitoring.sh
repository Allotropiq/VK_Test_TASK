#!/bin/bash 
CONFFILE="./source/configuration.txt"
SITEURL=$(grep "Адрес сайта=" $CONFFILE | awk -F'=' '{print $2}' | tr -d ' \t\r\n')
INT=$(grep "Интервал запуска в секундах=" $CONFFILE | awk -F'=' '{print $2}' | tr -d ' \t\r\n')
errorFlag=0


if [[ ! "$INT" =~ ^[0-9]+$ ]]; then
    echo "Новое значение не применено, будет использовано изначальное. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
    errorFlag=1;
elif [ "$1" -eq "$int" ]; then 
    $INT=$1
else
    exec checkscript.sh
fi

if ! docker ps | grep mini_server; then 
    docker compose up -d;
    echo "Запуск контейнера с приложением $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
else 
    if curl -sI "$SITEURL" | grep -q -e "HTTP/.* 2.." -e "HTTP/.* 3.."; then 
        echo "Сайт доступен! $(date '+%Y-%m-%d %H:%M:%S')"
    elif curl -sI "$SITEURL" | grep -q -e "HTTP/.* 4.."; then
        echo "Неполадки на стороне клиента. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
    else 
        echo "Неполадки на стороне сервера. Попытка перезагрузки. $(date '+%Y-%m-%d %H:%M:%S')" | tee -a monitoring.log;
        docker compose restart
    fi
fi
