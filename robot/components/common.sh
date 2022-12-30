APPUSER=roboshop
LOFGILE="/tmp/$COMPONENT.log"

ID=$(id -u)
if [ $ID -ne 0 ] ; then 
    echo -e "\e[31m You need to script either as a root user or with a sudo privilege \e[0m"
    exit 1
fi 

stat() {
    if [ $1 -eq 0 ]; then 
        echo -e "\e[32m Success \e[0m "
    else 
        echo -e "\e[31m failure \e[0m"
    fi 
}

JAVA() {
    echo -e "Installing Maven : "
    yum install maven -y  &>> "${LOFGILE}"
    stat $? 

    
}

NODEJS() {
    echo -n "Configuring Node JS:"
    curl -sL https://rpm.nodesource.com/setup_16.x | bash  &>> "${LOFGILE}"
    stat $? 

    echo -n "Installing nodeJs : "
    yum install nodejs -y &>> "${LOFGILE}"
    stat $?  

    CREATE_USER             # Calling Create_User function to create user account

    DOWNLOAD_AND_EXTRACT    # Calling DOWNLOAD_AND_EXTRACT function to download and extract the component 

    NPM_INSTALL             # Calling NPM Install 

    CONFIGURE_SVC           # Configuring and starting service
}

CREATE_USER() {
    id $APPUSER &>> "${LOFGILE}" 
    if [ $? -ne 0 ] ; then 
        echo -n "Creating Application User $APPUSER :"
        useradd $APPUSER  &>> "${LOFGILE}"
        stat $? 
    fi 
}

DOWNLOAD_AND_EXTRACT() {
    echo -n "Downloading the $COMPONENT :" 
    curl -s -L -o /tmp/$COMPONENT.zip "https://github.com/stans-robot-project/$COMPONENT/archive/main.zip"
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
}

NPM_INSTALL() {
    echo -n "Installing $COMPONENT Dependencies :"
    cd $COMPONENT 
    npm install  &>> "${LOFGILE}" 
    stat $?    
}

CONFIGURE_SVC() {
    echo -n "Configuring the $COMPONENT Service:"
    sed -i -e 's/CATALOGUE_ENDPOINT/catalogue.roboshop.internal/' -e 's/REDIS_ENDPOINT/redis.roboshop.internal/' -e 's/MONGO_ENDPOINT/mongodb.roboshop.internal/' -e 's/MONGO_DNSNAME/mongodb.roboshop.internal/' /home/$APPUSER/$COMPONENT/systemd.service
    mv /home/$APPUSER/$COMPONENT/systemd.service  /etc/systemd/system/$COMPONENT.service 
    stat $? 

    echo -n "Starting $COMPONENT Service :"
    systemctl daemon-reload &>> "${LOFGILE}"
    systemctl enable $COMPONENT &>> "${LOFGILE}"
    systemctl restart $COMPONENT &>> "${LOFGILE}" 
    systemctl status $COMPONENT &>> "${LOFGILE}"
    stat $? 

    echo -e "\e[32m ______ $COMPONENT Configuration Completed _________ \e[0m"
}