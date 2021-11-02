#!/bin/bash

###############
## FUNCTIONS ##
###############

## PRESS ENTER ## 
function press_enter() {
  echo ""
  echo -n "	Press Enter to continue "
  read
  clear
}

## OS DETECTION ##
function OS_Detection() {
  clear
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m  Detecting Operating System"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo ""
  local os_val=$(cat /etc/*-release | grep DISTRIB_DESCRIPTION | tr -d 'DISTRIB_DESCRIPTION="')
  echo "$os_val"
}

## SYSTEM UPDATES ## 
function update_system(){
  clear
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m Updating the System"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo ""
  apt-get update
  apt-get upgrade -y
  apt-get dist-upgrade -y
}

## SSH SERVER ##
function SSH_Hardening() {
  clear
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m Hardening SSH Server"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo ""

  # Set /etc/ssh/sshd_config ownership and access permissions
  chown root:root /etc/ssh/sshd_config
  chmod 600 /etc/ssh/sshd_config
  
  # Protocol 2
  echo "Protocol 2" >> /etc/ssh/sshd_config

  # Set SSH LogLevel to INFO
  sed -i "/LogLevel.*/s/^#//g" /etc/ssh/sshd_config

  # Set SSH MaxAuthTries to 3
  sed -i "s/#MaxAuthTries 6/MaxAuthTries 3/g" /etc/ssh/sshd_config

  # Enable SSH IgnoreRhosts
  sed -i "/IgnoreRhosts.*/s/^#//g" /etc/ssh/sshd_config

  # Disable SSH HostbasedAuthentication
  sed -i "/HostbasedAuthentication.*no/s/^#//g" /etc/ssh/sshd_config

  # Disable SSH root login
  sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin no/g" /etc/ssh/sshd_config

  # Deny Empty Passwords
  sed -i "/PermitEmptyPasswords.*no/s/^#//g" /etc/ssh/sshd_config

  # Deny Users to set environment options through the SSH daemon
  sed -i "/PermitUserEnvironment.*no/s/^#//g" /etc/ssh/sshd_config

  # Allow only approved ciphers
  echo "Ciphers aes256-ctr" >> /etc/ssh/sshd_config

  # Set MAC
  echo "MACs hmac-sha2-512-etm@openssh.com,hmac-sha2-256-etm@openssh.com,hmac-sha2-512,hmac-sha2-256" >> /etc/ssh/sshd_config

  # Configure SSH Idle Timeout Interval
  sed -i "s/#ClientAliveInterval 0/ClientAliveInterval 300/g" /etc/ssh/sshd_config
  sed -i "s/#ClientAliveCountMax 3/ClientAliveCountMax 0/g" /etc/ssh/sshd_config

  # Set Banner
  sed -i "s/#Banner none/Banner \/etc\/issue\.net/g" /etc/ssh/sshd_config
  echo "Welcome" > /etc/issue.net

  # Allow wheel group use ssh
  #echo "AllowGroups wheel" >> /etc/ssh/sshd_config

  # Disable X11 forwarding
  sed -i "s/X11Forwarding yes/#X11Forwarding yes/g" /etc/ssh/sshd_config

  iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
  
  service sshd restart
}

## IP TABLES
function IP_Tables() {
  clear
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo -e "\e[93m[+]\e[00m Setting up IP Tables"
  echo -e "\e[34m---------------------------------------------------------------------------------------------------------\e[00m"
  echo ""

  apt-get -y install iptables

  # Install iptables-persistent
  apt-get -y install iptables-persistent
  systemctl enable netfilter-persistent

  # Flush/Delete firewall rules
  iptables -F
  iptables -X
  iptables -Z

  # Reset and disable IPv6
  ip6tables -t nat -F
  ip6tables -t mangle -F
  ip6tables -F
  ip6tables -X
  ip6tables -Z
  ip6tables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  ip6tables -P INPUT DROP
  ip6tables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
  ip6tables -A OUTPUT -o lo -m state --state NEW,ESTABLISHED,RELATED -j ACCEPT
  ip6tables -P OUTPUT DROP
  ip6tables -P FORWARD DROP
  ip6tables-save

  # Reset IPv4
  iptables -t nat -F
  iptables -t mangle -F
  iptables -F
  iptables -X
  iptables -Z
  iptables -P FORWARD DROP

  # Βlock null packets (DoS)
  iptables -A INPUT -p tcp --tcp-flags ALL NONE -j DROP

  # Block syn-flood attacks (DoS)
  iptables -A INPUT -p tcp ! --syn -m state --state NEW -j DROP

  # Block XMAS packets (DoS)
  iptables -A INPUT -p tcp --tcp-flags ALL ALL -j DROP

  # Allow internal traffic on the loopback device
  iptables -A INPUT -i lo -j ACCEPT

  # Allow established connections
  iptables -I INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
    
  # Allow outgoing connections
  iptables -P OUTPUT ACCEPT
    
  # Set default deny firewall policy
  iptables -P INPUT DROP

  # Set default deny firewall policy
  iptables -P FORWARD DROP

  # Save rules
  iptables-save > /etc/iptables/rules.v4

  # Apply and confirm
  iptables-apply -t 40 /etc/iptables/rules.v4
}

## BLOCK IP ##
function Block_IP() {
  #Specify the IP you want to block
  echo Input IP you want to block: 
  read ip

  # Blocks ALL Traffic From the Sepcified IP
  iptables -I INPUT 1 -s $ip  -j DROP
  iptables -I OUTPUT 1 -s $ip -j DROP
  iptables -I FORWARD 1 -s $ip -j DROP

  echo The IP $ip was succesfully blocked. 
}

## CUT SWITCH ##
function Cut_Switch() {
  # Deny All Traffic
  iptables -I INPUT 1 -j DROP
  iptables -I FORWARD 1 -j DROP
  iptables -I OUTPUT 1 -j DROP
}

## REMOVE BAD SERVICES ##
function Bad_Services() {
  # Remove legacy services (e.g., telnet-server; rsh, rlogin, rcp; ypserv, ypbind; tftp, tftp-server; talk, talk-server).
  # Disable legacy services (e.g., chargen-dgram, chargen-stream, daytime-dgram, daytime-stream, echo-dgram, echo-stream, tcpmux-server).
  # Disable or remove server services that are not going to be utilized (e.g., FTP, DNS, LDAP, SMB, DHCP, NFS, SNMP, etc.).
  echo "Empty"
}

function Ascii_Art() { 
  printf "${BLUE}
                 /C.   C\.
                /SS.   SS\.
               /UUU.   UUU\.
              /SSSS.   SSSS\.
             /BBBBB.   BBBBB\.
          /CSUSBCSUSBCSUSBCSUSB\.
       /CSUSBCSUSBCSUSBCSUSBCSUSBC\.
    /CSUSBCSUSBCSUSBCSUSBCSUSBCSUSBCS\.
 \CSUSBCSUS   USBCSUSBCSUSBC   BCSUSBCSU/.
  \CSUSBCSUS   USBCSUSBCSUS   USBCSUSBC/.
   \CSUSBCSUS   USBCSUSBCS   CSUSBCSUS/.
    \CSUSBCSUS   USBCSUSB   SBCSUSBCS/.
     \CSUSBCSUS   CSUSBC   SUSBCSUSB/.
      \CSUSBCSUSBCSUSBCSUSBCSUSBCSU/.
       \CSUSBCSUSBCSUSBCSUSBCSUSBC/.
             \CSUSBCSUSBCSUS/.
              \CSUSBCSUSBCS/.
               \CSUSBCSUSB/.
                \CSUSBCSU/.
                 \CSUSBC/.
                  \CSUS/.
                   \**/.\n\n${NC}" 

  printf "\t${RED}   ________________  ______\n${NC}"
  printf "\t${RED}  / ____/ ____/ __ \/ ____/\n${NC}"
  printf "\t${RED} / /   / /   / / / / /\n${NC}"     
  printf "\t${RED}/ /___/ /___/ /_/ / /___\n${NC}"   
  printf "\t${RED}\____/\____/_____/\____/\n${NC}"   
}        

###################
## PROGRAM START ##
###################

RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

::'
if [ "$EUID" -ne 0 ]; then
  echo "Error: Please run as root"
  exit 1
fi'
        
## DETECT OS ##
OS=$(OS_Detection)

##########
## MENU ##
##########
until [ "$selection" = "0" ]; do
  clear
  Ascii_Art
  echo ""
  echo "    	1  -  Set IP Tables"
  echo "    	2  -  Harden SSH Server"
  echo "    	3  -  Block a Specific IP"
  echo "    	4  -  Remove Bad Services"
  echo "    	5  -  Update/Upgrade System"
  echo "    	0  -  Exit"
  echo ""
  echo -n "  Enter selection: "
  read selection
  echo ""
  case $selection in
    1 ) clear ; IP_Tables ; press_enter ;;
    2 ) clear ; SSH_Hardening ; press_enter ;;
    3 ) clear ; Block_IP ; press_enter ;;
    4 ) clear ; Bad_Services ; press_enter ;;
    5 ) clear ; Update ; press_enter ;;
    0 ) clear ; exit ;;
    * ) clear ; incorrect_selection ; press_enter ;;
  esac
done