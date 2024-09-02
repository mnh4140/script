#!/bin/bash

#Update : 20220922
#JEON MYEONG GEUN
#Cloud Security Setting Scripts(CentOS Linux release 7.6.1810 (Core))
#----------------------------------------------------------------------
#Update : 20230922
#NO-HUN
#Cloud Security Setting Scripts(CentOS release 6.6 (Final))
#Start of Shell Scripts



TITLE="Security Setting [WINS Cloud MSP]"
function DialogSetup()
{
	dialogRPM=$(rpm -qa |grep dialog)

	if [ -z "$dialogRPM" ]
		then
		#yes |unzip /root/WinsCloud_Tool/2.RPM/4.dialog/8-07-14_MegaCLI.zip -d /root/WinsCloud_Tool/2.RPM/4.dialog/ &> /dev/null
                # dialog 버전 변경
		#rpm -ivh /root/WinsCloud_Tool/2.RPM/4.dialog/dialog-1.2-4.20130523.el7.x86_64.rpm &> /dev/null
		rpm -ivh /root/WinsCloud_Tool/2.RPM/4.dialog/dialog-1.1-10.20080819.el6.x86_64.rpm &> /dev/null
		dialogRPM=$(rpm -qa |grep dialog)
		if [ -n "$dialogRPM" ]
			then
			echo -e "  [INFO] [\033[0;32m Success \033[0m] Dialog Setup complete."
		else
        	echo -e "  [ERROR][\033[0;31m  Fail   \033[0m] Dialog Setup Fail."
		fi
	elif [ -n "$dialogRPM" ];
		then
		echo -e "  [INFO] [\033[0;32m   OK    \033[0m] Dialog Already Setup."
	fi
}

function GetDate()
{
	#uptime=`uptime`
	date=$(date '+%Y%m%d_%H%M')
	logfilename="security_$date"
	BACKTITLE="$(pwd)/LOG/security/$logfilename.log"
}

function HDDCheck()
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

function CompareValue()
{
	if [ "$2" = "$3" ]
        then
                echo -n "$1"
                echo " Setting Sucess\n"
        else
                echo -n "$1"
                echo " Setting Fail\n"
        fi	
	sed -i -e 's/\\n$//' $(pwd)/LOG/security/$logfilename.log
}

function SshRestart()
{
    dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Setting Result]\n\n #[OK]\n  $setResult $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")\n\n # Do you want to restart SSHD Service?" 15 55		
    answer=$?
    case $answer in
        0)
			systemctl restart sshd.service
			echo "# SSHD Service restart completed." >> $(pwd)/LOG/security/$logfilename.log
			echo "" >> $(pwd)/LOG/security/$logfilename.log
            ;;
        1)
			echo "# Didn't restart the SSHD Service." >> $(pwd)/LOG/security/$logfilename.log
			echo "" >> $(pwd)/LOG/security/$logfilename.log
            ;;
        255)
			echo "# Didn't restart the SSHD Service." >> $(pwd)/LOG/security/$logfilename.log
			echo "" >> $(pwd)/LOG/security/$logfilename.log
            ;;
    esac
}

#U-02
function PwdComplexity()
{
	setminlen="minlen=9"
	setdcredit="dcredit=-1"
	setucredit="ucredit=-1"
	setlcredit="lcredit=-1"
	setocredit="ocredit=-1"

	minlen=$(cat /etc/pam.d/system-auth | grep minlen | awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')
	dcredit=$(cat /etc/pam.d/system-auth | grep dcredit | awk -F "dcredit=" '{print $2}'| awk -F " " '{print $1}')
	ucredit=$(cat /etc/pam.d/system-auth | grep ucredit | awk -F "ucredit=" '{print $2}'| awk -F " " '{print $1}')
	lcredit=$(cat /etc/pam.d/system-auth | grep lcredit | awk -F "lcredit=" '{print $2}'| awk -F " " '{print $1}')
	ocredit=$(cat /etc/pam.d/system-auth | grep ocredit | awk -F "ocredit=" '{print $2}'| awk -F " " '{print $1}')
	cmp1="$minlen$dcredit$ucredit$lcredit$ocredit"
	cmp2="9-1-1-1-1"
	if [ -z "$cmp1" ]
	then
		#위험
        echo "01.[U-02|Passwd Complexity ] : WARN\n" >> ./.SecurityInfo
	elif [ "$cmp1" != "$cmp2" ]
	then
		#위험
        echo "01.[U-02|Passwd Complexity ] : WARN\n" >> ./.SecurityInfo
	else
        #안전
        echo "01.[U-02|Passwd Complexity ] : SAFE\n" >> ./.SecurityInfo
	fi
	echo " *current: ${cmp1}\n" >> ./.SecurityInfo
	echo " *suggest: ${cmp2}\n\n" >> ./.SecurityInfo
	Progress=5
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-02|Passwd Complexity ] Check... " 10 55 0
}

function PwdComplexity_check()
{
	setminlen="minlen=9"
	setdcredit="dcredit=-1"
	setucredit="ucredit=-1"
	setlcredit="lcredit=-1"
	setocredit="ocredit=-1"

	checkvalue=$(cat /etc/pam.d/system-auth | grep password | grep requisite | grep -E "pam_cracklib.so" |grep $1)
	if [ -n $1 ]
	then
		retval="true"
	else
		retval="false"
	fi
}

function PwdComplexityExcute_check()
{	
	preValue=$(cat /etc/pam.d/system-auth | grep password | grep requisite | grep -E "pam_cracklib.so")
	PwdComplexity_check minlen
	PwdComplexity_check dcredit
	PwdComplexity_check ucredit
	PwdComplexity_check lcredit
	PwdComplexity_check ocredit
}

function PwdComplexityExcute()
{
	
	minlen=$(cat /etc/pam.d/system-auth | grep minlen | awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')
	dcredit=$(cat /etc/pam.d/system-auth | grep dcredit | awk -F "dcredit=" '{print $2}'| awk -F " " '{print $1}')
	ucredit=$(cat /etc/pam.d/system-auth | grep ucredit | awk -F "ucredit=" '{print $2}'| awk -F " " '{print $1}')
	lcredit=$(cat /etc/pam.d/system-auth | grep lcredit | awk -F "lcredit=" '{print $2}'| awk -F " " '{print $1}')
	ocredit=$(cat /etc/pam.d/system-auth | grep ocredit | awk -F "ocredit=" '{print $2}'| awk -F " " '{print $1}')

	preValue=$(cat /etc/pam.d/system-auth | grep password | grep requisite | grep -E "pam_cracklib.so")
	setValue="password    requisite     pam_cracklib.so try_first_pass retry=3 minlen=9 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 type="


	if [ $(cat ./.SecurityInfo | grep "U-02" | awk -F ": " '{print $2}') == "SAFE\n" ]
		then
		echo "01.[U-02|Passwd Complexity ] : Already applied\n"
    elif [ $(cat ./.SecurityInfo | grep "U-02" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup system-auth /etc/pam.d/system-auth "01.[U-02|Passwd Complexity ] :"
		#sed -i'' -r -e "/password    requisite     pam_pwquality.so/a\password    required      pam_cracklib.so retry=3 minlen=9 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1" /etc/pam.d/system-auth
		# 원복 설정 백업
		sed -i '/password    requisite     pam_cracklib.so try_first_pass retry=3 type=/ s/^/#/' /etc/pam.d/system-auth
		# 패스워드 복잡도 수행
		sed -i'' -r -e "/password    requisite     pam_cracklib.so try_first_pass retry=3 type=/a\password    requisite     pam_cracklib.so try_first_pass retry=3 type=minlen=9 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1" /etc/pam.d/system-auth
		
			minlen=$(cat /etc/pam.d/system-auth | grep minlen | awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')
			dcredit=$(cat /etc/pam.d/system-auth | grep dcredit | awk -F "dcredit=" '{print $2}'| awk -F " " '{print $1}')
			ucredit=$(cat /etc/pam.d/system-auth | grep ucredit | awk -F "ucredit=" '{print $2}'| awk -F " " '{print $1}')
			lcredit=$(cat /etc/pam.d/system-auth | grep lcredit | awk -F "lcredit=" '{print $2}'| awk -F " " '{print $1}')
			ocredit=$(cat /etc/pam.d/system-auth | grep ocredit | awk -F "ocredit=" '{print $2}'| awk -F " " '{print $1}')
			CompareValue "01.[U-02|Passwd Complexity ] :" "9-1-1-1-1" "$minlen$dcredit$ucredit$lcredit$ocredit"
			echo "  - Before Value : $preValue"
			echo "  - After  Value : $(cat /etc/pam.d/system-auth | grep password | grep requisite | grep -E "pam_cracklib.so")"	
    else
		echo "01.[U-02|Passwd Complexity ] : Error\n"
    fi
}

#U-03
function AccountLockCritical()
{
	#set1=$(egrep -n "auth        required      /lib64/security/pam_tally2.so deny=5 unlock_time=120 no_magic_root" /etc/pam.d/system-auth | grep -v '#' | awk -F ":" '{print$1}')
	#set2=$(egrep -n "account     required      /lib64/security/pam_tally2.so no_magic_root reset" /etc/pam.d/system-auth | grep -v '#' | awk -F ":" '{print$1}')
	#cmp1=$(egrep -n "auth" /etc/pam.d/system-auth | egrep "required" | egrep "/lib64/security/pam_tally2.so deny=5 unlock_time=120 no_magic_root" | grep -v '#' | awk -F ":" '{print$1}')
	#cmp2=$(egrep -n "account" /etc/pam.d/system-auth | egrep "required" | egrep "/lib64/security/pam_tally2.so no_magic_root reset" | grep -v '#' | awk -F ":" '{print$1}')
	cmp1=$(egrep -n "auth" /etc/pam.d/system-auth | egrep "required" | egrep "pam_tally2.so|deny=5|unlock_time=120|no_magic_root")
	cmp2=$(egrep -n "account" /etc/pam.d/system-auth | egrep "required" | egrep "/lib64/security/pam_tally2.so no_magic_root reset")
	
	if [ -z "$cmp1" ]
	then
		#위험
        echo "02.[U-03|Account Lock-1    ] : WARN\n" >> ./.SecurityInfo
	else
        #안전
        echo "02.[U-03|Account Lock-1    ] : SAFE\n" >> ./.SecurityInfo
    fi
	echo " *suggest: auth        required      /lib64/security/pam_tally2.so deny=5 unlock_time=120 no_magic_root\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n" >> ./.SecurityInfo
    Progress=16
	#echo "------------------------------------------------------------------------------"
	if [ -z "$cmp2" ]
	then
		#위험
        echo "   [U-03|Account Lock-2    ] : WARN\n" >> ./.SecurityInfo
	else
        #안전
        echo "   [U-03|Account Lock-2    ] : SAFE\n" >> ./.SecurityInfo
    fi
	echo " *suggest: account     required      /lib64/security/pam_tally2.so no_magic_root reset\n" >> ./.SecurityInfo
	echo " *current: ${cmp2}\n\n" >> ./.SecurityInfo
    Progress=11
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-03|Account Lock-2    ] Check... " 10 55 0
}

#U-03
function AccountLockCriticalExcute()
{
	preValue=$(cat /etc/pam.d/system-auth | grep auth | grep required | grep pam_deny.so)
	if [ $(cat ./.SecurityInfo | grep -E "02.\[U-03" | awk -F ": " '{print $2}') == "WARN\n" ]
		then
		filebackup system-auth /etc/pam.d/system-auth "02.[U-03|Account Lock-1    ] :"
		#line=$(egrep -n "auth        required      pam_deny.so" /etc/pam.d/system-auth | grep -v '#' | awk -F ":" '{print$1}')"s"
		line=$(egrep -n "auth" /etc/pam.d/system-auth | egrep required | egrep pam_deny.so | grep -v '#' | awk -F ":" '{print$1}')"s"
		if [ "$line" = "s" ]
			then
			echo "02.[U-03|Account Lock-1    ] : Error\n"
		else
			sed -i "$line/.*/auth        required      \/lib64\/security\/pam_tally2.so deny=5 unlock_time=120 no_magic_root/g" /etc/pam.d/system-auth
			#CompareValue "02.[U-03|Account Lock-1    ] :" "$(cat /etc/pam.d/system-auth | grep "pam_tally2.so deny=5 unlock_time=120 no_magic_root")" "auth        required      \/lib64\/security\/pam_tally2.so deny=5 unlock_time=120 no_magic_root"
			if [ -n "$(cat /etc/pam.d/system-auth | grep auth | grep required | grep deny=5 | grep unlock_time=120 | grep no_magic_root)" ]
		        then
	                echo "02.[U-03|Account Lock-1    ] : Setting Sucess\n "
	        else
	                echo "02.[U-03|Account Lock-1    ] : Setting Fail\n   "
	        fi	
			echo "  - Before Value : $preValue"
			echo "  - After  Value : $(cat /etc/pam.d/system-auth | grep auth | grep required | grep deny | grep "unlock_time")"
			#echo " * File  : /etc/pam.d/system-auth"
			#echo " * Value : $(egrep -n "auth        required      /lib64/security/pam_tally2.so deny=5 unlock_time=120 no_magic_root" /etc/pam.d/system-auth | grep -v '#'| awk -F ":" '{print $2}')"
		fi
	elif [ $(cat ./.SecurityInfo | grep -E "02.\[U-03" | awk -F ": " '{print $2}') == "SAFE\n" ]
		then
		echo "02.[U-03|Account Lock-1    ] : Already applied\n"
		#echo " * File  : /etc/pam.d/system-auth"
		#echo " * Value : $(egrep -n "auth        required      /lib64/security/pam_tally2.so deny=5 unlock_time=120 no_magic_root" /etc/pam.d/system-auth | grep -v '#'| awk -F ":" '{print $2}')"
	else
		echo "02.[U-03|Account Lock-1    ] : Error\n"
	fi
	#echo "------------------------------------------------------------------------------"
	#echo ""
	preValue=$(cat /etc/pam.d/system-auth | grep account | grep required | grep pam_permit.so)
	if [ $(cat ./.SecurityInfo | grep -E "\ \ \ \[U-03" | awk -F ": " '{print $2}') == "WARN\n" ]
		then
		filebackup system-auth /etc/pam.d/system-auth "   [U-03|Account Lock-2    ] :"
		#line=$(egrep -n "account     required      pam_permit.so" /etc/pam.d/system-auth | grep -v '#' | awk -F ":" '{print$1}')"s"
		line=$(egrep -n "account" /etc/pam.d/system-auth | egrep "required" | egrep "pam_permit.so" | grep -v '#' | awk -F ":" '{print$1}')"s"
		if [ "$line" = "s" ]
			then
			echo "   [U-03|Account Lock-2    ] : Error\n"
		else
			sed -i "$line/.*/account     required      \/lib64\/security\/pam_tally2.so no_magic_root reset/g" /etc/pam.d/system-auth
			#CompareValue "   [U-03|Account Lock-2    ] :" "$(cat /etc/pam.d/system-auth | grep "pam_tally2.so no_magic_root reset")" "account     required      \/lib64\/security\/pam_tally2.so no_magic_root reset"
			if [ -n "$(cat /etc/pam.d/system-auth | grep account | grep required | grep no_magic_root | grep reset)" ]
		        then
	                echo "   [U-03|Account Lock-2    ] : Setting Sucess\n "
	        else
	                echo "   [U-03|Account Lock-2    ] : Setting Fail\n   "
	        fi
			echo "  - Before Value : $preValue"
			echo "  - After  Value : $(cat /etc/pam.d/system-auth | grep account | grep required | grep no_magic_root | grep reset)"
			#echo " * File  : /etc/pam.d/system-auth"
			#echo " * Value : $(egrep -n "account     required      /lib64/security/pam_tally2.so no_magic_root reset" /etc/pam.d/system-auth | grep -v '#' | awk -F ":" '{print $2}')"
		fi
	elif [ $(cat ./.SecurityInfo | grep -E "\ \ \ \[U-03" | awk -F ": " '{print $2}') == "SAFE\n" ]
		then
		echo "   [U-03|Account Lock-2    ] : Already applied\n"
		#echo " * File  : /etc/pam.d/system-auth"
		#echo " * Value : $(egrep -n "account     required      /lib64/security/pam_tally2.so no_magic_root reset" /etc/pam.d/system-auth | grep -v '#' | awk -F ":" '{print $2}')"
	else
		echo "   [U-03|Account Lock-2    ] : Error\n"
	fi
}

#U-07
function PwdMinLength()
{
	cmp1=$(cat /etc/login.defs | grep PASS_MIN_LEN | grep -v '#' | awk -F " " '{print $2}')
	if [ $cmp1 -ge 8 ]
	then
        #안전
        echo "03.[U-07|Passwd Min Len    ] : SAFE\n" >> ./.SecurityInfo
	else
        #안전
        echo "03.[U-07|Passwd Min Len    ] : WARN\n" >> ./.SecurityInfo
	fi
	echo " *suggest: 9\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=14
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-07|Passwd Min Len    ] Check... " 10 55 0
}

function PwdMinLengthExcute()
{
	preValue=$(cat /etc/login.defs | grep PASS_MIN_LEN | grep -v '#')
	if [ $(cat ./.SecurityInfo | grep "U-07" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "03.[U-07|Passwd Min Len    ] : Already applied\n"
    elif [ $(cat ./.SecurityInfo | grep "U-07" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
		filebackup login.defs /etc/login.defs "03.[U-07|Passwd Min Len    ] :"
		line=$(grep -n PASS_MIN_LEN /etc/login.defs | grep -v '#' | awk -F ":" '{print$1}')"s"
		sed -i "$line/.*/PASS_MIN_LEN    9/g" /etc/login.defs
		CompareValue "03.[U-07|Passwd Min Len    ] :" "$(cat /etc/login.defs | grep PASS_MIN_LEN | grep -v '#' | awk -F " " '{print $2}')" "9"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/login.defs | grep PASS_MIN_LEN | grep -v '#')"
		#echo " => /etc/login.defs"
		#echo "    $(cat /etc/login.defs | grep PASS_MIN_LEN | grep -v '#')"
	else
		echo "03.[U-07|Passwd Min Len    ] : Error\n"
	fi
}

#U-08
function PwdMaxDays()
{
	cmp1=$(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#' | awk -F " " '{print $2}')
	if [ $cmp1 -le 90 ]
	then
        #안전
        echo "04.[U-08|Passwd Max Days   ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        echo "04.[U-08|Passwd Max Days   ] : WARN\n" >> ./.SecurityInfo
	fi
	echo " *suggest: 90\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=18
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-08|Passwd MaxDays    ] Check... " 10 55 0
	#sleep 1
}

function PwdMaxDaysExcute()
{
	preValue=$(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#')
	if [ $(cat ./.SecurityInfo | grep "U-08" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "04.[U-08|Passwd Max Days   ] : Already applied\n"
    elif [ $(cat ./.SecurityInfo | grep "U-08" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
		filebackup login.defs /etc/login.defs "04.[U-08|Passwd Max Days   ] :"
		line=$(grep -n PASS_MAX_DAYS /etc/login.defs | grep -v '#' | awk -F ":" '{print$1}')"s"
		sed -i "$line/.*/PASS_MAX_DAYS   90/g" /etc/login.defs 
		CompareValue "04.[U-08|Passwd Max Days   ] :" "$(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#' | awk -F " " '{print $2}')" "90"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#')"
		#echo " => /etc/login.defs"
		#echo "    $(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#')"
	else
		echo "04.[U-08|Passwd Max Days   ] : Error\n"
	fi
	sleep 1
}

#U-09
function PwdMinDays()
{
	cmp1=$(cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v '#' | awk -F " " '{print $2}')
	if [ $cmp1 -ne 0 ]
	then
        #안전
        echo "05.[U-09|Passwd Min Days   ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        echo "05.[U-09|Passwd Min Days   ] : WARN\n" >> ./.SecurityInfo
	fi
	echo " *suggest: 0\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=23
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-09|Passwd Min Days   ] Check... " 10 55 0
	sleep 1
}

function PwdMinDaysExcute()
{
	preValue=$(cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v '#')
	if [ $(cat ./.SecurityInfo | grep "U-09" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
        echo "05.[U-09|Passwd Min Days   ] : Already applied\n"

    elif [ $(cat ./.SecurityInfo | grep "U-09" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup login.defs /etc/login.defs "05.[U-09|Passwd Min Days   ] :"
		line=$(grep -n PASS_MIN_DAYS /etc/login.defs | grep -v '#' | awk -F ":" '{print$1}')"s"
		sed -i "$line/.*/PASS_MIN_DAYS   1/g" /etc/login.defs
		CompareValue "05.[U-09|Passwd Min Days   ] :" "$(cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v '#' | awk -F " " '{print $2}')" "1"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v '#')"
		#echo " => /etc/login.defs"
		#echo "    $(cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v '#')"
	else
		echo "05.[U-09|Passwd Min Days   ] : Error\n"		
	fi
	sleep 1
}

#U-10 
function UserDel()
{
	cmp1=$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|sync|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid")
	if [ -z "$cmp1" ]
	then
        #안전
        echo "06.[U-10|User Delete       ] : SAFE\n" >> ./.SecurityInfo
    else
		#위험
        echo "06.[U-10|User Delete       ] : WARN\n" >> ./.SecurityInfo
    fi	
	echo " *suggest: -\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
    Progress=28
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-10|User Delete       ] Check... " 10 55 0
	#sleep 1
}

function UserDelExecute()
{
	preValue=$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|sync|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid")
	if [ $(cat ./.SecurityInfo | grep "U-10" | awk -F ": " '{print $2}') == "SAFE\n" ]
		then
        echo "06.[U-10|User Delete       ] : Already applied\n"
    elif [ $(cat ./.SecurityInfo | grep "U-10" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
		#echo "[NOT SAFE]"
		#echo " * File  : /etc/passwd"
		#echo " * Value : $cmp1"
		#echo -n " => Do you want to set security now? [Y/N] : "
		#read tmp
		filebackup passwd /etc/passwd "06.[U-10|User Delete       ] :"
		userdel adm >& /dev/null
		userdel lp >& /dev/null
		userdel sync >& /dev/null
		userdel shutdown >& /dev/null
		userdel halt >& /dev/null
		userdel news >& /dev/null
		userdel uucp >& /dev/null
		userdel operator >& /dev/null
		userdel games >& /dev/null
		userdel gopher >& /dev/null
		userdel nfsnobody >& /dev/null
		userdel squid >& /dev/null
		CompareValue "06.[U-10|User Delete       ] :" "$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|sync|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid")" ""
		echo "  - Before Value : $preValue"
		setValue=$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|sync|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid")
		if [ -z $(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|sync|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid") ]
			then
			setValue="-"
		fi
		echo "  - After  Value : $setValue"
		#echo "$cmp1"
	else
		echo "7 .[U-10|User Delete       ] : Error\n"
    fi	
	sleep 1
}

#U-12 
function GroupDel()
{
	cmp1=$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")
	if [ -z "$cmp1" ]
	then
        #안전
        echo "07.[U-12|Group Delete      ] : SAFE\n" >> ./.SecurityInfo
    else
		#위험
        echo "07.[U-12|Group Delete      ] : WARN\n" >> ./.SecurityInfo
    fi
	echo " *suggest: -\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
    Progress=32
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-12|Group Delete      ] Check... " 10 55 0
	sleep 1
}

function GroupDelExecute()
{
	preValue=$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")
	if [ $(cat ./.SecurityInfo | grep "U-12" | awk -F ": " '{print $2}') == "SAFE\n" ]
		then
        echo "07.[U-12|Group Delete      ] : Already applied\n"
		#cat /etc/passwd | egrep "lp|uucp"
    elif [ $(cat ./.SecurityInfo | grep "U-12" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
		filebackup group /etc/group "07.[U-12|Group Delete      ] :"
		groupdel lp >& /dev/null
		groupdel uucp >& /dev/null
		groupdel games >& /dev/null
		groupdel tape >& /dev/null
		groupdel video >& /dev/null
		groupdel audio >& /dev/null
		groupdel floppy >& /dev/null
		groupdel cdrom >& /dev/null
		groupdel man >& /dev/null
		groupdel slocate >& /dev/null
		groupdel stapusr >& /dev/null
		groupdel stapsys >& /dev/null
		groupdel stapdev >& /dev/nullss
		usermod postfix -G mail,postfix,postdrop
		#useradd tmsplus -s /sbin/nologin -G 3,5,6,8,9,18,54,22,35,999,998,190
		useradd tmsplus -s /sbin/nologin -G sys,tty,disk,mem,kmem,dialout,lock,utmp,utempter,ssh_keys,input,systemd-journal
		CompareValue "07.[U-12|Group Delete      ] :" "$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")" ""
		echo "  - Before Value : $preValue"
		setValue=$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")
		if [ -z $(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev") ]
			then
			setValue="-"
		fi
		echo "  - After  Value : $(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")"
	else
		echo "07.[U-12|Group Delete      ] : Error\n"
	fi
}

#U-15
function SessionTimeOut()
{
	cmp1=$(cat /etc/profile | grep TMOUT=)
	if [ -n "$cmp1" ]
        then
        cmp1=$(cat /etc/profile | grep TMOUT | awk -F "=" '{print $2}')
        if [ "$cmp1" -le 300 ]
        then
        	#안전
        	echo "08.[U-15|Session TimeOut   ] : SAFE\n" >> ./.SecurityInfo
        else
        	#위험
        	echo "08.[U-15|Session TimeOut   ] : WARN\n" >> ./.SecurityInfo
        fi
	else
		#위험
        echo "08.[U-15|Session TimeOut   ] : WARN\n" >> ./.SecurityInfo
        echo "Value not exist"
        echo ""
	fi
	echo " *suggest: TMOUT=300 Under value\n" >> ./.SecurityInfo
	echo " *current: $(cat /etc/profile | grep TMOUT=)\n\n" >> ./.SecurityInfo
	Progress=38
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-15|Session TimeOut   ] Check... " 10 55 0
	#sleep 1
}

function SessionTimeOutExcute()
{
	preValue=$(cat /etc/profile | grep TMOUT=)
	if [ $(cat ./.SecurityInfo | grep "U-15" | awk -F ": " '{print $2}') == "SAFE\n" ]
        then
		echo "08.[U-15|Session TimeOut   ] : Already applied\n"
    elif [ $(cat ./.SecurityInfo | grep "U-15" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup profile /etc/profile "08.[U-15|Session TimeOut   ] :"
    	#if [ -n $preValue ]
		#then
			#sed -i "s/$preValue/TMOUT=600/g" /etc/profile
		#else
		#	preValue="-"
		#	echo "bbbb"
			echo >> /etc/profile
			echo TMOUT=300 >> /etc/profile
			echo export TMOUT >> /etc/profile
		#fi
		CompareValue "08.[U-15|Session TimeOut   ] :" "$(cat /etc/profile | grep TMOUT | awk -F "=" '{print $1}' | sed -n 1p)" "TMOUT"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/profile | grep TMOUT=)"
	else
		echo "08.[U-15|Session TimeOut   ] : Error\n"
	fi
	sleep 1
}

#U-20
function HostsPermission()
{
	cmp1=$(ls -l /etc/hosts | awk -F " " '{print $1}' |awk -F "." '{print $1}')
	cmp2="-rw-------"
	
	if [ "$cmp1" = "$cmp2" ]
	then
        #안전
        echo "17.[U-20|hostsFile Permit  ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        echo "17.[U-20|hostsFile Permit  ] : WARN\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=95
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-20|hostsFile Permit  ] Check... " 10 55 0
	sleep 1
}

function HostsPermissionExcute()
{	
	preValue=$(ls -l /etc/hosts | awk -F " " '{print $1}' |awk -F "." '{print $1}')
	if [ $(cat ./.SecurityInfo | grep "U-20" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "17.[U-20|hostsFile Permit  ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-20" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup hosts /etc/hosts "17.[U-20|hostsFile Permit  ] :"
    	chmod 600 /etc/hosts
		CompareValue "17.[U-20|hostsFile Permit  ] :" "$(ls -l /etc/hosts | awk -F " " '{print $1}' | awk -F "." '{print $1}')" "-rw-------"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(ls -l /etc/hosts | awk -F " " '{print $1}' |awk -F "." '{print $1}')"
	else
		echo "17.[U-20|hostsFile Permit  ] : Error\n"
	fi	
}

#U-39
function CronPermission()
{
	cmp1=$(ls -l /etc/cron.deny | awk -F " " '{print $1}')
	cmp2="-rw-r-----."
	cmp3="-rw-------."
	
	if [ "$cmp1" = "$cmp2" -o "$cmp1" = "$cmp3" ]
	then
        #안전
        echo "09.[U-39|CronFile Permit   ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        echo "09.[U-39|CronFile Permit   ] : WARN\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: ${cmp2} or ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=44
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-39|CronFile Permit   ] Check... " 10 55 0
	sleep 1
}

function CronPermissionExcute()
{	
	preValue=$(ls -l /etc/cron.deny | awk -F " " '{print $1}')
	if [ $(cat ./.SecurityInfo | grep "U-39" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "09.[U-39|CronFile Permit   ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-39" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup cron.deny /etc/cron.deny "09.[U-39|CronFile Permit   ] :"
    	chmod 640 /etc/cron.deny
		CompareValue "09.[U-39|CronFile Permit   ] :" "$(ls -l /etc/cron.deny | awk -F " " '{print $1}')" "-rw-r-----."
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(ls -l /etc/cron.deny | awk -F " " '{print $1}')"
	else
		echo "09.[U-39|CronFile Permit   ] : Error\n"
	fi	
}

#U-25
function AnonymousFTP()
{
	cmp1=$(cat /etc/passwd | grep ftp)
	#cmp2=$(cat /etc/shadow | grep ftp)	
	if [[ -f /etc/vsftpd.conf ]] || [[ -f /etc/vsftpd/vsftpd.conf ]] || [[ -n $cmp1 ]] ;
	then
        #안전
        echo "19.[U-25|AnonymousFTP Limit] : WARN\n" >> ./.SecurityInfo
	else
		#위험
        echo "19.[U-25|AnonymousFTP Limit] : SAFE\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: Delete ftp User (/etc/passwd,/etc/shadow)\n" >> ./.SecurityInfo
	echo " *current: passwd) ${cmp1}\n" >> ./.SecurityInfo
	#echo "           shadow) ${cmp2}\n\n" >> ./.SecurityInfo
	Progress=97
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-25|AnonymousFTP Limit] Check... " 10 55 0
	sleep 1
}

function AnonymousFTPExcute()
{	
	preValue=$(cat /etc/passwd | grep ftp)
	#preValue2=$(cat /etc/shadow | grep ftp)
	if [ $(cat ./.SecurityInfo | grep "U-25" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "19.[U-25|AnonymousFTP Limit] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-25" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup passwd /etc/passwd "19.[U-25|AnonymousFTP Limit] :"
    	#filebackup shadow /etc/shadow "19.[U-25|AnonymousFTP Limit] :"
    	userdel ftp 
		#cmp1=$(cat /etc/passwd | grep ftp)
		#cmp2=$(cat /etc/shadow | grep ftp)
		CompareValue "19.[U-25|AnonymousFTP Limit] :" "$(cat /etc/passwd | grep ftp)" ""
		echo "  - Before Value : passwd) $preValue\n"
		#echo "                   shadow) $preValue2\n"
		echo "  - After  Value : passwd) $cmp1\n"
		#echo "                   shadow) $cmp2\n"
	else
		echo "19.[U-25|AnonymousFTP Limit] : Error\n"
	fi	
}

#U-67
function WarningMessage()
{
	cmp1=$(cat /etc/motd)
	cmp2=$(cat /etc/issue.net)
	cmp3=$(cat /etc/issue)
	cmp4="Administrator Access Only"
	cmp5=$'\S\nKernel \\r on an \m'

	if [ -z "$cmp1" -o "$cmp1" = "$cmp5" ]
		then
		#위험
        echo "10.[U-67|Warning Messages  ] : WARN\n" >> ./.SecurityInfo
    elif [ -z "$cmp2" -o "$cmp2" = "$cmp5" ]
    	then
		#위험
        echo "10.[U-67|Warning Messages  ] : WARN\n" >> ./.SecurityInfo
    elif [ -z "$cmp3" -o "$cmp3s" = "$cmp5" ]
    	then
		#위험
        echo "10.[U-67|Warning Messages  ] : WARN\n" >> ./.SecurityInfo
	#elif [ "$(cat /etc/motd | grep "Administrator Access Only" | awk -F " " '{print $1" "$2" "$3}')" = "$cmp4" ]	
	elif [ -n "$cmp1" ] && [ -n "$cmp2" ] && [ -n "$cmp3" ]
		then
        #안전
        echo "10.[U-67|Warning Messages  ] : SAFE\n" >> ./.SecurityInfo
	else
        #안전
        echo "10.[U-67|Warning Messages  ] : SAFE\n" >> ./.SecurityInfo
	fi
	echo " *suggest: Setting to Logon Message..\n" >> ./.SecurityInfo
	echo " *current: \n  /etc/motd: \n ${cmp1}\n" >> ./.SecurityInfo
	echo "  /etc/issue.net: \n ${cmp2}\n" >> ./.SecurityInfo
	echo "  /etc/issue: \n ${cmp3}\n\n" >> ./.SecurityInfo
	Progress=51
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-67|Warning Messages  ] Check... " 10 55 0
	sleep 1
}

function WarningMessageExcute_config()
{
	preValue=$(cat $1)
	if [ -z "$preValue" ]
		then
		preValue="-"
	fi	

	vi -c "%g/\S/d" -c ":wq" $1 >& /dev/null
	vi -c "%g/Kernel/d" -c ":wq" $1 >& /dev/null
	echo \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# >> $1
	echo \ \ \ \ \ \ \ \ \ \ ASSURING YOUR NETWORK SECURITY >> $1
	echo \ \ \ \ \ \ \ \ \ \ \ Administrator Access Only !! >> $1
	echo \ Unauthrozied and illegal access is strictly prohibited. >> $1
	echo \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# >> $1

	echo "  - Before Value($1) : $preValue"
	echo "  - After  Value($1) : $(cat $1)"
}
function WarningMessageExcute()
{
	if [ $(cat ./.SecurityInfo | grep "U-67" | awk -F ": " '{print $2}') == "WARN\n" ]
		then
		filebackup issue.net /etc/issue.net "10.[U-67|Warning Messages  ] :"
		filebackup issue /etc/issue "10.[U-67|Warning Messages  ] :"
		filebackup motd /etc/motd "10.[U-67|Warning Messages  ] :"

		WarningMessageExcute_config /etc/issue.net
		WarningMessageExcute_config /etc/issue
		WarningMessageExcute_config /etc/motd

		CompareValue "10.[U-67|Warning Messages  ] :" "$(cat /etc/motd | grep "Administrator Access Only" | awk -F " " '{print $1" "$2" "$3}')" "Administrator Access Only"
	elif [ $(cat ./.SecurityInfo | grep "U-67" | awk -F ": " '{print $2}') == "SAFE\n" ]
		then
		echo "10.[U-67|Warning Messages  ] : Already applied\n"
	else
		echo "10.[U-67|Warning Messages  ] : Error\n"
	fi
	sleep 1
}

#U-06
function wheelgroup()
{
	ret=0
	if [ -z "$(cat /etc/group | grep wheel | grep ",$1,")" ]
		then
	    if [ "$1" = "$(cat /etc/group | grep wheel | awk -F "," '{print $NF}')" ]
	    	then
	    	ret=1
    	else
	       	ret=2
	    fi
	else
	    ret=2
	fi
}

#U-06
function SuRootLimit_config()
{
	cmp1=$(cat /etc/pam.d/su | grep auth | grep required | awk -F " " '{print $1" "$2" "$3" "$4" "$5}')
	cmp2="auth required pam_wheel.so debug group=wheel"

	if [ -z "$cmp1" -o "$cmp1" != "$cmp2" ]
		then
		#위험
        echo "10.[U-67|Warning Messages  ] : WARN\n" >> ./.SecurityInfo
	else
        #안전
        echo "10.[U-67|Warning Messages  ] : SAFE\n" >> ./.SecurityInfo
	fi
	echo " *suggest: ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=51
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-67|Warning Messages  ] Check... " 10 55 0
	sleep 1
}

#U-06
function SuRootLimit()
{
    userid=$(dialog --backtitle "$BACKTITLE" --title "$TITLE" --inputbox "Enter User ID (Include for Wheel Group)" 10 55  3>&1 1>&2 2>&3 3>&-)
    case $? in
        0)
			if [ "$userid" != "$(cat /etc/passwd | awk -F ":" '{print $1}' | grep "^$userid$")" ]
				then
				useradd "$userid"
				passwd "$userid"
				#SuRootLimit
				if [ "$userid" != "$(cat /etc/passwd | awk -F ":" '{print $1}' | grep "^$userid$")" ]
				then
					echo "[U-06|User Create][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
					echo " # '$userid' creation failed." >> $(pwd)/LOG/security/$logfilename.log			
				else
					echo "[U-06|User Create][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
					echo " # '$userid' creation success." >> $(pwd)/LOG/security/$logfilename.log
				fi
			else
				useradd "$userid"
				echo "[U-06|User Create][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log	
				echo " # '$userid' Already exists." >> $(pwd)/LOG/security/$logfilename.log				
				sleep 1
			fi

			#if [ -n "$(cat /etc/group | grep wheel | grep $userid)" ]
			wheelgroup $userid
			if [ $ret -eq 1 ]
				then
				dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[OK]\n  [U-06|SU - Root Limit] Already applied.\n  '$userid' Already included in wheel group.\n\n #[wheel group List]\n  $(cat /etc/group | grep wheel | awk -F ":" '{print $4}')" 15 55
				echo "[U-06|SU - Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
				echo "# [OK][U-06|SU - Root Limit] Already applied." >> $(pwd)/LOG/security/$logfilename.log
				echo "# '$userid' Already included in wheel group." >> $(pwd)/LOG/security/$logfilename.log
				echo "# [wheel group List] : $(cat /etc/group | grep wheel | awk -F ":" '{print $4}')" >> $(pwd)/LOG/security/$logfilename.log
				echo " " >> $(pwd)/LOG/security/$logfilename.log
			elif [ $ret -eq 2 ]
				then
				chgrp wheel /bin/su
				usermod -G wheel root
				usermod -G wheel $userid
				chmod 4750 /bin/su
				wheelgroup $userid
				if [ $ret -eq 1 ]
				then
					dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[OK]\n  [U-06|SU - Root Limit] Setting Success.\n  '$userid' was successfully created.\n  '$userid' included in the 'wheel' group.\n\n #[wheel group List]\n  $(cat /etc/group | grep wheel | awk -F ":" '{print $4}')" 15 55
					echo "[U-06|SU - Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
					echo "# [OK][U-06|SU - Root Limit] Setting Success." >> $(pwd)/LOG/security/$logfilename.log
					echo "# '$userid' was successfully created. '$userid' included in the 'wheel' group." >> $(pwd)/LOG/security/$logfilename.log
					echo "# [wheel group List] $(cat /etc/group | grep wheel | awk -F ":" '{print $4}')" >> $(pwd)/LOG/security/$logfilename.log
					echo " " >> $(pwd)/LOG/security/$logfilename.log
				else
					dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[ERROR]\n  [U-06|SU - Root Limit] Setting Fail.\n  '$userid' has failed to create.\n\n #[wheel group List]\n  $(cat /etc/group | grep wheel | awk -F ":" '{print $4}')" 15 55
					echo "[U-06|SU - Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
					echo "# [ERROR][U-06|SU - Root Limit] Setting Fail." >> $(pwd)/LOG/security/$logfilename.log
					echo "# '$userid' has failed to create." >> $(pwd)/LOG/security/$logfilename.log
					echo "# [wheel group List] : $(cat /etc/group | grep wheel | awk -F ":" '{print $4}')" >> $(pwd)/LOG/security/$logfilename.log
					echo " " >> $(pwd)/LOG/security/$logfilename.log
					menu
				fi
			else
				dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[ERROR]\n  [U-06|SU - Root Limit] Check Fail. (return $ret)\n\n #[wheel group List]\n  $(cat /etc/group | grep wheel | awk -F ":" '{print $4}')" 15 55
				echo "[U-06|SU - Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
				echo "# [ERROR][U-06|SU - Root Limit] Check Fail. (return $ret)" >> $(pwd)/LOG/security/$logfilename.log
				echo "# [wheel group List] : $(cat /etc/group | grep wheel | awk -F ":" '{print $4}')" >> $(pwd)/LOG/security/$logfilename.log
				echo " " >> $(pwd)/LOG/security/$logfilename.log
						
			fi	
			menu		
            ;;
        1)
			menu
			;;
        255)
            return 255
            ;;
    esac
}

#U-01
function SshRootLimit()
{
	if [ "$(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" = "PermitRootLogin no" ]
	then
        #안전
        #echo "11.[U-01|SSH Root Limit    ] : SAFE\n" >> ./.SecurityInfo
		dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[OK]\n  [U-01|SSH Root Limit] Already applied.\n  $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" 15 55
		echo "[U-01|SSH Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
		echo "# [OK][U-01|SSH Root Limit] Already applied. - $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" >> $(pwd)/LOG/security/$logfilename.log
		echo "" >> $(pwd)/LOG/security/$logfilename.log
	else
		#위험
		echo "[U-01|SSH Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log	
		filebackup sshd_config /etc/ssh/sshd_config "# [U-01|SSH Root Limit] :"
		line=$(egrep -n "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no" /etc/ssh/sshd_config | awk -F ":" '{print$1}')"s"
		sed -i "$line/.*/PermitRootLogin no/g" /etc/ssh/sshd_config
		setResult=$(CompareValue "[U-01|SSH Root Limit]" "$(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" "PermitRootLogin no")
        #dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[OK]\n  $setResult $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" 15 55
		echo "# $setResult - $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" >> $(pwd)/LOG/security/$logfilename.log
		#echo "" >> $(pwd)/LOG/security/$logfilename.log
		SshRestart
	fi
	menu
	#Progress=99
	#echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-01|SSH Root Limit    ] Check... " 10 55 0
	#sleep 1
}

#U-22/U-23
function ipForward()
{
	cmp1=$(cat /proc/sys/net/ipv4/ip_forward)
	cmp2=$(cat /proc/sys/net/ipv4/conf/default/accept_source_route)
	#if [[ "$cmp1" = "0" ]] && [[ "$cmp2" = "0" ]] && [[ "$(md5sum /etc/sysctl.conf | awk -F " " '{print $1}')" == "$(md5sum sysctl.conf | awk -F " " '{print $1}')" ]]
	if [[ "$cmp1" = "0" ]] && [[ "$cmp2" = "0" ]] 
	then
        #안전cc
        echo "11.[U-22|IP Forwarding     ] : SAFE\n" >> ./.SecurityInfo
    else
		#위험
        echo "11.[U-22|IP Forwarding     ] : WARN\n" >> ./.SecurityInfo
	fi
	echo " *suggest: ipforward=0, acceptRoute=0\n" >> ./.SecurityInfo
	echo " *current: ipforward=${cmp1}, acceptRoute=${cmp2}\n\n" >> ./.SecurityInfo
	Progress=59
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-22|IP Forwarding     ] Check... " 10 55 0
	sleep 1

}

#U-22/U-23
function ipForwardExcute()
{	
	preValueIpFoward=$(cat /proc/sys/net/ipv4/ip_forward)
	preValueAcceptRoute=$(cat /proc/sys/net/ipv4/conf/default/accept_source_route)
	if [ $(cat ./.SecurityInfo | grep "U-22" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "11.[U-22|IP Forwarding     ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-22" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup ip_forward /proc/sys/net/ipv4/ip_forward "11.[U-22|IP Forwarding     ] :"
    	filebackup accept_source_route /proc/sys/net/ipv4/conf/default/accept_source_route "11.[U-22|IPforward inactive] :"
    	filebackup sysctl.conf /etc/sysctl.conf "11.[U-22|IP Forwarding     ] :"
    	/sbin/sysctl -w net.ipv4.ip_forward=0 >& /dev/null
    	/sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0 >& /dev/null
    	if [ "$(md5sum /etc/sysctl.conf | awk -F " " '{print $1}')" != "$(md5sum sysctl.conf | awk -F " " '{print $1}')" ]
    		then
    		\cp /WinsCloud_Tool/2.RPM/5.sysctl/.sysctl.conf /etc/sysctl.conf
    	fi
		CompareValue "11.[U-22|IP Forwarding     ] :" "$(cat /proc/sys/net/ipv4/ip_forward)$(cat /proc/sys/net/ipv4/conf/default/accept_source_route)" "00"
		echo "  - Before Value : ip_forward=$preValueIpFoward / accept_source_route=$preValueAcceptRoute"
		echo "  - After  Value : ip_forward=$(cat /proc/sys/net/ipv4/ip_forward) / accept_source_route=$(cat /proc/sys/net/ipv4/conf/default/accept_source_route)"
	else
		echo "11.[U-22|IP Forwarding     ] : Error\n"
	fi	
}

#U-24
function icmpRedirectsValue()
{
	icmp01=$(cat /proc/sys/net/ipv4/conf/all/accept_redirects)
	icmp02=$(cat /proc/sys/net/ipv4/conf/all/send_redirects)
	icmp03=$(cat /proc/sys/net/ipv4/conf/default/accept_redirects)
	icmp04=$(cat /proc/sys/net/ipv4/conf/default/send_redirects)
	icmp05=$(cat /proc/sys/net/ipv4/conf/eth0/accept_redirects)
	icmp06=$(cat /proc/sys/net/ipv4/conf/eth0/send_redirects)
	icmp07=$(cat /proc/sys/net/ipv4/conf/eth1/accept_redirects)
	icmp08=$(cat /proc/sys/net/ipv4/conf/eth1/send_redirects)
	icmp09=$(cat /proc/sys/net/ipv4/conf/lo/accept_redirects)
	icmp10=$(cat /proc/sys/net/ipv4/conf/lo/send_redirects)
	icmp11=$(cat /proc/sys/net/ipv6/conf/all/accept_redirects)
	icmp12=$(cat /proc/sys/net/ipv6/conf/default/accept_redirects)
	icmp13=$(cat /proc/sys/net/ipv6/conf/eth0/accept_redirects)
	icmp14=$(cat /proc/sys/net/ipv6/conf/eth1/accept_redirects)
	icmp15=$(cat /proc/sys/net/ipv6/conf/lo/accept_redirects)
	icmpv4="$icmp01$icmp02$icmp03$icmp04$icmp05$icmp06$icmp07$icmp08$icmp09$icmp10"
	icmpv6="$icmp11$icmp12$icmp13$icmp14$icmp15"
}

function icmpRedirects()
{
	icmpRedirectsValue
	if [[ "$icmpv4" = "0000000000" ]] && [[ "$icmpv6" = "00000" ]] && [[ "$(md5sum /etc/sysctl.conf | awk -F " " '{print $1}')" == "$(md5sum sysctl.conf | awk -F " " '{print $1}')" ]]
	then
        #안전
        echo "12.[U-24|ICMP Redirects    ] : SAFE\n" >> ./.SecurityInfo
    else
		#위험
        echo "12.[U-24|ICMP Redirects    ] : WARN\n" >> ./.SecurityInfo
	fi
	echo " *suggest: icmpv4=0000000000, icmpv6=00000\n" >> ./.SecurityInfo
	echo " *current: icmpv4=${icmpv4}, icmpv6=${icmpv6}\n\n" >> ./.SecurityInfo
	Progress=66
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-24|ICMP Redirects    ] Check... " 10 55 0
	sleep 1

}

#U-24
function icmpRedirectsExcute()
{	
	if [ $(cat ./.SecurityInfo | grep "U-24" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "12.[U-24|ICMP Redirects    ] : Already applied\n"

	elif [ $(cat ./.SecurityInfo | grep "U-24" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup accept_redirects_All /proc/sys/net/ipv4/conf/all/accept_redirects "12.[U-24|ICMP Redirects    ] :"
    	filebackup accept_redirects_Default /proc/sys/net/ipv4/conf/default/accept_redirects "12.[U-24|ICMP Redirects    ] :"
    	filebackup sysctl.conf /etc/sysctl.conf "12.[U-24|ICMP Redirects    ] :"
    	#ipv4
    	/sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0 >& /dev/null
 		/sbin/sysctl -w net.ipv4.conf.all.send_redirects=0 >& /dev/null
    	/sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0 >& /dev/null
 		/sbin/sysctl -w net.ipv4.conf.default.send_redirects=0 >& /dev/null
    	/sbin/sysctl -w net.ipv4.conf.eth0.accept_redirects=0 >& /dev/null
 		/sbin/sysctl -w net.ipv4.conf.eth0.send_redirects=0 >& /dev/null
    	/sbin/sysctl -w net.ipv4.conf.eth1.accept_redirects=0 >& /dev/null
 		/sbin/sysctl -w net.ipv4.conf.eth1.send_redirects=0 >& /dev/null
    	/sbin/sysctl -w net.ipv4.conf.lo.accept_redirects=0 >& /dev/null
 		/sbin/sysctl -w net.ipv4.conf.lo.send_redirects=0 >& /dev/null
 		#ipv6
 		/sbin/sysctl -w net.ipv6.conf.all.accept_redirects=0 >& /dev/null
 		/sbin/sysctl -w net.ipv6.conf.default.accept_redirects=0 >& /dev/null
    	/sbin/sysctl -w net.ipv6.conf.eth0.accept_redirects=0 >& /dev/null
    	/sbin/sysctl -w net.ipv6.conf.eth1.accept_redirects=0 >& /dev/null
    	/sbin/sysctl -w net.ipv6.conf.lo.accept_redirects=0 >& /dev/null
 		#/etc/sysctl.conf update
    	if [ "$(md5sum /etc/sysctl.conf | awk -F " " '{print $1}')" != "$(md5sum sysctl.conf | awk -F " " '{print $1}')" ]
    		then
    		\cp /WinsCloud_Tool/2.RPM/5.sysctl/.sysctl.conf /etc/sysctl.conf
    	fi
    	preValue1="$icmpv4"
    	preValue2="$icmpv6"
		icmpRedirectsValue 
		CompareValue "12.[U-24|ICMP Redirects    ] :" "$icmpv4-$icmpv6" "0000000000-00000"
		echo "  - Before Value : icmpv4=$preValue1 / icmpv6=$preValue2"
		echo "  - After  Value : icmpv4=$icmpv4 / icmpv6=$icmpv6"
	else
		echo "12.[U-24|ICMP Redirects    ] : Error\n"
	fi	
}

#U-21
function xinetdPermission()
{
	cmp1=$(ls -al /etc/xinetd.d/ | awk -F " " '{print $1}' | sed -n 2p)
	cmp2="drw-------."
	
	if [ "$cmp1" = "$cmp2" ]
	then
        #안전
        echo "13.[U-21|inetd.conf Permit ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        echo "13.[U-21|inetd.conf Permit ] : WARN\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=74
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-21|inetd.conf Permit ] Check... " 10 55 0
	sleep 1
}
#U-21
function xinetdPermissionExcute()
{	
	preValue=$(ls -al /etc/xinetd.d/ | awk -F " " '{print $1}' | sed -n 2p)
	if [ $(cat ./.SecurityInfo | grep "U-21" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "13.[U-21|inetd.conf Permit ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-21" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	#filebackup xinetd.d/ /etc/xinetd.d/ "13.[U-21|inetd.conf Permit ] :"
    	chmod 600 -R /etc/xinetd.d/
		CompareValue "13.[U-21|inetd.conf Permit ] :" "$(ls -al /etc/xinetd.d/ | awk -F " " '{print $1}' | sed -n 2p)" "drw-------."
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(ls -al /etc/xinetd.d/ | awk -F " " '{print $1}' | sed -n 2p)"
	else
		echo "13.[U-21|inetd.conf Permit ] : Error\n"
	fi	
}

#U-68
function NFSinactive()
{	
	cmp1=$(ls -al /etc/xinetd.d/ | awk -F " " '{print $1}' | sed -n 2p)
	cmp2="drw-------."
	if [ -e /etc/exports ]
	then
		#위험
        echo "14.[U-68|NFS Service       ] : WARN\n" >> ./.SecurityInfo
	else
        #안전
        echo "14.[U-68|NFS Service       ] : SAFE\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=81
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-68|NFS Service       ] Check... " 10 55 0
	sleep 1
}
#U-68
function NFSinactiveExcute()
{	
	preValue=$(ls -al /etc/exports | awk -F " " '{print $9}')
	if [ $(cat ./.SecurityInfo | grep "U-68" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "14.[U-68|NFS Service       ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-68" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup exports /etc/exports "14.[U-68|NFS Service       ] :"
    	rm -rf /etc/exports
    	if [ -e /etc/exports ]
		then
			CompareValue "14.[U-68|NFS Service       ] :" "$(ls -al /etc/exports | awk -F " " '{print $9}')" ""
			echo "  - Before Value : $preValue"
			echo "  - After  Value : $(ls -al /etc/exports | awk -F " " '{print $9}')"
		else
			CompareValue "14.[U-68|NFS Service       ] :" "" ""
			echo "  - Before Value : $preValue"
			echo "  - After  Value : -"
		fi	
	else
		echo "14.[U-68|NFS Service       ] : Error\n"
	fi	
}

#U-73
function logPolicy()
{	
	cmp1=$(cat /etc/rsyslog.conf | grep "*.alert")
	if [ -z "$cmp1" ]
	then
		#위험
        echo "15.[U-73|Logging Policy    ] : WARN\n" >> ./.SecurityInfo
	else
        #안전
        echo "15.[U-73|Logging Policy    ] : SAFE\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: *.alert\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=89
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-73|Logging Policy    ] Check... " 10 55 0
	sleep 1
}
#U-73
function logPolicyExcute()
{	
	preValue=$(cat /etc/rsyslog.conf | grep "*.alert")
	if [ -z "$preValue" ]
		then
		preValue="-"
	fi	

	if [ $(cat ./.SecurityInfo | grep "U-73" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "15.[U-73|Logging Policy    ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-73" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup rsyslog.conf /etc/rsyslog.conf "15.[U-73|Logging Policy    ] :"
    	echo "*.alert                                                 /dev/console" >> /etc/rsyslog.conf
    	systemctl restart rsyslog.service
		CompareValue "15.[U-73|Logging Policy    ] :" "$(cat /etc/rsyslog.conf | grep "*.alert" | awk -F " " '{print $1}')" "*.alert"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/rsyslog.conf | grep "*.alert")"
	else
		echo "15.[U-73|Logging Policy    ] : Error\n"
	fi	
}

#U-74
function suLog()
{	
	cmp1=$(cat /etc/login.defs | grep "SULOG_FILE")
	cmp2=$(cat /etc/rsyslog.conf | grep "/var/log/sulog")
	if [[ -z "$cmp1" ]] || [[ -z "$cmp2" ]]
	then
		#위험
        echo "16.[U-74|su Log File       ] : WARN\n" >> ./.SecurityInfo
	else
        #안전
        echo "16.[U-74|su Log File       ] : SAFE\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: Setting to config(/etc/login.defs,rsyslog.conf)\n" >> ./.SecurityInfo
	echo " *current: ${cmp1} ${cmp2}\n\n" >> ./.SecurityInfo
	Progress=93
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-74|su Log File       ] Check... " 10 55 0
	sleep 1
}
#U-74
function suLogExcute()
{	
	preValue1=$(cat /etc/login.defs | grep "SULOG_FILE")
	prevalue2=$(cat /etc/rsyslog.conf | grep "/var/log/sulog")
	if [[ -z "$preValue1" ]] || [[ -z "$preValue2" ]]
		then
		preValue1="-"
		preValue2="-"
	fi	

	if [ $(cat ./.SecurityInfo | grep "U-74" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "16.[U-74|su Log File       ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-74" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	filebackup login.defs /etc/login.defs "16.[U-74|su Log File       ] :"
    	filebackup rsyslog.conf /etc/rsyslog.conf "16.[U-74|su Log File       ] :"
    	echo "SULOG_FILE /var/log/sulog" >> /etc/login.defs
    	echo "auth.info                                               /var/log/sulog" >> /etc/rsyslog.conf
		CompareValue "16.[U-74|su Log File       ] :" "$(cat /etc/login.defs | grep "SULOG_FILE")$(cat /etc/rsyslog.conf | grep "/var/log/sulog")" "SULOG_FILE /var/log/sulogauth.info                                               /var/log/sulog"
		echo "  - Before Value : $preValue1 / $preValue2"
		echo "  - After  Value : $(cat /etc/login.defs | grep "SULOG_FILE") / $(cat /etc/rsyslog.conf | grep "/var/log/sulog")"
	else
		echo "16.[U-74|su Log File       ] : Error\n"
	fi	
}

#U-64
function atPermission()
{
	cmp1=$(ls -l /etc/at.deny | awk -F " " '{print $1}' | awk -F "." '{print $1}')
	cmp2=$(ls -l /etc/at.allow | awk -F " " '{print $1}' | awk -F "." '{print $1}')  
    # at.deny 파일이 존재하고 640인 경우 & at.allow파일이 존재하고 640인 경우
	if [[ -f /etc/at.deny ]] && [[ "$cmp1" = "-rw-r-----" ]] && [[ -f /etc/at.allow ]] && [[ "$cmp2" = "-rw-r-----" ]];
	then
	    #안전
	    echo "18.[U-64|at.* File Permit  ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        echo "18.[U-64|at.* File Permit  ] : WARN\n" >> ./.SecurityInfo
        #at.deny 파일 위험 현황 체크(존재여부,권한)
		if [ ! -f /etc/at.deny ]; then
			cmp1="File not exist"
		else
			cmp1=$(ls -l /etc/at.deny | awk -F " " '{print $1}' | awk -F "." '{print $1}')
        fi
        #at.allow 파일 위험 현황 체크(존재여부,권한)
        if [ ! -f /etc/at.allow ]; then
			cmp2="File not exist"
		else
			cmp2=$(ls -l /etc/at.allow | awk -F " " '{print $1}' | awk -F "." '{print $1}')
        fi  
	fi
	echo " *suggest: at.deny(-rw-r-----),at.allow(-rw-r-----)\n" >> ./.SecurityInfo
	echo " *current: at.deny(${cmp1}),at.allow(${cmp2})\n\n" >> ./.SecurityInfo
	Progress=96
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-64|at.* File Permit  ] Check... " 10 55 0
	sleep 1
}

function atPermissionExcute()
{	
	if [ $(cat ./.SecurityInfo | grep "U-64" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "18.[U-64|at.* File Permit  ] : Already applied\n"
	#WARN일때 취약점 조치 수행(at.deny,at.allow 파일생성 및 640 권한 설정)
	elif [ $(cat ./.SecurityInfo | grep "U-64" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    	#at.deny 파일 없으면 생성하고 640 권한 설정
    	if [ -f /etc/at.deny ]; then
	    	filebackup at.deny /etc/at.deny "18.[U-64|at.* File Permit  ] :"
			preValue1=$(ls -l /etc/at.deny | awk -F " " '{print $1}')
		else
			touch /etc/at.deny
			preValue1="File not exist"
	    fi
    	chmod 640 /etc/at.deny
		cmp1=$(ls -l /etc/at.deny | awk -F " " '{print $1}' | awk -F "." '{print $1}')

		#at.allow 파일 없으면 생성하고 640 권한 설정
	    if [ -f /etc/at.allow ]; then
	    	filebackup at.allow /etc/at.allow "18.[U-64|at.* File Permit  ] :"
    		prevalue2=$(ls -l /etc/at.allow | awk -F " " '{print $1}')
	    else
			touch /etc/at.allow
			prevalue2="File not exist"
	    fi
    	chmod 640 /etc/at.allow
		cmp2=$(ls -l /etc/at.allow | awk -F " " '{print $1}' | awk -F "." '{print $1}')   

        if [[ -f /etc/at.deny ]] && [[ "$cmp1" = "-rw-r-----" ]] && [[ -f /etc/at.allow ]] && [[ "$cmp2" = "-rw-r-----" ]];
			then
			CompareValue "18.[U-64|at.* File Permit  ] :" "1" "1"
		else
			CompareValue "18.[U-64|at.* File Permit  ] :" "1" "0"
		fi
		echo "  - Before Value : at.deny($preValue1),at.allow($preValue2)"
		echo "  - After  Value : at.deny($cmp1),at.allow($cmp2)"
	else
		echo "18.[U-64|at.* File Permit  ] : Error\n"
	fi	
}

function filebackup()
{
	if [ -f /WinsCloud_Tool/1.Tool/BACKUP/$1 ]
	then
		echo "$3 Backup Exists    : $2 -> ./BACKUP/$1" >> $(pwd)/LOG/security/$logfilename.log
	else
		\cp $2 /root/WinsCloud_Tool/1.Tool/BACKUP/$1
		if [ -f /root/WinsCloud_Tool/1.Tool/BACKUP/$1 ]
		then
			echo "$3 Backup Completed : $2 -> ./BACKUP/$1" >> $(pwd)/LOG/security/$logfilename.log
		else
			echo "$3 Backup Fail" >> $(pwd)/LOG/security/$logfilename.log
		fi
	fi
}

function MainPrint()
{
	#echo "" >> .ServerInfo
	#echo "******************************************************************************" >> .ServerInfo
	echo "******************************************************************************" >> .ServerInfo
	echo "                       [ WINS Cloud Security Setting ]                   " >> .ServerInfo
    echo " #) DATE     : $(date) " >> .ServerInfo
    echo " #) USER     : $(who am i | awk -F " " '{print $1$5,$3,$4}') " >> .ServerInfo
	echo " #) UPTIME   :$(uptime | awk -F "up" '{print $2}' | awk -F ", " '{print $1" "$2}')"   >> .ServerInfo
	echo " #) LOG File : $logfilename.log " >> .ServerInfo
	echo "******************************************************************************" >> .ServerInfo
	#echo "******************************************************************************" >> .ServerInfo
}

function ServerInfo()
{
	#echo "" >> .ServerInfo
	echo "==============================================================================" >> .ServerInfo
    echo "* [INFO] Server Information                                                  *" >> .ServerInfo
	echo "==============================================================================" >> .ServerInfo
	echo "1. HW" >> .ServerInfo
	echo "	1.1  Model          |    $(dmidecode -s system-product-name | grep -v '#')" >> .ServerInfo
  	echo "	1.2  Serial         |    $(dmidecode -s system-serial-number | grep -v '#')" >> .ServerInfo
    #echo "	1.3 CPU            |    $(grep -c processor /proc/cpuinfo) Core"
    echo "	1.3  CPU            |    $(cat /proc/cpuinfo |grep model |grep name |uniq |awk '{printf $4$5" "$6" "$7$8" "$9$10"\n"}') $(grep 'cpu cores' /proc/cpuinfo | tail -1 | awk -F ": " '{print$2}')Core *$(dmidecode -t processor | grep 'Socket Designation' | wc -l)"                     	 >> .ServerInfo
    echo "	1.4  MEM            |    $(cat /proc/meminfo | grep MemTotal | awk -F ":       " '{print $2/1024/1024"GB"}') [ $(dmidecode | grep 'Size.*MB' | uniq | awk '{printf $2$3"\n"}') * $(dmidecode | grep 'Size.*MB' | wc -l) ]" >> .ServerInfo
    #echo -n "	1.5  DISK [dev/sda] |    " >> .ServerInfo
	#HDDCheck sda >> .ServerInfo
	#echo -n "	1.6  DISK [dev/sdb] |    " >> .ServerInfo
	#HDDCheck sdb >> .ServerInfo

	echo "2. OS" >> .ServerInfo
	echo "	2.1  Name           |   $(uname -n)" >> .ServerInfo
	echo "	2.2  Release        |   $(cat /etc/*-release | uniq | sed -n 1p)" >> .ServerInfo
	echo "	2.3  Kernel         |   $(uname -r)" >> .ServerInfo
	echo "	2.4  SELINUX        |   $(cat /etc/sysconfig/selinux | grep "^SELINUX=" | awk -F "=" '{print $2}')" >> .ServerInfo

	#echo "3. SW " >> .ServerInfo
	#echo "	3.1  APP            |   $(/home1/$homeDir/.tms -v |sed -n 1p)" >> .ServerInfo
	#echo "	3.2  Build Version  |   $(/home1/$homeDir/.tms -v |sed -n 2p | awk -F ": " '{printf $2"\n"}')" >> .ServerInfo
	#echo "	3.3  Release Date   |   $(/home1/$homeDir/.tms -v |sed -n 3p | awk -F ": " '{printf $2"\n"}')" >> .ServerInfo
	#echo "	3.4  Serial Number  |   $(cat /home1/$homeDir/sniper.dat | grep "Serial Number" | awk -F "[" '{printf $2}' | awk -F "]" '{printf $1"\n"}')" >> .ServerInfo
	#echo "	3.5  License Key    |   $(cat /home1/$homeDir/sniper.dat | grep "License Key" | awk -F "[" '{printf $2}' | awk -F "]" '{printf $1"\n"}')" >> .ServerInfo

	#echo "4. DB " >> .ServerInfo
	#echo "	4.1  Mongo          |   $(/home1/$homeDir/mongo/bin/mongo --port 21011 --version | awk -F ": " '{print $2}')" >> .ServerInfo
	#echo "	4.2  SQLite         |   $(/home1/$homeDir/www/dbb/./sqlcipher --version | awk -F " "  '{print $1}')" >> .ServerInfo

	#echo "5. WEB " >> .ServerInfo
	#echo "	5.1  Node.js        |   $(/home1/$homeDir/node/bin/./node -v)" >> .ServerInfo
	#if [ "$homeDir" == "TMS40" ]
	#	then
	#	echo "	5.2  Apache         |   $(/home1/apache/bin/./apachectl -v | grep version | awk -F "/" '{print $2}' | awk -F " " '{print $1}')" >> .ServerInfo
	#fi

	#echo "6. Network " >> .ServerInfo
	#echo "	6.1  IP (eth0)      |   x.x.$(cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep IPADDR | awk -F "=" '{printf $2"\n"}' | awk -F "." '{printf $3"."$4"\n"}')" >> .ServerInfo
	#echo "	     Netmask        |   $(cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep NETMASK | awk -F "=" '{printf $2"\n"}')" >> .ServerInfo
	#echo "	     Gateway        |   x.x.$(cat /etc/sysconfig/network-scripts/ifcfg-eth0|grep GATEWAY | awk -F "=" '{printf $2"\n"}' | awk -F "." '{printf $3"."$4"\n"}')" >> .ServerInfo
	#echo "	     Status         |   $(ethtool eth0 | grep Link | awk -F " " '{print $1" "$2" "$3}')" >> .ServerInfo
	#echo "	6.2  IP (eth1)      |   x.x.$(cat /etc/sysconfig/network-scripts/ifcfg-eth1|grep IPADDR | awk -F "=" '{printf $2"\n"}'| awk -F "." '{printf $3"."$4"\n"}')" >> .ServerInfo
	#echo "	     Netmask        |   $(cat /etc/sysconfig/network-scripts/ifcfg-eth1|grep NETMASK | awk -F "=" '{printf $2"\n"}')" >> .ServerInfo
	#echo "	     Gateway        |   x.x.$(cat /etc/sysconfig/network-scripts/ifcfg-eth1|grep GATEWAY | awk -F "=" '{printf $2"\n"}' | awk -F "." '{printf $3"."$4"\n"}')" >> .ServerInfo
	#echo "	     Status         |   $(ethtool eth1 | grep Link | awk -F " " '{print $1" "$2" "$3}')" >> .ServerInfo
	#if [ -f /etc/sysconfig/network-scripts/ifcfg-eth2 ]
#		then
		#echo "	6.3  IP (eth2)      |   x.x.$(cat /etc/sysconfig/network-scripts/ifcfg-eth2|grep IPADDR | awk -F "=" '{printf $2"\n"}'| awk -F "." '{printf $3"."$4"\n"}')" >> .ServerInfo
		#echo "	     Netmask        |   $(cat /etc/sysconfig/network-scripts/ifcfg-eth2|grep NETMASK | awk -F "=" '{printf $2"\n"}')" >> .ServerInfo
		#echo "	     Gateway        |   x.x.$(cat /etc/sysconfig/network-scripts/ifcfg-eth2|grep GATEWAY | awk -F "=" '{printf $2"\n"}' | awk -F "." '{printf $3"."$4"\n"}')" >> .ServerInfo
		#echo "	     Status         |   $(ethtool eth2 | grep Link | awk -F " " '{print $1" "$2" "$3}')" >> .ServerInfo
	#fi
	#if [ -f /etc/sysconfig/network-scripts/ifcfg-eth3 ]
	#	then
	#	echo "	6.4  IP (eth3)      |   x.x.$(cat /etc/sysconfig/network-scripts/ifcfg-eth3|grep IPADDR | awk -F "=" '{printf $2"\n"}'| awk -F "." '{printf $3"."$4"\n"}')" >> .ServerInfo
	#	echo "	     Netmask        |   $(cat /etc/sysconfig/network-scripts/ifcfg-eth3|grep NETMASK | awk -F "=" '{printf $2"\n"}')" >> .ServerInfo
	#	echo "	     Gateway        |   x.x.$(cat /etc/sysconfig/network-scripts/ifcfg-eth3|grep GATEWAY | awk -F "=" '{printf $2"\n"}' | awk -F "." '{printf $3"."$4"\n"}')" >> .ServerInfo
	#	echo "	     Status         |   $(ethtool eth3 | grep Link | awk -F " " '{print $1" "$2" "$3}')" >> .ServerInfo
	#fi
	echo "==============================================================================" >> .ServerInfo
	echo "" >> .ServerInfo
	#msg=$(cat .ServerInfo)
	#rm -rf ./.ServerInfo
}



function CheckSecurity()
{
	PwdComplexity
	AccountLockCritical
	PwdMinLength
	PwdMaxDays
	PwdMinDays
	UserDel
	GroupDel
	SessionTimeOut
	CronPermission
	WarningMessage
	ipForward
	#icmpRedirects
	xinetdPermission
	NFSinactive
	logPolicy
	suLog
	HostsPermission
	atPermission
	AnonymousFTP
	#SshRootLimit
	echo "[Check Result]" >> $(pwd)/LOG/security/$logfilename.log
	echo "$(cat ./.SecurityInfo)" >> $(pwd)/LOG/security/$logfilename.log
	#sed -i -e 's/\\n$//' $(pwd)/LOG/security/$logfilename.log
	sed -i 's/\\n//g' $(pwd)/LOG/security/$logfilename.log
	echo "" >> $(pwd)/LOG/security/$logfilename.log

	dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "[Check Result]\n$(cat ./.SecurityInfo)  # Do you want to set security?" 25 70
    answer=$?
    case $answer in
        0)
            SettingSecurity
            ;;
        1)
			dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n  # User select 'NO'.\n  # Exit the Cloud Security Setting." 25 70
			echo "[Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
			echo "User select 'NO'" >> $(pwd)/LOG/security/$logfilename.log
			rm -rf ./.SecurityInfo
			menu
            ;;
        255)
			dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n  # User select 'NO'.\n  # Exit the Cloud Security Setting." 25 70
			echo "[Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
			echo "User select 'NO'" >> $(pwd)/LOG/security/$logfilename.log
			rm -rf ./.SecurityInfo
            exit
            ;;
    esac
	#sed -i -e 's/\\n$//' $(pwd)/LOG/security/$logfilename.log
	rm -rf ./.SecurityInfo
	rm -rf ./.SecuritySet
	menu
}

function SettingSecurity()
{
	echo "[Backup Result] : /root/WinsCloud_Tool/1.Tool/BACKUP/" >> $(pwd)/LOG/security/$logfilename.log
	echo  4 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-02|Passwd Complexity ] Setting... " 10 55 0
	PwdComplexityExcute >> ./.SecuritySet
	echo  8 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-03|Account Lock-1    ] Setting... " 10 55 0
	echo 11 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-03|Account Lock-2    ] Setting... " 10 55 0
    AccountLockCriticalExcute >> ./.SecuritySet
	echo 18 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-07|Passwd Min Len    ] Setting... " 10 55 0
    PwdMinLengthExcute >> ./.SecuritySet
	echo 24 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-08|Passwd MaxDays    ] Setting... " 10 55 0
    PwdMaxDaysExcute >> ./.SecuritySet
	echo 29 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-09|Passwd Min Days   ] Setting... " 10 55 0
    PwdMinDaysExcute >> ./.SecuritySet
	echo 35 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-10|User Delete       ] Setting... " 10 55 0
    UserDelExecute >> ./.SecuritySet
	echo 43 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-12|Group Delete      ] Setting... " 10 55 0
    GroupDelExecute >> ./.SecuritySet
	echo 49 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-15|Session TimeOut   ] Setting... " 10 55 0
    SessionTimeOutExcute >> ./.SecuritySet
	echo 54 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-39|CronFile Permit   ] Setting... " 10 55 0
    CronPermissionExcute >> ./.SecuritySet
    echo 59 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-67|Warning Messages  ] Setting... " 10 55 0
    WarningMessageExcute >> ./.SecuritySet
	echo 62 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-22|IP Forwarding     ] Setting... " 10 55 0
    ipForwardExcute >> ./.SecuritySet
	echo 67 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-24|ICMP Redirects    ] Setting... " 10 55 0
    #icmpRedirectsExcute >> ./.SecuritySet
	echo 72 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-21|inetd.conf Permit ] Setting... " 10 55 0
	xinetdPermissionExcute >> ./.SecuritySet
	echo 76 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-68|NFS Service       ] Setting... " 10 55 0
	NFSinactiveExcute >> ./.SecuritySet
	echo 81 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-73|Logging Policy    ] Setting... " 10 55 0
	logPolicyExcute >> ./.SecuritySet
	echo 88 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-74|su Log File       ] Setting... " 10 55 0
	suLogExcute >> ./.SecuritySet
	echo 90 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-20|hostsFile Permit  ] Setting... " 10 55 0
	HostsPermissionExcute >> ./.SecuritySet
	echo 92 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-64|at.* File Permit  ] Setting... " 10 55 0
	atPermissionExcute >> ./.SecuritySet
	echo 99 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-25|AnonymousFTP Limit] Setting... " 10 55 0
	AnonymousFTPExcute >> ./.SecuritySet
    #SshRootLimitExcute >> ./.SecuritySet
	#echo 99 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-01|SSH Root Limit    ] Setting... " 10 55 0
	sleep 1
	dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "[Setting Result]\n$(cat ./.SecuritySet | grep -v "Before" | grep -v "After" | grep -v "#" | grep -v "ASSURING" | grep -v "Unauthrozied" | grep -v ^$ |grep "[|]")  # Cloud Security Setting is Completed!" 25 70
	#dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n # User select 'NO'" 23 70
	#dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Check Result]\n$(cat ./.SecurityInfo)\n  # Do you want to set secyrity?" 23 70
	echo "" >> $(pwd)/LOG/security/$logfilename.log
	echo "[Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
	echo "$(cat ./.SecuritySet)" >> $(pwd)/LOG/security/$logfilename.log
	sed -i 's/\\n//g' $(pwd)/LOG/security/$logfilename.log
	echo "" >> $(pwd)/LOG/security/$logfilename.log
}

function Initialize()
{
	OPTION=$(dialog --title "$TITLE" --menu "Choose your option - (!)Initialization " 15 55 5 \
	"1" "Init Primary" \
	"2" "Init root Limit (su)" \
	"3" "Init root Limit (ssh)" 3>&1 1>&2 2>&3)
	case $? in
        0)
            case $OPTION in
            	1)
                	dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Initialize All Setting]\n\n  # Do you want to initialize 'Primary' setting?" 15 55
				    answer=$?
				    case $answer in
				        0)
				            #U-02 #U-03
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/system-auth /etc/pam.d/system-auth
							#U-10 
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/passwd /etc/passwd
							#U-12 
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/group /etc/group
							#U-15
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/profile /etc/profile
							#U-39
							chmod 644 /etc/cron.deny
							#\cp /root/WinsCloud_Tool/1.Tool/BACKUP/cron.deny /etc/cron.deny
							#U-67
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/issue /etc/issue
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/motd /etc/motd
							#U-22
							#/sbin/sysctl -w net.ipv4.ip_forward=1 >& /dev/null
    						#/sbin/sysctl -w net.ipv4.conf.default.accept_source_route=1 >& /dev/null
							#\cp /root/WinsCloud_Tool/1.Tool/BACKUP/ip_forward /proc/sys/net/ipv4/ip_forward
							#\cp /root/WinsCloud_Tool/1.Tool/BACKUP/accept_source_route /proc/sys/net/ipv4/conf/default/accept_source_route
							#U-24
							 #ipv4
					    	#/sbin/sysctl -w net.ipv4.conf.all.accept_redirects=1 >& /dev/null
					 		#/sbin/sysctl -w net.ipv4.conf.all.send_redirects=1 >& /dev/null
					    	#/sbin/sysctl -w net.ipv4.conf.default.accept_redirects=1 >& /dev/null
					 		#/sbin/sysctl -w net.ipv4.conf.default.send_redirects=1 >& /dev/null
					    	#/sbin/sysctl -w net.ipv4.conf.eth1.accept_redirects=1 >& /dev/null
					 		#/sbin/sysctl -w net.ipv4.conf.eth1.send_redirects=1 >& /dev/null
					    	#/sbin/sysctl -w net.ipv4.conf.eth1.accept_redirects=1 >& /dev/null
					 		#/sbin/sysctl -w net.ipv4.conf.eth1.send_redirects=1 >& /dev/null
					    	#/sbin/sysctl -w net.ipv4.conf.lo.accept_redirects=1 >& /dev/null
					 		#/sbin/sysctl -w net.ipv4.conf.lo.send_redirects=1 >& /dev/null
					 		 #ipv6
					 		#/sbin/sysctl -w net.ipv6.conf.all.accept_redirects=1 >& /dev/null
					 		#/sbin/sysctl -w net.ipv4.conf.default.accept_redirects=1 >& /dev/null
					    	#/sbin/sysctl -w net.ipv6.conf.eth1.accept_redirects=1 >& /dev/null
					    	#/sbin/sysctl -w net.ipv6.conf.eth1.accept_redirects=1 >& /dev/null
					    	#/sbin/sysctl -w net.ipv6.conf.lo.accept_redirects=1 >& /dev/null
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/sysctl.conf /etc/sysctl.conf
							#\cp /root/WinsCloud_Tool/1.Tool/BACKUP/accept_redirects_All /proc/sys/net/ipv4/conf/all/accept_redirects
							#\cp /root/WinsCloud_Tool/1.Tool/BACKUP/accept_redirects_Default /proc/sys/net/ipv4/conf/default/accept_redirects
							#U-20
							chmod 644 /etc/hosts
							#U-21
							chmod 755 -R /etc/xinetd.d/
							#U-68
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/exports /etc/exports
							#U-07 #U-08 #U-09 #U-74
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/login.defs /etc/login.defs
							#U-73
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/rsyslog.conf /etc/rsyslog.conf
							systemctl restart rsyslog.service
							#U-64
							\cp /root/WinsCloud_Tool/1.Tool/BACKUP/at.* /etc/
							chmod 644 at.*

							dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'Primary' setting initialization succeeded.\n " 15 55
							echo "[Initialize Result] - 'Primary' setting initialization succeeded."  >> $(pwd)/LOG/security/$logfilename.log
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
					dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Initialize All Setting]\n\n  # Do you want to\n    initialize 'root Limit (su)' setting?" 15 55
				    answer=$?
				    case $answer in
				        0)
				            #U-06
							chmod 4755 /bin/su
				            chgrp root /bin/su
				            if [ "$(ls -l /bin/su | awk -F " " '{print $1}')" = "-rwxr-xr-x." ]
				            then
								dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'root Limit (su)' setting\n  initialization succeeded.\n " 15 55
								echo "[Initialize Result] - 'root Limit (su)' setting initialization is complete."  >> $(pwd)/LOG/security/$logfilename.log
				            else
								dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'root Limit (su)' setting\n  initialization failed.\n " 15 55
								echo "[Initialize Result] - 'root Limit (su)' setting initialization failed."  >> $(pwd)/LOG/security/$logfilename.log
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
								echo "[Initialize Result] - 'root Limit (ssh)' setting initialization succeeded."  >> $(pwd)/LOG/security/$logfilename.log
					        else
								dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Initialize Result]\n\n #[OK]\n  'root Limit (ssh)' setting\n  initialization failed.\n " 15 55
								echo "[Initialize Result] - 'root Limit (ssh)' setting initialization failed."  >> $(pwd)/LOG/security/$logfilename.log
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

function menu()
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
                	CheckSecurity
                	;;
            	2)
					SuRootLimit
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
			echo "******************************************************************************" >> $(pwd)/LOG/security/$logfilename.log
			echo "  # Exit the Cloud Security Setting                                        " >> $(pwd)/LOG/security/$logfilename.log
			echo "******************************************************************************" >> $(pwd)/LOG/security/$logfilename.log
			echo ""
            exit
            ;;
        255)
            exit
            ;;
    esac
}

function main()
{
	GetDate
	DialogSetup
	mkdir -p $(pwd)/LOG/security/
	mkdir -p $(pwd)/BACKUP/
	MainPrint
	ServerInfo
	echo "$(cat ./.ServerInfo)" 2>&1 >> $(pwd)/LOG/security/$logfilename.log
	dialog --title "$TITLE" --textbox "./.ServerInfo" 50 85
	rm -rf ./.ServerInfo
	rm -rf ./.SecurityInfo
	rm -rf ./.SecuritySet
	sleep 1
	menu
}

clear
main
echo "******************************************************************************" >> $(pwd)/LOG/security/$logfilename.log
echo "  # Exit the Cloud Security Setting                                        " >> $(pwd)/LOG/security/$logfilename.log
echo "******************************************************************************" >> $(pwd)/LOG/security/$logfilename.log
#sed -i -e 's/\\n$//' $(pwd)/LOG/security/$logfilename.log
sed -i 's/\\n//g' $(pwd)/LOG/security/$logfilename.log
echo ""
#End of Shell Script
