#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo 'Error: Please run as root'
  exit 1
fi

RED='\033[0;31m'
blue='\033[0;34m'
NC='\033[0m'

function usage() {
	banner
	printf -- "-v =  host infomration\n"
	printf -- "-u =  user infomration\n"
	printf -- "-l =  lastlog\n"
	printf -- "-p =  port information\n"
	printf -- "-s =  service information\n"
	printf -- "-c =  cron information\n"
	printf -- "-g =  log information\n"
	printf -- "-f =  file information\n"
	printf -- "-a =  all information\n"
	printf -- "-h = help\n"
}

function banner() {
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

	printf "\t${RED}   ________________  ______\n${NC}"
	printf "\t${RED}  / ____/ ____/ __ \/ ____/\n${NC}"
	printf "\t${RED} / /   / /   / / / / /\n${NC}"     
	printf "\t${RED}/ /___/ /___/ /_/ / /___\n${NC}"   
	printf "\t${RED}\____/\____/_____/\____/\n${NC}" 

	printf "\n${blue}BLUE TEAM INVENTORY\n\n${NC}"
}
function spacer () {
	printf "\n\n############################ $1 ############################\n\n"
}

function smallspacer () {
	printf "\n############## $1 ##############\n"
}

function ExportToCSV () {
	#figure out a way to make a newline for the csv file and fix it for the arrays
	printf "\n\n${blue}Exporting to CSV...\n\n${NC}"
	if ! [ -f ./inventory.csv ]; then
		touch ./inventory.csv
		runtime=$(date +"%H:%M:%S")
		printf "$runtime," >> ./inventory.csv
	fi
	printf "$1," >> ./inventory.csv
}

#host and ip
#hostname | ip 

function host() {
	host=$(hostname)
	printf "Hostname: $host\n"
	cards=$(lshw -class network | grep "logical name:" | sed 's/logical name://')
	ips=()
	for n in $cards; do
		ip4=$(/sbin/ip -o -4 addr list $n | awk '{print $4}' | cut -d/ -f1)
		printf "Ip: $ip4 Card: $n\n"
		ips+=($ip4)
	done

	section="${blue}OS INFORMATION${NC}"
	spacer "$section"

	#host info
	version=$(cat /etc/*rel*)
	printf "$version\n"
	#kernel shit
	kernel=$(uname -a)
	printf "\n\n$kernel\n"
	os_release=$(lsb_release -a)
	printf "\n\n$os_release\n"
}

function user() {
	section="${blue}USER INFORMATION${NC}"
	spacer "$section"

	#users
	#cat /etc/passwd | grep -in /bin/bash
	users=$(grep 'sh$' /etc/passwd)
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
		section="${blue}Users in admin group${NC}"
		smallspacer "$section"
		grep -Po '^admin.+:\K.*$' /etc/group
		section="${blue}Users in wheel group${NC}"
		smallspacer "$section"
		grep -Po '^wheel.+:\K.*$' /etc/group
	fi
}

function login() {
	section="${blue}Login Information${NC}"
	smallspacer "$section"

	printf "$(lastlog)\n\n"

	printf "$(w)\n\n"
}

function ports() {
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
			#TO DO 
			#also print the command used for last process, just in case
			#
			var=$(lsof -iTCP:$i -sTCP:LISTEN | awk '{print $2}' | tail -n1)
			printf "\nPort: ${RED}$i${NC} Owning process: $var \n"
			motherprocess "$var"
		fi
	done
}
#put those ports into lsof -iTCP:53 -sTCP:LISTEN to find process
#ps -o ppid= -p pid
#ps -fp PID find some way to parse the ps output to get the full command alone maybe

#firewall
#either learn how to read iptables or just figure out a way to make it easy to read

#services
#systemctl is-active --quiet service && echo Service is running

function service() {
	section="${blue}SERVICES${NC}"
	spacer "$section"
	runningservs=()
	essentials=("ssh" "sshd" "apache" "apache2" "httpd" "smbd" "vsftpd" "mysql" "postgresql" "vncserver" "xinetd" "telnetd" "webmin" "cups" "ntpd" "snmpd" "dhcpd" "ipop3" "postfix" "rsyslog" "docker" "samba" "postfix" "smtp" "psql" "clamav" "bind9" "nginx" "mariadb" "ftp")
	for i in ${essentials[@]}; do
		var=$(systemctl is-active $i)
		if [ "$var" == "active" ]; then
			secvar=$(systemctl is-enabled $i)
			if [ "$secvar" == "enabled" ]; then
				printf "Service: ${RED}$i${NC} is running and enabled!\n"
				loc=$(ls /etc | grep $i)
				printf "\t Likely config files: /etc/$loc\n"
			else
				printf "Service: ${RED}$i${NC} is running!\n"
				loc=$(ls /etc | grep $i)
				printf "\t Likely config files: /etc/$loc\n"
				runningservs+=("$i")
			fi
		fi
	done
	serviceslong=$(systemctl --type=service --state=active)
}

function cron() { 
	section="${blue}CRONTAB${NC}"
	spacer "$section"

	section="${blue}System Cronjobs${NC}"
	smallspacer "$section"

	crontab -l

	section="${blue}User Cronjobs${NC}"
	smallspacer "$section"

	users=$(grep 'sh$' /etc/passwd | cut -d':' -f1)
	for user in $users; do
		crontab -l -u $user
	done
}


function log() {
	section="${blue}LOGS${NC}"
	spacer "$section"

	#add log section
		
}

function dockerenum() {

	runnin=$(docker ps)

	images=$(docker images)
	section="${blue}currently running${NC}"
	smallspacer "$section"
	printf -- "$runnin\n\n"
	section="${blue}images installed${NC}"
	smallspacer "$section"
	printf -- "$images\n\n"

}

function dockercheck() {
	section="${blue}DOCKER${NC}"
	spacer "$section"

	if [ -x "$(command -v Docker)" ]; then
  		echo 'Error: Docker is not installed.'
  		return 1
  	else 
  		echo 'Docker installed'
  		dockerenum
	fi
}




function file() {
	section="${blue}FILES${NC}"
	spacer "$section"

	#add file section
	scriptsinhome=$(find /home -daystart -mtime -2 -name '*.sh' -type f -exec ls -l {} \; 2>/dev/null)

	printf -- "$scriptsinhome"
	printf "\n\n"
}

while getopts 'host:user:login:ports:services:cron:log:file:all' option; do
	case "$option" in
		v)host; exit 0 ;;
		u)user; exit 0 ;;
		l)login; exit 0 ;;
		p)ports; exit 0 ;;
		s)service; exit 0 ;;
		c)cron; exit 0 ;;
		o)dockercheck; exit 0 ;;
		g)log; exit 0 ;;
		f)file; exit 0 ;;
		a)a= host; user; login; ports; service; cron; dockercheck; log; file; exit 0;;
		h) usage; exit 0;;
	esac
done
