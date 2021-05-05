#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo 'Error: Please run as root'
  exit 1
fi

RED='\033[0;31m'
blue='\033[0;34m'
NC='\033[0m'

printf "
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
                   \**/.\n\n"

printf "${RED}   /=====   /=====   /====\   /=====\n${NC}"
printf "${RED}  /=       /=       /=   =\  /=\n${NC}"
printf "${RED} /=       /=       /=   =/  /=\n${NC}"
printf "${RED}/=====   /=====   /====/   /=====\n${NC}"

printf "\n${blue}BLUE TEAM INVENTORY\n\n${NC}"


function spacer () {
	printf "\n\n############################ $1 ############################\n\n"
}

function smallspacer () {
	printf "\n############## $1 ##############\n"
}

#host and ip
#hostname | ip 
host=$(hostname)
printf "Hostname: $host\n"
cards=$(lshw -class network | grep "logical name:" | sed 's/logical name://')
for n in $cards; do
ip4=$(/sbin/ip -o -4 addr list $n | awk '{print $4}' | cut -d/ -f1)
printf "Ip: $ip4 Card: $n\n"
done

section="${blue}OS INFORMATION${NC}"
spacer "$section"

#host info
version=$(cat /etc/*rel*)
printf "$version\n"

section="${blue}USER INFORMATION${NC}"
spacer "$section"

#users
#cat /etc/passwd | grep -in /bin/bash
users=$(cat /etc/passwd | grep -in /bin/bash)
section="${blue}Users that can login${NC}"
smallspacer "$section"
printf "$users"

if [ -f /etc/sudoers ] ; then
    section="${blue}Users in Sudoers File${NC}"
    smallspacer "$section"
    awk '!/#(.*)|^$/' /etc/sudoers
fi 

if ! [ -z "grep sudo /etc/group" ]; then
	section="${blue}Users in sudo group${NC}"
	smallspacer "$section"
	grep -Po '^sudo.+:\K.*$' /etc/group
fi

if ! [ -z "grep sudo /etc/group" ]; then
	section="${blue}Users in sudo group${NC}"
	smallspacer "$section"
	grep -Po '^sudo.+:\K.*$' /etc/group
fi



section="${blue}LISTENING CONNECTIONS${NC}"
spacer "$section"

#ports
ports=$(lsof -i -P -n | grep LISTEN)
printf "$ports"
#find open ports
#put those ports into lsof -iTCP:53 -sTCP:LISTEN to find process
#ps -o ppid= -p pid
#ps -fp PID    find some way to parse the ps output to get the full command alone maybe

#firewall
#either learn how to read iptables or just figure out a way to make it easy to read

#services
#systemctl is-active --quiet service && echo Service is running
section="${blue}SERVICES${NC}"
spacer "$section"

essentials=("ssh" "apache" "apache2" "httpd" "smbd" "vsftpd" "mysql" "postgresql" "vncserver" "xinetd" "telnetd" "webmin" "")
for i in ${essentials[@]}; do
	var=$(systemctl is-active $i)
	if [ "$var" == "active" ]; then
		printf "Service: $i is running!\n"
	fi
done
serviceslong=$(systemctl --type=service --state=active)

