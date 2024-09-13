#!/bin/bash

# 1. 계정 관리
source U-01.sh
source U-02.sh

###############################################################################################################\

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
}

main
