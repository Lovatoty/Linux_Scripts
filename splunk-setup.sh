#!/bin/bash

#This function is ultimately not needed because the folder is created by the tar
#function installSplunkForwarder(){
#need to fix /opt
#if [[ ! -e /opt/splunkforwarder ]]; then
#whiptail --msgbox "/opt/splunkforwarder does not exist, creating it now." 8 44
#mkdir /opt/splunkforwarder
#fi

#Creating a new user so we are not running splunk as root
#this adds complexity to the install, but offers some level of protection
#note we will have to configure SELinux for splunk to work properly
useradd --system --disabed-login --shell=/bin/bash --group splunk

cd /opt
SPLUNKURL=$(whiptail --inputbox "What is the bit.ly URL? to download splunk?" --title "Splunk URL" 8 64 8 3>&1 1>&2 2>&3)

#need to set home variable.
wget -O /opt/splunkforwarder.tgz $SPLUNKURL
#whiptail --title "Splunk Download" --msgbox "Download Done, prepairing to extract" 8 44
tar -xzf /opt/splunkforwarder.tgz
#whiptail --title "Splunk Download" --msgbox "Extracting Complete" 8 44
chown  --recursive splunk:splunk /opt/splunkforwarder

cd /opt/splunkforwarder/bin
chmod 770 splunk

./splunk start --accept-license
./splunk enable boot-start

#ADD FORWARD SERVER
##Please Test First!!
FORWARDSERVER=$(whiptail --inputbox "What is the IP address and port number of the forwarder server?\nUse the format IP:Port" --title "Splunk Forwarder Configuratuib" 8 64 8 3>&1 1>&2 2>&3)

./splunk add forward-server $FORWARDSERVER

##add SELinux stuff here


#add something to monitor. /var/log should cover most bases
./splunk add monitor /var/log


./splunk restart
#}

