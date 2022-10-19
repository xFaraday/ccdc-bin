#!/bin/bash

if [ "$EUID" -ne 0 ]; then
  echo 'Error: Please run as root'
  exit 1
fi

C=$(printf '\033')
ORANGE="${C}[48;2;255;165;0m"
RED="${C}[1;31m"
WHITE="${C}[1;37m"
BLACK="${C}[1;30m"
SED_RED="${C}[1;31m&${C}[0m"
GREEN="${C}[1;32m"
SED_GREEN="${C}[1;32m&${C}[0m"
YELLOW="${C}[1;33m"
SED_YELLOW="${C}[1;33m&${C}[0m"
SED_RED_YELLOW="${C}[1;31;103m&${C}[0m"
BLUE="${C}[1;34m"
SED_BLUE="${C}[1;34m&${C}[0m"
ITALIC_BLUE="${C}[1;34m${C}[3m"
LIGHT_MAGENTA="${C}[1;95m"
SED_LIGHT_MAGENTA="${C}[1;95m&${C}[0m"
LIGHT_CYAN="${C}[1;96m"
SED_LIGHT_CYAN="${C}[1;96m&${C}[0m"
LG="${C}[1;37m" #LightGray
SED_LG="${C}[1;37m&${C}[0m"
DG="${C}[1;90m" #DarkGray
SED_DG="${C}[1;90m&${C}[0m"
NC="${C}[0m"
UNDERLINED="${C}[5m"
ITALIC="${C}[3m"

print_title(){
  if [ "$DEBUG" ]; then
    END_T2_TIME=$(date +%s 2>/dev/null)
    if [ "$START_T2_TIME" ]; then
      TOTAL_T2_TIME=$(($END_T2_TIME - $START_T2_TIME))
      printf $DG"This check took $TOTAL_T2_TIME seconds\n"$NC
    fi

    END_T1_TIME=$(date +%s 2>/dev/null)
    if [ "$START_T1_TIME" ]; then
      TOTAL_T1_TIME=$(($END_T1_TIME - $START_T1_TIME))
      printf $DG"The total section execution took $TOTAL_T1_TIME seconds\n"$NC
      echo ""
    fi

    START_T1_TIME=$(date +%s 2>/dev/null)
  fi

  title=$1
  title_len=$(echo $title | wc -c)
  max_title_len=100
  rest_len=$((($max_title_len - $title_len) / 2))

  printf ${BLUE}
  for i in $(seq 1 $rest_len); do printf " "; done
  printf "╔"
  for i in $(seq 1 $title_len); do printf "═"; done; printf "═";
  printf "╗"

  echo ""

  for i in $(seq 1 $rest_len); do printf "═"; done
  printf "╣ $GREEN${title}${BLUE} ╠"
  for i in $(seq 1 $rest_len); do printf "═"; done

  echo ""

  printf ${BLUE}
  for i in $(seq 1 $rest_len); do printf " "; done
  printf "╚"
  for i in $(seq 1 $title_len); do printf "═"; done; printf "═";
  printf "╝"
  
  printf $NC
  echo ""
}

print_2title(){
  if [ "$DEBUG" ]; then
    END_T2_TIME=$(date +%s 2>/dev/null)
    if [ "$START_T2_TIME" ]; then
      TOTAL_T2_TIME=$(($END_T2_TIME - $START_T2_TIME))
      printf $DG"This check took $TOTAL_T2_TIME seconds\n"$NC
      echo ""
    fi

    START_T2_TIME=$(date +%s 2>/dev/null)
  fi

  printf ${BLUE}"╔══════════╣ $GREEN$1\n"$NC #There are 10 "═"
}

print_3title(){
  printf ${BLUE}"══╣ $GREEN$1\n"$NC #There are 2 "═"
}

print_list(){
  printf ${BLUE}"═╣ $GREEN$1"$NC #There is 1 "═"
}

print_info(){
  printf "${BLUE}╚ ${ITALIC_BLUE}$1\n"$NC
}

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
                 ${DG}/C.   C\.
                ${BLUE}/SS.   SS\.
               /UUU.   UUU\.
              /SSSS.   SSSS\.
             ${DG}/BBBBB.   BBBBB\.
          /CSUSBCSUSBCSUSBCSUSB\.
        ${BLUE}/CSUSBCSUSBCSUSBCSUSBCSUSBC\.
    /CSUSB${RED}CSUSB${BLUE}CSUSBCSUSBCSUS${RED}BCSUS${BLUE}BCS\.
  \CSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUSBCSUSB${RED}C${WHITE}&&&${RED}B${BLUE}CSUSBCSU/.
   \CSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUSBC/.
    \CSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUSBC${RED}S${WHITE}&&&${RED}C${BLUE}SUSBCSUS/.
     \CSUSBCSU${RED}S${WHITE}&&&${RED}U${BLUE}SBCSUS${RED}B${WHITE}&&&${RED}S${BLUE}BCSUSBCS/.
      \CSUSBCSU${RED}S${WHITE}&&&${RED}C${BLUE}SUSB${RED}C${WHITE}&&&${RED}S${BLUE}USBCSUSB/.
       \CSUSBCSU${RED}SBCSU${BLUE}SB${RED}CSUSB${BLUE}CSUSBCSU/.
        \CSUSBCSUSBCSUSBCSUSBCSUSBC/.
              ${RED}\CSUSBCSUSBCSUS${RED}/${DG}.
              ${WHITE}V${RED}\\${BLUE}CSUSBCSUSBCS${RED}/${WHITE}V${DG}.
               ${WHITE}V${RED}\\${BLUE}CSUSBCSUSB${RED}/${WHITE}V${DG}.
                ${WHITE}V${RED}\\${BLUE}CSUSBCSU${RED}/${WHITE}V${DG}.
                 ${WHITE}V${RED}\\${BLUE}CSUSBC${RED}/${WHITE}V${DG}.
                  ${WHITE}V${RED}\\${BLUE}CSUS${RED}/${WHITE}V${DG}.${WHITE}=\\${DG}      ~
                   ${WHITE}V${RED}\**/${WHITE}V${DG}.${WHITE}\\==\\${DG}   ~
                           ${WHITE}\\==\\${DG}    ~
                            ${WHITE}\\==\\${DG} ~
                             ${RED}(--)${DG}~~
                             ~\n" 
                           
	printf "\t${RED}   ________________  ______\n${NC}"
	printf "\t${RED}  / ____/ ____/ __ \/ ____/\n${NC}"
	printf "\t${RED} / /   / /   / / / / /\n${NC}"     
	printf "\t${RED}/ /___/ /___/ /_/ / /___\n${NC}"   
	printf "\t${RED}\____/\____/_____/\____/\n${NC}" 

	printf "\n${BLUE}BLUE TEAM INVENTORY\n\n${NC}"
}
function spacer () {
	printf "\n\n############################ $1 ############################\n\n"
}

function smallspacer () {
	printf "\n############## $1 ##############\n"
}

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

	section="${BLUE}OS INFORMATION${NC}"
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
	section="${BLUE}USER INFORMATION${NC}"
	spacer "$section"

	#users
	#cat /etc/passwd | grep -in /bin/bash
	users=$(grep 'sh$' /etc/passwd)
	section="${BLUE}Users that can login${NC}"
	smallspacer "$section"
	printf "$users"

	if [ -f /etc/sudoers ] ; then
		section="${BLUE}Users in Sudoers File${NC}"
		smallspacer "$section"
		awk '!/#(.*)|^$/' /etc/sudoers
	fi 

	if ! [ -z "grep sudo /etc/group" ]; then
		section="${BLUE}Users in sudo group${NC}"
		smallspacer "$section"
		grep -Po '^sudo.+:\K.*$' /etc/group
		section="${BLUE}Users in admin group${NC}"
		smallspacer "$section"
		grep -Po '^admin.+:\K.*$' /etc/group
		section="${BLUE}Users in wheel group${NC}"
		smallspacer "$section"
		grep -Po '^wheel.+:\K.*$' /etc/group
	fi
}

function login() {
	section="${BLUE}Login Information${NC}"
	smallspacer "$section"

	printf "$(lastlog)\n\n"

	printf "$(w)\n\n"
}

function ports() {
	if [  -z "$1" ]; then
		section="${BLUE}LISTENING CONNECTIONS${NC}"
		spacer "$section"
		ports=$(lsof -i -P -n | grep LISTEN)
		printf "$ports"
	fi

	function motherprocess() {
		tmp=$1
		tmpname=""
		until [[ $tmp -eq 1 || $tmpname == "systemd" ]]; do
			reg=$tmp
			tmp=$(ps -o ppid= -p $reg)
			tmpname=$(ps -fp $tmp | awk '{print $8}' | tail -n 1 | rev | cut -d '/' -f1 | rev | grep -Eo '[sS]ystemd')
		done
		cmd=$(ps -fp $reg | awk '{print $8}')
		if [[ ! -z "$1" ]]; then
			last=$(echo $cmd | tail -n 1 | awk {'print $2'})
			printf "\"service\":\"$last\"},"
		else
			printf "Master process ID: $reg\n $cmd\n"
		fi
	}

	#ports
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
			if [[ ! -z "$1" ]]; then
				var=$(lsof -iTCP:$i -sTCP:LISTEN | awk '{print $2}' | tail -n1)
				printf "{\"port\":$i,"
				motherprocess "$var"
			else
				var=$(lsof -iTCP:$i -sTCP:LISTEN | awk '{print $2}' | tail -n1)
				printf "\nPort: ${RED}$i${NC} Owning process: $var \n"
				motherprocess "$var"
			fi	
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
	if [  -z "$1" ]; then
		section="${BLUE}SERVICES${NC}"
		spacer "$section"
	fi
	runningservs=()
	essentials=("ssh" "sshd" "apache" "apache2" "httpd" "smbd" "vsftpd" "mysql" "postgresql" "vncserver" "xinetd" "telnetd" "webmin" "cups" "ntpd" "snmpd" "dhcpd" "ipop3" "postfix" "rsyslog" "docker" "samba" "postfix" "smtp" "psql" "clamav" "bind9" "nginx" "mariadb" "ftp")
	for i in ${essentials[@]}; do
		var=$(systemctl is-active $i)
		if [ "$var" == "active" ]; then
			secvar=$(systemctl is-enabled $i)
			if [ "$secvar" == "enabled" ]; then
				if [[ ! -z "$1" ]]; then
					printf "$i\n"
				else
					printf "Service: ${RED}$i${NC} is running and enabled!\n"
					loc=$(ls /etc | grep $i)
					printf "\t Likely config files: /etc/$loc\n"
				fi
			else
				if [[ ! -z "$1" ]]; then
					printf "$i\n"
				else
					printf "Service: ${RED}$i${NC} is running!\n"
					loc=$(ls /etc | grep $i)
					printf "\t Likely config files: /etc/$loc\n"
					runningservs+=("$i")
				fi
			fi
		fi
	done
	serviceslong=$(systemctl --type=service --state=active)
}

function cron() { 
	section="${BLUE}CRONTAB${NC}"
	spacer "$section"

	section="${BLUE}System Cronjobs${NC}"
	smallspacer "$section"

	crontab -l

	section="${BLUE}User Cronjobs${NC}"
	smallspacer "$section"

	users=$(grep 'sh$' /etc/passwd | cut -d':' -f1)
	for user in $users; do
		crontab -l -u $user
	done
}


function log() {
	section="${BLUE}LOGS${NC}"
	spacer "$section"

	#add log section
		
}

function dockerenum() {

	runnin=$(docker ps)

	images=$(docker images)
	section="${BLUE}currently running${NC}"
	smallspacer "$section"
	printf -- "$runnin\n\n"
	section="${BLUE}images installed${NC}"
	smallspacer "$section"
	printf -- "$images\n\n"

}

function file() {
	section="${BLUE}FILES${NC}"
	spacer "$section"

	#add file section
	scriptsinhome=$(find /home -daystart -mtime -2 -name '*.sh' -type f -exec ls -l {} \; 2>/dev/null)

	printf -- "$scriptsinhome"
	printf "\n\n"
}

##########################################
#					                     #
#	         new functions               #
#					                     #
#########################################

GetOS() {
	if [ -x $(which hostnamectl) ]; then
		OS=$(hostnamectl | grep "Operating System" | cut -d':' -f2)
		printf "$OS"
	else
		OS=$(cat /etc/*-release | grep PRETTY_NAME | cut -d'=' -f2)
	fi
}

GetIP() {
	cards=$(lshw -class network | grep "logical name:" | sed 's/logical name://')
	for n in $cards; do
		ip4=$(/sbin/ip -o -4 addr list $n | awk '{print $4}' | cut -d/ -f1)
		printf "$ip4"
	done
}

GetUsers() {
	users=$(grep 'sh$' /etc/passwd | tr ':' ' ')

	printf "$users" | gawk '
	BEGIN { ORS = ""; print ""}
	/Filesystem/ {next}
	{ printf "%s{\"username\": \"%s\", \"uid\": \"%s\", \"home_dir\": \"%s\"}",
		separator, $1, $3, $5
	separator = ", "
	}
	END { print "" }
	'
}

function dockercheck() {
	#section="${BLUE}DOCKER${NC}"
	#spacer "$section"

	if [ -x "$(command -v Docker)" ]; then
  		echo 'Error: Docker is not installed.'
  		return 1
  	else 
  		echo 'Docker installed'
  		return 0
	fi
}

PostToServ() {
	#webserv="10.123.80.115:5000/api/v1/common/inventory"
	webserv="httpbin.org/post"
	postdata=$1
	echo $postdata | jq 
	if [ -x $(which curl) ]; then
		#add custom user agent
		curl -H 'Content-Type: application/json' -d "$postdata" https://${webserv} --insecure
	else 
		wget --post-data "$postdata" https://${webserv} #--no-check-certificate
	fi
}

DSuck() {
	#containers = [
	#	{
	#		"container_id": "test",
	#		"image": "test",
	#		"status": "",
	#	}
	#]
	#
	docs=$(docker ps -a --format "{{.ID}} {{.Image}} {{.Status}}")
	if [[ -z "$docs" ]]; then
		printf "null"
	else 
		IDs=$(printf "$docs" | awk '{print $1}')
		images=$(printf "$docs" | awk '{print $2}')
		status=$(printf "$docs" | awk '{print $3}')
		#printf "$IDs\n$images\n$status\n"
		
		printf "$docs" | gawk '
		BEGIN { ORS = ""; print ""}
    	/Filesystem/ {next}
    	{ printf "%s{\"container_id\": \"%s\", \"image\": \"%s\", \"status\": \"%s\"}",
          separator, $1, $2, $3
      	separator = ", "
    	}
    	END { print "" }
		'
	fi
}

function ExportToJSON() {
	OS=$(GetOS)
	IP=""
	IPS=$(GetIP)
	if [[ $(echo $IPS | wc -l) -gt 1 ]]; then
		for i in $IPS; do
			IP+="$i-:-"
		done
	else
		IP+=$IPS
	fi

	docks=""
	if [ ! -x "$(command -v Docker)" ]; then
		dockerCon=$(DSuck)
		docks+=$dockerCon
	fi

	printf "\n\n${BLUE}Exporting to JSON...\n\n${NC}"
	JSON='{"name":"%s","hostname":"%s","ip":"%s","OS":"%s","services":[%s], "containers":[%s], "users":[%s]}'
	#create array with format of
	#\{ "port": 80, "service": "http"},
	#from the cracked lsof function

	hostname=$(hostname)

	nameIP=$(echo $IPS | rev | cut -d '.' -f1 | rev)

	name="host-$nameIP"

	services=$(ports "json")

	#@TODO: !get groups for each user!
	#
	#
	#
	users=$(GetUsers)

	#echo -e "${services::-1}\n\n"
	if [[ $(echo -e "${services}" | wc -l) -gt 0 ]]; then
		postdata=$(printf "$JSON" "$name" "$hostname" "$IP" "$OS" "${services::-1}" "$docks" "$users")
		PostToServ "$postdata"
	else 
		$services='{"port": "NULL", "service": "NULL"}'
		postdata=$(printf "$JSON" "$name" "$hostname" "$IP" "$OS" "$services" "$docks" "$users")
		PostToServ "$postdata"
	fi
}

#while getopts 'banner:host:user:login:ports:services:cron:log:file:all' option; do
#	case "$option" in
#		b)banner; exit 0 ;;
#		v)host; exit 0 ;;
#		u)user; exit 0 ;;
#		l)login; exit 0 ;;
#		p)ports; exit 0 ;;
#		s)service; exit 0 ;;
#		c)cron; exit 0 ;;
#		o)dockercheck; exit 0 ;;
#		g)log; exit 0 ;;
#		f)file; exit 0 ;;
#		a)a= banner; host; user; login; ports; service; cron; dockercheck; log; file; exit 0;;
#		h) usage; exit 0;;
#	esac
#done
#host
#banner
ExportToJSON
#GetUsers