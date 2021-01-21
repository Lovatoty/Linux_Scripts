#!/bin/bash

#This function is ultimately not needed because the folder is created by the tar
#function installSplunkForwarder(){
#need to fix /opt
#if [[ ! -e /opt/splunkforwarder ]]; then
#whiptail --msgbox "/opt/splunkforwarder does not exist, creating it now." 8 44
#mkdir /opt/splunkforwarder
#fi

cd /opt
pwd
SPLUNKURL=$(whiptail --inputbox "What is the bit.ly URL? to download splunk?" --title "Splunk URL" 8 64 8 3>&1 1>&2 2>&3)

#need to set home variable.
wget -O /opt/splunkforwarder.tgz $SPLUNKURL
#whiptail --title "Splunk Download" --msgbox "Download Done, prepairing to extract" 8 44
tar -xzf /opt/splunkforwarder.tgz
#whiptail --title "Splunk Download" --msgbox "Extracting Complete" 8 44
cd /opt/splunkforwarder/bin
pwd
chmod +x splunk
./splunk start --accept-license
./splunk enable boot-start
#}

