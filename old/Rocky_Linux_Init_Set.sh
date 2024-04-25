#!/bin/bash

#################################
#
# ┌ 2023 07 25 최초 수정┐
# 기존 KT Cloud DX Zone CentOS Inital Setting 참고 #
#
#--------------------------------
#
# AWS Rocky Linux Inital Setting #
#
#################################

# root 권한으로 실행해야됨
#sudo -i

# UTC to KST Converter / 서울 시간으로 변경
ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime
timedatectl

# History Time Logging / history 명령어에 시간 추가
echo "HISTTIMEFORMAT=\"[%Y-%m-%d_%H:%M:%S]  \"" >> /etc/profile
source /etc/profile

# SSH Password Login / ssh 접속 시 계정으로 접속 할 수 있게 변경
sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config # root 계정 로그인 허용 안함
sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config # 패스워드 인증 활성화
sed -i '/PasswordAuthentication no/ s/^/#/' /etc/ssh/sshd_config # 패스워드 인증 옵션이 'no' 이면 주석처리
sed -i '/GSSAPIAuthentication yes/ s/^/#/' /etc/ssh/sshd_config  # GSS API 인증 설정 비활성화 / kerberos DNS 질의 발생하여 ssh 접속 지연 발생
systemctl restart sshd

# Password Change
echo 'Sniper13@$' | passwd --stdin root
#
# ┌ 2023 07 25 주석 처리 ┐
#echo 'Sniper13@$' | passwd --stdin centos
#
# ┌ 2023 07 25 추가 ┐							
echo 'Sniper13@$' | passwd --stdin rocky # Rocky Linux는 기본 계정이 rocky임

# FTP root Login / FTP 접속 시 root 계정으로 로그인 제한
echo "root" >> /etc/ftpusers

# Selinux Disable
setenforce 0 # 임시적으로 SELINUX 비활성화
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config

# Firewalld Disable
## Rocky Linux 8.8 버전은 firewalld 가 설치 안되어있음
#
# ┌ 2023 07 25 주석 처리 ┐
#systemctl stop firewalld && systemctl disable firewalld

# Network Tool Install 
## Rock Linux 8 버전은 yum 대신 dnf 사용
# ┌ 2023 07 25 주석 처리 ┐
#yum install iputils net-tools tcpdump -y 	
#							
# ┌ 2023 07 25 추가 ┐
dnf install iputils net-tools tcpdump -y 								

# NTP Client Configuration
## RHEL 8 버전 부터 NTP 패키지 지원 X / chronyd 로 대체
#---------------------------
# ┌ 2023 07 25 주석 처리 ┐
#yum install ntp ntpdate -y
#
# ┌ 2023 07 25 주석 처리 ┐
#systemctl stop ntpd 
#						
# ┌ 2023 07 25 주석 처리 ┐
#sed -i '/time.bora.net/ s/^/#/g' /etc/ntp.conf
#
# ┌ 2023 07 25 주석 처리 ┐
#sed -i '/kr.pool.ntp.org/ s/^/#/g' /etc/ntp.conf
#
# ┌ 2023 07 25 주석 처리 ┐
#sed -i'' -r -e "/joining/a\server 172.25.2.171 iburst" /etc/ntp.conf
#
# ┌ 2023 07 25 주석 처리 ┐
#ntpdate  172.25.2.171	#NGS Server IP
#
# ┌ 2023 07 25 주석 처리 ┐
#systemctl start ntpd && systemctl enable ntpd
#
# ┌ 2023 07 25 주석 처리 ┐
#echo "00 1 * * * root ntpdate 172.25.2.171" >> /etc/crontab
#
# ┌ 2023 07 25 주석 처리 ┐
#systemctl restart crond
#---------------------------
#								
## Rocky Linux NTP 설정
# ┌ 2023 07 27 추가 ┐ ntpd -> chronyd
dnf install chrony -y # chrony 패키지 설치
systemctl stop chronyd # chrony 데몬 중지
sed -i '/pool 2.rocky.pool.ntp.org iburst/ s/^/#/' /etc/chrony.conf # 기본 ntp 서버 주석
sed -i '/pool 2.rocky.pool.ntp.org iburst/a\server time.bora.net iburst' /etc/chrony.conf # ntp 서버 'time.bora.net' 추가
systemctl start chronyd # chrony 데몬 시작
chronyc sources # ntp 서버 싱크 확인
