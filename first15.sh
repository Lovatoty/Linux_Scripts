#!/bin/bash

function usersWithShells(){
whiptail --title "List of users with shells" --msgbox "The Following users have shells." 16 60 
whiptail --title "List of users with shells" --textbox /dev/stdin 32 60 <<<"$(
grep -v -e 'sync' -e 'bin/false' -e 'sbin/nologin' /etc/passwd)"
}

function firewallRules(){
if (whiptail --yesno "Remove FirewallD and use IPTables?" 16 60); then
	whiptail --textbox /dev/sddin 32 60 <<<"$(systectl disable --now )"
	
	

else
	whiptail --msgbox "IPTables will not be configured." 16 60
fi

}


function menuFunction(){

#using integer variable for portability
EXITVAR=0

while [ $EXITVAR -le 0 ]
do

      MENUSELECT=$(whiptail --title "First 15" --fb --menu "Where to Start" 15 60 4 \
        "1" "View Users with Shells" \
        "2" "Firewall Rules" \
        "10" "Exit" 3>&1 1>&2 2>&3)
    case $MENUSELECT in
        1)
		usersWithShells
        ;;
        2)
		firewallRules
        ;;
        10)
		whiptail --title "Exit" --msgbox "GoodBye!" 8 45
		EXITVAR=5
        ;;
    esac
done
} 

menuFunction
