#!/bin/bash
#execute the functionality in lab2 that other labs depend on 

cd ~/lab4

TARGET_IP=summit-rhel-dev:5000
SED_REGEXP="s/MY_REPOSITORY_WITH_IMAGE_NAME/$TARGET_IP/g"

cp -R ~/lab4/* ~/workspace

sed -i -e "s/MY_REPOSITORY_WITH_IMAGE_NAME/$TARGET_IP\/wordpress/g" ~/workspace/wordpress/kubernetes/wordpress-pod.json
sed -i -e "s/MY_REPOSITORY_WITH_IMAGE_NAME/$TARGET_IP\/mariadb/g" ~/workspace/mariadb/kubernetes/mariadb-pod.json 

