#!/bin/bash
#execute the functionality in lab1 that other labs depend on 

sudo systemctl start docker
cd ~/lab1
docker build -t redhat/apache .
docker run -dt -p 80:80 redhat/apache
docker ps

docker build -t registry registry/
docker run --restart="always" --name registry -d registry

sudo sed -i -e "s/# INSECURE_REGISTRY='--insecure-registry'/INSECURE_REGISTRY='--insecure-registry summit-rhel-dev'/g" /etc/sysconfig/docker

sudo systemctl restart docker

