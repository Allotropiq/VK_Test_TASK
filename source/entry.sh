#!/bin/bash

./mini_server &
exec nginx -g 'daemon off;'