#!/bin/bash

################################################

# Update : 2024-01-23
# Cloud Security Setting Scripts(Rocky Linux 8.X)
# TEST CSP : KT Cloud, AWS

################################################

#Start of Shell Scripts

TITLE="Security Setting [WINS Cloud MSP]"
function DialogSetup()	#	DIalog 패키지 설치 함수 / Rocky Linux는 다른 버전 설치 해야 됨
{
	dialogRPM=$(rpm -qa |grep dialog)

	if [ -z "$dialogRPM" ]
		then
		# 기존 코드 : rpm -ivh /root/WinsCloud_Tool/2.RPM/4.dialog/dialog-1.2-4.20130523.el7.x86_64.rpm &> /dev/null
		#	버전 호환 안됨 
		#		* 기존 : dialog-1.2-4.20130523.el7.x86_64.rpm 
		#		* 변경 : dialog-1.3-13.20171209.el8.x86_64.rpm
		#	설치 경로 하드코딩 -> 사용자 경로 받아오는 방법으로 변경
		#		* 기존 : /root/WinsCloud_Tool/2.RPM/4.dialog/
		#		* 변경 : $(pwd)/../2.RPM/4.dialog/
		# 변경 코드┐
		rpm -ivh $(pwd)/../2.RPM/4.dialog/dialog-1.3-13.20171209.el8.x86_64.rpm &> /dev/null
		#
		dialogRPM=$(rpm -qa |grep dialog)
		#
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


function GetDate()	#	날짜 받아오는 함수, 날짜 받아와서 로그파일 이름에 날짜 넣어줌
{
	date=$(date '+%Y%m%d_%H%M')
	logfilename="security_$date"
	BACKTITLE="$(pwd)/LOG/security/$logfilename.log"
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
	sed -i -e 's/\\n$//' $(pwd)/LOG/security/$logfilename.log
}

function SshRestart()	#	SSH 데몬 재시작 함수
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



###############################################################################################################

# 2021 클라우드 취약점 조치 항목 추가

###############################################################################################################


# U-05 패스워드 파일 보호
function U-05()
{
	## echo -e " U-05. 패스워드 파일 보호" >> $(pwd)/LOG/security/$logfilename.log
	
	# /etc/shadow 존재 유무 확인
	shadow_file="/etc/shadow"
	passwd_file="/etc/passwd"
	
	# 비밀번호가 암호화 되어 있는 계정 수
	encrypted_count=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)
	
	# 전체 계정 수
	total_accounts=$(grep -c -v '^$' "$passwd_file")
	
	if [ -e "$shadow_file" ]; then
		if [ "$encrypted_count" -eq "$total_accounts" ]; then
			echo "00.[New U-05|Password file protect ] : SAFE\n" >> ./.SecurityInfo
		else
			echo "00.[New U-05|Password file protect ] : WARN\n" >> ./.SecurityInfo
		fi
	else
		echo "00.[New U-05|Password file protect ] : WARN\n" >> ./.SecurityInfo
	fi

	echo " *suggest: total user : $total_accounts\n" >> ./.SecurityInfo
	echo " *current: encrypted user password : $encrypted_count\n\n" >> ./.SecurityInfo
	Progress=5
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   00.[New U-05|Password file protect ] Check... " 10 55 0
}

function U-05_execute()
{
	#echo " U-05. 패스워드 파일 보호"  >> $(pwd)/LOG/security/$logfilename.log
	
	# 설정 파일 백업 수행
	#filebackup shadow /etc/shadow "File Backup :"
	
	# /etc/shadow 존재 유무 확인
	shadow_file="/etc/shadow"
	passwd_file="/etc/passwd"
	
	# 비밀번호가 암호화 되어 있는 계정 수
	encrypted_count=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)
	
	# 전체 계정 수
	total_accounts=$(grep -c -v '^$' "$passwd_file")
	
	#preValue=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)
	
	if [ $(cat ./.SecurityInfo | grep "New U-05" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "00.[New U-05|Password file protect ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "New U-05" | awk -F ": " '{print $2}') == "WARN\n" ]
	then
		# 백업 필요 없음
		pwconv # shadow 파일 사용 명령어
		if [ -e "$shadow_file" ]; then
			echo "00.[New U-05|Password file protect ] : Setting Sucess\n "
		else
			echo "00.[New U-05|Password file protect ] : Error\n"
		fi
		echo "  - Before Value : $encrypted_count"
		echo "  - After  Value : $(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)"
    else
		echo "00.[New U-05|Password file protect ] : Error\n"
    fi
}

#####

# U-15 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정

#####

Homedir=(`ls /home`)
homecount=$(ls -l /home/ | grep -v total | wc -l)
#filepermission=$(stat -c %a /etc/bashrc)


function Check_permission()
{
	if [ $(stat -c %a /etc/bashrc) == 644 ] || [ $(stat -c %a /etc/bashrc) == 640 ] || [ $(stat -c %a /etc/bashrc) == 660 ]
	then
		if [ $(stat -c %a /etc/profile) == 644 ] || [ $(stat -c %a /etc/profile) == 640 ] || [ $(stat -c %a /etc/profile) == 660 
		then
			sys_permission=true
		else
			sys_permission=false
		fi
	else
		sys_permission=false
	fi

	isgood=0
	
	for i in "${Homedir[@]}";
    do
		if [ $(stat -c %a /home/$i/.bashrc) == 644 ] || [ $(stat -c %a /home/$i/.bashrc) == 640 ] || [ $(stat -c %a /home/$i/.bashrc) == 660 ]
		then 
			if [ $(stat -c %a /home/$i/.bash_profile) == 644 ] || [ $(stat -c %a /home/$i/.bash_profile) == 640 ] || [ $(stat -c %a /home/$i/.bash_profile) == 660 ]
			then
				$((isgood++))
			fi
		#else
		fi
	done
	
	if [ $isgood == $homecount ] && [ $sys_permission == true ]
	then
		echo "00.[New U-15|System Conf file - Permision ] : SAFE\n" >> ./.SecurityInfo
	else
		echo "00.[New U-15|System Conf file - Permision ] : WAE\n" >> ./.SecurityInfo
	fi

	echo " *suggest: /etc/profile : 644\n           /etc/bashrc : 644\n           /home/유저네임/.bashrc : 644\n           /home/유저네임/.bash_profile : 644\n" >> ./.SecurityInfo
    echo " *current: /etc/profile : $(stat -c %a /etc/profile)\n           /etc/bashrc : $(stat -c %a /etc/bashrc)" >> ./.SecurityInfo
	
	for usr in "${Homedir[@]}";
	do
			echo "\n           /home/$usr/.bashrc : $(stat -c %a /home/$i/.bashrc)" >> ./.SecurityInfo
			echo "\n           /home/$usr/.bash_profile :$(stat -c %a /home/$i/.bash_profile)" >> ./.SecurityInfo
	done
	echo "  \n\n" >> ./.SecurityInfo

	Progress=5
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   00.[New U-15|System Conf file - Permision ] Check... " 10 55 0
}

function Check_own()
{
	# /etc/profile 소유권 확인
	profile_own=$(ls -al /etc/profile | awk -F " " '{print $3 $4}' | grep -v ^$)
		
	# /etc/bashrc 소유권 확인
	bashrc_own=$(ls -al /etc/bashrc | awk -F " " '{print $3 $4}' | grep -v ^$)
	
	if [ $profile_own == rootroot ] && [ $bashrc_own == rootroot ]
	then 
		isgoodsysown=true
	else
		isgoodsysown=false
	fi

	
	for usrhome in "${Homedir[@]}";
	do
		# 홈 디렉터리 .bash_profile 소유권 확인
		usr_profile_own=$(ls -al /home/$usrhome/.bash_profile | awk -F " " '{print $3 $4}' | grep -v ^$)
		
		# 홈 디렉터리 .bashrc  소유권 확인
		usr_bashrc_own=$(ls -al /home/$usrhome/.bashrc | awk -F " " '{print $3  $4}' | grep -v ^$)
		
		if [ $usr_profile_own == rootroot ] && [ $usr_bashrc_own == rootroot ]
		then 
			isgoodusrown=true
		else
			isgoodusrown=false
		fi
	done

	if [ $isgoodsysown == true ] && [ $isgoodusrown == true ]
	then
		echo "   [New U-15|System Conf file - Ownership ] : SAFE\n" >> ./.SecurityInfo
	else
		echo "   [New U-15|System Conf file - Ownership ] : WARN\n" >> ./.SecurityInfo
	fi
	
	echo " *suggest: /etc/profile : rootroot\n           /etc/bashrc : rootroot\n           /home/유저네임/.bashrc : rootroot\n           /home/유저네임/.bash_profile : rootroot\n" >> ./.SecurityInfo
    echo " *current: /etc/profile : $profile_own\n           /etc/bashrc : $bashrc_own" >> ./.SecurityInfo
	
	for usr in "${Homedir[@]}";
	do
		# 홈 디렉터리 .bash_profile 소유권 확인
		check_usr_profile_own=$(ls -al /home/$usr/.bash_profile | awk -F " " '{print $3 $4}' | grep -v ^$)
		
		# 홈 디렉터리 .bashrc  소유권 확인
		check_usr_bashrc_own=$(ls -al /home/$usr/.bashrc | awk -F " " '{print $3 $4}' | grep -v ^$)
		
		echo "\n           /home/$usr/.bashrc : $check_usr_bashrc_own" >> ./.SecurityInfo
		echo "\n           /home/$usr/.bash_profile :$check_usr_profile_own" >> ./.SecurityInfo
	done
	echo "  \n\n" >> ./.SecurityInfo

	Progress=5
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   00.[New U-15|System Conf file - Permision ] Check... " 10 55 0
}

function Execute_permission() 
{
	for e in "${Homedir[@]}"; 
	do
		before_usr_bashrc+="/home/$e/.bashrc = $(stat -c %a /home/$e/.bashrc)\n                   "
		before_usr_bash_profile+="/home/$e/.bash_profile = $(stat -c %a /home/$e/.bash_profile)\n                   "
	done
	
	before_sys_bashrc=$(stat -c %a /etc/bashrc)
	before_sys_profile=$(stat -c %a /etc/profile)
	
	if [ $(cat ./.SecurityInfo | grep -E "00.\[New U-15" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "00.[New U-15|System Conf file - Permision ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep -E "[New U-15" | awk -F ": " '{print $2}') == "WARN\n" ]
	then
		filebackup profile /etc/profile "File Backup :" #추가 백업 파일
		filebackup bashrc /etc/bashrc "File Backup :" # 추가 백업 파일
		for i in "${Homedir[@]}"; # 홈 디렉터리 백업
		do
			filebackup $i /home/$i "File Backup :" # 홈 디렉터리 백업
		done
		
		chmod 644 /etc/bashrc
		chmod 644 /etc/profile
		
		for exce_usrhome in "${Homedir[@]}";
		do
			chmod 644 /home/$ex_usrhome/.bashrc
			chmod 644 /home/$ex_usrhome/.bash_profile
		done
		echo "00.[New U-15|System Conf file - Permision ] : Setting Sucess\n "
		echo -e "  - Before Value : /etc/bashrc : $before_sys_bashrc\n                   /etc/profile : $before_sys_profile\n                   $before_usr_bashrc\n                   $before_usr_bash_profile"
	
		echo -e "  - After  Value : /etc/bashrc : $(stat -c %a /etc/bashrc)\n                   /etc/profile : $(stat -c %a /etc/profile)"
	
		for after in "${Homedir[@]}";
		do
			echo -e "\n                   /home/$after/.bashrc : $(stat -c %a /home/$after/.bashrc)\n/                   home/$after/.bash_profile : $(stat -c %a /home/$after/.bash_profile)"
		done
		echo -e "  - Before Value : /etc/bashrc : $before_sys_bashrc\n                   /etc/profile : $before_sys_profile\n                   $before_usr_bashrc$before_usr_bash_profile"
		
		echo -e "  - After  Value : /etc/bashrc : $(stat -c %a /etc/bashrc)\n                   /etc/profile : $(stat -c %a /etc/profile)"
		
		for after in "${Homedir[@]}";
		do
			echo -e "                   /home/$after/.bashrc : $(stat -c %a /home/$after/.bashrc)\n                   /home/$after/.bash_profile : $(stat -c %a /home/$after/.bash_profile)"
		done
	else
		echo "00.[New U-15|System Conf file - Permision ] : Error\n"
	fi

}
	
function Execute_own()
{
	for i in "${Homedir[@]}";
	do
		before_usr_bashrc_own+="/home/$i/.bashrc = $(ls -al /home/$usrhome/.bashrc | awk -F " " '{print $3 $4}' | grep -v ^$)\n                   "
		before_usr_bash_profile_own+="/home/$i/.bash_profile = $(ls -al /home/$i/.bash_profile | awk -F " " '{print $3 $4}' | grep -v ^$)\n                   "
	done
	
	before_sys_bashrc_own=$(ls -al /etc/bashrc | awk -F " " '{print $3 $4}' | grep -v ^$)
	before_sys_profile_own=$(ls -al /etc/profile | awk -F " " '{print $3 $4}' | grep -v ^$)
	
	
	if [ $(cat ./.SecurityInfo | grep -E "\ \ \ \[New U-15" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "   [New U-15|System Conf file - Ownership ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep -E "\ \ \ \[New U-15" | awk -F ": " '{print $2}') == "WARN\n" ]
	then
		filebackup profile /etc/profile "File Backup :" #추가 백업 파일
		filebackup bashrc /etc/bashrc "File Backup :" # 추가 백업 파일
		for i in "${Homedir[@]}"; # 홈 디렉터리 백업
		do
			filebackup $i /home/$i "File Backup :" # 홈 디렉터리 백업
			before_usr_bashrc+="/home/$i/.bashrc = $(stat -c %a /home/$i/.bashrc)\n"
			before_usr_bash_profile+="/home/$i/.bash_profile = $(stat -c %a /home/$i/.bash_profile)\n"
		done
		chown root:root /etc/bashrc
		chown root:root /etc/profile
		for exce_usrhome in "${Homedir[@]}";
		do
			chown root:root /home/$exce_usrhome/.bashrc
			chown root:root /home/$exce_usrhome/.bash_profile
		done
		echo "   [New U-15|System Conf file - Ownership ] : Setting Sucess\n "
		echo -e "  - Before Value : /etc/bashrc : $before_sys_bashrc_own\n                   /etc/profile : $before_sys_profile_own\n                   $before_usr_bashrc_own$before_usr_bash_profile_own"
		
		echo -e "  - After  Value : /etc/bashrc : $(ls -al /etc/bashrc | awk -F " " '{print $3 $4}' | grep -v ^$)\n                   /etc/profile : $(ls -al /etc/profile | awk -F " " '{print $3 $4}' | grep -v ^$)"
		
		for after in "${Homedir[@]}";
		do
			echo -e "                   /home/$after/.bashrc : $(ls -al /home/$after/.bashrc | awk -F " " '{print $3 $4}' | grep -v ^$)\n                   /home/$after/.bash_profile : $(ls -al /home/$after/.bash_profile | awk -F " " '{print $3 $4}' | grep -v ^$)"
		done	
	else
		echo "   [New U-15|System Conf file - Ownership ] : Error\n"
	fi


}


function U-15()
{
	Check_permission
	Check_own
}

function U-15_execute()
{
	Execute_permission
	Execute_own
}

###############################################################################################################

# 기존 조치 항목들

###############################################################################################################


################################################################################################################
#### U-02 패스워드 복잡도
# 변경 내역
## system-auth 파일 항목 중 수정 항목 변경
## RHEL8 이후 pam_cracklib.so -> pam_pwquality.so로 변경/ 기존 "pam_cracklib.so" RHEL8 부터 지원 안함

function PwdComplexity()	# 패스워드 복잡도 점검 함수 / RHEL 8 버전부터 점검 방법 변중 / 테스트 중
{
	minlen=$(cat /etc/pam.d/system-auth | grep minlen | awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')
	dcredit=$(cat /etc/pam.d/system-auth | grep dcredit | awk -F "dcredit=" '{print $2}'| awk -F " " '{print $1}')
	ucredit=$(cat /etc/pam.d/system-auth | grep ucredit | awk -F "ucredit=" '{print $2}'| awk -F " " '{print $1}')
	lcredit=$(cat /etc/pam.d/system-auth | grep lcredit | awk -F "lcredit=" '{print $2}'| awk -F " " '{print $1}')
	ocredit=$(cat /etc/pam.d/system-auth | grep ocredit | awk -F "ocredit=" '{print $2}'| awk -F " " '{print $1}')
	#
	#
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
	echo " *suggest: ${cmp2}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
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

        # RHEL8 이후 pam_cracklib.so -> pam_pwquality.so로 변경/ 기존 "pam_cracklib.so" RHEL8 부터 지원 안함
        checkvalue=$(cat /etc/pam.d/system-auth | grep password | grep requisite | grep -E "pam_pwquality.so" |grep $1)	
	if [ -n $1 ]
	then
		retval="true"
	else
		retval="false"
	fi
}

function PwdComplexityExcute_check()
{	
	# RHEL8 이후 pam_cracklib.so -> pam_pwquality.so로 변경/ 기존 "pam_cracklib.so" RHEL8 부터 지원 안함
	preValue=$(cat /etc/pam.d/system-auth | grep password | grep requisite | grep -E "pam_pwquality.so")
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

	# RHEL8 이후 pam_cracklib.so -> pam_pwquality.so로 변경/ 기존 "pam_cracklib.so" RHEL8 부터 지원 안함
	preValue=$(cat /etc/pam.d/system-auth | grep password | grep requisite | grep -E "pam_pwquality.so")
	setValue="password    requisite     pam_pwquality.so try_first_pass retry=3 minlen=9 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1 type="


	if [ $(cat ./.SecurityInfo | grep "U-02" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "01.[U-02|Passwd Complexity ] : Already applied\n"
    	elif [ $(cat ./.SecurityInfo | grep "U-02" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup system-auth /etc/pam.d/system-auth "01.[U-02|Passwd Complexity ] :"
		# RHEL8 이후 pam_cracklib.so -> pam_pwquality.so로 변경/ 기존 "pam_cracklib.so" RHEL8 부터 지원 안함
		##sed -i'' -r -e "/password    requisite     pam_pwquality.so/a\password    required      pam_pwquality.so retry=3 minlen=9 lcredit=-1 ucredit=-1 dcredit=-1 ocredit=-1" /etc/pam.d/system-auth
		##sed -i'' -r -e "/password    requisite                                    pam_pwquality.so/a\password    requisite                                    pam_pwquality.so try_first_pass local_users_only enforce_for_root retry=3 authtok_type= minlen=9 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1" /etc/pam.d/system-auth
		sed -i'' -r -e "/password    requisite                                    pam_pwquality.so local_users_only/a\password    requisite                                    pam_pwquality.so try_first_pass local_users_only enforce_for_root retry=3 authtok_type= minlen=9 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1" /etc/pam.d/system-auth
		minlen=$(cat /etc/pam.d/system-auth | grep minlen | awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')
		dcredit=$(cat /etc/pam.d/system-auth | grep dcredit | awk -F "dcredit=" '{print $2}'| awk -F " " '{print $1}')
		ucredit=$(cat /etc/pam.d/system-auth | grep ucredit | awk -F "ucredit=" '{print $2}'| awk -F " " '{print $1}')
		lcredit=$(cat /etc/pam.d/system-auth | grep lcredit | awk -F "lcredit=" '{print $2}'| awk -F " " '{print $1}')
		ocredit=$(cat /etc/pam.d/system-auth | grep ocredit | awk -F "ocredit=" '{print $2}'| awk -F " " '{print $1}')
		CompareValue "01.[U-02|Passwd Complexity ] :" "9-1-1-1-1" "$minlen$dcredit$ucredit$lcredit$ocredit"
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(cat /etc/pam.d/system-auth | grep password | grep requisite | grep -E "pam_pwquality.so")"		
    	else
		echo "01.[U-02|Passwd Complexity ] : Error\n"
    	fi
}

################################################################################################################
#### U-03 
# 변경 내역
## system-auth 파일 항목 중 수정 항목 변경
## RHEL8 이후 pam_tally2.so-> pam_faillock.so로 변경/ 기존 "pam_tally2.so" 지원 안함

function AccountLockCritical()
{
        # RHEL8 부터 "pam_tally2.so" 지원 안함/ pam_tally2.so-> pam_faillock.so
	## cmp1=$(egrep -n "auth" /etc/pam.d/system-auth | egrep "required" | egrep "pam_tally2.so|deny=5|unlock_time=120|no_magic_root")
	## cmp2=$(egrep -n "account" /etc/pam.d/system-auth | egrep "required" | egrep "/lib64/security/pam_tally2.so no_magic_root reset")
        cmp1=$(egrep -n "auth" /etc/pam.d/system-auth | egrep "required" | egrep "pam_faillock.so|deny=5|unlock_time=120|no_magic_root")
        cmp2=$(egrep -n "account" /etc/pam.d/system-auth | egrep "required" | egrep "/lib64/security/pam_faillock.so no_magic_root reset")
	
	if [ -z "$cmp1" ]
	then
		#위험
        	echo "02.[U-03|Account Lock-1    ] : WARN\n" >> ./.SecurityInfo
	else
        	#안전
        	echo "02.[U-03|Account Lock-1    ] : SAFE\n" >> ./.SecurityInfo
        fi
	##echo " *suggest: auth        required      	/lib64/security/pam_tally2.so deny=5 unlock_time=120 no_magic_root\n" >> ./.SecurityInfo
	echo " *suggest: auth        required      	/lib64/security/pam_faillock.so deny=5 unlock_time=120 no_magic_root\n" >> ./.SecurityInfo
	##echo " *current: ${cmp1}\n" >> ./.SecurityInfo
	echo " *current: ${cmp1}\n\n" >> ./.SecurityInfo
    	Progress=16

	if [ -z "$cmp2" ]
	then
		#위험
        	echo "   [U-03|Account Lock-2    ] : WARN\n" >> ./.SecurityInfo
	else
        	#안전
        	echo "   [U-03|Account Lock-2    ] : SAFE\n" >> ./.SecurityInfo
    	fi
	#echo " *suggest: account     required      	/lib64/security/pam_tally2.so no_magic_root reset\n" >> ./.SecurityInfo
	echo " *suggest: account     required     	/lib64/security/pam_faillock.so no_magic_root reset\n" >> ./.SecurityInfo
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

		line=$(egrep -n "auth" /etc/pam.d/system-auth | egrep required | egrep pam_deny.so | grep -v '#' | awk -F ":" '{print$1}')"s"
		if [ "$line" = "s" ]
		then
			echo "02.[U-03|Account Lock-1    ] : Error\n"
		else
			##sed -i "$line/.*/auth        required      \/lib64\/security\/pam_tally2.so deny=5 unlock_time=120 no_magic_root/g" /etc/pam.d/system-auth
			##sed -i "$line/.*/auth        required      	\/lib64\/security\/pam_faillock.so deny=5 unlock_time=120 no_magic_root/g" /etc/pam.d/system-auth
			sed -i "$line/.*/auth        required                                     \/lib64\/security\/pam_faillock.so deny=5 unlock_time=120 no_magic_root/g" /etc/pam.d/system-auth

			if [ -n "$(cat /etc/pam.d/system-auth | grep auth | grep required | grep deny=5 | grep unlock_time=120 | grep no_magic_root)" ]
		        then
	                	echo "02.[U-03|Account Lock-1    ] : Setting Sucess\n "
	        	else
	                	echo "02.[U-03|Account Lock-1    ] : Setting Fail\n   "
	        	fi	
			echo "  - Before Value : $preValue"
			echo "  - After  Value : $(cat /etc/pam.d/system-auth | grep auth | grep required | grep deny | grep "unlock_time")"
		fi
	elif [ $(cat ./.SecurityInfo | grep -E "02.\[U-03" | awk -F ": " '{print $2}') == "SAFE\n" ]
		then
		echo "02.[U-03|Account Lock-1    ] : Already applied\n"

	else
		echo "02.[U-03|Account Lock-1    ] : Error\n"
	fi

	preValue=$(cat /etc/pam.d/system-auth | grep account | grep required | grep pam_permit.so)
	if [ $(cat ./.SecurityInfo | grep -E "\ \ \ \[U-03" | awk -F ": " '{print $2}') == "WARN\n" ]
	then
		filebackup system-auth /etc/pam.d/system-auth "   [U-03|Account Lock-2    ] :"

		line=$(egrep -n "account" /etc/pam.d/system-auth | egrep "required" | egrep "pam_permit.so" | grep -v '#' | awk -F ":" '{print$1}')"s"
		if [ "$line" = "s" ]
		then
			echo "   [U-03|Account Lock-2    ] : Error\n"
		else
			##sed -i "$line/.*/account     required      \/lib64\/security\/pam_tally2.so no_magic_root reset/g" /etc/pam.d/system-auth
			sed -i "$line/.*/account     required                                     \/lib64\/security\/pam_faillock.so no_magic_root reset/g" /etc/pam.d/system-auth

			if [ -n "$(cat /etc/pam.d/system-auth | grep account | grep required | grep no_magic_root | grep reset)" ]
		        then
	                	echo "   [U-03|Account Lock-2    ] : Setting Sucess\n "
	        	else
	                	echo "   [U-03|Account Lock-2    ] : Setting Fail\n   "
	        	fi
				echo "  - Before Value : $preValue"
				echo "  - After  Value : $(cat /etc/pam.d/system-auth | grep account | grep required | grep no_magic_root | grep reset)"
		fi
	elif [ $(cat ./.SecurityInfo | grep -E "\ \ \ \[U-03" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "   [U-03|Account Lock-2    ] : Already applied\n"
	else
		echo "   [U-03|Account Lock-2    ] : Error\n"
	fi
}

#U-07 #U-46
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
	else
		echo "03.[U-07|Passwd Min Len    ] : Error\n"
	fi
}

#U-08 #U-47
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
	else
		echo "04.[U-08|Passwd Max Days   ] : Error\n"
	fi
	sleep 1
}

#U-09 #U-48
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
	else
		echo "05.[U-09|Passwd Min Days   ] : Error\n"		
	fi
	sleep 1
}

#U-10  #U-49
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
		#useradd tmsplus -s /sbin/nologin -G sys,tty,disk,mem,kmem,dialout,lock,utmp,utempter,ssh_keys,input,systemd-journal
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

# 구 U-15 
# U-54
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
}

function SessionTimeOutExcute()
{
	preValue=$(cat /etc/profile | grep TMOUT=)
	if [ $(cat ./.SecurityInfo | grep "08.\[U-15" | awk -F ": " '{print $2}') == "SAFE\n" ]
        then
		echo "08.[U-15|Session TimeOut   ] : Already applied\n"
    	elif [ $(cat ./.SecurityInfo | grep "U-15" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup profile /etc/profile "08.[U-15|Session TimeOut   ] :"

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

# 구 U-20
# U-09
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

# 구 U-39
# U-22
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

# 구 U-25
# U-20
function AnonymousFTP()
{
	cmp1=$(cat /etc/passwd | grep ftp)

	if [[ -f /etc/vsftpd.conf ]] || [[ -f /etc/vsftpd/vsftpd.conf ]] || [[ -n $cmp1 ]] ;
	then
        	#안전
        	echo "19.[U-25|AnonymousFTP Limit] : WARN\n" >> ./.SecurityInfo
	else
		#위험
        	echo "19.[U-25|AnonymousFTP Limit] : SAFE\n" >> ./.SecurityInfo
	fi	
	echo " *suggest: Delete ftp User (/etc/passwd,/etc/shadow)\n" >> ./.SecurityInfo
	##echo " *current: passwd) ${cmp1}\n" >> ./.SecurityInfo
	echo " *current: passwd) ${cmp1}\n\n" >> ./.SecurityInfo
	Progress=97
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-25|AnonymousFTP Limit] Check... " 10 55 0
	sleep 1
}

function AnonymousFTPExcute()
{	
	preValue=$(cat /etc/passwd | grep ftp)
	if [ $(cat ./.SecurityInfo | grep "U-25" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "19.[U-25|AnonymousFTP Limit] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-25" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		filebackup passwd /etc/passwd "19.[U-25|AnonymousFTP Limit] :"

    		userdel ftp 

		CompareValue "19.[U-25|AnonymousFTP Limit] :" "$(cat /etc/passwd | grep ftp)" ""
		echo "  - Before Value : passwd) $preValue\n"

		echo "  - After  Value : passwd) $cmp1\n"

	else
		echo "19.[U-25|AnonymousFTP Limit] : Error\n"
	fi	
}

# 구 U-67
# U-68
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

############
# 구 U-06
# U-45
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

function SuRootLimit()
{
    	userid=$(dialog --backtitle "$BACKTITLE" --title "$TITLE" --inputbox "Enter User ID (Include for Wheel Group)" 10 55  3>&1 1>&2 2>&3 3>&-)
    	case $? in
        	0)
			if [ "$userid" != "$(cat /etc/passwd | awk -F ":" '{print $1}' | grep "^$userid$")" ]
			then
				useradd "$userid"
				passwd "$userid"
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

############

# U-01
function SshRootLimit()
{
	if [ "$(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" = "PermitRootLogin no" ]
	then
        #안전
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
		echo "# $setResult - $(cat /etc/ssh/sshd_config | egrep "#PermitRootLogin yes|PermitRootLogin yes|#PermitRootLogin no|PermitRootLogin no")" >> $(pwd)/LOG/security/$logfilename.log
		SshRestart
	fi
	menu
}

############

# 구 U-22/U-23
# KISA 항목 없음
function ipForward()
{
	cmp1=$(cat /proc/sys/net/ipv4/ip_forward)
	cmp2=$(cat /proc/sys/net/ipv4/conf/default/accept_source_route)

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

############

# 구 U-24
# KISA 항목 없음
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

############

# 구 U-21
# U-10
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

function xinetdPermissionExcute()
{	
	preValue=$(ls -al /etc/xinetd.d/ | awk -F " " '{print $1}' | sed -n 2p)
	if [ $(cat ./.SecurityInfo | grep "U-21" | awk -F ": " '{print $2}') == "SAFE\n" ]
	then
		echo "13.[U-21|inetd.conf Permit ] : Already applied\n"
	elif [ $(cat ./.SecurityInfo | grep "U-21" | awk -F ": " '{print $2}') == "WARN\n" ]
    	then
    		chmod 600 -R /etc/xinetd.d/
		CompareValue "13.[U-21|inetd.conf Permit ] :" "$(ls -al /etc/xinetd.d/ | awk -F " " '{print $1}' | sed -n 2p)" "drw-------."
		echo "  - Before Value : $preValue"
		echo "  - After  Value : $(ls -al /etc/xinetd.d/ | awk -F " " '{print $1}' | sed -n 2p)"
	else
		echo "13.[U-21|inetd.conf Permit ] : Error\n"
	fi	
}

############

# 구 U-68
# U-25, U-69
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

############

# 구 U-73
# U-72
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

############

# 구 U-74
# KISA 항목 없음
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

############

# 구 U-64
# U-65
function atPermission()
{
	cmp1=$(ls -l /etc/at.deny | awk -F " " '{print $1}' | awk -F "." '{print $1}')
	cmp2=$(ls -l /etc/at.allow | awk -F " " '{print $1}' | awk -F "." '{print $1}')  

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

############

function filebackup()
{
	if [ -e $(pwd)/BACKUP/$1 ]
	then
		echo "$3 Backup Exists    : $2 -> ./BACKUP/$1" >> $(pwd)/LOG/security/$logfilename.log
	else
		#\cp $2 /root/WinsCloud_Tool/1.Tool/BACKUP/$1
		## \cp $2 $(pwd)/BACKUP/$1
		\cp -r $2 $(pwd)/BACKUP/$1
		#if [ -f /root/WinsCloud_Tool/1.Tool/BACKUP/$1 ]
		if [ -e $(pwd)/BACKUP/$1 ]
		then
			echo "$3 Backup Completed : $2 -> ./BACKUP/$1" >> $(pwd)/LOG/security/$logfilename.log
		else
			echo "$3 Backup Fail" >> $(pwd)/LOG/security/$logfilename.log
		fi
	fi
}

function MainPrint()
{
	echo "******************************************************************************" >> .ServerInfo
	echo "                       [ WINS Cloud Security Setting ]                   " >> .ServerInfo
    	echo " #) DATE     : $(date) " >> .ServerInfo
    	echo " #) USER     : $(who am i | awk -F " " '{print $1$5,$3,$4}') " >> .ServerInfo
	echo " #) UPTIME   :$(uptime | awk -F "up" '{print $2}' | awk -F ", " '{print $1" "$2}')"   >> .ServerInfo
	echo " #) LOG File : $logfilename.log " >> .ServerInfo
	echo "******************************************************************************" >> .ServerInfo
}

function ServerInfo()
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



function CheckSecurity()
{
	# 새로 만든 함수
	U-05
	U-15
	# 기존 함수
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
	xinetdPermission
	NFSinactive
	logPolicy
	suLog
	HostsPermission
	atPermission
	AnonymousFTP
	echo "[Check Result]" >> $(pwd)/LOG/security/$logfilename.log
	echo "$(cat ./.SecurityInfo)" >> $(pwd)/LOG/security/$logfilename.log
	sed -i 's/\\n//g' $(pwd)/LOG/security/$logfilename.log
	echo "" >> $(pwd)/LOG/security/$logfilename.log

	##dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "[Check Result]\n$(cat ./.SecurityInfo)  # Do you want to set security?" 25 70
	dialog --title "$TITLE" --backtitle "$BACKTITLE" --yesno "[Check Result]\n$(cat ./.SecurityInfo)  # Do you want to set security?" 45 100
    	answer=$?
    	case $answer in
        	0)
            		SettingSecurity
            		;;
        	1)
			dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n  # User select 'NO'.\n  # Exit the Cloud Security Setting." 25 70
			echo "[Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
			echo "User select 'NO'" >> $(pwd)/LOG/security/$logfilename.log
			#rm -rf ./.SecurityInfo
			menu
            		;;
        	255)
			dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "\n[Setting Result]\n\n  # User select 'NO'.\n  # Exit the Cloud Security Setting." 25 70
			echo "[Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
			echo "User select 'NO'" >> $(pwd)/LOG/security/$logfilename.log
			#rm -rf ./.SecurityInfo
            		exit
            		;;
    	esac
	#rm -rf ./.SecurityInfo
	#rm -rf ./.SecuritySet
	menu
}

function SettingSecurity()
{
	echo "[Backup Result] : $(pwd)/BACKUP/" >> $(pwd)/LOG/security/$logfilename.log
	
	# 추가 함수
	echo  4 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-00|패스워드 파일 보호 ] Setting... " 10 55 0
	U-05_execute >> ./.SecuritySet
	echo  4 | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-00|사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정] Setting... " 10 55 0
	U-15_execute >> ./.SecuritySet
	# 기존 함수
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
	sleep 1
	dialog --title "$TITLE" --backtitle "$BACKTITLE" --msgbox "[Setting Result]\n$(cat ./.SecuritySet | grep -v "Before" | grep -v "After" | grep -v "#" | grep -v "ASSURING" | grep -v "Unauthrozied" | grep -v ^$ |grep "[|]")  # Cloud Security Setting is Completed!" 25 70

	echo "" >> $(pwd)/LOG/security/$logfilename.log
	echo "[Setting Result]" >> $(pwd)/LOG/security/$logfilename.log
	echo "$(cat ./.SecuritySet)" >> $(pwd)/LOG/security/$logfilename.log
	sed -i 's/\\n//g' $(pwd)/LOG/security/$logfilename.log
	echo "" >> $(pwd)/LOG/security/$logfilename.log
}

function Initialize()
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
				clear
            	exit
            	;;
        255)
            	exit
            	;;
    	esac
}

# 실제 동작 함수
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

# main 함수 실행
main

# 로그파일 마지막에 추가
echo "******************************************************************************" >> $(pwd)/LOG/security/$logfilename.log
echo "  # Exit the Cloud Security Setting                                        " >> $(pwd)/LOG/security/$logfilename.log
echo "******************************************************************************" >> $(pwd)/LOG/security/$logfilename.log

sed -i 's/\\n//g' $(pwd)/LOG/security/$logfilename.log
echo ""
#End of Shell Script

