#!/bin/bash

function usersWithShells(){
whiptail --title "List of users with shells" --msgbox "The following users have shells they can log in with." 8 60 
whiptail --title "List of users with shells" --textbox /dev/stdin 32 60 <<<"$(
grep -v -e 'sync' -e 'bin/false' -e 'sbin/nologin' /etc/passwd)"
}

function installSplunkForwarder(){
if [[ ! -d /opt/splunkforwarder ]]; then
whiptail --textbox "/opt/splunkforwarder does not exist, creating it now."
mkdir /opt/splunkforwarder
fi
#whiptail -msgbox "Prepairing to install splunk forwarder"



SPLUNKURL=$(whiptail --inputbox "What is the bit.ly URL? to download splunk?" --title "Splunk URL" 8 64 8 3>&1 1>&2 2>&3)


#Trying some fancy thing that doesn't work
#URL='https://www.splunk.com/bin/splunk/DownloadActivityServlet?architecture=x86_64&platform=linux&version=8.1.0&product=universalforwarder&filename=splunkforwarder-8.1.0-f57c09e87251-Linux-x86_64.tgz&wget=true'
#wget --Splunk.tgz --progress=dot "$URL" 2>&1 |\
#grep "%" |\
#sed -u -e "s,\.,,g" | awk '(print $2)' | sed -u -e "s,\%,,g" | whiptail --gauge "Download" 10 100
}
function FIREWALL_INBOUND_RULES(){
			INBOUNDRULES=$(whiptail --title "IPv4 - Inbound Rules" --checklist "Inbound Rules" 32 60 8 \
				"22-TCP" "SSH" OFF \
				"25-TCP" "SMTP" OFF \
				"53-UDP" "DNS over UDP" OFF \
				"53-TCP" "DNS over TCP" OFF \
				"80-TCP" "HTTP" OFF \
				"110-TCP" "POP3" OFF \
				"143-TCP" "IMAP" OFF \
				"443-TCP" "HTTPS" OFF \
				"lo" "Localhost Traffic" ON 3>&1 1>&2 2>&3)

			case $INBOUNDRULES in
				22-TCP)
					iptables -A INPUT -p tcp --dport 22 -j ACCEPT
				;;
				25-TCP)
					iptables -A INPUT -p tcp --dport 25 -j ACCEPT
				;;
				
				53-UDP)
					iptables -A INPUT -p udp --dport 53 -j ACCEPT			
				;;
				80-TCP)
					iptables -A INPUT -p tcp --dport 80 -j ACCEPT
				;;
				110-TCP)
					iptables -A INPUT -p tcp --dport 110 -j ACCEPT
				;;

				443-TCP)
					iptables -A INPUT -p tcp --dport 442 -j ACCEPT
				;;
				lo)
				;;
			esac

}
function FIREWALL_OUTBOUND_RULES(){
			OUTBOUNDRULES=$(whiptail --title "IPv4 - Outbound Rules" --checklist "Outbound Rules" 32 60 8 \
                "22-TCP" "SSH" OFF \
                "53-UDP" "DNS" OFF \
                "80-TCP" "HTTP" OFF \
                "443-TCP" "HTTPS" OFF \
				"lo" "Localhost Traffic" ON 3>&1 1>&2 2>&3)

				case $OUTBOUNDRULES in
				22-TCP)
					iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
				;;
				25-TCP)
					iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT
				;;
				
				53-UDP)
					iptables -A OUTPUT -p udp --dport 53 -j ACCEPT			
				;;
				80-TCP)
					iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
				;;
				110-TCP)
					iptables -A OUTPUT -p tcp --dport 110 -j ACCEPT
				;;

				443-TCP)
					iptables -A OUTPUT -p tcp --dport 442 -j ACCEPT
				;;
				lo)
				;;
			esac
}
function FIREALL_DDOS_PROTECTION_RULES(){
    echo hello
}
function FIREWALL_BLOCK_IPV6(){
    echo hello
}
function firewallRules(){
FIREWALLLOOPVAR=0
whiptail --title "Firewall Rules" --msgbox "Currently by Default this Script uses IP-Tables. I do plan on adding support for firewalld later. For the Time being this script will make you disable firewallD before you can add IP Tables Rules. FirewallD may or may not be running on your system depending on Distro and Version." 16 60

#if (whiptail --yesno "Remove FirewallD and use IPTables?" 16 60); then
#	whiptail --textbox /dev/sddin 32 60 <<<"$(systectl disable --now )"
#else 

#fi
while [ $FIREWALLLOOPVAR -le 0 ]
do
	RULESELECT=$(whiptail --title "Firewall Rules" --fb --menu "Configure Firewall Rules" 16 60 8 \
	"I" "Modify Inbound Rules" \
	"O" "Modify Outbound Rules" \
	"D" "Apply rules for DDoS Protection" \
	"6" "Block IPv6" \
	"E" "Exit" 3>&1 1>&2 2>&3)

	case $RULESELECT in
		I)
            FIREWALL_INBOUND_RULES
		;;
		O)
            FIREWALL_OUTBOUND_RULES
				
		;;
		D)
            FIREALL_DDOS_PROTECTION_RULES
		;;
		6)
            FIREWALL_BLOCK_IPV6
		;;
		E)
			FIREWALLLOOPVAR=10
		;;
	esac

done
}


function menuFunction(){

#using integer variable for portability
EXITVAR=0

while [ $EXITVAR -le 0 ]
do

	MENUSELECT=$(whiptail --title "First 15" --fb --menu "Where to Start" 15 60 4 \
	"U" "View Users with Shells" \
	"F" "Firewall Rules" \
	"S" "Install Splunk Forwarder" \
	"E" "Exit" 3>&1 1>&2 2>&3)
	
	case $MENUSELECT in
	U)
		usersWithShells
	;;
	F)
		firewallRules
	;;
	E)
		whiptail --title "Exit" --msgbox "GoodBye!" 8 45
		EXITVAR=5
    ;;
    S)
        installSplunkForwarder
    ;;
	esac
done
} 

menuFunction
