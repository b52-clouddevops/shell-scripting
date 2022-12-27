#!/bin/bash 

UID=$(id -u)
if [ $UID -ne 0 ] ; then 
    echo -e "\32m You need to script either as a root user or with a sudo privilege \e[0m"
    exit 1
fi 

yum install nginx -y
systemctl enable nginx
systemctl start nginx
