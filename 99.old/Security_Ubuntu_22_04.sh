#!/bin/sh

################################################

# Update : 2024-01-17
# Cloud Security Setting Scripts(Ubuntu Linux 22.04)
# TEST CSP : AWS
# by Kim, Mijeong

################################################

## READ ME
## 실행 방법 : bash 파일명


## 수정 내역
### 기존 명령어 함수로 묶음
### 설정 파일 백업 추가
### 스크립트 결과 출력 추가
###  -> Before : 스크립트 결과 로그파일에만 저장
###  -> After  : 스크립트 실행 후 로그파일 출력
### 스크립트 기능을 취약점 분석과 조치로 나눔
###  -> Before : 스크립트 실행 시 바로 조치
###	 -> After  : 스크립트 실행 시 분석 내용만 출력 하도록 수정
###	 -> After  : 조치 여부는 사용자가 결정하도록 수정
### 원복 기능 추가 (미완)
### 기능 함수 추가

## 취약첨 항목 현황
### U-01	|	완료
### U-02	|	
### U-03	|	완료
### U-04	|	완료
### U-05	|	
### U-06	|	
### U-07	|	
### U-08	|	완료
### U-09	|	완료
### U-10	|	완료
### U-11	|	완료
### U-12	|	완료
### U-13	|	완료
### U-14	|	
### U-15	|	완료
### U-16	|	
### U-17	|	완료
### U-18	|	
### U-19	|	완료
### U-20	|	
### U-21	|	
### U-22	|	
### U-23	|	
### U-24	|	
### U-25	|	
### U-26	|	
### U-27	|	
### U-28	|	
### U-29	|	
### U-30	|	
### U-31	|	
### U-32	|	
### U-33	|	
### U-34	|	
### U-35	|	수동 조치
### U-36	|	수동 조치

################################################

## 원본
#echo -e "***********************************************" >> $log_file
#echo -e "* 클라우드 취약점 점검/조치(2021)-Ubuntu22.04 *" >> $log_file
#echo -e "*               by Kim, Mijeong on 12, 2023 *" >> $log_file
#echo -e "***********************************************\n" >> $log_file


# 로그 파일 헤더 부분 -> 함수화
function Log_header() {
	echo -e "***********************************************" >> $log_file
	echo -e "* 클라우드 취약점 점검/조치(2021)-Ubuntu22.04 *" >> $log_file
#
########### 스크립트에 본인 이름 그렇게 넣고 싶으셨나요?ㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋㅋ
########### 주석으로 넣어 놓는게 더 간지가 납니다. 위쪽에 넣어드렸어요.
	echo -e "*               by Kim, Mijeong on 12, 2023 *" >> $log_file
	echo -e "***********************************************\n" >> $log_file
}


function Execute_Log_header() {
        echo -e "***********************************************" >> $execute_log_file
        echo -e "* 클라우드 취약점 점검/조치(2021)-Ubuntu22.04 *" >> $execute_log_file
        echo -e "*               by Kim, Mijeong on 12, 2023 *" >> $execute_log_file
        echo -e "*               취약점 조치 결과            *" >> $execute_log_file
        echo -e "***********************************************\n" >> $execute_log_file
}




################################################

# 변수 정리

################################################

# 현재 날짜를 포맷팅하여 저장
current_date=$(date '+%Y-%m-%d_%H-%M-%S')

# 스크립트 실행 위치 저장하는 변수
#PWD=$(pwd)

# 취약점 조치 로깅
#  log_file_path="/root/security_script_log" # 변수에 로그파일 위치 지정 
## 수정 : 스크립트 파일 위치에 로그 저장하도록
log_file_path="$(pwd)/security_script_log" # 변수에 로그파일 위치 지정 
[ -d "$log_file_path" ] || mkdir "$log_file_path" # 로그파일 저장 경로가 없다면 생성

#  log_file="/root/security_script_log/security_script_log_$current_date.txt"
## 수정 : 스크립트 파일 위치에 로그 저장하도록
log_file="$log_file_path/security_script_log_$current_date.txt"

## 추가
execute_log_file="$log_file_path/execute_log_$current_date.txt"

# 취약점 파일 경로 
## hosts_equiv_file="/etc/hosts.equiv"
hosts_equiv_file="/etc/hosts.equiv"
rhosts_file="/home/.rhosts"

# 파일 소유자 및 권한
owner_root="root"
permission_644="644"
permission_400="400"




### 취약점 조치 설정 파일 원복 백업 절차 필요

## 백업 파일 저장 경로 생성
[ -d "$(pwd)/BACKUP" ] || mkdir "BACKUP"

## 취약점 조치 설정 원본 파일 백업
function filebackup()
{
        if [ -e $(pwd)/BACKUP/$1 ]
        then
                echo -e "\t$3 Backup Exists    : $2 -> ./BACKUP/$1" >> $log_file
        else
                \cp -r $2 $(pwd)/BACKUP/$1
                if [ -e $(pwd)/BACKUP/$1 ]
                then
                        echo -e "\t$3 Backup Completed : $2 -> ./BACKUP/$1" >> $log_file
                else
                        echo -e "\t$3 Backup Fail" >> $log_file
                fi
        fi
}



##########################################################################################################
#
### U-01 / 완료
#
##########################################################################################################

## 원본 코드
### echo -e " U-01. root 계정 원격 접속 제한(/etc/ssh/sshd_config)"  >> $log_file
### sshd_config_file="/etc/ssh/sshd_config"
### 
### # 현재 PermitRootLogin 값
### PermitRootLogin_value=$(grep "^PermitRootLogin" $sshd_config_file | awk '{print $2}')
### 
### # PermitRootLogin 값 비교하여 'no'로 변경
### if [ -z "$PermitRootLogin_value" ]; then
###     sed -i'' -r -e "/#PermitRootLogin prohibit-password/a\PermitRootLogin no" $sshd_config_file
###     echo -e "\tPermitRootLogin 값이 no로 변경되었습니다.\n\n" >> $log_file
### elif [ "$PermitRootLogin_value" = "no" ]; then
###     echo -e "\tPermitRootLogin 값이 no로 설정되어 있습니다.\n\n" >> $log_file
### else
###     sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' $sshd_config_file
###     echo -e "\tPermitRootLogin 값이 yes에서 no로 변경되었습니다.\n\n" >> $log_file
### fi

## 위에 코드 함수화
function U-01()
{
	echo -e " U-01. root 계정 원격 접속 제한(/etc/ssh/sshd_config)"  >> $log_file
	
	## 설정 파일 백업 수행
	###filebackup sshd_config /etc/ssh/sshd_config "File Backup :"
	
	sshd_config_file="/etc/ssh/sshd_config"

	# 현재 PermitRootLogin 값
	PermitRootLogin_value=$(grep "^PermitRootLogin" $sshd_config_file | awk '{print $2}')

	###PermitRootLogin 값 비교하여 'no'로 변경
	if [ -z "$PermitRootLogin_value" ]; then
		###sed -i'' -r -e "/#PermitRootLogin prohibit-password/a\PermitRootLogin no" $sshd_config_file
		echo -e "\tU-01 : 취약\n\n" >> $log_file
	elif [ "$PermitRootLogin_value" = "no" ]; then
		echo -e "\tU-01 : 양호\n\n" >> $log_file
	else
		###sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' $sshd_config_file
		echo -e "\tU-01 : 취약\n\n" >> $log_file
	fi
	
	echo -e "Step : U-01. root 계정 원격 접속 제한(/etc/ssh/sshd_config)"
}

function U-01_execute()
{
    echo -e " U-01. root 계정 원격 접속 제한(/etc/ssh/sshd_config)"  >> $execute_log_file

    ## 설정 파일 백업 수행
    filebackup sshd_config /etc/ssh/sshd_config "File Backup :"

    sshd_config_file="/etc/ssh/sshd_config"

    # 현재 PermitRootLogin 값
    PermitRootLogin_value=$(grep "^PermitRootLogin" $sshd_config_file | awk '{print $2}')

    # PermitRootLogin 값 비교하여 'no'로 변경
    if [ -z "$PermitRootLogin_value" ]; then
            sed -i'' -r -e "/#PermitRootLogin prohibit-password/a\PermitRootLogin no" $sshd_config_file
            echo -e "\tPermitRootLogin 값이 no로 변경되었습니다.\n\n" >> $execute_log_file
    elif [ "$PermitRootLogin_value" = "no" ]; then
            echo -e "\tPermitRootLogin 값이 no로 설정되어 있습니다.\n\n" >> $execute_log_file
    else
            sed -i 's/^PermitRootLogin yes/PermitRootLogin no/' $sshd_config_file
            echo -e "\tPermitRootLogin 값이 yes에서 no로 변경되었습니다.\n\n" >> $execute_log_file
    fi

    echo -e "Step : U-01. root 계정 원격 접속 제한(/etc/ssh/sshd_config)"
}


##########################################################################################################
#
### U-02 / pam_pwquality.so 설치 해야됨 / 적용하는 명령어도 따로 해줘야됨
#
##########################################################################################################

## 원본 코드
###   echo -e " U-02. 패스워드 복잡성 설정(/etc/pam.d/common-password)"  >> $log_file
###   common_password_file="/etc/pam.d/common-password"
###   
###   # 계정 잠금 임계값 설정
###   PwdComplexity="password\trequisite\t\t\tpam_pwquality.so enforce_for_root retry=3 minlen=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1"
###   
###   # 복잡성 설정 있는지 확인 후 없으면 추가
###   if [ `cat $common_password_file | grep "password" | grep "requisite" | grep "pam_pwquality.so enforce_for_root retry=3 minlen=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1" | wc -l` -eq 1 ]
###   then
###       echo -e "\t패스워드 복잡성이 설정되어 있습니다.\n\n" >> $log_file
###   else
###       # 문자열이 존재하지 않으면 찾아서 그 뒤에 추가   
###       sed -i'' -r -e "/password\s+requisite\s+pam_deny.so/a\\$PwdComplexity" "$common_password_file"
###       echo -e "\t패스워드 복잡성 설정이 추가 되었습니다.\n\n" >> $log_file
###   fi

## 함수화
function U-02()
{
	apt-get -y install libpam-pwquality # pwquality 사용을 위해 설치 필요
	# dpkg -l | grep libpam-pwquality / 패키지 설치 되어있는지 확인 명령어
	
	echo -e " U-02. 패스워드 복잡성 설정(/etc/pam.d/common-password)"  >> $log_file
	
	## 설정 파일 백업 수행
	filebackup common-password /etc/pam.d/common-password "File Backup :"
	
	common_password_file="/etc/pam.d/common-password"
	
	# 계정 잠금 임계값 설정
	PwdComplexity="password\trequisite\t\t\tpam_pwquality.so enforce_for_root retry=3 minlen=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1"
	
	# 복잡성 설정 있는지 확인 후 없으면 추가
	if [ `cat $common_password_file | grep "password" | grep "requisite" | grep "pam_pwquality.so enforce_for_root retry=3 minlen=8 dcredit=-1 ucredit=-1 lcredit=-1 ocredit=-1" | wc -l` -eq 1 ]
	then
		echo -e "\t패스워드 복잡성이 설정되어 있습니다.\n\n" >> $log_file
	else
		# 문자열이 존재하지 않으면 찾아서 그 뒤에 추가   
		sed -i'' -r -e "/password\s+requisite\s+pam_deny.so/a\\$PwdComplexity" "$common_password_file"
		echo -e "\t패스워드 복잡성 설정이 추가 되었습니다.\n\n" >> $log_file
	fi
	echo -e "Step : U-02. 패스워드 복잡성 설정(/etc/pam.d/common-password)"
}

##########################################################################################################
#
### U-03 완료
#
##########################################################################################################

## 원본 코드
### echo " U-03. 계정 잠금 임계값 설정(/etc/pam.d/common-auth)"  >> $log_file
### common_auth_file="/etc/pam.d/common-auth"
### 
### # 계정 잠금 임계값 설정
### AccountLockCritical="auth\trequired\t\t\tpam_faillock.so deny=10 unlock_time=120"
### 
### # 복잡성 설정 있는지 확인 후 없으면 추가
### if [ `cat $common_auth_file | grep "auth" | grep "required" | grep "pam_faillock.so deny=10 unlock_time=120" | wc -l` -eq 1 ]
### then
###     echo -e "\t계정 잠금 임계값이 설정되어 있습니다.\n\n" >> $log_file
### else
###     # 문자열이 존재하지 않으면 찾아서 그 뒤에 추가
###     sed -i'' -r -e "/auth\s+required\s+pam_permit.so/a\\$AccountLockCritical" "$common_auth_file"
###     echo -e "\t계정 잠금 임계값 설정이 추가 되었습니다.\n\n" >> $log_file
### fi

## 함수화
function U-03()
{
	echo " U-03. 계정 잠금 임계값 설정(/etc/pam.d/common-auth)"  >> $log_file
	
	## 설정 파일 백업 수행
	###filebackup common-auth /etc/pam.d/common-auth "File Backup :"
	
	common_auth_file="/etc/pam.d/common-auth"

	# 계정 잠금 임계값 설정
	AccountLockCritical="auth\trequired\t\t\tpam_faillock.so deny=10 unlock_time=120"

	# 복잡성 설정 있는지 확인 후 없으면 추가
	if [ `cat $common_auth_file | grep "auth" | grep "required" | grep "pam_faillock.so deny=10 unlock_time=120" | wc -l` -eq 1 ]
	then
		echo -e "\tU-03 : 양호\n\n" >> $log_file
	else
		# 문자열이 존재하지 않으면 찾아서 그 뒤에 추가
		###sed -i'' -r -e "/auth\s+required\s+pam_permit.so/a\\$AccountLockCritical" "$common_auth_file"
		echo -e "\tU-03 : 취약\n\n" >> $log_file
	fi
	echo -e "Step : U-03. 계정 잠금 임계값 설정(/etc/pam.d/common-auth)"
}

function U-03_execute()
{
	echo " U-03. 계정 잠금 임계값 설정(/etc/pam.d/common-auth)"  >> $execute_log_file
	
	## 설정 파일 백업 수행
	filebackup common-auth /etc/pam.d/common-auth "File Backup :"
	
	common_auth_file="/etc/pam.d/common-auth"

	# 계정 잠금 임계값 설정
	AccountLockCritical="auth\trequired\t\t\tpam_faillock.so deny=10 unlock_time=120"

	# 복잡성 설정 있는지 확인 후 없으면 추가
	if [ `cat $common_auth_file | grep "auth" | grep "required" | grep "pam_faillock.so deny=10 unlock_time=120" | wc -l` -eq 1 ]
	then
		echo -e "\t계정 잠금 임계값이 설정되어 있습니다.\n\n" >> $execute_log_file
	else
		# 문자열이 존재하지 않으면 찾아서 그 뒤에 추가
		sed -i'' -r -e "/auth\s+required\s+pam_permit.so/a\\$AccountLockCritical" "$common_auth_file"
		echo -e "\t계정 잠금 임계값 설정이 추가 되었습니다.\n\n" >> $execute_log_file
	fi
	echo -e "Step : U-03. 계정 잠금 임계값 설정(/etc/pam.d/common-auth)"
}


##########################################################################################################
#
### U-04 완료
#
##########################################################################################################

## 원본 코드
### echo " U-04. 패스워드 최대 사용 기간 설정(/etc/login.defs)"  >> $log_file
### login_defs_file="/etc/login.defs"
### PASS_MAX_DAYS_value="PASS_MAX_DAYS\t90"
### 
### # awk를 사용하여 PASS_MAX_DAYS 값을 확인하고 변경
### awk -v PASS_MAX_DAYS_value="$PASS_MAX_DAYS_value" '$1 == "PASS_MAX_DAYS" && $2 != 90 {$2 = 90} {print $0}' "$login_defs_file" > temp_file && mv temp_file "$login_defs_file"
### 
### echo -e "\tPASS_MAX_DAYS 값을 90으로 변경하였습니다.\n\n"  >> $log_file

## 함수화
function U-04()
{
	echo " U-04. 패스워드 최대 사용 기간 설정(/etc/login.defs)"  >> $log_file
	
	## 설정 파일 백업 수행
	###filebackup login.defs /etc/login.defs "File Backup :"
	
	login_defs_file="/etc/login.defs"
	####PASS_MAX_DAYS_value="PASS_MAX_DAYS\t90"

	PASS_MAX_DAYS_value=$(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#' |awk '{print $2}')
	### awk를 사용하여 PASS_MAX_DAYS 값을 확인하고 변경
	###awk -v PASS_MAX_DAYS_value="$PASS_MAX_DAYS_value" '$1 == "PASS_MAX_DAYS" && $2 != 90 {$2 = 90} {print $0}' "$login_defs_file" > temp_file && mv temp_file "$login_defs_file"
	
	if [ $PASS_MAX_DAYS_value == 90 ]
	then
		echo -e "\tU-04 : 양호\n\n"  >> $log_file
	else
		echo -e "\tU-04 : 취약\n\n"  >> $log_file
	fi

	###echo -e "\tPASS_MAX_DAYS 값을 90으로 변경하였습니다.\n\n"  >> $log_file
	echo -e "Step : U-04. 패스워드 최대 사용 기간 설정(/etc/login.defs)"
}

function U-04_execute()
{
	echo " U-04. 패스워드 최대 사용 기간 설정(/etc/login.defs)"  >> $execute_log_file
	
	## 설정 파일 백업 수행
	filebackup login.defs /etc/login.defs "File Backup :"
	
	login_defs_file="/etc/login.defs"
	PASS_MAX_DAYS_value=$(cat /etc/login.defs | grep PASS_MAX_DAYS | grep -v '#' |awk '{print $2}')

	#### awk를 사용하여 PASS_MAX_DAYS 값을 확인하고 변경
	###awk -v PASS_MAX_DAYS_value="$PASS_MAX_DAYS_value" '$1 == "PASS_MAX_DAYS" && $2 != 90 {$2 = 90} {print $0}' "$login_defs_file" > temp_file && mv temp_file "$login_defs_file"
	

	if [ $PASS_MAX_DAYS_value == 90 ]
	then
		echo -e "\tPASS_MAX_DAYS 값이 이미 90 입니다..\n\n"  >> $execute_log_file

    else
        sed -i "s/PASS_MAX_DAYS $PASS_MAX_DAYS_value/PASS_MAX_DAYS      90/g" $login_defs_file
		echo -e "\tPASS_MAX_DAYS 값을 90으로 변경하였습니다.\n\n"  >> $execute_log_file
    fi


	#echo -e "\tPASS_MAX_DAYS 값을 90으로 변경하였습니다.\n\n"  >> $execute_log_file
	echo -e "Step : U-04. 패스워드 최대 사용 기간 설정(/etc/login.defs)"
}

##########################################################################################################
#
### U-05 / 조치 스크립트 짜야됨
#
##########################################################################################################

## 원본 코드
### echo -e " U-05. 패스워드 파일 보호" >> $log_file
### echo -e "\t1) /etc/shadow 파일 존재 여부" >> $log_file
### shadow_file="/etc/shadow"
### if [ -e "$shadow_file" ]; then
###     echo -e "\t/etc/shadow 파일 존재합니다.\n" >> $log_file
### else
###     echo -e "\t경고: /etc/shadow 파일이 존재하지 않습니다.\n" >> $log_file
### fi
### 
### echo -e "\t2) 사용자 패스워드가 암호화되어 저장되어 있는지 확인" >> $log_file
### passwd_file="/etc/passwd"
### # 비밀번호가 암호화 되어 있는 계정 수
### encrypted_count=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)
### # 전체 계정 수
### total_accounts=$(grep -c -v '^$' "$passwd_file")
### 
### # 모든 계정이 "x"로 설정되어 있는지 확인
### if [ "$encrypted_count" -eq "$total_accounts" ]; then
###     echo -e "\t모든 계정이 암호화되어 저장되고 있습니다.\n\n" >> $log_file
### else
###     echo -e "\t다음은 \"x\"로 설정되지 않은 계정입니다:" >> $log_file
###     awk -F: '$2 != "x" {print $1}' $passwd_file  >> $log_file
###     echo -e "\n\n"
### fi

## 함수화
function U-05()
{
	echo -e " U-05. 패스워드 파일 보호" >> $log_file
	
	## 설정 파일 백업 수행
	###filebackup shadow /etc/shadow "File Backup :"
	
	echo -e "\t1) /etc/shadow 파일 존재 여부" >> $log_file
	shadow_file="/etc/shadow"
	if [ -e "$shadow_file" ]; then
		echo -e "\t/etc/shadow 파일 존재합니다.\n" >> $log_file
	else
		echo -e "\t경고: /etc/shadow 파일이 존재하지 않습니다.\n" >> $log_file
	fi

	echo -e "\t2) 사용자 패스워드가 암호화되어 저장되어 있는지 확인" >> $log_file
	passwd_file="/etc/passwd"
	
	# 비밀번호가 암호화 되어 있는 계정 수
	encrypted_count=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)
	
	# 전체 계정 수
	total_accounts=$(grep -c -v '^$' "$passwd_file")

	# 모든 계정이 "x"로 설정되어 있는지 확인
	if [ "$encrypted_count" -eq "$total_accounts" ]; then
		echo -e "\t모든 계정이 암호화되어 저장되고 있습니다.\n\n" >> $log_file
	else
		echo -e "\t다음은 \"x\"로 설정되지 않은 계정입니다:" >> $log_file
		awk -F: '$2 != "x" {print $1}' $passwd_file  >> $log_file
    echo -e "\n\n"
	fi
	echo -e "Step : U-05. 패스워드 파일 보호"
}



##########################################################################################################
#
### U-06 / 잘못 됨 / 조치를 해야되나?
#
##########################################################################################################
echo -e " U-06. root 홈, 패스 디렉터리 권한 및 패스 설정" >> $log_file
# 환경변수를 :를 기준으로 나누어 배열로 저장
IFS=':' read -ra envPath <<< "$PATH" ## 이거 안됨

# 정상적인지 여부를 나타내는 플래그
valid=true

# 등록된 모든 환경변수 확인
for envpath in "${envPath[@]}"; do
    if [[ "$envpath" == "." || "$envpath" == *":."* ]]; then
        echo -e "\t비정상적으로 등록된 환경변수 : $envpath" >> $log_file
        valid=false
    fi
done

if $valid; then
    echo -e "\t모든 환경변수가 정상적으로 등록되어 있습니다.\n\n" >> $log_file
fi


##########################################################################################################
#
### U-07 / 조치 필요 없음
#
##########################################################################################################

## 원본 코드
### echo -e " U-07. 파일 및 디렉터리 소유자 설정"  >> $log_file
### # 소유자나 그룹이 존재하지 않는 파일 찾기
### find_nouser=$(find / -nouser 2>/dev/null)
### find_nogroup=$(find / -nogroup 2>/dev/null)
### 
### if [ -z "$find_nouser" ] && [ -z "$find_nogroup" ]; then
###     echo -e "\t'/' 하위에 소유자나 그룹이 없는 파일 및 디렉토리는 없습니다.\n\n" >> $log_file
### 
### else
###     echo -e "\t소유자나 그룹이 존재하지 않는 파일:"
###     # 소유자 없는 파일 및 디렉토리
###     if [ -n "$find_nouser" ]; then
###         echo "\tnouser: $find_nouser" >> $log_file
###     fi
### 
###     # 그룹이 없는 파일 및 디렉토리
###     if [ -n "$find_nogroup" ]; then
###         echo -e "\tnogroup: $find_nogroup" >> $log_file
###     fi
###     echo -e "\n\n" >> $log_file
### fi

function U-07()
{
	echo -e " U-07. 파일 및 디렉터리 소유자 설정"  >> $log_file
	
	## 설정 파일 백업 수행 필요 없음
	
	# 소유자나 그룹이 존재하지 않는 파일 찾기
	find_nouser=$(find / -nouser 2>/dev/null)
	find_nogroup=$(find / -nogroup 2>/dev/null)

	if [ -z "$find_nouser" ] && [ -z "$find_nogroup" ]; then
		echo -e "\t'/' 하위에 소유자나 그룹이 없는 파일 및 디렉토리는 없습니다.\n\n" >> $log_file

	else
		echo -e "\t소유자나 그룹이 존재하지 않는 파일:"
		# 소유자 없는 파일 및 디렉토리
		if [ -n "$find_nouser" ]; then
			echo "\tnouser: $find_nouser" >> $log_file
		fi

		# 그룹이 없는 파일 및 디렉토리
		if [ -n "$find_nogroup" ]; then
			echo -e "\tnogroup: $find_nogroup" >> $log_file
		fi
		echo -e "\n\n" >> $log_file
	fi
	echo -e "Step : U-07. 파일 및 디렉터리 소유자 설정"
}


##########################################################################################################
#
### U-08 됨 /
#
##########################################################################################################

## 원본코드
### echo -e " U-08. /etc/passwd 파일 소유자 및 권한 설정"  >> $log_file
### Update_owner_permission() {
###   local filePath=$1
###   local owner=$2
###   local permission=$3
### 
###   # 파일 존재 여부 확인
###   if [ -e "$filePath" ]; then
###     # 현재 소유자와 권한 확인   
###     current_owner=$(stat -c %U "$filePath")
###     current_permission=$(stat -c %a "$filePath")
### 
###     # 현재 소유자와 권한이 이미 설정되어 있는 경우
###     if [ "$current_owner" = "$owner" ] && [ "$current_permission" = "$permission" ]; then
###       echo -e "\t$filePath 파일은 소유자 $owner, 권한 $permission으로 설정되어 있습니다." >> $log_file
###     else
###       # 소유자와 권한 변경
###       sudo chown "$owner" "$filePath"
###       sudo chmod "$permission" "$filePath"
###       current_owner=$(stat -c %U "$filePath")
###       current_permission=$(stat -c %a "$filePath")
### 
###       echo -e "\t$filePath 파일의 소유자와 권한을 변경했습니다." >> $log_file
###       echo -e "\t현재 소유자: $current_owner, 현재 권한: $current_permission" >> $log_file
### 
###     fi
###   else
###     echo -e "\t$filePath 파일이 존재하지 않습니다." >> $log_file
###   fi
###   echo -e "\n\n" >> $log_file
### }
### Update_owner_permission "/etc/passwd" "root" "644"

## 기존 함수 사용
Update_owner_permission() {
  local filePath=$1
  local owner=$2
  local permission=$3

  # 파일 존재 여부 확인
  if [ -e "$filePath" ]; then
    # 현재 소유자와 권한 확인   
    current_owner=$(stat -c %U "$filePath")
    current_permission=$(stat -c %a "$filePath")

    # 현재 소유자와 권한이 이미 설정되어 있는 경우
    if [ "$current_owner" = "$owner" ] && [ "$current_permission" = "$permission" ]; then
      echo -e "\t$filePath 파일은 소유자 $owner, 권한 $permission으로 설정되어 있습니다." >> $log_file
    else
      # 소유자와 권한 변경
      sudo chown "$owner" "$filePath"
      sudo chmod "$permission" "$filePath"
      current_owner=$(stat -c %U "$filePath")
      current_permission=$(stat -c %a "$filePath")

      echo -e "\t$filePath 파일의 소유자와 권한을 변경했습니다." >> $log_file
      echo -e "\t현재 소유자: $current_owner, 현재 권한: $current_permission" >> $log_file

    fi
  else
    echo -e "\t$filePath 파일이 존재하지 않습니다." >> $log_file
  fi
  echo -e "\n\n" >> $log_file
}

Chcek_permission()
{
  local filePath=$1
  local owner=$2
  local permission=$3

  # 파일 존재 여부 확인
  if [ -e "$filePath" ]; then
    # 현재 소유자와 권한 확인   
    current_owner=$(stat -c %U "$filePath")
    current_permission=$(stat -c %a "$filePath")
	echo -e "\t현재 소유자: $current_owner, 현재 권한: $current_permission" >> $log_file
  else
    echo -e "\t$filePath 파일이 존재하지 않습니다." >> $log_file
  fi
  #echo -e "\n\n" >> $log_file
}

Execute_Update_permission()
{
  local filePath=$1
  local owner=$2
  local permission=$3

  # 파일 존재 여부 확인
  if [ -e "$filePath" ]; then
    # 현재 소유자와 권한 확인   
    current_owner=$(stat -c %U "$filePath")
    current_permission=$(stat -c %a "$filePath")

    # 현재 소유자와 권한이 이미 설정되어 있는 경우
    if [ "$current_owner" = "$owner" ] && [ "$current_permission" = "$permission" ]; then
      echo -e "\t$filePath 파일은 소유자 $owner, 권한 $permission으로 설정되어 있습니다." >> $execute_log_file
    else
      # 소유자와 권한 변경
      sudo chown "$owner" "$filePath"
      sudo chmod "$permission" "$filePath"
      current_owner=$(stat -c %U "$filePath")
      current_permission=$(stat -c %a "$filePath")

      echo -e "\t$filePath 파일의 소유자와 권한을 변경했습니다." >> $execute_log_file
      echo -e "\t현재 소유자: $current_owner, 현재 권한: $current_permission" >> $execute_log_file

    fi
  else
    echo -e "\t$filePath 파일이 존재하지 않습니다." >> $execute_log_file
  fi
  #echo -e "\n\n" >> $execute_log_file
}

## 함수화
function U-08()
{
	echo -e " U-08. /etc/passwd 파일 소유자 및 권한 설정"  >> $log_file
	## 설정 파일 백업 수행
	### filebackup passwd /etc/passwd "File Backup :"
	Chcek_permission "/etc/passwd" "root" "644"
	echo -e "Step : U-08. /etc/passwd 파일 소유자 및 권한 설정"
}

function U-08_execute()
{
	echo -e " U-08. /etc/passwd 파일 소유자 및 권한 설정"  >> $execute_log_file
	## 설정 파일 백업 수행
	filebackup passwd /etc/passwd "File Backup :"
	Execute_Update_permission "/etc/passwd" "root" "644"
	echo -e "Step : U-08. /etc/passwd 파일 소유자 및 권한 설정"
}

##########################################################################################################
#
### U-09 됨
#
##########################################################################################################

## 원본코드
### echo -e " U-09. /etc/shadow 파일 소유자 및 권한 설정"  >> $log_file
### Update_owner_permission "/etc/shadow" "root" "644"

## 함수화
function U-09()
{
	echo -e " U-09. /etc/shadow 파일 소유자 및 권한 설정"  >> $log_file
	## 설정 파일 백업 수행
	###filebackup shadow /etc/shadow "File Backup :"
	Chcek_permission "/etc/passwd" "root" "644"
	echo -e "Step : U-09. /etc/shadow 파일 소유자 및 권한 설정"
}

function U-09_execute()
{
	echo -e " U-09. /etc/shadow 파일 소유자 및 권한 설정"  >> $execute_log_file
	## 설정 파일 백업 수행
	filebackup shadow /etc/shadow "File Backup :"
	Execute_Update_permission "/etc/passwd" "root" "644"
	echo -e "Step : U-09. /etc/shadow 파일 소유자 및 권한 설정"
}

##########################################################################################################
#
### U-10 됨
#
##########################################################################################################

## 원본코드
### echo -e " U-10. /etc/hosts 파일 소유자 및 권한 설정"  >> $log_file
### Update_owner_permission "/etc/hosts" "root" "644"


## 함수화
function U-10()
{
	echo -e " U-10. /etc/hosts 파일 소유자 및 권한 설정"  >> $log_file
	###filebackup hosts /etc/hosts "File Backup :"
	Chcek_permission "/etc/hosts" "root" "644"
	echo -e "Step : U-10. /etc/hosts 파일 소유자 및 권한 설정"
}

function U-10_execute()
{
	echo -e " U-10. /etc/hosts 파일 소유자 및 권한 설정"  >> $execute_log_file
	filebackup hosts /etc/hosts "File Backup :"
	Execute_Update_permission "/etc/hosts" "root" "644"
	echo -e "Step : U-10. /etc/hosts 파일 소유자 및 권한 설정"
}

##########################################################################################################
#
### U-11 됨
#
##########################################################################################################

## 원본코드
### echo -e " U-11. /etc/(x)inetd.conf 파일 소유자 및 권한 설정"  >> $log_file
### Update_owner_permission "/etc/xinetd.conf" "root" "664"

## 함수화
function U-11()
{
	echo -e " U-11. /etc/(x)inetd.conf 파일 소유자 및 권한 설정"  >> $log_file
	###filebackup xinetd.conf /etc/xinetd.conf "File Backup :"
	Chcek_permission "/etc/xinetd.conf" "root" "664"
	echo -e "Step : U-11. /etc/(x)inetd.conf 파일 소유자 및 권한 설정"
}

function U-11_execute()
{
	echo -e " U-11. /etc/(x)inetd.conf 파일 소유자 및 권한 설정"  >> $execute_log_file
	filebackup xinetd.conf /etc/xinetd.conf "File Backup :"
	Execute_Update_permission "/etc/xinetd.conf" "root" "664"
	echo -e "Step : U-11. /etc/(x)inetd.conf 파일 소유자 및 권한 설정"
}

##########################################################################################################
#
### U-12
#
##########################################################################################################

## 원본코드
### echo -e " U-12. /etc/(r)syslog.conf 파일 소유자 및 권한 설정"  >> $log_file
### Update_owner_permission "/etc/rsyslog.conf" "root" "644"

function U-12()
{
	echo -e " U-12. /etc/(r)syslog.conf 파일 소유자 및 권한 설정"  >> $log_file
	###filebackup rsyslog.conf /etc/rsyslog.conf "File Backup :"
	Chcek_permission "/etc/rsyslog.conf" "root" "644"
	echo -e "Step : U-12. /etc/(r)syslog.conf 파일 소유자 및 권한 설정"
}

function U-12_execute()
{
	echo -e " U-12. /etc/(r)syslog.conf 파일 소유자 및 권한 설정"  >> $execute_log_file
	filebackup rsyslog.conf /etc/rsyslog.conf "File Backup :"
	Execute_Update_permission "/etc/rsyslog.conf" "root" "644"
	echo -e "Step : U-12. /etc/(r)syslog.conf 파일 소유자 및 권한 설정"
}

##########################################################################################################
#
### U-13 됨
#
##########################################################################################################

## 원본코드
### echo -e " U-13. /etc/services 파일 소유자 및 권한 설정"  >> $log_file
### Update_owner_permission "/etc/services" "root" "644"

function U-13()
{
	echo -e " U-13. /etc/services 파일 소유자 및 권한 설정"  >> $log_file
	###filebackup services /etc/services "File Backup :"
	Chcek_permission "/etc/services" "root" "644"
	echo -e "Step : U-13. /etc/services 파일 소유자 및 권한 설정"
}

function U-13_execute()
{
	echo -e " U-13. /etc/services 파일 소유자 및 권한 설정"  >> $execute_log_file
	filebackup services /etc/services "File Backup :"
	Execute_Update_permission "/etc/services" "root" "644"
	echo -e "Step : U-13. /etc/services 파일 소유자 및 권한 설정"
}

##########################################################################################################
#
### U-14 / 점검 필요 / OS 파일 건들여야됨
#
##########################################################################################################

## 원본코드
### echo -e " U-14. SUID, SGID, Sticky bit 설정 파일 점검"  >> $log_file
### # find 명령어 실행 및 결과를 파일에 저장
### find_stickyBit=$(find / -user root -type f \( -perm -4000 -o -perm -2000 \) -exec ls -lg {} \; 2>/dev/null)
### 
### # 결과가 있는지 확인 후 처리
### if [ -n "$find_stickyBit" ]; then
###     echo -e ">> SUID, SGID, Sticky bit 설정 되어 있는 파일 목록" >> $log_file
###     echo -e "$find_stickyBit" >> $log_file
###     echo -e "\n" >> $log_file
### else
###     echo -e "정상: 소유자가 root이고 setuid 또는 setgid 비트가 설정된 파일이 없습니다.\n\n" >> $log_file
### fi

function U-14()
{
	echo -e " U-14. SUID, SGID, Sticky bit 설정 파일 점검"  >> $log_file
	## 파일 변경이 아니라 백업 필요 없음
	# find 명령어 실행 및 결과를 파일에 저장
	find_stickyBit=$(find / -user root -type f \( -perm -4000 -o -perm -2000 \) -exec ls -lg {} \; 2>/dev/null)

	# 결과가 있는지 확인 후 처리
	if [ -n "$find_stickyBit" ]; then
		echo -e ">> SUID, SGID, Sticky bit 설정 되어 있는 파일 목록" >> $log_file
		echo -e "$find_stickyBit" >> $log_file
		echo -e "\n" >> $log_file
	else
		echo -e "정상: 소유자가 root이고 setuid 또는 setgid 비트가 설정된 파일이 없습니다.\n\n" >> $log_file
	fi

	echo -e "Step : U-14. SUID, SGID, Sticky bit 설정 파일 점검"
}

function U-14_execute()
{
	echo -e " U-14. SUID, SGID, Sticky bit 설정 파일 점검"  >> $log_file
	## 파일 변경이 아니라 백업 필요 없음
	# find 명령어 실행 및 결과를 파일에 저장
	find_stickyBit=$(find / -user root -type f \( -perm -4000 -o -perm -2000 \) -exec ls -lg {} \; 2>/dev/null)

	# 결과가 있는지 확인 후 처리
	if [ -n "$find_stickyBit" ]; then
		echo -e ">> SUID, SGID, Sticky bit 설정 되어 있는 파일 목록" >> $log_file
		echo -e "$find_stickyBit" >> $log_file
		echo -e "\n" >> $log_file
	else
		echo -e "정상: 소유자가 root이고 setuid 또는 setgid 비트가 설정된 파일이 없습니다.\n\n" >> $log_file
	fi

	echo -e "Step : U-14. SUID, SGID, Sticky bit 설정 파일 점검"
}

##########################################################################################################
#
### U-15 됨 / 멘트 다듬기
#
##########################################################################################################

## 원본코드
### echo -e " U-15. 사용자, 시스템 시작파일 및 환경파일 소유자"  >> $log_file
### echo -e " - 이거 어떻게 점검/조치해야할지 모르것어...\n\n"  >> $log_file


Homedir=(`ls /home`)

function Check_homedir_permission()
{
	for i in "${Homedir[@]}";
    do
		echo -e "$i 홈 디렉터리 권한 : $(stat -c %a /home/$i)"; >> $log_file
		if [ $(stat -c %a /home/$i) == 644 ]
		then
			echo -e "\t$i 홈 디렉터리 권한 양호" >> $log_file
		elif [ $(stat -c %a /home/$i) == 640 ]
			then
				echo -e "\t$i 홈 디렉터리 권한 양호" >> $log_file
		else
				echo -e "\t$i 홈 디렉터리 권한 취약" >> $log_file
		fi
    done
}

function Execute_homedir_permission()
{
	for i in "${Homedir[@]}";
	do
			filebackup $i /home/$i "File Backup :"
			if [ $(stat -c %a /home/$i) == 644 ]
			then
				echo -e "\t$i 홈 디렉터리 권한 이미 644으로 적용 되어있습니다."  >> $execute_log_file
			else
				chmod 0644 /home/$i;
				echo -e "\t$i 홈 디렉터리 권한 644으로 변경 완료"  >> $execute_log_file
			fi	
	done
}

function U-15()
{
	echo -e " U-15. 사용자, 시스템 시작파일 및 환경파일 소유자"  >> $log_file
	Check_homedir_permission
	echo -e "Step : U-15. 사용자, 시스템 시작파일 및 환경파일 소유자"
}

function U-15_execute()
{
	echo -e " U-15. 사용자, 시스템 시작파일 및 환경파일 소유자"  >> $execute_log_file
	Execute_homedir_permission
	echo -e "Step : U-15. 사용자, 시스템 시작파일 및 환경파일 소유자"
}

##########################################################################################################
#
### U-16 안되어 있음
#
##########################################################################################################

## 원본코드
echo -e " U-16. world writable 파일 점검"  >> $log_file
# find / -type f -perm -2 -exec ls -l l {} \;
# find / . ! \( \( -path '/proc' -o -path '/sys' \) -prune \) -type f -perm -2 -exec ls -l {} \;
echo -e "\n\n" >> $log_file

function U-16()
{
	echo -e " U-16. world writable 파일 점검"  >> $log_file

	echo -e "Step : U-16. world writable 파일 점검"
}

##########################################################################################################
#
### U-17 / 됨
#
##########################################################################################################

## 원본코드
### echo -e " U-17. \$HOME/.rhosts, host.equiv 사용 금지"  >> $log_file
### if [ -e "$hosts_equiv_file" ]; then
###     echo -e "\t'$hosts_equiv_file' 조치 필요." >> $log_file
### else
###     echo -e "\t'$hosts_equiv_file' 파일 존재하지 않습니다." >> $log_file
### fi
### 
### if [ -e "$rhosts_file" ]; then
###     echo -e "\t'$rhosts_file' 조치 필요. \n\n" >> $log_file
### else
###     echo -e "\t'$rhosts_file' 파일 존재하지 않습니다. \n\n" >> $log_file
### fi



function Check_file()
{
	if [ -e "$1" ]; then
		echo -e "\t'$1' 조치 필요." >> $log_file
	else
		echo -e "\t'$1' 파일 존재하지 않습니다." >> $log_file
	fi
}

function Delete_file()
{
	fname=$(echo -e "$1" | awk -F / '{print $NF}')

	filebackup $fname $1 "File Backup :"
	

	if [ -e "$hosts_equiv_file" ]; then
		rm -rf $1
		echo -e "\t'$1' 삭제 완료"  >> $execute_log_file
	else
		echo -e "\t'$1' 파일 존재하지 않습니다."  >> $execute_log_file
	fi
}



function U-17()
{
	echo -e " U-17. \$HOME/.rhosts, host.equiv 사용 금지"  >> $log_file
	Check_file $hosts_equiv_file
	Check_file $rhosts_file
	echo -e "Step : U-17. \$HOME/.rhosts, host.equiv 사용 금지"
}

function U-17_execute()
{
	echo -e " U-17. \$HOME/.rhosts, host.equiv 사용 금지"  >> $execute_log_file
	
	Delete_file $hosts_equiv_file
	Delete_file $rhosts_file
	echo -e "Step : U-17. \$HOME/.rhosts, host.equiv 사용 금지"
}


##########################################################################################################
#
### U-18 / hosts.allow hosts.deny 수동 조치가 필요
#
##########################################################################################################

## 원본코드
### echo -e " U-18. 접속 IP 및 포트 제한" >> $log_file
### ufw 비활성화로 변경
###  ufw_status=$(sudo ufw status)
###  
###  if echo "$ufw_status" | grep -q "Status: active"; then
###    sudo systemctl disable --now ufw
###    echo -e "\tUFW가 비활성화 되었습니다." >> $log_file
###  else
###    echo -e "\tUFW가 비활성화 되어있습니다." >> $log_file
###  fi
###  
###  hosts_deny_file="/etc/hosts.deny"
###  if ! grep -q "ALL:ALL" "$hosts_deny_file"; then
###  
###      # 존재하지 않으면 파일 끝에 문자열 추가
###      echo "ALL:ALL" >> "$hosts_deny_file"
###      echo -e "\t$hosts_deny_file에 'All Deny' 설정되었습니다.\n\n" >> $log_file
###  else
###      echo -e "\t$hosts_deny_file에 'ALL Deny'설정이 되어있습니다.\n\n" >> $log_file
###  fi


function Disable_ufw() ## ufw 비활성화 함수
{
# ufw 비활성화로 변경
	ufw_status=$(sudo ufw status)

	if echo "$ufw_status" | grep -q "Status: active"; then
	  sudo systemctl disable --now ufw
	  echo -e "\tUFW가 비활성화 되었습니다." >> $log_file
	else
	  echo -e "\tUFW가 비활성화 되어있습니다." >> $log_file
	fi
}

function U-18()
{
	echo -e " U-18. 접속 IP 및 포트 제한" >> $log_file
	Disable_ufw ## ufw 비활성화 함수
	echo -e "Step : U-18. 접속 IP 및 포트 제한"
}

##########################################################################################################
#
### U-19 됨
#
##########################################################################################################

## 원본코드
### echo -e "● U-19. cron 파일 소유자 및 권한 설정" >> $log_file
### Update_owner_permission "/etc/cron.allow" "root" "640"
### Update_owner_permission "/etc/cron.deny" "root" "640"



function U-19()
{
	echo -e "● U-19. cron 파일 소유자 및 권한 설정" >> $log_file
	
	Chcek_permission "/etc/cron.allow" "root" "640"
	Chcek_permission "/etc/cron.deny" "root" "640"

	echo -e "Step : U-19. cron 파일 소유자 및 권한 설정"
}

function U-19_execute()
{
	echo -e "● U-19. cron 파일 소유자 및 권한 설정" >> $execute_log_file
	
	## 파일 백업
	filebackup cron.allow /etc/cron.allow "File Backup :"
	filebackup cron.deny /etc/cron.deny "File Backup :"
	
	Execute_Update_permission "/etc/cron.allow" "root" "640"
	Execute_Update_permission "/etc/cron.deny" "root" "640"
	
	echo -e "Step : U-19. cron 파일 소유자 및 권한 설정"
}

##########################################################################################################
#
### U-20
#
##########################################################################################################

## 원본코드
### echo -e "● U-20. Finger 서비스 비활성화" >> $log_file
### xinetdService_exists() {
###     local file_path="$1"
### 
###     # 서비스 설정 파일이 존재하는지 확인
###     if [ -e "$file_path" ]; then
###         # 'disable = no'를 'disable = yes'로 교체하는 sed 명령어 실행
###         sed -i 's/\(^[[:space:]]*disable[[:space:]]*=[[:space:]]*\)no/\1yes/g' "$file_path"
###         sudo /etc/init.d/xinetd restart
###         echo -e "\t $file_path 서비스가 비활성화 되었습니다." >> $log_file
###     else
###         echo -e "\t$file_path 파일이 존재하지 않습니다." >> $log_file
###     fi
### }
### xinetdService_exists "/etc/xinetd.d/finger"
### echo -e "\n\n"

xinetdService_exists() ## xinetdService 서비스 비활성화 함수
{
    local file_path="$1"

    # 서비스 설정 파일이 존재하는지 확인
    if [ -e "$file_path" ]; then
        # 'disable = no'를 'disable = yes'로 교체하는 sed 명령어 실행
        sed -i 's/\(^[[:space:]]*disable[[:space:]]*=[[:space:]]*\)no/\1yes/g' "$file_path"
        sudo /etc/init.d/xinetd restart
        echo -e "\t $file_path 서비스가 비활성화 되었습니다." >> $log_file
    else
        echo -e "\t$file_path 파일이 존재하지 않습니다." >> $log_file
    fi
}

Check_xinetdService() ## xinetdService 서비스 비활성화 함수
{
    local file_path="$1"

    # 서비스 설정 파일이 존재하는지 확인
    if [ -e "$file_path" ]; then
        # 'disable = no'를 'disable = yes'로 교체하는 sed 명령어 실행
        #sed -i 's/\(^[[:space:]]*disable[[:space:]]*=[[:space:]]*\)no/\1yes/g' "$file_path"
        #sudo /etc/init.d/xinetd restart
		
        echo -e "\t $file_path 서비스가 비활성화 되었습니다." >> $log_file
    else
        echo -e "\t$file_path 파일이 존재하지 않습니다." >> $log_file
    fi
}

function U-20()
{
	echo -e "● U-20. Finger 서비스 비활성화" >> $log_file
	
	## 파일 백업
	filebackup finger /etc/xinetd.d/finger "File Backup :"
	
	xinetdService_exists "/etc/xinetd.d/finger" ## xinetdService 서비스 비활성화 함수
	
	echo -e "Step : U-20. Finger 서비스 비활성화"
}

##########################################################################################################
#
### U-21
#
##########################################################################################################

## 원본코드
### echo -e "● U-21. Anomymous FTP 비활성화" >> $log_file
### ftp_user="ftp"
### 
### # 'ftp' 계정이 있는지 확인
### if grep -q "^$ftp_user:" /etc/passwd; then
###     # 'ftp' 계정이 있으면 삭제
###     userdel "$ftp_user"
###     echo -e "\t'$ftp_user' 계정을 삭제했습니다." >> $log_file
### else
###     echo -e "\t'$ftp_user' 계정이 존재하지 않습니다." >> $log_file
### fi
### 
### 
### 
### vsftpd_conf="/etc/vsftpd.conf"
### 
### # vsftpd.conf 파일이 존재하는지 확인
### if [ -f "$vsftpd_conf" ]; then
###     # anonymous_enable 설정값 가져오기
###     anonymous_enable=$(awk '/^anonymous_enable/ {print $2}' "$vsftpd_conf")
### 
###     # anonymous_enable이 "NO"로 설정되어 있는지 확인
###     if [ "$anonymous_enable" != "NO" ]; then
###         # anonymous_enable을 "NO"로 변경
###         sed -i 's/^anonymous_enable.*/anonymous_enable=NO/' "$vsftpd_conf"
###         echo -e "\tanonymous_enabler 값이 NO로 설정되었습니다." >> $log_file
###     else
###         echo -e "\tanonymous_enable 값이 NO로 설정되어 있습니다." >> $log_file
###     fi
### else
###     echo -e "\t$vsftpd_conf 파일이 존재하지 않습니다." >> $log_file
### fi
### 
function Check_ftp_user()
{
	ftp_user="ftp"
	# 'ftp' 계정이 있는지 확인
	if grep -q "^$ftp_user:" /etc/passwd; then
		# 'ftp' 계정이 있으면 삭제
		userdel "$ftp_user"
		echo -e "\t'$ftp_user' 계정을 삭제했습니다." >> $log_file
	else
		echo -e "\t'$ftp_user' 계정이 존재하지 않습니다." >> $log_file
	fi
}

function Disable_anonymous()
{
	vsftpd_conf="/etc/vsftpd.conf"

	# vsftpd.conf 파일이 존재하는지 확인
	if [ -f "$vsftpd_conf" ]; then
		# anonymous_enable 설정값 가져오기
		anonymous_enable=$(awk '/^anonymous_enable/ {print $2}' "$vsftpd_conf")

		# anonymous_enable이 "NO"로 설정되어 있는지 확인
		if [ "$anonymous_enable" != "NO" ]; then
			# anonymous_enable을 "NO"로 변경
			sed -i 's/^anonymous_enable.*/anonymous_enable=NO/' "$vsftpd_conf"
			echo -e "\tanonymous_enabler 값이 NO로 설정되었습니다." >> $log_file
		else
			echo -e "\tanonymous_enable 값이 NO로 설정되어 있습니다." >> $log_file
		fi
	else
		echo -e "\t$vsftpd_conf 파일이 존재하지 않습니다." >> $log_file
	fi
}

function U-21()
{
	echo -e "● U-21. Anomymous FTP 비활성화" >> $log_file
	
	## 파일 백업
	filebackup vsftpd.conf /etc/vsftpd.conf "File Backup :"
	
	Check_ftp_user ## ftp 유저 존재 확인 함수
	Disable_anonymous ##  vsftp 설정 중 anonymous 비활성화 함수
	
	echo -e "Step : U-21. Anomymous FTP 비활성화"
}


##########################################################################################################
#
### U-22
#
##########################################################################################################

## 원본코드
### echo -e "● U-22. r 계열 서비스 비활성화" >> $log_file
### xinetdService_exists "/etc/xinetd.d/rsh"
### xinetdService_exists "/etc/xinetd.d/rlogin"
### xinetdService_exists "/etc/xinetd.d/rexec"
### echo -e "\n\n" >> $log_file

function U-22()
{
	echo -e "● U-22. r 계열 서비스 비활성화" >> $log_file
	
	## 파일 백업
	filebackup rsh /etc/xinetd.d/rsh "File Backup :"
	filebackup rlogin /etc/xinetd.d/rlogin "File Backup :"
	filebackup rexec /etc/xinetd.d/rexec "File Backup :"
	
	xinetdService_exists "/etc/xinetd.d/rsh"
	xinetdService_exists "/etc/xinetd.d/rlogin"
	xinetdService_exists "/etc/xinetd.d/rexec"
	
	echo -e "\n\n" >> $log_file
	
	echo -e "Step : U-22. r 계열 서비스 비활성화"
}


##########################################################################################################
#
### U-23
#
##########################################################################################################

## 원본코드
### echo -e "● U-23. Dos 공격에 취약한 서비스 비활성화" >> $log_file
### xinetdService_exists "/etc/xinetd.d/echo"
### xinetdService_exists "/etc/xinetd.d/discard"
### xinetdService_exists "/etc/xinetd.d/daytime"
### xinetdService_exists "/etc/xinetd.d/chargen"
### echo -e "\n\n" >> $log_file

function U-23()
{
	echo -e "● U-23. Dos 공격에 취약한 서비스 비활성화" >> $log_file
	
	## 파일 백업
	filebackup echo /etc/xinetd.d/echo "File Backup :"
	filebackup discard /etc/xinetd.d/discard "File Backup :"
	filebackup daytime /etc/xinetd.d/daytime "File Backup :"
	filebackup chargen /etc/xinetd.d/chargen "File Backup :"
	
	xinetdService_exists "/etc/xinetd.d/echo"
	xinetdService_exists "/etc/xinetd.d/discard"
	xinetdService_exists "/etc/xinetd.d/daytime"
	xinetdService_exists "/etc/xinetd.d/chargen"
	
	echo -e "Step : U-23. Dos 공격에 취약한 서비스 비활성화"
}

##########################################################################################################
#
### U-24 / 확인 필요
#
##########################################################################################################

## 원본코드
echo -e "● U-24. NFS 서비스 비활성화" >> $log_file


function Service_Check() ## 서비스 동작 여부 체크하는 함수
{
	ps -ef | grep $1 | grep -v grep ## 서비스 출력
	
	svc=$(ps -ef | grep $1 | grep -v grep | wc -l) ## 서비스 실행 개수 담는 변수

    if [ $svc == 0 ] ## 실행중인 서비스 개수가 0개면 비활성화 라고 표시 / 그 외에는 실행중이라고 표시
    then
        echo -e "\t $1 서비스는 비활성화 되어 있습니다." >> $log_file
    else
        echo -e "\t $1 서비스는 활성화 되어있습니다." >> $log_file
    fi
}


function Kill_service() ## 서비스 Kill 함수
{
	kill -9 $(ps -ef | grep $1 | grep -v grep | awk '{print $2}')
}

function U-24()
{
	echo -e "● U-24. NFS 서비스 비활성화" >> $log_file
	
	Service_Check nfsd ## nfsd 서비스 체크
}

function U-24_execute()
{
	Kil_service nfsd
}

##########################################################################################################
#
### U-25
#
##########################################################################################################

## 원본코드
### echo -e "● U-25. NFS 접근통제" >> $log_file

function Check_exist_file()
{
	if [ -e $1 ]
	then
		echo -e "$1 파일이 존재합니다. 취약" >> $log_file
	else
		echo -e "$1 파일이 존재하지 않습니다. 안전" >> $log_file
	fi	
}

function Remove_file()
{
	rm -rf $1
}

function U-25()
{
	echo -e "● U-25. NFS 접근통제" >> $log_file
	Check_exist_file /etc/exports
}

function U-25_execute()
{
	filebackup exports /etc/exports "File Backup :"
	Remove /etc/exports
}

##########################################################################################################
#
### U-26
#
##########################################################################################################

## 원본코드
echo -e "● U-26. automountd 제거" >> $log_file


##########################################################################################################
#
### U-27
#
##########################################################################################################

## 원본코드
echo -e "● U-27. RPC 서비스 확인" >> $log_file
xinetdService_exists "/etc/xinetd.d/rstatd"
echo -e "\n\n" >> $log_file

##########################################################################################################
#
### U-28 확인 필요
#
##########################################################################################################

## 원본코드
echo -e "● U-28. NIS, NIS+ 점검" >> $log_file

## 확인 하는 명령어
ps -ef | egrep "ypserv|ypbind|ypxfrd|rpc.yppasswdd|rpc.ypupdated" | grep -v grep

##########################################################################################################
#
### U-29 확인 필요
#
##########################################################################################################

## 원본코드
echo -e "● U-29. tftp, talk 서비스 비활성화" >> $log_file


xinetdService_exists "/etc/xinetd.d/tftp"
xinetdService_exists "/etc/xinetd.d/talk"
xinetdService_exists "/etc/xinetd.d/ntalk"


##########################################################################################################
#
### U-30 / 수동 점검 항목 / sendmail 버전 확인 후 패치
### Sendmail 서비스 실행 여부 및 버전 점검 후 각 OS 벤더사의 보안 패치 설치
#
##########################################################################################################

## 원본코드
echo -e "● U-30. Sendmail 버전 점검" >> $log_file

## Sendmail 서비스 실행 여부 확인
ps -ef | grep sendmail | grep -v grep


##########################################################################################################
#
### U-31
#
##########################################################################################################

## 원본코드
echo -e "● U-31. 스팸 메일 릴레이 제한" >> $log_file

## 진단 방법
ps -ef | grep sendmail | grep -v grep
cat /mail/dendmail.cf | grep "R$ \*" | grep "Relaying denied"

## 조치 방법
### vi 편집기로 sendmail.cf 주석 제거
### #R$* $#error $@ 5.7.1 $: "550 Relaying denied" -> R$* $#error $@ 5.7.1 $: "550 Relaying denied"


##########################################################################################################
#
### U-32
#
##########################################################################################################

## 원본코드
echo -e "● U-32. 일반사용자의 Sendmail 실행 방지" >> $log_file


##########################################################################################################
#
### U-33
### DNS 서비스 사용 시 해당
#
##########################################################################################################

## 원본코드
echo -e "● U-33. DNS 보안 버전 패치" >> $log_file


##########################################################################################################
#
### U-34
#
##########################################################################################################

## 원본코드
echo -e "● U-34. DNS ZoneTransfer 설정" >> $log_file


##########################################################################################################
#
### U-35 / 수동 조치 항목
#
##########################################################################################################

## 원본코드
echo -e "● U-35. 최신 보안 패치 및 벤더 권고사항 적용" >> $log_file


##########################################################################################################
#
### U-36 / 수동 조치 항목
#
##########################################################################################################

## 원본코드
echo -e "● U-36. 로그의 정기적 검토 및 보고" >> $log_file


###########################################

### 실행 부분

###########################################


### 확인 필요
function menu()
{
        echo -e "***********************************************"
        echo -e "* 클라우드 취약점 점검/조치(2021)-Ubuntu22.04 *"
        echo ""
        echo -e "[1] 취약점 점검"
        echo -e "[2] 취약점 조치"
        echo -e "[3] 원복"
        read -p "원하는 항목을 선택하세요. : " ans

        case $ans in
                1)
                        Check_Security
                        ;;
                2)
                        Execute_Security
                        ;;
                *)
                        echo "error"
                        ;;
        esac
}



function Check_Security()
{
	Log_header ## 로그 헤더 출력
	U-01
	###U-02
	###U-03
	###U-04
	###U-05
	###U-06
	###U-07
	###U-08
	###U-09
	###U-10
	###U-11
	###U-12
	###U-13
	###U-14
	###U-15
	###U-16
	###U-17
	###U-18
	###U-19
	###U-20
	###U-21
	###U-22
	###U-23
	###U-24
	###U-25
	###U-26
	###U-27
	###U-28
	###U-29
	###U-30
	###U-31
	###U-32
	###U-33
	###U-34
	###U-35
	###U-36
	echo ""
    echo ""
    cat $log_file
}

function Execute_Security()
{
        Execute_Log_header ## 로그 헤더 출력
        U-01_execute
        echo ""
        echo ""
        cat $execute_log_file
}


function main()
{
	menu
}


clear
main

#End of Shell Script
