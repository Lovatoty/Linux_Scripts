#!/bin/bash

function usersWithShells(){
whiptail --title "List of users with shells" --msgbox "The following users have shells they can log in with." 8 60 
whiptail --title "List of users with shells" --textbox /dev/stdin 32 60 <<<"$(
grep -v -e 'sync' -e 'bin/false' -e 'sbin/nologin' /etc/passwd)"
}

#This function is ultimately not needed because the folder is created by the tar
function installSplunkForwarder(){
#need to fix /opt
#if [[ ! -e /opt/splunkforwarder ]]; then
#whiptail --msgbox "/opt/splunkforwarder does not exist, creating it now." 8 44
#mkdir /opt/splunkforwarder
#fi

SPLUNKURL=$(whiptail --inputbox "What is the bit.ly URL? to download splunk?" --title "Splunk URL" 8 64 8 3>&1 1>&2 2>&3)

#need to set home variable.
wget -O /opt/splunk.tgz $SPLUNKURL
whiptail --title "Splunk Download" --msgbox "Download Done, prepairing to extract" 8 44
tar -xzf /opt/splunk.tgz
whiptail --title "Splunk Download" --msgbox "Extracting Complete" 8 44

}
function FIREWALL_INBOUND_RULES(){

			whiptail --title "IPv4 Inbound Rules" --msgbox "Flushing rules and setting default policy to drop" 8 44 
			iptables -F INPUT
			iptables -F FORWARD
			iptables -P INPUT DROP
			iptables -P FORWARD DROP

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
					echo "Adding Except Rule for port 22 inbound."
				;;
				25-TCP)
					iptables -A INPUT -p tcp --dport 25 -j ACCEPT
					echo "Adding Except Rule for port 25 inbound."
				;;
				
				53-UDP)
					iptables -A INPUT -p udp --dport 53 -j ACCEPT
					echo "Adding Except Rule for port 53 inbound."
				;;
				80-TCP)
					iptables -A INPUT -p tcp --dport 80 -j ACCEPT
					echo "Adding Except Rule for port 80 inbound."
				;;
				110-TCP)
					iptables -A INPUT -p tcp --dport 110 -j ACCEPT
					echo "Adding Except Rule for port 110 inbound."
				;;

				443-TCP)
					iptables -A INPUT -p tcp --dport 442 -j ACCEPT
					echo "Adding Except Rule for port 442 inbound."
				;;
				lo)
					ptables -A INPUT -i lo -j ACCEPT
					echo "Enabling Localhost Communication"
				;;
			esac

}
function FIREWALL_OUTBOUND_RULES(){

			whiptail --title "IPv4 Outbound Rules" --msgbox "Flushing rules and setting default policy to drop" 8 44 
			iptables -F OUTPUT
			iptables -P OUTPUT DROP

			OUTBOUNDRULES=$(whiptail --title "IPv4 - Outbound Rules" --checklist "Outbound Rules" 32 60 8 \
                "22-TCP" "SSH" OFF \
                "53-UDP" "DNS" OFF \
                "80-TCP" "HTTP" OFF \
                "443-TCP" "HTTPS" OFF \
                "9997" "Splunk Forwarder" ON \
				"lo" "Localhost Traffic" ON 3>&1 1>&2 2>&3)

				case $OUTBOUNDRULES in
				22-TCP)
					iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
					echo "Adding Except Rule for port 22 outbound."
				;;
				25-TCP)
					iptables -A OUTPUT -p tcp --dport 25 -j ACCEPT
					echo "Adding Except Rule for port 25 outbound."
				;;
				
				53-UDP)
					iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
					echo "Adding Except Rule for port 53 outbound."
					;;
				80-TCP)
					iptables -A OUTPUT -p tcp --dport 80 -j ACCEPT
					echo "Adding Except Rule for port 80 outbound."
				;;
				110-TCP)
					iptables -A OUTPUT -p tcp --dport 110 -j ACCEPT
					echo "Adding Except Rule for port 110 outbound."
				;;

				443-TCP)
					iptables -A OUTPUT -p tcp --dport 442 -j ACCEPT
					echo "Adding Except Rule for port 442 outbound."
				;;
				9997)
					iptables -A OUTPUT -p tcp --dport 9997 -j ACCEPT
					echo "Adding Except Rule for port 9997 outbound."
				;;
				lo)
					iptables -A OUTPUT -i lo -j ACCEPT
					echo "Enabling Localhost Communication"
				;;
			esac
}
function FIREALL_DDOS_PROTECTION_RULES(){
    iptables -A INPUT -p tcp -m conntrack --ctstate NEW -m limit --limit 60/s --limit-burst 20 -j ACCEPT
    iptables -A INPUT -p tcp -m conntrack --ctstate NEW -j DROP
}
function FIREWALL_BLOCK_IPV6(){
    ip6tables -P INPUT DROP
    ip6tables -P FORWARD DROP
    ip6tables -P OUTPUT DROP
    ip6tables-save
	whiptail --msgbox "IPv6 Chains Set to Block" 8 44
    
}
function VIEW_CURRENT_FIREWALL_RULES(){
	whiptail --title "IPTables IPv4 Chains" --textbox /dev/stdin 32 60 <<<"$(iptables -L -v -n)"
	whiptail --title "IPTables IPv6 Chains" --textbox /dev/stdin 32 60 <<<"$(ip6tables -L -v -n)"
}

function FIREWALL_RULES_SAVE(){
#There has got to be a better way
	if [ -n "$(uname -a | grep Ubuntu)" ] || [ -n "$(uname -a | grep Debian)" ]; then
		iptables-save
	else
		/sbin/server iptables save
	fi
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
	"V" "View Current Rules" \
	"I" "Modify Inbound Rules" \
	"O" "Modify Outbound Rules" \
	"D" "Apply rules for DDoS Protection" \
	"6" "Block IPv6" \
	"S" "Save Firewall Rules" \
	"E" "Exit" 3>&1 1>&2 2>&3)

	case $RULESELECT in
        V)
            VIEW_CURRENT_FIREWALL_RULES
        ;;
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
		S)
			FIREWALL_RULES_SAVE
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
if (( $EUID != 0 )); then
    whiptail --title "Error" --msgbox "ERROR. Not Root User! Exiting." 8 44
    exit
fi

menuFunction
