#!/bin/bash

#source core.sh
#source menu.sh
#source module/menu.sh
#source ./check/Security_check.sh
#source ./module/textstyle.sh
source /root/WinsCloud/02.Security/module/textstyle.sh
#source ./module/menu.sh
source /root/WinsCloud/02.Security/module/menu.sh
#source check/Security_check.sh
#source Install_Ansible.sh
#source Create_PublicKey.sh

function main() {
	menu
	#Install_Ansible # 앤서블 설치 함수
	#Create_Pubkey # 퍼블릭키 배포 함수
}

main
