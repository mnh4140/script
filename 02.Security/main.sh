#!/bin/bash

# 1. 계정 관리
source U-01.sh
source U-02.sh
source U-03.sh
source U-04.sh
source U-45.sh
source U-46.sh
source U-47.sh
source U-48.sh
source U-54.sh
# 2. 파일 및 디렉터리 관리
source U-07.sh
source U-08.sh
source U-09.sh
source U-10.sh
source U-11.sh
source U-12.sh
source U-14.sh
source U-56.sh
# 3. 서비스 관리
source U-20.sh
source U-22.sh
source U-65.sh
source U-68.sh
source U-69.sh

# 함수들

###############################################################################################################\

function GetDate()	#	날짜 받아오는 함수, 날짜 받아와서 로그파일 이름에 날짜 넣어줌
{
	date=$(date '+%Y%m%d_%H%M')
	logfilename="security_$date"
	LOGFILE=$HERE/LOG/security/$logfilename.log # 로그 파일 경로 저장 변수
	BACKTITLE="$LOGFILE"
}

function HDDCheck()	#	HDD 정보 받아오는 함수
{
	parted=`parted /dev/$1 <<!EOF
	print
	quit
	!EOF
	`
	disk=`echo "$parted" | awk -F "Disk" '{print $2}' | grep /dev` 
	device=`echo "$disk" | awk -F ":" '{print $1}'`
	size=`echo "$disk" | awk -F ": " '{print $2}'`
	echo $size "   [" $device "]"
}

function CompareValue()	#	취약점 점검 시 취약한지 안전한지 값 비교
{
	if [ "$2" = "$3" ]
        then
                echo -n "$1"
                echo " Setting Sucess\n"
        else
                echo -n "$1"
                echo " Setting Fail\n"
        fi	
	sed -i -e 's/\\n$//' $LOGFILE
}

function filebackup() # 취약점 조치 시, 변경되는 파일 백업 수행
{
	if [ -e $HERE/BACKUP/$1 ]
	then
		echo "$3 Backup Exists    : $2 -> ./BACKUP/$1" >> $LOGFILE
	else
		\cp -rp $2 $HERE/BACKUP/$1

		if [ -e $HERE/BACKUP/$1 ]
		then
			echo "$3 Backup Completed : $2 -> ./BACKUP/$1" >> $LOGFILE
		else
			echo "$3 Backup Fail" >> $LOGFILE
		fi
	fi
}




##########################################################################################

function main() {
	echo "# 1. 계정 관리"
	U-01
	U-02
	U-03
	U-04
	U-45
	U-46
	U-47
	U-48
	U-54
	echo "# 2. 파일 및 디렉터리 관리"
	U-07
	U-08
	U-09
	U-10
	U-11
	U-12
	U-14
	U-56
	echo "# 3. 서비스 관리"
	U-20
	U-22
	U-65
	U-68
	U-69
}

main
