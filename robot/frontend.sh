#!/bin/bash 

ID=$(id -u)
if [ $ID -ne 0 ] ; then 
    echo -e "\e[31m You need to script either as a root user or with a sudo privilege \e[0m"
    exit 1
fi 

yum install nginx -y
systemctl enable nginx
systemctl start nginx
