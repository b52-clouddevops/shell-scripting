#!/bin/bash 

COMPONENT=catalogue
LOFGILE="/tmp/$COMPONENT.log"

source components/common.sh    # Source loads a file and this file has all the common patterns.

echo -n "Configuring Node JS:"
curl -sL https://rpm.nodesource.com/setup_16.x | bash  &>> ${LOFGILE}
stat $? 

echo -n "Creating Application User $APPUSER"
useradd $APPUSER  &>> "${LOFGILE}"
stat $? 


