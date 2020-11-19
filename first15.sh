#!/bin/bash

whiptail --title "First 15 Script" --menu "Choose an Option" 32 60 16 \ 
	"List Users" "Show all users with valid shells" \
	"Firewall" "Configure Firewall Rules" \	
	"<---" "Go Back"

whiptail --title "List of users with shells" --msgbox "The Following users have shells." 16 60 
whiptail --title "List of users with shells" --textbox /dev/stdin 32 60 <<<"$(
grep -v -e 'sync' -e 'bin/false' -e 'sbin/nologin' /etc/passwd)"

whiptail --msgbox "Time to set Firewall Rules" 16 60

if (whiptail --yesno "Remove FirewallD and use IPTables?" 16 60); then
	whiptail --textbox /dev/sddin 32 60 <<<"$(systectl disable --now )"
	
	

else
	whiptail --msgbox "IPTables will not be configured." 16 60
fi
## Firewall rules go here

