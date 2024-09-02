#!/bin/bash

################################################

# Update : 2024-04-24
# Cloud Security Setting Scripts(Rocky Linux 8.X, Ubuntu 22.04)
# TEST CSP : KT Cloud, AWS

################################################

#Start of Shell Scripts


###############################################################################################################

# OS 체크 함수

###############################################################################################################

function checkOS() # OS 체크 함수
{
    OS_NAME=$(cat /etc/os-release | grep ^NAME= | awk -F "=" '{print $2}') # OS 이름 저장 변수
    OS_VER=$(cat /etc/os-release | grep VERSION_ID= | awk -F "=" '{print $2}') # OS 버전 저장 변수

    if [ "$OS_NAME" == "\"Ubuntu\"" ] && [ "$OS_VER" == "22.04" ] # Ubuntu 22.04 이면 ubuntu 스크립트 import
    then 
        source ubuntu.sh
        #echo "UBUNTU"
    elif [ "$OS_NAME" == "\"Rocky Linux\"" ] && [[ "$OS_VER" == \"8.* ]] # rocky 8.x 면 rocky 스크립트 import
    then
        source rocky.sh
        #echo "Rocky"
    else
        echo "ERROR"
    fi
}




###############################################################################################################

# 전역 변수

###############################################################################################################

TITLE="Security Setting [WINS Cloud MSP]" # 다이얼로그 타이틀 표시
HERE=$(dirname $(realpath $0)) # 스크립트 위치 표시
#LOGFILE=$HERE/LOG/security/$logfilename.log # 로그 파일 경로 저장 변수


###############################################################################################################

# 공통 함수
## 함수 목록
###  1. GetDate()			# 날짜 받아오는 함수, 날짜 받아와서 로그파일 이름에 날짜 넣어줌
###  2. HDDCheck()			# HDD 정보 받아오는 함수
###  3. CompareValue()		# 취약점 점검 시 취약한지 안전한지 값 비교
###  4. filebackup() 		# 취약점 조치 시, 변경되는 파일 백업 수행
###  5. MainPrint() 		# 출력되는 화면 
###  6. ServerInfo() 		# 서버 정보 출력
###  7. CheckSecurity() 	# 취약점 점검 수행
###  8. SettingSecurity() 	# 취약점 조치 수행
###  9. Initialize() 		# 작업 원복 수행
### 10. menu() 				# 스크립트 메뉴 실행
### 11. function logTail()	# 로그 마지막 부분 출력
### 12. main() 				# 실제 동작 함수

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
	if [ -e $(pwd)/BACKUP/$1 ]
	then
		echo "$3 Backup Exists    : $2 -> ./BACKUP/$1" >> $LOGFILE
    then
        echo "$3 Backup Exists    : $2 -> ./BACKUP/$1" >> $LOGFILE
	else
		\cp -r $2 $(pwd)/BACKUP/$1
		if [ -e $(pwd)/BACKUP/$1 ]
		then
			echo "$3 Backup Completed : $2 -> ./BACKUP/$1" >> $LOGFILE
		else
			echo "$3 Backup Fail" >> $LOGFILE
		fi
	fi
}

function MainPrint() # 출력되는 화면 
{
	echo "******************************************************************************" >> .ServerInfo
	echo "                       [ WINS Cloud Security Setting ]                   " >> .ServerInfo
    	echo " #) DATE     : $(date) " >> .ServerInfo
    	echo " #) USER     : $(who am i | awk -F " " '{print $1$5,$3,$4}') " >> .ServerInfo
	echo " #) UPTIME   :$(uptime | awk -F "up" '{print $2}' | awk -F ", " '{print $1" "$2}')"   >> .ServerInfo
	echo " #) LOG File : $logfilename.log " >> .ServerInfo
	echo "******************************************************************************" >> .ServerInfo
}

function ServerInfo() # 서버 정보 출력
{
	echo "==============================================================================" >> .ServerInfo
    	echo "* [INFO] Server Information                                                  *" >> .ServerInfo
	echo "==============================================================================" >> .ServerInfo
	echo "1. HW" >> .ServerInfo
	echo "	1.1  Model          |    $(dmidecode -s system-product-name | grep -v '#')" >> .ServerInfo
  	echo "	1.2  Serial         |    $(dmidecode -s system-serial-number | grep -v '#')" >> .ServerInfo
    	echo "	1.3  CPU            |    $(cat /proc/cpuinfo |grep model |grep name |uniq |awk '{printf $4$5" "$6" "$7$8" "$9$10"\n"}') $(grep 'cpu cores' /proc/cpuinfo | tail -1 | awk -F ": " '{print$2}')Core *$(dmidecode -t processor | grep 'Socket Designation' | wc -l)"                     	 >> .ServerInfo
	# 총 메모리만 출력 되도록 수정
	echo "	1.4  MEM            |    $(cat /proc/meminfo | grep MemTotal | awk -F ":       " '{print $2/1024/1024"GB"}')" >> .ServerInfo


	echo "2. OS" >> .ServerInfo
	echo "	2.1  Name           |   $(uname -n)" >> .ServerInfo
	echo "	2.2  Release        |   $(cat /etc/*-release | uniq | sed -n 1p)" >> .ServerInfo
	echo "	2.3  Kernel         |   $(uname -r)" >> .ServerInfo
	echo "	2.4  SELINUX        |   $(cat /etc/sysconfig/selinux | grep "^SELINUX=" | awk -F "=" '{print $2}')" >> .ServerInfo

	echo "==============================================================================" >> .ServerInfo
	echo "" >> .ServerInfo
}

function CheckSecurity() # 취약점 점검 수행
{
    echo "# 1. 계정 관리" >> $LOGFILE ## 로깅
	# U-02
    PwdComplexity
    # U-03
    AccountLockCritical
    # U-04
    U-04
    # U-46
    PwdMinLength
    echo "U-15 끝" >> $LOGFILE ## 로깅
	echo "[Check Result]" >> $LOGFILE
	echo "$(cat ./.SecurityInfo)" >> $LOGFILE
	sed -i 's/\\n//g' $LOGFILE
	echo "" >> $LOGFILE

	##dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "[Check Result]\n$(cat ./.SecurityInfo)  # Do you want to set security?" 25 70
	dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "[Check Result]\n$(cat ./.SecurityInfo)  # Do you want to set security?" 45 100
    	answer=$?
    	case $answer in
        	0)
            	SettingSecurity
                echo "조치 끝" >> $LOGFILE ## 로깅
            ;;
        	1)
                dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n  # User select 'NO'.\n  # Exit the Cloud Security Setting." 25 70
                echo "[Setting Result]" >> $LOGFILE
                echo "User select 'NO'" >> $LOGFILE
                rm -rf ./.SecurityInfo
                echo "SecurityInfo 삭제" >> $LOGFILE ## 로깅
                echo "메뉴 진입" >> $LOGFILE ## 로깅
                menu
            ;;
        	255)
                dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n  # User select 'NO'.\n  # Exit the Cloud Security Setting." 25 70
                echo "[Setting Result]" >> $LOGFILE
                echo "User select 'NO'" >> $LOGFILE
                echo "SecurityInfo 삭제" >> $LOGFILE ## 로깅
                rm -rf ./.SecurityInfo
            exit
            ;;
    	esac
    echo "SecurityInfo 삭제" >> $LOGFILE ## 로깅
    rm -rf ./.SecurityInfo
    echo "메뉴 진입" >> $LOGFILE ## 로깅
	menu
}

function SettingSecurity() # 취약점 조치 수행
{
	echo "[Backup Result] : $(pwd)/BACKUP/" >> $LOGFILE
	
	#echo  4 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-00|사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정] Setting... " 10 55 0
	#U-15_execute >> ./.SecuritySet

    # U-02
    echo  4 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-00|패스워드 복잡도] Setting... " 10 55 0
    PwdComplexityExcute >> ./.SecuritySet
    # U-03
    echo  8 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-03|Account Lock-1    ] Setting... " 10 55 0
	echo 11 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-03|Account Lock-2    ] Setting... " 10 55 0
    AccountLockCriticalExcute >> ./.SecuritySet
    # U-04
    echo 11 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-03|Account Lock-2    ] Setting... " 10 55 0
    U-04_execute >> ./.SecuritySet
    # U-46
    echo 11 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-46|PwdMinLength    ] Setting... " 10 55 0
    PwdMinLengthExcute >> ./.SecuritySet
    # U-47 패스워드 만료기간 확인 함수
    PwdMaxDaysExcute
    


	sleep 1
	dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "[Setting Result]\n$(cat ./.SecuritySet | grep -v "Before" | grep -v "After" | grep -v "#" | grep -v "ASSURING" | grep -v "Unauthrozied" | grep -v ^$ |grep "[|]")  # Cloud Security Setting is Completed!" 25 70

	echo "" >> $LOGFILE
	echo "[Setting Result]" >> $LOGFILE
	echo "$(cat ./.SecuritySet)" >> $LOGFILE
	sed -i 's/\\n//g' $LOGFILE
	echo "" >> $LOGFILE
    rm -rf ./.SecuritySet
}

function Initialize() # 작업 원복 수행
{
	##OPTION=$(dialog --title "$TITLE" --menu "Choose your option - (!)Initialization " 15 55 5 \
	OPTION=$(dialog --title "$TITLE" --menu "Choose your option - (!)Initialization " 35 85 5 \
	"1" "Init Primary" \
	"2" "Init root Limit (su)" \
	"3" "Init root Limit (ssh)" 3>&1 1>&2 2>&3)
	case $? in
        0)
            case $OPTION in
                1)
                    dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Initialize All Setting]\n\n  # Do you want to initialize 'Primary' setting?" 15 55
                    #dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Initialize All Setting]\n\n  # Do you want to initialize 'Primary' setting?" 35 85
                    answer=$?
                    case $answer in
                        0)
                            #U-02 #U-03
                            \cp $(pwd)/BACKUP/system-auth /etc/pam.d/system-auth
                            #U-10 
                            \cp $(pwd)/BACKUP/passwd /etc/passwd
                            #U-12 
                            \cp $(pwd)/BACKUP/group /etc/group
                            #U-15
                            \cp $(pwd)/BACKUP/profile /etc/profile
                            #U-39
                            chmod 644 /etc/cron.deny
                            #U-67
                            \cp $(pwd)/BACKUP/issue /etc/issue
                            \cp $(pwd)/BACKUP/motd /etc/motd
                            #U-22
                            #U-24
                            \cp $(pwd)/BACKUP/sysctl.conf /etc/sysctl.conf
                            chmod 644 /etc/hosts
                            #U-21
                            chmod 755 -R /etc/xinetd.d/
                            #U-68
                            \cp $(pwd)/BACKUP/exports /etc/exports
                            #U-07 #U-08 #U-09 #U-74
                            \cp $(pwd)/BACKUP/login.defs /etc/login.defs
                            #U-73
                            \cp $(pwd)/BACKUP/rsyslog.conf /etc/rsyslog.conf
                            systemctl restart rsyslog.service
                            #U-64
                            \cp $(pwd)/BACKUP/at.* /etc/
                            chmod 644 at.*

                            dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'Primary' setting initialization succeeded.\n " 15 55
                            #dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'Primary' setting initialization succeeded.\n " 35 85
                            echo "[Initialize Result] - 'Primary' setting initialization succeeded."  >> $LOGFILE
                            Initialize
                        ;;
                        1)
                            Initialize
                        ;;
                        255)
                            return 255
                        ;;
                    esac
                ;;
                2)
                    #dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Initialize All Setting]\n\n  # Do you want to\n    initialize 'root Limit (su)' setting?" 15 55
                    dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Initialize All Setting]\n\n  # Do you want to\n    initialize 'root Limit (su)' setting?" 35 85
                    answer=$?
                    case $answer in
                        0)
                            #U-06
                            chmod 4755 /bin/su
                            chgrp root /bin/su
                            if [ "$(ls -l /bin/su | awk -F " " '{print $1}')" = "-rwxr-xr-x." ]
                            then 
                            dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'root Limit (su)' setting\n  initialization succeeded.\n " 15 55
                            echo "[Initialize Result] - 'root Limit (su)' setting initialization is complete."  >> $LOGFILE
                            else
                            dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'root Limit (su)' setting\n  initialization failed.\n " 15 55
                            echo "[Initialize Result] - 'root Limit (su)' setting initialization failed."  >> $LOGFILE
                            fi
                            Initialize
                        ;;
                        1)
                            Initialize
                        ;;
                        255)
                            return 255
                        ;;
                    esac
				;;
            	3)
                    dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Initialize All Setting]\n\n  # Do you want to\n    initialize 'root Limit (ssh)' setting?" 15 55
                    answer=$?
                    case $answer in
                        0)
                            #U-01
                            line=$(egrep -n "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no" /etc/ssh/sshd_config | awk -F ":" '{print$1}')"s"
                            sed -i "$line/.*/#PermitRootLogin yes/g" /etc/ssh/sshd_config
                            SshRestart >& /dev/null
                            if [ "$(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" = "PermitRootLogin yes" -o "$(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" = "#PermitRootLogin yes" ]
                            then
                            dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'root Limit (ssh)' setting\n  initialization succeeded.\n " 15 55
                            echo "[Initialize Result] - 'root Limit (ssh)' setting initialization succeeded."  >> $LOGFILE
                            else
                            dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'root Limit (ssh)' setting\n  initialization failed.\n " 15 55
                            echo "[Initialize Result] - 'root Limit (ssh)' setting initialization failed."  >> $LOGFILE
                            fi
                            Initialize
                        ;;
                        1)
                            
                        ;;
                        255)
                            
                        ;;
                    esac
                ;;
            esac
        ;;
        1)
            menu
        ;;
        255)
            exit
        ;;
    esac
}

function menu() # 스크립트 메뉴 실행
{
	OPTION=$(dialog --title "$TITLE" --menu "Choose your option" 15 55 5 \
	"1" "Primary Setting" \
	"2" "root Limit (su)" \
	"3" "root Limit (ssh)" \
	"4" "Initialize All Setting" 3>&1 1>&2 2>&3)
	case $? in
        0)
            case $OPTION in
                1)
                    echo "점검 함수 진입" >> $LOGFILE ## 로깅
                    CheckSecurity
                    echo "점검 끝" >> $LOGFILE ## 로깅
                ;;
                2)
                    echo "Wheel 그룹 진입" >> $LOGFILE ## 로깅
                    SuRootLimit
                    echo "Wheel 그룹 끝" >> $LOGFILE ## 로깅
				;;
                3)
                    SshRootLimit
				;;
                4)
                    Initialize
				;;
            esac
		;;
        1)
            echo "******************************************************************************" >> $LOGFILE
            echo "  # Exit the Cloud Security Setting                                        " >> $LOGFILE
            echo "******************************************************************************" >> $LOGFILE
            echo ""
			clear
            exit
        ;;
        255)
            exit
        ;;
    esac
}

function logTail() # 로그 마지막 부분 출력
{
	echo "******************************************************************************" >> $LOGFILE
	echo "  # Exit the Cloud Security Setting                                        " >> $LOGFILE
	echo "******************************************************************************" >> $LOGFILE

	sed -i 's/\\n//g' $LOGFILE
	echo ""
}

function main() # 실제 동작 함수
{
    GetDate
    checkOS
	DialogSetup
	mkdir -p $HERE/LOG/security/
	mkdir -p $HERE/BACKUP/
	MainPrint
	ServerInfo
	echo "$(cat ./.ServerInfo)" 2>&1 >> $LOGFILE
	dialog --title "$TITLE" --textbox "./.ServerInfo" 50 85
	rm -rf ./.ServerInfo
	rm -rf ./.SecurityInfo
	rm -rf ./.SecuritySet
	sleep 1
	menu
	logTail
}


clear

main
