#!/bin/bash

#"host" doesn't use /etc/hosts so we have to use this semi-esoteric method
if ! getent hosts deploy.example.com > /dev/null 2>&1 ; then
    echo "deploy.example.com doesn't resolve, this won't work"
    exit 1
fi

#"host" doesn't use /etc/hosts so we have to use this semi-esoteric method
if ! getent hosts dev.example.com > /dev/null 2>&1 ; then
    echo "dev.example.com doesn't resolve, this won't work"
    exit 1
fi

#check to be sure the dir to store connections exists
if ! test ~/.ssh/ctl ; then
    mkdir ~/.ssh/ctl
fi

#create a connection to share amongst all the rsync calls so you don't get reprompted for password
ssh -nNf -M -S "$HOME/.ssh/ctl/%L-%r@%h:%p" root@deploy.example.com
for i in `seq 1 5` ; do	  
    rsync -e "ssh -S '$HOME/.ssh/ctl/%L-%r@%h:%p'" -avzP labs/lab$i/answer/* root@deploy.example.com:/root/answers/
    rsync -e "ssh -S '$HOME/.ssh/ctl/%L-%r@%h:%p'" -avzP labs/lab$i/support/* root@deploy.example.com:/root/lab$i/
    rsync -e "ssh -S '$HOME/.ssh/ctl/%L-%r@%h:%p'" -avzP labs/lab$i/chapter*md root@deploy.example.com:/root/markdown_lab_docs/
done
#kill the connection
ssh -O exit -S "$HOME/.ssh/ctl/%L-%r@%h:%p" root@deploy.example.com

#create a connection to share amongst all the rsync calls so you don't get reprompted for password
ssh -nNf -M -S "$HOME/.ssh/ctl/%L-%r@%h:%p" root@dev.example.com
for i in `seq 1 5` ; do
    rsync -e "ssh -S '$HOME/.ssh/ctl/%L-%r@%h:%p'" -avzP labs/lab$i/answer/* root@dev.example.com:/root/answers/
    rsync -e "ssh -S '$HOME/.ssh/ctl/%L-%r@%h:%p'" -avzP labs/lab$i/support/* root@dev.example.com:/root/lab$i/
    rsync -e "ssh -S '$HOME/.ssh/ctl/%L-%r@%h:%p'" -avzP labs/lab$i/chapter*md root@dev.example.com:/root/markdown_lab_docs/
done
#kill the connection
ssh -O exit -S "$HOME/.ssh/ctl/%L-%r@%h:%p" root@dev.example.com
