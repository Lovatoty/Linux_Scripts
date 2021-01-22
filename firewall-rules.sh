#!/bin/bash


#TODO Change Dport to sport
#TODO add DDoS protection and contrack
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
					iptables -A INPUT -p tcp --dport 443 -j ACCEPT
					echo "Adding Except Rule for port 443 inbound."
				;;
				8089-TCP)
					iptables -A INPUT -p tcp --dport 8089 -j ACCEPT
				;;
				lo)
					iptables -A INPUT -i lo -j ACCEPT
					echo "Enabling Localhost Communication"
				;;
			esac

}
function FIREWALL_OUTBOUND_RULES(){

#whiptail --title "IPv4 Outbound Rules" --msgbox "Flushing rules and setting default policy to drop" 8 44 
#iptables -F OUTPUT
#iptables -P OUTPUT DROP

whiptail --title "IPv4 - Outbound Rules" --seperate-output "Choose:" --checklist "Outbound Rules" 32 60 8 \
                "22-TCP" "SSH" OFF \
                "53-UDP" "DNS" OFF \
                "80-TCP" "HTTP" OFF \
                "443-TCP" "HTTPS" OFF \
                "9997" "Splunk Forwarder" ON \
				"lo" "Localhost Traffic" ON 2>results

				while read OUTBOUNDRULES
				do
				case $OUTBOUNDRULES in
				22-TCP)
					iptables -A OUTPUT -p tcp --sport 22 -j ACCEPT
					echo "Adding Except Rule for port 22 outbound."
				;;
				25-TCP)
					iptables -A OUTPUT -p tcp --sport 25 -j ACCEPT
					echo "Adding Except Rule for port 25 outbound."
				;;
				
				53-UDP)
					iptables -A OUTPUT -p udp --sport 53 -j ACCEPT
					echo "Adding Except Rule for port 53 outbound."
					;;
				80-TCP)
					iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
					echo "Adding Except Rule for port 80 outbound."
				;;
				110-TCP)
					iptables -A OUTPUT -p tcp --sport 110 -j ACCEPT
					echo "Adding Except Rule for port 110 outbound."
				;;

				443-TCP)
					iptables -A OUTPUT -p tcp --sport 442 -j ACCEPT
					echo "Adding Except Rule for port 442 outbound."
				;;
				9997)
					iptables -A OUTPUT -p tcp --sport 9997 -j ACCEPT
					echo "Adding Except Rule for port 9997 outbound."
				;;
				lo)
					iptables -A OUTPUT -i lo -j ACCEPT
					echo "Enabling Localhost Comimunication"
				;;
			esac
			done < results
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
firewallRules
