#!/bin/bash
# 돌아감
################################################

# Update : 2024-04-25
# Cloud Security Setting Scripts(Ubuntu22.04)
# CSP: AWS

################################################

#Start of Shell Scripts


###############################################################################################################

# 패키지 설치
## 패키지 설치 목록
### 1. DialogSetup()	#	Dialog 패키지 설치 함수
### 2. libpam-pwquality()	#	Ubuntu 전용 / libpam-pwquality(패스워드 복잡성 설정) 라이브러리 설치

###############################################################################################################

TITLE="Security Setting [WINS Cloud MSP]"

# Dialog 패키지 설치
function DialogSetup()	
{
    dialogAMD=$(dpkg --get-selections | grep dialog)

    if [ -z "$dialogAMD" ]
        then
        # 경로 확인 필요
        dpkg --force-all -i $(pwd)/../2.AMD/1.dialog/dialog_1.3-20211214-1_amd64.deb  

        dialogAMD=$(dpkg --get-selections | grep dialog)
        
        if [ -n "$dialogAMD" ]
            then
            echo -e "  [INFO] [\033[0;32m Success \033[0m] Dialog Setup complete."
        else
            echo -e "  [ERROR][\033[0;31m  Fail   \033[0m] Dialog Setup Fail."
        fi
    elif [ -n "$dialogAMD" ];
        then
        echo -e "  [INFO] [\033[0;32m   OK    \033[0m] Dialog Already Setup."
    fi
}

# libpam-pwquality(패스워드 복잡성 설정) 라이브러리 설치
function libpam-pwquality()	
{
    libpamPwquality=$(dpkg --get-selections | grep libpam-pwquality)

    if [ -z "$libpamPwquality" ]
        then
        # 경로 확인 필요
        dpkg --force-all -i $(pwd)/../2.AMD/2.libpam-pwquality/libcrack2_2.9.6-3.4build4_amd64.deb
        dpkg --force-all -i $(pwd)/../2.AMD/2.libpam-pwquality/libpwquality-common_1.4.4-1build2_all.deb
        dpkg --force-all -i $(pwd)/../2.AMD/2.libpam-pwquality/cracklib-runtime_2.9.6-3.4build4_amd64.deb
        dpkg --force-all -i $(pwd)/../2.AMD/2.libpam-pwquality/libpam-pwquality_1.4.4-1build2_amd64.deb
        dpkg --force-all -i $(pwd)/../2.AMD/2.libpam-pwquality/libpwquality1_1.4.4-1build2_amd64.deb
        dpkg --force-all -i $(pwd)/../2.AMD/2.libpam-pwquality/wamerican_2020.12.07-2_all.deb

        dialogAMD=$(dpkg --get-selections | grep libpam-pwquality)
        
        if [ -n "$dialogAMD" ]
            then
            echo -e "  [INFO] [\033[0;32m Success \033[0m] pwquality library Installation Complete."
        else
            echo -e "  [ERROR][\033[0;31m  Fail   \033[0m] pwquality library Installation Fail."
        fi
    elif [ -n "$libpamPwquality" ];
        then
        echo -e "  [INFO] [\033[0;32m   OK    \033[0m]pwquality library Installed"
    fi
}





###############################################################################################################

# 2021/03/31 KISA 취약점 조치 항목 (총 72개)
## 조치 코드 목록
### 1. 계정관리 (15개)
#### U-01	- 조치 / menu 항목 따로 빠짐
#### U-02	- 조치
#### U-03	- 조치
#### U-04
#### U-44
#### U-45	- 조치 / menu 항목 따로 빠짐
#### U-46	
#### U-47	- 조치
#### U-48	- 조치
#### U-49	- 조치
#### U-50
#### U-51	- 조치
#### U-52
#### U-53
#### U-54	- 조치
#
### 2. 파일 및 디렉터리 관리 (19개)
#### U-05
#### U-06
#### U-07
#### U-08	- 조치 (신규 24/04)
#### U-09	- 조치
#### U-10
#### U-11	- 조치 (신규 24/04)
#### U-12
#### U-13
#### U-14	- 조치
#### U-15
#### U-16
#### U-17
#### U-18
#### U-55
#### U-56	- 조치 (신규 24/04)
#### U-57
#### U-58
#### U-59
#
### 3. 서비스 관리 (35개)
#### U-19
#### U-20
#### U-21
#### U-22
#### U-23
#### U-24
#### U-25
#### U-26
#### U-27
#### U-28
#### U-29
#### U-30
#### U-31
#### U-32
#### U-33
#### U-34
#### U-35
#### U-36
#### U-37
#### U-38
#### U-39
#### U-40
#### U-41
#### U-60
#### U-61
#### U-62
#### U-63
#### U-64
#### U-65
#### U-66
#### U-67
#### U-68	- 조치
#### U-69
#### U-70
#### U-71
#
### 4. 패치 관리 (1개)
#### U-42
#
### 5. 로그 관리 (2개)
#### U-43
#### U-72	- 조치
#
### 6. 추가 조치 항목 (3개)
#### ASU-01	- 조치
#### ASU-02	- 조치
#### ASU-03	- 조치

###############################################################################################################

###########################################################

# 1. 계정 관리

###########################################################


# U-01 root 계정 접속 제한 check
function SshRootLimit()
{
	if [ "$(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no|#PermitRootLogin prohibit-password")" = "PermitRootLogin no" ]
	then
        #안전
		dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[OK]\n  [U-01|SSH Root Limit] Already applied.\n  $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no|#PermitRootLogin prohibit-password")" 15 55
		echo "[U-01|SSH Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
		echo "# [OK][U-01|SSH Root Limit] Already applied. - $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no|#PermitRootLogin prohibit-password")" >> $(pwd)/LOG/security/$logfilename.log
		echo "" >> $(pwd)/LOG/security/$logfilename.log
	else
		#위험
		echo "[U-01|SSH Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log	
		filebackup sshd_config /etc/ssh/sshd_config "# [U-01|SSH Root Limit] :"
		line=$(egrep -n "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no|#PermitRootLogin prohibit-password" /etc/ssh/sshd_config | awk -F ":" '{print$1}')"s"
		sed -i "$line/.*/PermitRootLogin no/g" /etc/ssh/sshd_config
		setResult=$(CompareValue "[U-01|SSH Root Limit]" "$(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no|#PermitRootLogin prohibit-password")" "PermitRootLogin no")
		echo "# $setResult - $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no|#PermitRootLogin prohibit-password")" >> $(pwd)/LOG/security/$logfilename.log
		SshRestart
	fi
	menu
}

# U-01 SshRootLimit 참조 함수
# SSH 데몬 재시작 함수 
function SshRestart()	#	SSH 데몬 재시작 함수
{
    dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "\n[Setting Result]\n\n #[OK]\n  $setResult $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin prohibit-password|#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")\n\n # Do you want to restart SSHD Service?" 15 55		
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

################################################################################################################
#### U-02 패스워드 복잡도
# 변경 내역

# 패스워드 복잡도 취약점 현황 점검. 비밀번호 최소 길이 10으로 변경
function PwdComplexity()	
{
	minlen=$(cat /etc/pam.d/common-password | grep minlen | awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')
	dcredit=$(cat /etc/pam.d/common-password | grep dcredit | awk -F "dcredit=" '{print $2}'| awk -F " " '{print $1}')
	ucredit=$(cat /etc/pam.d/common-password | grep ucredit | awk -F "ucredit=" '{print $2}'| awk -F " " '{print $1}')
	lcredit=$(cat /etc/pam.d/common-password | grep lcredit | awk -F "lcredit=" '{print $2}'| awk -F " " '{print $1}')
	ocredit=$(cat /etc/pam.d/common-password | grep ocredit | awk -F "ocredit=" '{print $2}'| awk -F " " '{print $1}')
	#
	#
	cmp1="$minlen$dcredit$ucredit$lcredit$ocredit"
	cmp2="10-1-1-1-1"
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
	echo " *suggest: ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=5
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-02|Passwd Complexity ] Check... " 10 55 0
}

# 비밀번호 복잡성 현재 설정 확인 함수
function PwdComplexity_check()
{
	setminlen="minlen=10"
	setdcredit="dcredit=-1"
	setucredit="ucredit=-1"
	setlcredit="lcredit=-1"
	setocredit="ocredit=-1"

        # RHEL8 이후 pam_cracklib.so -> pam_pwquality.so로 변경/ 기존 "pam_cracklib.so" RHEL8 부터 지원 안함
        checkvalue=$(cat /etc/pam.d/common-password | grep password | grep requisite | grep -E "pam_pwquality.so" |grep $1)	
	if [ -n $1 ]
	then
		retval="true"
	else
		retval="false"
	fi
}

# 비밀번호 복잡성 설정하기 위한 확인 함수
function PwdComplexityExcute_check()
{	
	# RHEL8 이후 pam_cracklib.so -> pam_pwquality.so로 변경/ 기존 "pam_cracklib.so" RHEL8 부터 지원 안함
	preValue=$(cat /etc/pam.d/common-password | grep password | grep requisite | grep -E "pam_pwquality.so")
	PwdComplexity_check minlen
	PwdComplexity_check dcredit
	PwdComplexity_check ucredit
	PwdComplexity_check lcredit
	PwdComplexity_check ocredit
}

# 비밀번호 복잡성 설정 함수
function PwdComplexityExcute()
{
	
	minlen=$(cat /etc/pam.d/common-password | grep minlen | awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')
	dcredit=$(cat /etc/pam.d/common-password | grep dcredit | awk -F "dcredit=" '{print $2}'| awk -F " " '{print $1}')
	ucredit=$(cat /etc/pam.d/common-password | grep ucredit | awk -F "ucredit=" '{print $2}'| awk -F " " '{print $1}')
	lcredit=$(cat /etc/pam.d/common-password | grep lcredit | awk -F "lcredit=" '{print $2}'| awk -F " " '{print $1}')
	ocredit=$(cat /etc/pam.d/common-password | grep ocredit | awk -F "ocredit=" '{print $2}'| awk -F " " '{print $1}')

	preValue=$(cat /etc/pam.d/common-password | grep password | grep requisite | grep -E "pam_pwquality.so")
	setValue="password    requisite     pam_pwquality.so enforce_for_root retry=3 minlen=10 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1"


	if [ $(cat ./.SecurityInfo | grep "U-02" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "01.[U-02|Passwd Complexity ] : Already applied\n"
    	elif [ $(cat ./.SecurityInfo | grep "U-02" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup common-password /etc/pam.d/common-password "01.[U-02|Passwd Complexity ] :"

		sed -i'' -r -e "/password\s+requisite\s+pam_deny.so/a\password\trequisite\t\t\tpam_pwquality.so enforce_for_root retry=3 minlen=10 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1" "/etc/pam.d/common-password"

		minlen=$(cat /etc/pam.d/common-password | grep minlen | awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')
		dcredit=$(cat /etc/pam.d/common-password | grep dcredit | awk -F "dcredit=" '{print $2}'| awk -F " " '{print $1}')
		ucredit=$(cat /etc/pam.d/common-password | grep ucredit | awk -F "ucredit=" '{print $2}'| awk -F " " '{print $1}')
		lcredit=$(cat /etc/pam.d/common-password | grep lcredit | awk -F "lcredit=" '{print $2}'| awk -F " " '{print $1}')
		ocredit=$(cat /etc/pam.d/common-password | grep ocredit | awk -F "ocredit=" '{print $2}'| awk -F " " '{print $1}')
		CompareValue "01.[U-02|Passwd Complexity ] :" "10-1-1-1-1" "$minlen$dcredit$ucredit$lcredit$ocredit"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/pam.d/common-password | grep password | grep requisite | grep -E "pam_pwquality.so")"		
    	else
		echo "01.[U-02|Passwd Complexity ] : Error\n"
    	fi
}

################################################################################################################
#### U-03 
# 변경 내역

# U-03 계정 잠금 임계값 확인 함수
function AccountLockCritical()
{
    # RHEL8 부터 "pam_tally2.so" 지원 안함/ pam_tally2.so-> pam_faillock.so
	## cmp1=$(egrep -n "auth" /etc/pam.d/common-password | egrep "required" | egrep "pam_tally2.so|deny=5|unlock_time=120|no_magic_root")
	## cmp2=$(egrep -n "account" /etc/pam.d/common-password | egrep "required" | egrep "/lib64/security/pam_tally2.so no_magic_root reset")
    # cmp1=$(egrep -n "auth" /etc/pam.d/common-auth | egrep "required" | egrep "pam_faillock.so|deny=5|unlock_time=120|no_magic_root")
    # cmp2=$(egrep -n "account" /etc/pam.d/common-auth | egrep "required" | egrep "/lib64/security/pam_faillock.so no_magic_root reset")

    # cmp1=$(egrep -n "auth" /etc/pam.d/common-auth | egrep "required" | egrep "pam_faillock.so|deny=5|unlock_time=120|no_magic_root")
    # cmp2=$(egrep -n "account" /etc/pam.d/common-account | egrep "required" | egrep "pam_faillock.so no_magic_root reset")
    cmp1=$(egrep "auth" /etc/pam.d/common-auth | egrep "required" | egrep "pam_faillock.so|deny=5|unlock_time=120")
	
	if [ -z "$cmp1" ]
	then
		#위험
        	echo "02.[U-03|Account Lock    ] : WARN\n" >> ./.SecurityInfo
	else
        #안전
        	echo "02.[U-03|Account Lock    ] : SAFE\n" >> ./.SecurityInfo
    fi
	echo " *suggest: auth        required			pam_faillock.so deny=5 unlock_time=120\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
    	Progress=16

	# if [ -z "$cmp2" ]
	# then
	# 	#위험
    #     	echo "   [U-03|Account Lock-2    ] : WARN\n" >> ./.SecurityInfo
	# else
    #     	#안전
    #     	echo "   [U-03|Account Lock-2    ] : SAFE\n" >> ./.SecurityInfo
    # fi

	#echo " *suggest: account     required      	/lib64/security/pam_tally2.so no_magic_root reset\n" >> ./.SecurityInfo
	# echo " *suggest: account     required			pam_faillock.so no_magic_root reset\n" >> ./.SecurityInfo
	# echo " *current: ${cmp2}\n\n" >> ./.SecurityInfo
    	Progress=11
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-03|Account Lock-1    ] Check... " 10 55 0
}

# U-03 계정 잠금 임계값 설정 함수
function AccountLockCriticalExcute()
{
	# preValue=$(cat /etc/pam.d/common-auth | grep auth | grep required | grep pam_deny.so)
    preValue=$(cat /etc/pam.d/common-auth | grep auth | grep required | grep pam_faillock.so)
    common_auth_file="/etc/pam.d/common-auth"
    AccountLockCritical="auth\trequired\t\t\tpam_faillock.so deny=5 unlock_time=120"

    # WARN 일 때 동작
	if [ $(cat ./.SecurityInfo | grep -E "02.\[U-03" | awk -F ": " '{print $2}') == "WARN\n" ]
	then
		filebackup common-auth /etc/pam.d/common-auth "02.[U-03|Account Lock    ] :"

		# line=$(egrep -n "auth" /etc/pam.d/common-password | egrep required | egrep pam_deny.so | grep -v '#' | awk -F ":" '{print$1}')"s"
        # 임계값 설정(pam_faillock.so) 찾아서 몇번 째 줄인지 line에 저장
        line=$(egrep -n "auth" /etc/pam.d/common-auth | egrep required | egrep pam_faillock.so | grep -v '#' | awk -F ":" '{print$1}')"s"
        
        # 임계값 설정(pam_faillock.so)이 존재하면: 'Already applied' 출력
        if [ `cat $common_auth_file | grep "auth" | grep "required" | grep "pam_faillock.so deny=5 unlock_time=120" | wc -l` -eq 1 ]
        then
            echo "02.[U-03|Account Lock    ] : Already applied\n"
        
        # 임계값 설정(pam_faillock.so)이 존재하지 않으면
        else
            # 문자열이 존재하지 않으면 찾아서 그 뒤에 추가
            sed -i'' -r -e "/auth\s+required\s+pam_permit.so/a\\$AccountLockCritical" "$common_auth_file"
            # 임계값 설정이 잘 되었는지 재확인
            if [ -n "$(cat /etc/pam.d/common-auth | grep auth | grep required | grep deny=5 | grep unlock_time=120)" ]
		    then
	            echo "02.[U-03|Account Lock    ] : Setting Sucess\n "
	        else
	            echo "02.[U-03|Account Lock    ] : Setting Fail\n   "
	        fi	

			echo "  - Before Value : $preValue"
			echo "  - After  Value : $(cat /etc/pam.d/common-auth | grep auth | grep required | grep deny | grep "unlock_time")"
        fi
    elif [ $(cat ./.SecurityInfo | grep -E "02.\[U-03" | awk -F ": " '{print $2}') == "SAFE\n" ]
    then
        filebackup2 common-auth /etc/pam.d/common-auth
        echo "02.[U-03|Account Lock    ] : Already applied\n"
    else
		echo "02.[U-03|Account Lock    ] : Error\n"
	fi


    # 기존 함수
	# 	if [ "$line" = "s" ]
	# 	then
    #         # s는 해당 라인의 줄번호, 줄번호가 없으니깐 Error
	# 		echo "02.[U-03|Account Lock-1    ] : Error\n"
	# 	else
    #         # 해당 줄번호가 있으면, line을 치환하는건데, default가 없잖아
	# 		##sed -i "$line/.*/auth        required      \/lib64\/security\/pam_tally2.so deny=5 unlock_time=120 no_magic_root/g" /etc/pam.d/common-password
	# 		##sed -i "$line/.*/auth        required      	\/lib64\/security\/pam_faillock.so deny=5 unlock_time=120 no_magic_root/g" /etc/pam.d/common-password
	# 		sed -i "$line/.*/auth        required                                     \/pam_faillock.so deny=5 unlock_time=120 no_magic_root/g" /etc/pam.d/common-auth

	# 		if [ -n "$(cat /etc/pam.d/common-auth | grep auth | grep required | grep deny=5 | grep unlock_time=120 | grep no_magic_root)" ]
	# 	    then
	#                 	echo "02.[U-03|Account Lock-1    ] : Setting Sucess\n "
	#         else
	#                 	echo "02.[U-03|Account Lock-1    ] : Setting Fail\n   "
	#         fi	
	# 		echo "  - Before Value : $preValue"
	# 		echo "  - After  Value : $(cat /etc/pam.d/common-auth | grep auth | grep required | grep deny | grep "unlock_time")"
	# 	fi
	#     elif [ $(cat ./.SecurityInfo | grep -E "02.\[U-03" | awk -F ": " '{print $2}') == "SAFE\n" ]
	# 	then
	# 	echo "02.[U-03|Account Lock-1    ] : Already applied\n"

	#     else
	# 	echo "02.[U-03|Account Lock-1    ] : Error\n"
	# fi

	# preValue=$(cat /etc/pam.d/common-password | grep account | grep required | grep pam_permit.so)
	# preValue=$(cat /etc/pam.d/common-account | grep account | grep required | grep pam_permit.so)
	# if [ $(cat ./.SecurityInfo | grep -E "\ \ \ \[U-03" | awk -F ": " '{print $2}') == "WARN\n" ]
	# then
	# 	filebackup common-account /etc/pam.d/common-account "   [U-03|Account Lock-2    ] :"

	# 	line=$(egrep -n "account" /etc/pam.d/common-account | egrep "required" | egrep "pam_permit.so" | grep -v '#' | awk -F ":" '{print$1}')"s"
	# 	if [ "$line" = "s" ]
	# 	then
	# 		echo "   [U-03|Account Lock-2    ] : Error\n"
	# 	else
	# 		##sed -i "$line/.*/account     required      \/lib64\/security\/pam_tally2.so no_magic_root reset/g" /etc/pam.d/common-password
	# 		sed -i "$line/.*/account     required                                     \/pam_faillock.so no_magic_root reset/g" /etc/pam.d/common-account

	# 		if [ -n "$(cat /etc/pam.d/common-account | grep account | grep required | grep no_magic_root | grep reset)" ]
	# 	        then
	#                 	echo "   [U-03|Account Lock-2    ] : Setting Sucess\n "
	#         	else
	#                 	echo "   [U-03|Account Lock-2    ] : Setting Fail\n   "
	#         	fi
	# 			echo "  - Before Value : $preValue"
	# 			echo "  - After  Value : $(cat /etc/pam.d/common-account | grep account | grep required | grep no_magic_root | grep reset)"
	# 	fi
	# elif [ $(cat ./.SecurityInfo | grep -E "\ \ \ \[U-03" | awk -F ": " '{print $2}') == "SAFE\n" ]
	# then
	# 	echo "   [U-03|Account Lock-2    ] : Already applied\n"
	# else
	# 	echo "   [U-03|Account Lock-2    ] : Error\n"
	# fi
}


#U-45 사용자가 sudo 그룹에 포함되는지 확인하는 함수(ubuntu 22.04는 wheel 그룹이 아닌 sudo 그룹에 유저 추가)
function wheelgroup()
{
	ret=0
	# if [ -z "$(cat /etc/group | grep wheel | grep ",$1,")" ]
	if [ -z "$(cat /etc/group | grep sudo | grep ",$1,")" ]

	then
	    if [ "$1" = "$(cat /etc/group | grep sudo | awk -F "," '{print $NF}')" ]
	    then
	    	ret=1
    	    else
	       	ret=2
	    fi
	else
	    ret=2
	fi
}

####################################################
#########내용 확인 필요
# U-45
# 미사용 함수
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

#U-45 사용자를 sudo 그룹에 포함하는 함수(ubuntu 22.04는 wheel 그룹이 아닌 sudo 그룹에 유저 추가)
# Debian에서는 wheel group을 사용하지 않음. wheel → sudo
function SuRootLimit()
{
    	# userid=$(dialog --backtitle "$BACKTITLE" --title "$TITLE" --inputbox "Enter User ID (Include for Wheel Group)" 10 55  3>&1 1>&2 2>&3 3>&-)
        userid=$(dialog --backtitle "$BACKTITLE" --title "$TITLE" --inputbox "Enter User ID (Include for sudo Group)" 10 55  3>&1 1>&2 2>&3 3>&-)
    	case $? in
        	0)
			if [ "$userid" != "$(cat /etc/passwd | awk -F ":" '{print $1}' | grep "^$userid$")" ]
			then
				useradd "$userid"
				passwd "$userid"
				if [ "$userid" != "$(cat /etc/passwd | awk -F ":" '{print $1}' | grep "^$userid$")" ]
				then
					echo "[U-45|User Create][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
					echo " # '$userid' creation failed." >> $(pwd)/LOG/security/$logfilename.log			
				else
					echo "[U-45|User Create][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
					echo " # '$userid' creation success." >> $(pwd)/LOG/security/$logfilename.log
				fi
			else
				useradd "$userid"
				echo "[U-45|User Create][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log	
				echo " # '$userid' Already exists." >> $(pwd)/LOG/security/$logfilename.log				
				sleep 1
			fi

			wheelgroup $userid
			if [ $ret -eq 1 ]
			then
				dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[OK]\n  [U-45|SU - Root Limit] Already applied.\n  '$userid' Already included in sudo group.\n\n #[sudo group List]\n  $(cat /etc/group | grep sudo | awk -F ":" '{print $4}')" 15 55
				echo "[U-45|SU - Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
				echo "# [OK][U-45|SU - Root Limit] Already applied." >> $(pwd)/LOG/security/$logfilename.log
				# echo "# '$userid' Already included in wheel group." >> $(pwd)/LOG/security/$logfilename.log
                echo "# '$userid' Already included in sudo group." >> $(pwd)/LOG/security/$logfilename.log
				# echo "# [wheel group List] : $(cat /etc/group | grep wheel | awk -F ":" '{print $4}')" >> $(pwd)/LOG/security/$logfilename.log
                echo "# [sudo group List] : $(cat /etc/group | grep sudo | awk -F ":" '{print $4}')" >> $(pwd)/LOG/security/$logfilename.log
				echo " " >> $(pwd)/LOG/security/$logfilename.log
			elif [ $ret -eq 2 ]
			then
				# chgrp wheel /bin/su
				# usermod -G wheel root
				# usermod -G wheel $userid
				# chmod 4750 /bin/su
				# wheelgroup $userid

                chgrp sudo /bin/su
				usermod -G sudo root
				usermod -G sudo $userid
				chmod 4750 /bin/su
				wheelgroup $userid
				if [ $ret -eq 1 ]
				then
					dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[OK]\n  [U-45|SU - Root Limit] Setting Success.\n  '$userid' was successfully created.\n  '$userid' included in the 'sudo' group.\n\n #[sudo group List]\n  $(cat /etc/group | grep sudo | awk -F ":" '{print $4}')" 15 55
					echo "[U-45|SU - Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
					echo "# [OK][U-45|SU - Root Limit] Setting Success." >> $(pwd)/LOG/security/$logfilename.log
					echo "# '$userid' was successfully created. '$userid' included in the 'sudo' group." >> $(pwd)/LOG/security/$logfilename.log
					echo "# [sudo group List] $(cat /etc/group | grep sudo | awk -F ":" '{print $4}')" >> $(pwd)/LOG/security/$logfilename.log
					echo " " >> $(pwd)/LOG/security/$logfilename.log
				else
					dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[ERROR]\n  [U-45|SU - Root Limit] Setting Fail.\n  '$userid' has failed to create.\n\n #[sudo group List]\n  $(cat /etc/group | grep sudo | awk -F ":" '{print $4}')" 15 55
					echo "[U-45|SU - Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
					echo "# [ERROR][U-45|SU - Root Limit] Setting Fail." >> $(pwd)/LOG/security/$logfilename.log
					echo "# '$userid' has failed to create." >> $(pwd)/LOG/security/$logfilename.log
					echo "# [sudo group List] : $(cat /etc/group | grep sudo | awk -F ":" '{print $4}')" >> $(pwd)/LOG/security/$logfilename.log
					echo " " >> $(pwd)/LOG/security/$logfilename.log
					menu
				fi
			else
				dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n #[ERROR]\n  [U-45|SU - Root Limit] Check Fail. (return $ret)\n\n #[sudo group List]\n  $(cat /etc/group | grep sudo | awk -F ":" '{print $4}')" 15 55
				echo "[U-45|SU - Root Limit][Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
				echo "# [ERROR][U-45|SU - Root Limit] Check Fail. (return $ret)" >> $(pwd)/LOG/security/$logfilename.log
				echo "# [sudo group List] : $(cat /etc/group | grep sudo | awk -F ":" '{print $4}')" >> $(pwd)/LOG/security/$logfilename.log
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

# U-47 패스워드 만료기간 확인 함수
function PwdMaxDays()
{
	cmp1=$(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#' | awk -F " " '{print $2}')
	if [ $cmp1 -le 90 ]
	then
        	#안전
        	echo "04.[U-47|Passwd Max Days   ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        	echo "04.[U-47|Passwd Max Days   ] : WARN\n" >> ./.SecurityInfo
	fi
	echo " *suggest: 90\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=18
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-47|Passwd MaxDays    ] Check... " 10 55 0
	#sleep 1
}

# U-47 패스워드 만료기간 조치 설정 함수
function PwdMaxDaysExcute()
{
	preValue=$(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#')
	if [ $(cat ./.SecurityInfo | grep "U-47" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "04.[U-47|Passwd Max Days   ] : Already applied\n"
    	elif [ $(cat ./.SecurityInfo | grep "U-47" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
		filebackup login.defs /etc/login.defs "04.[U-47|Passwd Max Days   ] :"
		line=$(grep -n PASS_MAX_DAYS /etc/login.defs | grep -v '#' | awk -F ":" '{print$1}')"s"
		sed -i "$line/.*/PASS_MAX_DAYS   90/g" /etc/login.defs 
		CompareValue "04.[U-47|Passwd Max Days   ] :" "$(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#' | awk -F " " '{print $2}')" "90"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#')"
	else
		echo "04.[U-47|Passwd Max Days   ] : Error\n"
	fi
	sleep 1
}

# U-48 패스워드 최소 사용기간 확인 함수
function PwdMinDays()
{
	cmp1=$(cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v '#' | awk -F " " '{print $2}')
	if [ $cmp1 -ne 0 ]
	then
        	#안전
        	echo "05.[U-48|Passwd Min Days   ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        	echo "05.[U-48|Passwd Min Days   ] : WARN\n" >> ./.SecurityInfo
	fi
	echo " *suggest: 1\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=23
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-48|Passwd Min Days   ] Check... " 10 55 0
	sleep 1
}

# U-48 패스워드 최소 사용기간 조치 함수
function PwdMinDaysExcute()
{
	preValue=$(cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v '#')
	if [ $(cat ./.SecurityInfo | grep "U-48" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
        	echo "05.[U-48|Passwd Min Days   ] : Already applied\n"
    	elif [ $(cat ./.SecurityInfo | grep "U-48" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup login.defs /etc/login.defs "05.[U-48|Passwd Min Days   ] :"
		line=$(grep -n PASS_MIN_DAYS /etc/login.defs | grep -v '#' | awk -F ":" '{print$1}')"s"
		sed -i "$line/.*/PASS_MIN_DAYS   1/g" /etc/login.defs
		CompareValue "05.[U-48|Passwd Min Days   ] :" "$(cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v '#' | awk -F " " '{print $2}')" "1"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/login.defs | grep PASS_MIN_DAYS | grep -v '#')"
	else
		echo "05.[U-48|Passwd Min Days   ] : Error\n"		
	fi
	sleep 1
}

# U-49 불필요한 user 확인 함수
function UserDel()
{
	cmp1=$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|^sync^|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid")
	# centot7 ### cmp1=$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|sync|shutdown|halt|#news|#uucp|operator|games|#gopher|#nfsnobody|#squid")
	# ubuntu22.04 ###cmp1=$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "#adm|lp|sync|#shutdown|#halt|news|uucp|#operator|#games|#gopher|#nfsnobody|squid")

	if [ -z "$cmp1" ]
	then
        	#안전
        	echo "06.[U-49|User Delete       ] : SAFE\n" >> ./.SecurityInfo
    	else
		#위험
        	echo "06.[U-49|User Delete       ] : WARN\n" >> ./.SecurityInfo
    	fi	
	echo " *suggest: -\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
    	Progress=28
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-49|User Delete       ] Check... " 10 55 0
	#sleep 1
}

# U-49 불필요한 user 삭제 조치 함수
function UserDelExecute()
{
	preValue=$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|^sync^|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid")
	if [ $(cat ./.SecurityInfo | grep "U-49" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
        	echo "06.[U-49|User Delete       ] : Already applied\n"
    	elif [ $(cat ./.SecurityInfo | grep "U-49" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
		filebackup passwd /etc/passwd "06.[U-49|User Delete       ] :"
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
		CompareValue "06.[U-49|User Delete       ] :" "$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|^sync^|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid")" ""
		echo "  - Before Value : $preValue"
		setValue=$(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|^sync^|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid")
		if [ -z $(cat /etc/passwd | awk -F ":" '{print$1}' | egrep "adm|lp|^sync^|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid") ]
		then
			setValue="-"
		fi
		echo "  - After  Value : $setValue"
	else
		echo "7 .[U-49|User Delete       ] : Error\n"
    	fi	
	sleep 1
}

# U-51 불필요한 group 확인 함수
function GroupDel()
{
	# cmp1=$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")
    cmp1=$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|slocate|stapusr|stapsys|stapdev")
	if [ -z "$cmp1" ]
	then
        	#안전
        	echo "07.[U-51|Group Delete      ] : SAFE\n" >> ./.SecurityInfo
    	else
		#위험
        	echo "07.[U-51|Group Delete      ] : WARN\n" >> ./.SecurityInfo
    	fi
	echo " *suggest: -\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
    	Progress=32
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-51|Group Delete      ] Check... " 10 55 0
	sleep 1
}

# U-51 불필요한 group 삭제 조치 함수
# man group 삭제 제외
function GroupDelExecute()
{
	# preValue=$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")
    preValue=$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|slocate|stapusr|stapsys|stapdev")

	if [ $(cat ./.SecurityInfo | grep "U-51" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
        	echo "07.[U-51|Group Delete      ] : Already applied\n"
    	elif [ $(cat ./.SecurityInfo | grep "U-51" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
		filebackup group /etc/group "07.[U-51|Group Delete      ] :"
		groupdel lp >& /dev/null
		groupdel uucp >& /dev/null
		groupdel games >& /dev/null
		groupdel tape >& /dev/null
		groupdel video >& /dev/null
		groupdel audio >& /dev/null
		groupdel floppy >& /dev/null
		groupdel cdrom >& /dev/null
		# groupdel man >& /dev/null
		groupdel slocate >& /dev/null
		groupdel stapusr >& /dev/null
		groupdel stapsys >& /dev/null
		groupdel stapdev >& /dev/nullss
		# usermod postfix -G mail,postfix,postdrop
		#useradd tmsplus -s /sbin/nologin -G sys,tty,disk,mem,kmem,dialout,lock,utmp,utempter,ssh_keys,input,systemd-journal
		# CompareValue "07.[U-51|Group Delete      ] :" "$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")" ""
        # CompareValue "07.[U-51|Group Delete      ] :" "$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|slocate|stapusr|stapsys|stapdev")" "\n"
        # cat으로 출력한 결과(Group을 삭제하여 해당 group이 없어 공백)이 ""과 동일하다고 인식하지 않아 'Setting Fail' 출력. '| tr -d '\n''추가하여 비교
        CompareValue "07.[U-51|Group Delete      ] :" "$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|slocate|stapusr|stapsys|stapdev" | tr -d '\n')" ""


		echo "  - Before Value : $preValue"
		# setValue=$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")
        setValue=$(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|slocate|stapusr|stapsys|stapdev")

		# if [ -z $(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev") ]
        if [ -z $(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|slocate|stapusr|stapsys|stapdev") ]

		then
			setValue="-"
		fi
		# echo "  - After  Value : $(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|man|slocate|stapusr|stapsys|stapdev")"
        echo "  - After  Value : $(cat /etc/group | awk -F ":" '{print$1}' | egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|slocate|stapusr|stapsys|stapdev")"
	else
		echo "07.[U-51|Group Delete      ] : Error\n"
	fi
}

# U-54 ssh 세션 Timeout 설정 확인 함수
function SessionTimeOut()
{
	cmp1=$(cat /etc/profile | grep TIMEOUT=)
	if [ -n "$cmp1" ]
        then
        	cmp1=$(cat /etc/profile | grep TIMEOUT | awk -F "=" '{print $2}')
        	if [ "$cmp1" -le 300 ]
        	then
        		#안전
        		echo "08.[U-54|Session TimeOut   ] : SAFE\n" >> ./.SecurityInfo
        	else
        		#위험
        		echo "08.[U-54|Session TimeOut   ] : WARN\n" >> ./.SecurityInfo
        	fi
	else
		#위험
        	echo "08.[U-54|Session TimeOut   ] : WARN\n" >> ./.SecurityInfo
        	echo "Value not exist"
        	echo ""
	fi
	echo " *suggest: TIMEOUT=300 Under value\n" >> ./.SecurityInfo
	echo " *current: $(cat /etc/profile | grep TIMEOUT=)\n\n" >> ./.SecurityInfo
	Progress=38
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-54|Session TimeOut   ] Check... " 10 55 0
}

# U-54 ssh 세션 Timeout 설정 조치 함수
function SessionTimeOutExcute()
{
	preValue=$(cat /etc/profile | grep TIMEOUT=)
	if [ $(cat ./.SecurityInfo | grep "08.\[U-54" | awk -F ": " '{print $2}') == "SAFE\n" ]
    then
		echo "08.[U-54|Session TimeOut   ] : Already applied\n"
    elif [ $(cat ./.SecurityInfo | grep "U-54" | awk -F ": " '{print $2}') == "WARN\n" ]
    then
    	filebackup profile /etc/profile "08.[U-54|Session TimeOut   ] :"

		# echo >> /etc/profile
		# echo TIMEOUT=300 >> /etc/profile
		# echo export TIMEOUT >> /etc/profile

        echo "" | sudo tee -a /etc/profile
        echo "TIMEOUT=300" | sudo tee -a /etc/profile
        echo "export TIMEOUT" | sudo tee -a /etc/profile

		#fi
		CompareValue "08.[U-54|Session TimeOut   ] :" "$(cat /etc/profile | grep TIMEOUT | awk -F "=" '{print $1}' | sed -n 1p)" "TIMEOUT"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/profile | grep TIMEOUT=)"
	else
		echo "08.[U-54|Session TimeOut   ] : Error\n"
	fi
	sleep 1
}

###########################################################

# 2. 파일 및 디렉터리 관리

###########################################################

# U-08 /etc/shadow 파일 권한 확인 함수
function ShadowPermission()
{
	cmp1=$(ls -l /etc/shadow | awk -F " " '{print $1}' |awk -F "." '{print $1}')
	cmp2="-r--------"
	
	if [ "$cmp1" = "$cmp2" ]
	then
        	#안전
        	echo "09.[U-08|shadowFile Permit  ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        	echo "09.[U-08|shadowFile Permit  ] : WARN\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=54
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-08|shadowFile Permit  ] Check... " 10 55 0
	sleep 1
}

# U-08 /etc/shadow 파일 권한 조치 함수
function ShadowPermissionExcute()
{	
	preValue=$(ls -l /etc/shadow | awk -F " " '{print $1}' |awk -F "." '{print $1}')
	if [ $(cat ./.SecurityInfo | grep "U-08" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "09.[U-08|shadowFile Permit  ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-08" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup shadow /etc/shadow "09.[U-08|shadowFile Permit  ] :"
    		chmod 400 /etc/shadow
		CompareValue "09.[U-08|shadowFile Permit  ] :" "$(ls -l /etc/shadow | awk -F " " '{print $1}' | awk -F "." '{print $1}')" "-r--------"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(ls -l /etc/shadow | awk -F " " '{print $1}' |awk -F "." '{print $1}')"
	else
		echo "09.[U-08|shadowFile Permit  ] : Error\n"
	fi	
}


# U-09 /etc/hosts 파일 권한 확인 함수
function HostsPermission()
{
	cmp1=$(ls -l /etc/hosts | awk -F " " '{print $1}' |awk -F "." '{print $1}')
	cmp2="-rw-------"
	
	if [ "$cmp1" = "$cmp2" ]
	then
        	#안전
        	echo "17.[U-09|hostsFile Permit  ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        	echo "17.[U-09|hostsFile Permit  ] : WARN\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=95
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-09|hostsFile Permit  ] Check... " 10 55 0
	sleep 1
}

# U-09 /etc/hosts 파일 권한 조치 함수
function HostsPermissionExcute()
{	
	preValue=$(ls -l /etc/hosts | awk -F " " '{print $1}' |awk -F "." '{print $1}')
	if [ $(cat ./.SecurityInfo | grep "U-09" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "17.[U-09|hostsFile Permit  ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-09" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup hosts /etc/hosts "17.[U-09|hostsFile Permit  ] :"
    		chmod 600 /etc/hosts
		CompareValue "17.[U-09|hostsFile Permit  ] :" "$(ls -l /etc/hosts | awk -F " " '{print $1}' | awk -F "." '{print $1}')" "-rw-------"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(ls -l /etc/hosts | awk -F " " '{print $1}' |awk -F "." '{print $1}')"
	else
		echo "17.[U-09|hostsFile Permit  ] : Error\n"
	fi	
}


##############################
# U-11 /etc/rsyslog.conf 파일 권한 확인 함수
function RsyslogPermission()
{
	cmp1=$(ls -l /etc/rsyslog.conf | awk -F " " '{print $1}' |awk -F "." '{print $1}')
	cmp2="-rw-r-----"
	
	if [ "$cmp1" = "$cmp2" ]
	then
        	#안전
        	echo "12.[U-11|rsyslog.conf Permit  ] : SAFE\n" >> ./.SecurityInfo
	else
		#위험
        	echo "12.[U-11|rsyslog.conf Permit  ] : WARN\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=67
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-11|rsyslog.conf Permit  ] Check... " 10 55 0
	sleep 1
}

# U-11 /etc/rsyslog.conf 파일 권한 조치 함수
function RsyslogPermissionExcute()
{	
	#preValue=$(ls -l 12.[U-11|rsyslog.conf Permit  ] | awk -F " " '{print $1}' |awk -F "." '{print $1}')
	preValue=$(ls -l /etc/rsyslog.conf ] | awk -F " " '{print $1}' |awk -F "." '{print $1}')
	if [ $(cat ./.SecurityInfo | grep "U-11" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "12.[U-11|rsyslog.conf Permit  ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-11" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup rsyslog.conf /etc/rsyslog.conf "12.[U-11|rsyslog.conf Permit  ] :"
    		chmod 640 /etc/rsyslog.conf
		CompareValue "12.[U-11|rsyslog.conf Permit  ] :" "$(ls -l /etc/rsyslog.conf | awk -F " " '{print $1}' | awk -F "." '{print $1}')" "-rw-r-----"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(ls -l /etc/rsyslog.conf | awk -F " " '{print $1}' |awk -F "." '{print $1}')"
	else
		echo "12.[U-11|rsyslog.conf Permit  ] : Error\n"
	fi	
}


#U-56 umask 설정 조치
function UmaskExcute()
{
	preValue=$(cat /etc/profile | grep "umask 022")
	if [ $(cat ./.SecurityInfo | grep "13.\[U-56" | awk -F ": " '{print $2}') == "SAFE\n" ]
    then
		echo "13.[U-56|UMASK Setting  ] : Already applied\n"
    elif [ $(cat ./.SecurityInfo | grep "U-56" | awk -F ": " '{print $2}') == "WARN\n" ]
    then
    	filebackup profile /etc/profile "08.13.[U-56|UMASK Setting  ] :"

		echo >> /etc/profile
		echo umask 022 >> /etc/profile
		echo export umask >> /etc/profile

		#fi
		CompareValue "13.[U-56|UMASK Setting  ] :" "$(cat /etc/profile | grep "umask 022" | awk -F "=" '{print $1}' | sed -n 1p)" "umask"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/profile | grep "umask 022")"
	else
		echo "13.[U-56|UMASK Setting  ] : Error\n"
	fi
	sleep 1
}

# U-56 umask 설정 확인
function Umask()
{
	cmp1=$(cat /etc/profile | grep "umask 022")
	if [ -n "$cmp1" ]
        then
			cmp1=$(cat /etc/profile | grep "umask 022" | awk -F " " '{print $2}')
            if [ "$cmp1" -ge "022" ] # $cmp1 값이 022와 같거나 크면
        	then
        		#안전
        		echo "13.[U-56|UMASK Setting  ] : SAFE\n" >> ./.SecurityInfo
        	else
        		#위험
        		echo "13.[U-56|UMASK Setting  ] : WARN\n" >> ./.SecurityInfo
        	fi
	else
		#위험
        	echo "13.[U-56|UMASK Setting  ] : WARN\n" >> ./.SecurityInfo
        	echo "Value not exist"
        	echo ""
	fi
	echo " *suggest: umask 022 Upper value\n" >> ./.SecurityInfo
	echo " *current: $(cat /etc/profile | grep "umask 022")\n\n" >> ./.SecurityInfo
	Progress=72
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-56|UMASK Setting  ] Check... " 10 55 0
}


############################

###########################################################

# 3. 서비스 관리

###########################################################

# U-68 warningMessage 설정 확인 함수
function WarningMessage()
{
	# cmp1=$(cat /etc/motd)
	cmp1=$(cat /etc/update-motd.d/00-header)
	cmp2=$(cat /etc/issue.net)
	cmp3=$(cat /etc/issue)
	cmp4="Administrator Access Only"
	# cmp5=$'\S\nKernel \\r on an \m'
	cmp5=$'Ubuntu 22.04.4 LTS \n \l'

	if [ -z "$cmp1" -o "$cmp1" = "$cmp5" ]
	then
		#위험
        	echo "10.[U-68|Warning Messages  ] : WARN\n" >> ./.SecurityInfo
    	elif [ -z "$cmp2" -o "$cmp2" = "$cmp5" ]
    	then
		#위험
        	echo "10.[U-68|Warning Messages  ] : WARN\n" >> ./.SecurityInfo
    	elif [ -z "$cmp3" -o "$cmp3s" = "$cmp5" ]
    	then
		#위험
        	echo "10.[U-68|Warning Messages  ] : WARN\n" >> ./.SecurityInfo
	elif [ -n "$cmp1" ] && [ -n "$cmp2" ] && [ -n "$cmp3" ]
	then
        	#안전
        	echo "10.[U-68|Warning Messages  ] : SAFE\n" >> ./.SecurityInfo
	else
        	#안전
        	echo "10.[U-68|Warning Messages  ] : SAFE\n" >> ./.SecurityInfo
	fi
	echo " *suggest: Setting to Logon Message..\n" >> ./.SecurityInfo
	echo " *current: \n  /etc/update-motd.d/00-header: \n ${cmp1}\n" >> ./.SecurityInfo
	echo "  /etc/issue.net: \n ${cmp2}\n" >> ./.SecurityInfo
	echo "  /etc/issue: \n ${cmp3}\n\n" >> ./.SecurityInfo
	Progress=51
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-68|Warning Messages  ] Check... " 10 55 0
	sleep 1
}

# U-68 warningMessage 설정 함수
function WarningMessageExcute_config()
{
	preValue=$(cat $1)
	if [ -z "$preValue" ]
	then
		preValue="-"
	fi	

	# vi -c "%g/\S/d" -c ":wq" $1 >& /dev/null
	# vi -c "%g/Kernel/d" -c ":wq" $1 >& /dev/null
	vi -c "%g/Ubuntu/d" -c ":wq" $1 >& /dev/null
	echo \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# >> $1
	echo \ \ \ \ \ \ \ \ \ \ ASSURING YOUR NETWORK SECURITY >> $1
	echo \ \ \ \ \ \ \ \ \ \ \ Administrator Access Only !! >> $1
	echo \ Unauthrozied and illegal access is strictly prohibited. >> $1
	echo \#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\#\# >> $1

	echo "  - Before Value($1) : $preValue"
	echo "  - After  Value($1) : $(cat $1)"
}

# U-68 warningMessage 설정 조치 함수
function WarningMessageExcute()
{
	if [ $(cat ./.SecurityInfo | grep "U-68" | awk -F ": " '{print $2}') == "WARN\n" ]
	then
		filebackup "issue.net" /etc/issue.net "10.[U-68|Warning Messages  ] :"
		filebackup "issue" /etc/issue "10.[U-68|Warning Messages  ] :"
		# filebackup motd /etc/motd "10.[U-68|Warning Messages  ] :"
		filebackup "00-header" /etc/update-motd.d/00-header "10.[U-68|Warning Messages  ] :"

		WarningMessageExcute_config /etc/issue.net
		WarningMessageExcute_config /etc/issue
		# WarningMessageExcute_config /etc/motd
		WarningMessageExcute_config /etc/update-motd.d/00-header


		CompareValue "10.[U-68|Warning Messages  ] :" "$(cat /etc/update-motd.d/00-header | grep "Administrator Access Only" | awk -F " " '{print $1" "$2" "$3}')" "Administrator Access Only"
	elif [ $(cat ./.SecurityInfo | grep "U-68" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
        filebackup2 issue /etc/issue
        filebackup2 issue.net /etc/issue.net
        filebackup2 00-header /etc/update-motd.d/00-header
		echo "10.[U-68|Warning Messages  ] : Already applied\n"
	else
		echo "10.[U-68|Warning Messages  ] : Error\n"
	fi
	sleep 1
}


###########################################################

# 5. 로그 관리

###########################################################

# U-72 로그 설정 확인 함수
function logPolicy()
{	
	cmp1=$(cat /etc/rsyslog.conf | grep "*.alert")
	if [ -z "$cmp1" ]
	then
		#위험
        	echo "15.[U-72|Logging Policy    ] : WARN\n" >> ./.SecurityInfo
	else
        	#안전
        	echo "15.[U-72|Logging Policy    ] : SAFE\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: *.alert\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=89
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-72|Logging Policy    ] Check... " 10 55 0
	sleep 1
}

# U-72 로그 설정 조치 함수
function logPolicyExcute()
{	
	preValue=$(cat /etc/rsyslog.conf | grep "*.alert")
	if [ -z "$preValue" ]
	then
		preValue="-"
	fi	

	if [ $(cat ./.SecurityInfo | grep "U-72" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "15.[U-72|Logging Policy    ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-72" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup rsyslog.conf /etc/rsyslog.conf "15.[U-72|Logging Policy    ] :"
    		echo "*.alert                                                 /dev/console" >> /etc/rsyslog.conf
    		systemctl restart rsyslog.service
		CompareValue "15.[U-72|Logging Policy    ] :" "$(cat /etc/rsyslog.conf | grep "*.alert" | awk -F " " '{print $1}')" "*.alert"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/rsyslog.conf | grep "*.alert")"
	else
		echo "15.[U-72|Logging Policy    ] : Error\n"
	fi	
}


###########################################################

# 6. 추가 조치 항목

###########################################################

# ASU-01 KISA 항목에 없는 추가 조치사항
function ipForward()
{
	cmp1=$(cat /proc/sys/net/ipv4/ip_forward)
	cmp2=$(cat /proc/sys/net/ipv4/conf/default/accept_source_route)

	if [[ "$cmp1" = "0" ]] && [[ "$cmp2" = "0" ]] 
	then
        	#안전
        	echo "11.[ASU-01|IP Forwarding     ] : SAFE\n" >> ./.SecurityInfo
    	else
		    #위험
        	echo "11.[ASU-01|IP Forwarding     ] : WARN\n" >> ./.SecurityInfo
	fi
	echo " *suggest: ipforward=0, acceptRoute=0\n" >> ./.SecurityInfo
	echo " *current: ipforward=${cmp1}, acceptRoute=${cmp2}\n\n" >> ./.SecurityInfo
	Progress=59
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [ASU-01|IP Forwarding     ] Check... " 10 55 0
	sleep 1

}

#ASU-01 KISA 항목에 없는 추가 조치사항
function ipForwardExcute()
{	
	preValueIpFoward=$(cat /proc/sys/net/ipv4/ip_forward)
	preValueAcceptRoute=$(cat /proc/sys/net/ipv4/conf/default/accept_source_route)
	if [ $(cat ./.SecurityInfo | grep "ASU-01" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
        filebackup2 sysctl.conf /etc/sysctl.conf
		echo "11.[ASU-01|IP Forwarding     ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "ASU-01" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup ip_forward /proc/sys/net/ipv4/ip_forward "11.[ASU-01|IP Forwarding     ] :"
    		filebackup accept_source_route /proc/sys/net/ipv4/conf/default/accept_source_route "11.[ASU-01|IPforward inactive] :"
    		filebackup sysctl.conf /etc/sysctl.conf "11.[ASU-01|IP Forwarding     ] :"
    		/sbin/sysctl -w net.ipv4.ip_forward=0 >& /dev/null
    		/sbin/sysctl -w net.ipv4.conf.default.accept_source_route=0 >& /dev/null
    	if [ "$(md5sum /etc/sysctl.conf | awk -F " " '{print $1}')" != "$(md5sum sysctl.conf | awk -F " " '{print $1}')" ]
    		then
    		\cp /WinsCloud_Tool/2.RPM/5.sysctl/.sysctl.conf /etc/sysctl.conf
    	fi
		CompareValue "11.[ASU-01|IP Forwarding     ] :" "$(cat /proc/sys/net/ipv4/ip_forward)$(cat /proc/sys/net/ipv4/conf/default/accept_source_route)" "00"
		echo "  - Before Value : ip_forward=$preValueIpFoward / accept_source_route=$preValueAcceptRoute"
		echo "  - After  Value : ip_forward=$(cat /proc/sys/net/ipv4/ip_forward) / accept_source_route=$(cat /proc/sys/net/ipv4/conf/default/accept_source_route)"
	else
		echo "11.[ASU-01|IP Forwarding     ] : Error\n"
	fi	
}


#ASU-02
function icmpRedirectsValue()
{
	icmp01=$(cat /proc/sys/net/ipv4/conf/all/accept_redirects)
	icmp02=$(cat /proc/sys/net/ipv4/conf/all/send_redirects)
	icmp03=$(cat /proc/sys/net/ipv4/conf/default/accept_redirects)
	icmp04=$(cat /proc/sys/net/ipv4/conf/default/send_redirects)
	icmp05=$(cat /proc/sys/net/ipv4/conf/eth0/accept_redirects)
	icmp06=$(cat /proc/sys/net/ipv4/conf/eth0/send_redirects)
	# icmp07=$(cat /proc/sys/net/ipv4/conf/eth1/accept_redirects)
	# icmp08=$(cat /proc/sys/net/ipv4/conf/eth1/send_redirects)
	icmp09=$(cat /proc/sys/net/ipv4/conf/lo/accept_redirects)
	icmp10=$(cat /proc/sys/net/ipv4/conf/lo/send_redirects)
	icmp11=$(cat /proc/sys/net/ipv6/conf/all/accept_redirects)
	icmp12=$(cat /proc/sys/net/ipv6/conf/default/accept_redirects)
	icmp13=$(cat /proc/sys/net/ipv6/conf/eth0/accept_redirects)
	# icmp14=$(cat /proc/sys/net/ipv6/conf/eth1/accept_redirects)
	icmp15=$(cat /proc/sys/net/ipv6/conf/lo/accept_redirects)

	# icmpv4="$icmp01$icmp02$icmp03$icmp04$icmp05$icmp06$icmp07$icmp08$icmp09$icmp10"
	# icmpv6="$icmp11$icmp12$icmp13$icmp14$icmp15"
	icmpv4="$icmp01$icmp02$icmp03$icmp04$icmp05$icmp06$icmp09$icmp10"
	icmpv6="$icmp11$icmp12$icmp13$icmp15"
	
}

function icmpRedirects()
{
	icmpRedirectsValue
	if [[ "$icmpv4" = "0000000000" ]] && [[ "$icmpv6" = "00000" ]] && [[ "$(md5sum /etc/sysctl.conf | awk -F " " '{print $1}')" == "$(md5sum sysctl.conf | awk -F " " '{print $1}')" ]]
	then
        	#안전
        	echo "12.[ASU-02|ICMP Redirects    ] : SAFE\n" >> ./.SecurityInfo
    	else
		#위험
        	echo "12.[ASU-02|ICMP Redirects    ] : WARN\n" >> ./.SecurityInfo
	fi
	echo " *suggest: icmpv4=0000000000, icmpv6=00000\n" >> ./.SecurityInfo
	echo " *current: icmpv4=${icmpv4}, icmpv6=${icmpv6}\n\n" >> ./.SecurityInfo
	Progress=66
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [ASU-02|ICMP Redirects    ] Check... " 10 55 0
	sleep 1
}

#ASU-02
function icmpRedirectsExcute()
{	
	if [ $(cat ./.SecurityInfo | grep "ASU-02" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
        filebackup2 sysctl.conf /etc/sysctl.conf
		echo "12.[ASU-02|ICMP Redirects    ] : Already applied\n"

	elif [ $(cat ./.SecurityInfo | grep "ASU-02" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup accept_redirects_All /proc/sys/net/ipv4/conf/all/accept_redirects "12.[ASU-02|ICMP Redirects    ] :"
    		filebackup accept_redirects_Default /proc/sys/net/ipv4/conf/default/accept_redirects "12.[ASU-02|ICMP Redirects    ] :"
    		filebackup sysctl.conf /etc/sysctl.conf "12.[ASU-02|ICMP Redirects    ] :"

			#ipv4
    		/sbin/sysctl -w net.ipv4.conf.all.accept_redirects=0 >& /dev/null
 			/sbin/sysctl -w net.ipv4.conf.all.send_redirects=0 >& /dev/null
    		/sbin/sysctl -w net.ipv4.conf.default.accept_redirects=0 >& /dev/null
 			/sbin/sysctl -w net.ipv4.conf.default.send_redirects=0 >& /dev/null
    		/sbin/sysctl -w net.ipv4.conf.eth0.accept_redirects=0 >& /dev/null
 			/sbin/sysctl -w net.ipv4.conf.eth0.send_redirects=0 >& /dev/null
    		# /sbin/sysctl -w net.ipv4.conf.eth1.accept_redirects=0 >& /dev/null
 			# /sbin/sysctl -w net.ipv4.conf.eth1.send_redirects=0 >& /dev/null
    		/sbin/sysctl -w net.ipv4.conf.lo.accept_redirects=0 >& /dev/null
 			/sbin/sysctl -w net.ipv4.conf.lo.send_redirects=0 >& /dev/null

			#ipv6
			/sbin/sysctl -w net.ipv6.conf.all.accept_redirects=0 >& /dev/null
			/sbin/sysctl -w net.ipv6.conf.default.accept_redirects=0 >& /dev/null
    		/sbin/sysctl -w net.ipv6.conf.eth0.accept_redirects=0 >& /dev/null
    		# /sbin/sysctl -w net.ipv6.conf.eth1.accept_redirects=0 >& /dev/null
    		/sbin/sysctl -w net.ipv6.conf.lo.accept_redirects=0 >& /dev/null

    	if [ "$(md5sum /etc/sysctl.conf | awk -F " " '{print $1}')" != "$(md5sum sysctl.conf | awk -F " " '{print $1}')" ]
    	then
    		\cp /WinsCloud_Tool/2.RPM/5.sysctl/.sysctl.conf /etc/sysctl.conf
    	fi
    	preValue1="$icmpv4"
    	preValue2="$icmpv6"
		icmpRedirectsValue 
		CompareValue "12.[ASU-02|ICMP Redirects    ] :" "$icmpv4-$icmpv6" "0000000000-00000"
		echo "  - Before Value : icmpv4=$preValue1 / icmpv6=$preValue2"
		echo "  - After  Value : icmpv4=$icmpv4 / icmpv6=$icmpv6"
	else
		echo "12.[ASU-02|ICMP Redirects    ] : Error\n"
	fi	
}


# ASU-03 su 명령어 로그 설정 확인 함수
function suLog()
{	
    cmp1=$(cat /etc/login.defs | grep "SULOG_FILE" | grep -v '#')
	cmp2=$(cat /etc/rsyslog.conf | grep "/var/log/sulog" | grep -v '#')
	if [[ -z "$cmp1" ]] || [[ -z "$cmp2" ]]
	then
		#위험
        	echo "16.[ASU-03|su Log File       ] : WARN\n" >> ./.SecurityInfo
	else
        	#안전
        	echo "16.[ASU-03|su Log File       ] : SAFE\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: Setting to config(/etc/login.defs,rsyslog.conf)\n" >> ./.SecurityInfo
	echo " *current: ${cmp1} ${cmp2}\n\n" >> ./.SecurityInfo
	Progress=93
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [ASU-03|su Log File       ] Check... " 10 55 0
	sleep 1
}

# ASU-03 su 명령어 로그 설정 조치 함수
# 각 설정파일에 대해 비교할 수 있도록 CompareValue 추가하여 설정 비교
function suLogExcute()
{	
	preValue1=$(cat /etc/login.defs | grep "SULOG_FILE" | grep -v '#')
	prevalue2=$(cat /etc/rsyslog.conf | grep "/var/log/sulog" | grep -v '#')
	if [[ -z "$preValue1" ]] || [[ -z "$preValue2" ]]
		then
		preValue1="-"
		preValue2="-"
	fi	

	if [ $(cat ./.SecurityInfo | grep "ASU-03" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "16.[ASU-03|su Log File       ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "ASU-03" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup login.defs /etc/login.defs "16.[ASU-03|su Log File       ] :"
    		filebackup rsyslog.conf /etc/rsyslog.conf "16.[ASU-03|su Log File       ] :"
    		echo "SULOG_FILE    /var/log/sulog" >> /etc/login.defs
    		echo "auth.info                                               /var/log/sulog" >> /etc/rsyslog.conf
		# CompareValue "16.[ASU-03|su Log File       ] :" "$(cat /etc/login.defs | grep "SULOG_FILE")$(cat /etc/rsyslog.conf | grep "/var/log/sulog")" "SULOG_FILE /var/log/sulogauth.info" 
        # CompareValue "16.[ASU-03|su Log File       ] :" "$(cat /etc/login.defs | grep "SULOG_FILE")$(cat /etc/rsyslog.conf | grep "/var/log/sulog")" "SULOG_FILE /var/log/sulogauth.info                                               /var/log/sulog"
        CompareValue "16-1.[ASU-03|su Log File(/etc/login.defs)   ] :" "$(cat /etc/login.defs | grep "SULOG_FILE"| grep -v '#')" "SULOG_FILE    /var/log/sulog"
        CompareValue "16-2.[ASU-03|su Log File(/etc/rsyslog.conf) ] :" "$(cat /etc/rsyslog.conf | grep "auth.info"| grep -v '#')" "auth.info                                               /var/log/sulog"
		echo "  - Before Value : $preValue1 / $preValue2"
		echo "  - After  Value : $(cat /etc/login.defs | grep "SULOG_FILE") / $(cat /etc/rsyslog.conf | grep "/var/log/sulog")"
	else
		echo "16.[ASU-03|su Log File       ] : Error\n"
	fi	
}

#End of Shell Script

