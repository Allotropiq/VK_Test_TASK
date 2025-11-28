#!/bin/bash

./mini_server &                #запуск fcgi сервера
exec nginx -g 'daemon off;'    #запуск nginx