#!/bin/bash 

COMPONENT=catalogue
source components/common.sh    # Source loads a file and this file has all the common patterns.

echo -n "Configuring Node JS:"
curl -sL https://rpm.nodesource.com/setup_16.x | bash  &>> "${LOFGILE}"
stat $? 

echo -n "Installing nodeJs : "
yum install nodejs -y &>> "${LOFGILE}"
stat $? 

id $APPUSER &>> "${LOFGILE}" 
if [ $? -ne 0 ] ; then 
    echo -n "Creating Application User $APPUSER :"
    useradd $APPUSER  &>> "${LOFGILE}"
    stat $? 
fi 

echo -n "Downloading the $COMPONENT :" 
curl -s -L -o /tmp/catalogue.zip "https://github.com/stans-robot-project/catalogue/archive/main.zip"
stat $? 

echo -n "Cleanup and Extraction $COMPONENT: "
rm -rf /home/$APPUSER/$COMPONENT/
cd /home/$APPUSER
unzip -o /tmp/$COMPONENT.zip  &>> "${LOFGILE}"
stat $? 

echo -n "Changing the ownership to $APPUSER"
mv /home/$APPUSER/$COMPONENT-main /home/$APPUSER/$COMPONENT
chown -R $APPUSER:$APPUSER /home/$APPUSER/$COMPONENT
stat $?

echo -n "Installing $COMPONENT Dependencies :"
cd $COMPONENT 
npm install  &>> "${LOFGILE}" 
stat $? 

echo -n "Configuring the $COMPONENT Service:"
sed -i -e  's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/$APPUSER/$COMPONET/systemd.servce
 