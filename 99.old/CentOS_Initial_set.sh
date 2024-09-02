#!/bin/bash

#################################
# KT Cloud DX Zone CentOS Inital Setting #
#################################

# UTC to KST Converter
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

# History Time Logging
echo "HISTTIMEFORMAT=\"[%Y-%m-%d_%H:%M:%S]  \"" >> /etc/profile
source /etc/profile

# SSH Password Login
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config  
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config 
sed -i '/PasswordAuthentication no/ s/^/#/' /etc/ssh/sshd_config 
sed -i '/GSSAPIAuthentication yes/ s/^/#/' /etc/ssh/sshd_config  
systemctl restart sshd

# Password Change
echo 'Sniper13@$' | passwd --stdin root
echo 'Sniper13@$' | passwd --stdin centos

# FTP root Login 
echo "root" >> /etc/ftpusers

# Selinux Disable
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Firewalld Disable
systemctl stop firewalld && systemctl disable firewalld

# Network Tool Install
yum install iputils net-tools tcpdump -y

# NTP Client Configuration
yum install ntp ntpdate -y
systemctl stop ntpd
sed -i '/time.bora.net/ s/^/#/g' /etc/ntp.conf
sed -i '/kr.pool.ntp.org/ s/^/#/g' /etc/ntp.conf
sed -i'' -r -e "/joining/a\server 172.25.2.171 iburst" /etc/ntp.conf
ntpdate  172.25.2.171	#NGS Server IP
systemctl start ntpd && systemctl enable ntpd
echo "00 1 * * * root ntpdate 172.25.2.171" >> /etc/crontab
systemctl restart crond


