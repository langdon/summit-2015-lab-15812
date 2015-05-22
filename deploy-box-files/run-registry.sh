#!/bin/bash

IP_ADDR=`ip -o -4 addr show | awk -F '[ /]+' '/global/ {print $4}' | head -1`
REGISTRY_PORT=5000
WEB_UI_PORT=9090
STORAGE_DIR=`pwd`/docker-registry-store/data

docker run -d -t --restart="always" \
        -e SETTINGS_FLAVOR=local \
        -e STORAGE_PATH=$STORAGE_DIR \
	-e SEARCH_BACKEND=sqlalchemy \
        -p $REGISTRY_PORT:5000 \
        registry

docker run -d -t --restart="always" \
	-p $WEB_UI_PORT:8080 \
	atcol/docker-registry-ui

sudo firewall-cmd --permanent --add-port $REGISTRY_PORT/tcp --add-port $WEB_UI_PORT/tcp
sudo firewall-cmd --add-port $REGISTRY_PORT/tcp --add-port $WEB_UI_PORT/tcp

sleep 5 #let the web ui come up

curl -X POST http://$IP_ADDR:9090/registry/save --data "apiVersion=v1&protocol=http&host=$IP_ADDR&port=5000"

echo "Please find the registry at docker://$IP_ADDR:5000 and http://$IP_ADDR:9090/"

