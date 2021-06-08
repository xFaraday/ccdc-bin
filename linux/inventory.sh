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

section="${blue}LISTENING CONNECTIONS${NC}"
spacer "$section"

function motherprocess() {
	tmp=$1
	until [ $tmp -eq 1 ]; do
		reg=$tmp
		tmp=$(ps -o ppid= -p $reg)
	done
	cmd=$(ps -fp $reg | awk '{print $8}')
	printf "Master process ID: $reg\n $cmd\n"
}

#ports
ports=$(lsof -i -P -n | grep LISTEN)
printf "$ports"
#find open ports lsof -i -P -n | grep LISTEN | awk '{print $9}' | cut -d':' -f2-
portlisten=$(lsof -i -P -n | grep LISTEN | awk '{print $9}' | cut -d':' -f2- | sort -u)
for i in $portlisten; do
	tmp=$(expr $i + 1 2>/dev/null)
	if [ $? == 2 ]; then
		printf "\n"
	else
		var=$(lsof -iTCP:$i -sTCP:LISTEN | awk '{print $2}' | tail -n1)
		printf "\nPort: ${RED}$i${NC} Owning process: $var \n"
		motherprocess "$var"
	fi
done
#put those ports into lsof -iTCP:53 -sTCP:LISTEN to find process
#ps -o ppid= -p pid
#ps -fp PID find some way to parse the ps output to get the full command alone maybe

#firewall
#either learn how to read iptables or just figure out a way to make it easy to read

#services
#systemctl is-active --quiet service && echo Service is running
section="${blue}SERVICES${NC}"
spacer "$section"

essentials=("ssh" "sshd" "apache" "apache2" "httpd" "smbd" "vsftpd" "mysql" "postgresql" "vncserver" "xinetd" "telnetd" "webmin" "cups" "ntpd" "snmpd" "dhcpd" "ipop3" "postfix" "rsyslog")
for i in ${essentials[@]}; do
	var=$(systemctl is-active $i)
	if [ "$var" == "active" ]; then
		secvar=$(systemctl is-enabled $i)
		if [ "$secvar" == "enabled" ]; then
			printf "Service: ${RED}$i${NC} is running and enabled!\n"
		else
			printf "Service: ${RED}$i${NC} is running!\n"
		fi
	fi
done
serviceslong=$(systemctl --type=service --state=active)
