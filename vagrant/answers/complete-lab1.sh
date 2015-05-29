#!/bin/bash
#execute the functionality in lab1 that other labs depend on 

sudo systemctl start docker
cd ~/sync/lab1
docker build -t redhat/apache .
docker run -dt -p 80:80 redhat/apache
docker ps
