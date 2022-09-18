#!/bin/bash

#determine operating system

#install fail2ban
if [ $(command -v apt-get) ]; then # Debian based
    apt-get install fail2ban -y 
elif [ $(command -v yum) ]; then
    yum -y install fail2ban
elif [ $(command -v pacman) ]; then 
    yes | pacman -S fail2ban
elif [ $(command -v apk) ]; then # Alpine
    apk update
    apk upgrade
    apk add bash fail2ban
fi

#ADD SUPPORT FOR OTHER DISTROS BECAUSE THE LOGPATH IS DIFF

#configure sshd
#sed -i '/^[sshd]*/a enabled=true\nmaxretry=3\nfindtime=20m\nbantime=30m' /etc/fail2ban/jail.conf
printf "[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 120
" > /etc/fail2ban/jail.d/ssh.conf

#wordpress
printf "[wordpress]
enabled = true
filter = wordpress
logpath = /var/log/auth.log
maxretry = 3
port = http,https
bantime = 300
" > /etc/fail2ban/jail.d/wordpress.conf

#add more fail2ban applications


systemctl restart fail2ban
systemctl enable fail2ban
systemctl mask fail2ban

fail2ban-client status