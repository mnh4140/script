#!/bin/sh
###########################################################
# ubuntu22.04_취약점_v1.1.sh
#  1) 업데이트 날짜: 2024/06/11/TUE
#  2) 업데이트 내용
#       - 점검 결과 요약 추가(SAFE, WARN, PASS 수)
###########################################################

userName=$(whoami)
hostname=$(hostname)
currentDate=$(date)
osInfo=$(grep PRETTY_NAME /etc/os-release | awk -F "\"" '{ print$2 }')

# 현재 날짜 포맷팅
dateFormat=$(date '+%Y%m%d_%H%M%S')

# 점검 항목 수 카운트
Num=0

# 로그 경로 및 이름 정의
logPATH="/home/$userName/wins/OS_Security/$hostname"
checkResultLog1="Ubuntu22.04_Security_Check_${hostname}_${dateFormat}.log"
checkResultLog2="Ubuntu22.04_Security_Check_$hostname.log"

# 통합용 로그 초기화
if [ -f "$logPATH/$checkResultLog2" ]; then
    rm -f "$logPATH/$checkResultLog2"
fi

# 점검 대상 파일 소유자 및 권한 점검
# fileCheck "파일경로"
fileCheck() {
    # 파일이 존재 시 소유자 및 권한 정보 출력
    if [ -f "$1" ]; then
        # 파일 정보 가져오기
        permissions=$(stat -c "%a" $1| awk '{print $1}')
        owner=$(ls -l $1 | awk '{print $3}')
        echo "$owner\t$permissions"
    # 파일이 미존재시
    else
        echo "PASS"
    fi
}


# 취약점 점검 로그
# securityLog "점검코드|점검항목명" "suggestion 설정값" "current 설정값" "SAFE OR WARN"
function securityLog() {   
    # 로그 폴더 없을시 생성
    if [ ! -d "$logPATH" ]; then
        mkdir -p "$logPATH"
    fi

    ((Num++))
    # 점검코드|점검항목명 로깅
    echo -e " $Num. [$1]" | tee -a "$logPATH/$checkResultLog1"
    echo -e " $Num. [$1]" >> "$logPATH/$checkResultLog2"
    
    # 점검 결과 상태 로깅
    if [ "$4" = "SAFE" ]; then
        echo -e "\t- Check result:\t\e[32m$4\e[0m" | tee -a "$logPATH/$checkResultLog1"
        echo -e "\t- Check result:\t\e[32m$4\e[0m" >> "$logPATH/$checkResultLog2"

    elif [[ "$4" == *"WARN"* ]]; then
        echo -e "\t- Check result:\t\e[33m$4\e[0m" | tee -a "$logPATH/$checkResultLog1"
        echo -e "\t- Check result:\t\e[33m$4\e[0m" >> "$logPATH/$checkResultLog2"

    elif [ "$4" = "ERROR" ]; then
        echo -e "\t- Check result:\t\e[31m$4\e[0m" | tee -a "$logPATH/$checkResultLog1"
        echo -e "\t- Check result:\t\e[31m$4\e[0m" >> "$logPATH/$checkResultLog2"

    else
        echo -e "\t- Check result:\t$4" | tee -a "$logPATH/$checkResultLog1"
        echo -e "\t- Check result:\t$4" >> "$logPATH/$checkResultLog2"
    fi  

    # 권장 설정값 및 현재 설정값 로깅
    echo -e "\t- Suggestion:\t$2" | tee -a "$logPATH/$checkResultLog1"
    echo -e "\t- Current:\t$3" | tee -a "$logPATH/$checkResultLog1"
    echo -e "\n" | tee -a "$logPATH/$checkResultLog1"

    echo -e "\t- Suggestion:\t$2" >> "$logPATH/$checkResultLog2"
    echo -e "\t- Current:\t$3" >> "$logPATH/$checkResultLog2"
    echo -e "\n" >> "$logPATH/$checkResultLog2"
}


# 가. 계정관리
# U-01. root 계정 원격 접속 제한(상)
function U-01() {
    suggestionValue="PermitRootLogin no"

    PermitRootLoginValue=$(grep '^PermitRootLogin' /etc/ssh/sshd_config | grep -v '^#' | awk '{print $2}')
    currentValue="PermitRootLogin $PermitRootLoginValue"

    # WARN(PermitRootLogin yes)
    if [ "$PermitRootLoginValue" = "yes" ]; then
        securityState="WARN"

    # SAFE(PermitRootLogin no)
    elif [ "$PermitRootLoginValue" = "no" ]; then
        securityState="SAFE"

    # SAFE(PermitRootLogin 설정이 주석처리 됬을 경우 "no"가 디폴트)
    elif [ -z "$PermitRootLoginValue" ]; then
        securityState="SAFE"
        currentValue=$(grep 'prohibit-password' /etc/ssh/sshd_config)

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-01|root 계정 원격 접속 제한" "$suggestionValue" "$currentValue" "$securityState"
}


# U-02. 패스워드 복잡성 설정(상)
function U-02() {
    suggestionValue="10-1-1-1-1"

    minlen=$(cat /etc/pam.d/common-password | grep minlen | awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')
	dcredit=$(cat /etc/pam.d/common-password | grep dcredit | awk -F "dcredit=" '{print $2}'| awk -F " " '{print $1}')
	ucredit=$(cat /etc/pam.d/common-password | grep ucredit | awk -F "ucredit=" '{print $2}'| awk -F " " '{print $1}')
	lcredit=$(cat /etc/pam.d/common-password | grep lcredit | awk -F "lcredit=" '{print $2}'| awk -F " " '{print $1}')
	ocredit=$(cat /etc/pam.d/common-password | grep ocredit | awk -F "ocredit=" '{print $2}'| awk -F " " '{print $1}')
    currentValue="$minlen$dcredit$ucredit$lcredit$ocredit"

    # WARN(패스워드 복잡성 설정 미적용)
    if [ -z "$currentValue" ]; then
        securityState="WARN(패스워드 복잡성 설정 미적용)"

    # WARN(패스워드 복잡성 임계값 미충족)
    elif [ "$suggestionValue" != "$currentValue" ]; then
        securityState="WARN(패스워드 복잡성 임계값 미충족)"
    
    # SAFE(패스워드 복작성 임계값 충족)
    elif [ "$suggestionValue" = "$currentValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-02|패스워드 복잡성 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-03. 계정 잠금 임계값 설정(상)
function U-03() {
    #auth        required			pam_faillock.so deny=5 unlock_time=120
    suggestionValue="auth    required                        pam_faillock.so deny=5 unlock_time=120"
    s_deny="5"
    s_unlock_time="120"

    c_deny=$(cat /etc/pam.d/common-auth | grep pam_faillock.so | awk -F "deny=" '{print $2}'| awk -F " " '{print $1}')
    c_unlock_time=$(cat /etc/pam.d/common-auth | grep pam_faillock.so | awk -F "unlock_time=" '{print $2}'| awk -F " " '{print $1}')
    currentValue="$(grep pam_faillock.so /etc/pam.d/common-auth)"

    # WARN(계정 잠금 임계값 설정 미적용)
    if [ -z "$currentValue" ]; then
        securityState="WARN(계정 잠금 임계값 설정 미적용)"

    # SAFE(계정 임계값 설정 충족)
    elif [ "$c_deny" -le "$s_deny" ] && [ "$c_unlock_time" -ge "$s_unlock_time" ]; then
        securityState="SAFE"

    # WARN(계정 잠금 임계값 설정 미충족)
    elif [ "$c_deny" -gt "$s_deny" ] || [ "$c_unlock_time" -lt "$s_unlock_time" ]; then
        securityState="WARN(계정 잠금 임계값 설정 미충족)"    

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-03|계정 잠금 임계값 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-04. 패스워드 파일 보호(상)
function U-04() {
    # 전체 계정 수
    # cat /etc/passwd | grep  -c -v '^$'
    suggestionValue=$(grep -c -v '^$' "/etc/passwd")

    # 비밀번호가 암호화 되어 있는 계정 수
    # cat /etc/passwd | awk -F: '$2 == "x" {count++} END {print count}'
    currentValue=$(awk -F: '$2 == "x" {count++} END {print count}' "/etc/passwd")

    # WARN(전체 계정 수와 암호화 된 계정 수가 다를 때)
    if [ "$currentValue" != "$suggestionValue" ]; then
        securityState="WARN"

    # SAFE(전체 계정 수와 암호화 된 계정 수가 같을 때)
    elif [ "$currentValue" = "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-04|패스워드 파일 보호" "$suggestionValue(전체 계정 수)" "$currentValue(비밀번호가 암호화 되어 있는 계정 수)" "$securityState"
}


# U-45. root 계정 su 제한(하)
function U-45() {
    suggestionValue="ubuntu22.04는 'adm' 그룹을 통해 su 명령어 사용 허용"

    admGroup=$(awk -F ":" '{ print $1 }' /etc/group | grep "^adm$")
    currentValue=$(grep "adm" /etc/group | awk -F ":" '{ print $4 }')

    # WARN(adm 그룹 없을 경우)
    if [ -z "$admGroup" ]; then
        securityState="WARN"
        currentValue="'adm' 그룹 없음"

    # SAFE(adm 그룹 있을 경우)
    elif [ "$admGroup" == "adm" ]; then
        securityState="SAFE"
        currentValue+="(adm 그룹 포함 계정)"
    
    # EXCEPTION
    else
        securityState="ERROR"
    fi
    
    securityLog "U-45|root 계정 su 제한" "$suggestionValue" "$currentValue" "$securityState"
}


# U-46. 패스워드 최소 길이 설정
function U-46() {
    suggestionValue="10"

    # 현재 패스워드 최소 길이 설정 출력
    currentValue=$(egrep "minlen" /etc/pam.d/common-password | grep -v '#'| awk -F "minlen=" '{print $2}'| awk -F " " '{print $1}')

    # WARN(최소 길이 설정이 안되어 있는 경우)
    if [ -z $currentValue ]; then
        securityState="WARN(패스워드 최소 길이 미설정)"
    
    # WARN(최소 길이가 10보다 작은 경우)
    elif [ "$currentValue" -lt "$suggestionValue" ]; then
        securityState="WARN"

    # SAFE(최소 길이가 10이상인 경우)
    elif [ "$currentValue" -ge "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-46|패스워드 최소 길이 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-47. 패스워드 최대 사용기간 설정(중)
function U-47() {
    suggestionValue="90"

    currentValue=$(grep "PASS_MAX_DAYS" /etc/login.defs | grep -v '#' | awk -F " " '{print $2}')

    # WARN(PASS_MAX_DAYS 값이 90 초과한 경우)
    if [ "$currentValue"  -gt "$suggestionValue" ]; then
        securityState="WARN"
    
    # SAFE(ASS_MAX_DAYS 값이 90 이하인 경우)
    elif [ "$currentValue"  -le "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-47|패스워드 최대 사용기간 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-48. 패스워드 최소 사용기간 설정(중)
function U-48 {
    suggestionValue="1"

    currentValue=$(grep "PASS_MIN_DAYS" /etc/login.defs | grep -v '#' | awk -F " " '{print $2}')

    # WARN(PASS_MIN_DAYS 1이 아닌 경우)
    if [ "$currentValue"  != "$suggestionValue" ]; then
        securityState="WARN"
    
    # SAFE(PASS_MIN_DAYS 1인 경우)
    elif [ "$currentValue" = "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-48|패스워드 최소 사용기간 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-49 불필요한 계정 제거(하)
function U-49() {
    # 불필요한 계정 정의
    suggestionValue="lp sync shutdown halt news uucp operator games gopher nfsnobody squid"

    # 현재 불필요한 계정 출력
    currentValue=$(egrep "lp|^sync^|shutdown|halt|news|uucp|operator|games|gopher|nfsnobody|squid" /etc/passwd | awk -F ":" '{print $1}' | tr '\n' ' ')
    currentValueCnt=$(echo "$currentValue" | awk '{print NF}')

    # WARN(불필요한 계정 수가 0보다 많은)
    if [ "$currentValueCnt" -gt 0 ]; then
        securityState="WARN"

    # SAFE(불필요한 계정 수가 0인 경우) 
    elif [ "$currentValueCnt" -eq 0 ]; then
        currentValue="불필요한 계정 없음"
        securityState="SAFE"

    # EXCEPTION    
    else
        securityState="ERROR"
    fi

    securityLog "U-49|불필요한 계정 제거" "불필요 계정 리스트\n\t\t\t$suggestionValue" "$currentValue" "$securityState"
}


# U-51 계정이 존재하지 않는 GID 금지(하)
function U-51() {
    # 불필요한 그룹 정의
    suggestionValue="lp uucp games tape video audio floppy cdrom slocate stapusr stapsys stapdev"

    # 현재 불필요한 그룹 출력
    currentValue=$(egrep "lp|uucp|games|tape|video|audio|floppy|cdrom|slocate|stapusr|stapsys|stapdev" /etc/group | awk -F ":" '{print $1}' | tr '\n' ' ')
    currentValueCnt=$(echo "$currentValue" | awk '{print NF}')

    # SAFE(불필요한 그룹이 없는 경우)
    if [ -z "$currentValueCnt" ]; then
        currentValue="불필요한 그룹 없음"
        securityState="SAFE"
    
    # WARN(불필요한 그룹 수가 1개 이상인 경우) 
    elif [ "$currentValueCnt" -ge 1 ]; then
        securityState="WARN"

    # EXCEPTION    
    else
        securityState="ERROR"
    fi

    securityLog "U-51|계정이 존재하지 않는 GID 금지" "불필요 그룹 리스트\n\t\t\t$suggestionValue" "$currentValue" "$securityState"
}


# U-54. Session Timeout 설정(하)
function U-54() {
    TIMEOUT_value="600"
    exportTIMEOUT="export TIMEOUT"
    suggestionValue="TIMEOUT=$TIMEOUT_value\n\t\t\t$exportTIMEOUT"

    c_TIMEOUT_value=$(grep "TIMEOUT=" /etc/profile | awk -F "TIMEOUT=" '{print $2}')
    c_exportTIMEOUT=$(grep "export TIMEOUT" /etc/profile | grep -v '^#')
    currentValue="TIMEOUT=$c_TIMEOUT_value\n\t\t\t$c_exportTIMEOUT"

    # WARN(TIMEOUT 설정이 비어 있거나 600보다 작을 경우) 
    if [ -z "$c_TIMEOUT_value" ] || [ "$c_TIMEOUT_value" -gt "$TIMEOUT_value" ]; then
        currentValue=""
        securityState="WARN(TIMEOUT 미설정)"

    # SAFE(TIMEOUT 설정이 600이하, export TIMEOUT 설정 되어 있는 경우)
    elif [ "$c_TIMEOUT_value" -le "$TIMEOUT_value" ] && [ "$c_exportTIMEOUT" = "$exportTIMEOUT" ]; then
        securityState="SAFE"

    # WARN(TIMEOUT 설정이 600이하, export TIMEOUT 설정 되어 있지 않은 경우)
    elif [ "$c_TIMEOUT_value" -le "$TIMEOUT_value" ] && [ "$c_exportTIMEOUT" != "$exportTIMEOUT" ]; then
        securityState="WARN('export TIMEOUT' 미설정)" 

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-54|Session Timeout 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# 나. 파일 및 디렉터리 관리
# U-07. /etc/passwd 파일 소유자 및 권한 설정(상)
function U-07() {
    # 파일 소유자 및 권한
    suggestionValue="root\t644"

    # 파일 존재시 현재 소유자 및 권한 정보
    currentValue=$(fileCheck "/etc/passwd")

    # PASS(해당 파일 없을 시)
    if [[ "$currentValue" == *"PASS"* ]]; then
        securityState="PASS(해당 파일 없음)"

    # WARN(소유자 root 및 권한 644가 아닐 때)
    elif [ "$currentValue"  != "$suggestionValue" ]; then
        securityState="WARN"

    # SAFE(소유자 root 및 권한 644가 일 때)
    elif [ "$currentValue"  = "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-07|/etc/passwd 파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-08. /etc/shadow 파일 소유자 및 권한 설정(상)
function U-08() {
    suggestionValue="root\t400"

    currentValue=$(fileCheck "/etc/shadow")

    # PASS(해당 파일 없을 시)
    if [[ "$currentValue" == "" ]]; then
        securityState="PASS(해당 파일 없음)"

    # WARN(소유자 root 및 권한 644가 아닐 때)
    elif [ "$currentValue"  != "$suggestionValue" ]; then
        securityState="WARN"

    # SAFE(소유자 root 및 권한 644가 일 때)
    elif [ "$currentValue"  = "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-08|/etc/shadow 파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-09. /etc/hosts 파일 소유자 및 권한 설정(상)
function U-09() {
    suggestionValue="root\t600"

    currentValue=$(fileCheck "/etc/hosts")

    # PASS(해당 파일 없을 시)
    if [[ "$currentValue" == "" ]]; then
        securityState="PASS(해당 파일 없음)"

    # WARN(소유자 root 및 권한 644가 아닐 때)
    elif [ "$currentValue"  != "$suggestionValue" ]; then
        securityState="WARN"

    # SAFE(소유자 root 및 권한 644가 일 때)
    elif [ "$currentValue"  = "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-09|/etc/hosts 파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-11 /etc/rsyslog.conf 파일 권한 확인 함수(상)
function U-11() {
    suggestionValue="root\t640"

    currentValue=$(fileCheck "/etc/rsyslog.conf")

    # PASS(해당 파일 없을 시)
    if [[ "$currentValue" == "" ]]; then
        securityState="PASS(해당 파일 없음)"

    # WARN(소유자 root 및 권한 640가 아닐 때)
    elif [ "$currentValue"  != "$suggestionValue" ]; then
        securityState="WARN"

    # SAFE(소유자 root 및 권한 640가 일 때)
    elif [ "$currentValue"  = "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-11|/etc/rsyslog.conf 파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-12 /etc/services 파일 소유자 및 권한 설정(상)
function U-12() {
    suggestionValue="root\t644"

    currentValue=$(fileCheck "/etc/services")

    # PASS(해당 파일 없을 시)
    if [[ "$currentValue" == "" ]]; then
        securityState="PASS(해당 파일 없음)"

    # WARN(소유자 root 및 권한 640가 아닐 때)
    elif [ "$currentValue"  != "$suggestionValue" ]; then
        securityState="WARN"

    # SAFE(소유자 root 및 권한 640가 일 때)
    elif [ "$currentValue"  = "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-12|/etc/services 파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-14. 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정(Permission 점검)
function U-14-1() {
    # 점검대상 파일 정의
    profileFile="/etc/profile"
    bashFile="/etc/bash.bashrc"
    userBashFile=".bashrc"
    userProfileFile=".profile"

    suggestionPermission="644"
    suggestionValue="$profileFile: $suggestionPermission\t\t$bashFile: $suggestionPermission\n\t\t\t/home/유저네임/$userBashFile: $suggestionPermission\t/home/유저네임/$userProfileFile: $suggestionPermission"

    # 시스템 환경파일 권한 현재값
    currentValue="$profileFile: $(stat -c %a $profileFile)\t\t$bashFile: $(stat -c %a $bashFile)"

    # 사용자 환경파일 권한 현재값
    Homedir=(`ls /home`)
	homecount=$(ls -l /home/ | grep -v total | wc -l)
    for user in "${Homedir[@]}"; do
        userBash=$(stat -c %a /home/$user/$userBashFile)
        userProfile=$(stat -c %a /home/$user/$userProfileFile)
        currentValue+="\n\t\t\t/home/$user/$userBashFile: $userBash\t/home/$user/$userProfileFile: $userProfile"
    done

    # 시스템 환경파일 권한 점검(ubuntu22.04 기준)
    if [[ $(stat -c %a $bashFile) == 660 || $(stat -c %a $bashFile) == 644 || $(stat -c %a $bashFile) == 640 ]]; then
        # true(/etc/bash.bashrc 권한이 660 or 644 or 640이고, profileFile 권한이 660 or 644 or 640인 경우)
        if [[ $(stat -c %a $profileFile) == 660 || $(stat -c %a $profileFile) == 644 || $(stat -c %a $profileFile) == 640 ]]; then
            sys_permission=true
        else
            sys_permission=false
        fi
    else
        sys_permission=false
    fi

    # 사용자 환경파일 권한 점검(ubuntu22.04 기준)
    isgood=0
    for user in "${Homedir[@]}"; do
        if [[ $(stat -c %a /home/$user/$userBashFile) == 644 || $(stat -c %a /home/$user/$userBashFile) == 640 || $(stat -c %a /home/$user/$userBashFile) == 660 ]]; then 
            # SAFE(각 사용자 환경파일 .bashrc, .profile이 660 or 644 or 640인 경우)
            if [[ $(stat -c %a /home/$user/$userProfileFile) == 644 || $(stat -c %a /home/$user/$userProfileFile) == 640 || $(stat -c %a /home/$user/$userProfileFile) == 660 ]]; then
                ((isgood++))
            fi
        fi
    done

    # SAFE(시스템 및 환경파일 권한이 모두 만족할 경우)
    if [[ $isgood == $homecount && $sys_permission == true ]]; then
        securityState="SAFE"
    else
        securityState="WARN"
    fi

    securityLog "U-14-1|사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정(Permission 점검)" "$suggestionValue" "$currentValue" "$securityState"
}


# U-14. 사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정(Owner 점검)
function U-14-2() {
    # 점검대상 파일 정의
    profileFile="/etc/profile"
    bashFile="/etc/bash.bashrc"
    userBashFile=".bashrc"
    userProfileFile=".profile"

    suggetionOwner="root root"
    suggestionValue="$profileFile: $suggetionOwner\t\t\t\t$bashFile: $suggetionOwner\n\t\t\t/home/유저네임/$userBashFile : 유저네임 유저네임\t/home/유저네임/$userProfileFile : 유저네임 유저네임"

	# /etc/profile 및 /etc/bash.bashrc 소유권 확인
	profileOwner=$(ls -al $profileFile | awk -F " " '{print $3 " " $4}' | grep -v ^$)
	bashrcOwner=$(ls -al $bashFile | awk -F " " '{print $3 " " $4}' | grep -v ^$)

    # 시스템 환경파일 소유자 현재값
    currentValue="$profileFile: $profileOwner\t\t\t\t$bashFile: $bashrcOwner"

    # 사용자 환경파일 소유자 현재값
    Homedir=(`ls /home`)
	homecount=$(ls -l /home/ | grep -v total | wc -l)
	for user in "${Homedir[@]}"; do
        userBashOwner=$(ls -al /home/$user/$userBashFile | awk -F " " '{print $3 " " $4}' | grep -v ^$)
        userProfileOwner=$(ls -al /home/$user/$userProfileFile | awk -F " " '{print $3 " " $4}' | grep -v ^$)
        currentValue+="\n\t\t\t/home/$user/$userBashFile: $userBashOwner\t\t/home/$user/$userProfileFile: $userProfileOwner"
	done
	
    # 시스템 환경파일 점검(ubuntu22.04 기준)
    # true(/etc/profile 및 /etc/bash.bashrc 파일이 정상 권한일 경우)
	if [ "$profileOwner" == "$suggetionOwner" ] && [ "$bashrcOwner" == "$suggetionOwner" ]; then 
		isgoodsysown=true
	else
		isgoodsysown=false
	fi

	# 사용자 환경파일 점검(ubuntu22.04 기준)
	for user in "${Homedir[@]}"; do
        # 홈 디렉터리 .bash_profile 및 .bashrc 소유권 확인
        userProfileOwner=$(ls -al /home/$user/$userProfileFile | awk -F " " '{print $3 " " $4}' | grep -v ^$)
        userBashOwner=$(ls -al /home/$user/$userBashFile | awk -F " " '{print $3 " " $4}' | grep -v ^$)
		
        # true(각 홈 디렉터리 .bashrc 및 .profile 파일이 정상 권한일 경우)
		if [ "$userProfileOwner" == "$user $user" ] && [ "$userBashOwner" == "$user $user" ]; then 
			isgoodusrown=true
		else
			isgoodusrown=false
		fi
	done

    # SAFE(시스템 및 사용자 환경파일 권한이 정상 설정일 경우)
	if [ $isgoodsysown == true ] && [ $isgoodusrown == true ]; then
        securityState="SAFE"
	else
        securityState="WARN"
	fi
	
    securityLog "U-14-2|사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정(Owner 점검)" "$suggestionValue" "$currentValue" "$securityState"
}


# U-18. 접속 IP 및 포트 제한
function U-18() {
    suggetionOwner="/etc/hosts.allow 내 특정 호스트 없음"

    # /etc/hosts.allow 파일 내 호스트 확인
    currentValue=$(cat /etc/hosts.allow | grep -v '^#')

    # SAFE(호스트가 없을 경우)
    if [ -z "$currentValue" ]; then
        currentValue="/etc/hosts.allow 내 특정 호스트 없음"
        securityState="SAFE"
    
    # WARN(호스트가 존재할 경우)
    elif [ -n "$currentValue" ]; then
        securityState="WARN"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-18|접속 IP 및 포트 제한" "$suggestionValue" "$currentValue" "$securityState"
}


# U-55. hosts.lpd 파일 소유자 및 권한 설정
function U-55() {
    suggestionValue="root\t600"

    currentValue=$(fileCheck "/etc/hosts.lpd")

    # PASS(해당 파일 없을 시)
    if [[ "$currentValue" == "" ]]; then
        securityState="PASS(해당 파일 없음)"

    # WARN(소유자 root 및 권한 640가 아닐 때)
    elif [ "$currentValue"  != "$suggestionValue" ]; then
        securityState="WARN"

    # SAFE(소유자 root 및 권한 640가 일 때)
    elif [ "$currentValue"  = "$suggestionValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-55|hosts.lpd 파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-56. UMASK 설정 관리(중)
function U-56() {
    umaskValue="0022"
    suggestionValue="umask $umaskValue"

    # 현재 umask 설정값
    currentValue=$(umask)

    # WARN(umask 설정이 비어 있거나 022미만 일 경우) 
    if [ -z "$currentValue" ]; then
        currentValue=""
        securityState="WARN(umask 미설정)"

    # WARN(umask 값이 022미만일 경우)
    elif [ "$currentValue" -lt "$umaskValue" ]; then
        securityState="WARN(umask 설정 미충족)"
    
    # SAFE(umask 값이 022이상일 경우)
    elif [ "$currentValue" -ge "$umaskValue" ]; then
        securityState="SAFE"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-56|UMASK 설정 관리" "$suggestionValue" "umask $currentValue" "$securityState"
}


# 다. 서비스 관리
# U-22. crond 파일 소유자 및 권한 설정
function U-22() {
    # 점검 대상 cron 설정 파일/폴더
    binCrontabFile="/usr/bin/crontab"
    cronFiles=$(ls /etc/ | grep cron | sed 's/^/\/etc\//')

    # 점검 대상 cron 설정 파일/폴더 권장 소유자 및 권한
    sbinCrontabOwner="root"
    sbinCrontabPerm="750"
    scrondOwner="root"
    scrondPerm="640"

    currentValue=""
    suggestionValue="${binCrontabFile}\t${sbinCrontabOwner}\t${sbinCrontabPerm}\n"
    stateArr=()

    # /etc/cron* 파일들에 대한 권장 값 추가(출력문 정리)
    for cronFile in $cronFiles; do
        cronFileLen=${#cronFile}
        if [ "$cronFileLen" -le 15 ]; then
            suggestionValue+="\t\t\t${cronFile}\t\t${scrondOwner}\t${scrondPerm}\n"
        else
            suggestionValue+="\t\t\t${cronFile}\t${scrondOwner}\t${scrondPerm}\n"
        fi
    done

    # /usr/bin/crontab 파일 소유자 및 권한 확인
    binCrontabOwner=$(stat -c '%U' $binCrontabFile)
    binCrontabPerm=$(stat -c '%a' $binCrontabFile)
    binCrontabState="$binCrontabOwner\t$binCrontabPerm"

    # /usr/bin/crontab 소유자 및 권한 확인
    if [[ "$binCrontabOwner" == "$sbinCrontabOwner" && "$binCrontabPerm" -eq "$sbinCrontabPerm" ]]; then
        currentValue="${binCrontabFile}\t${binCrontabState}"
        stateArr+=("SAFE")
        # securityState1="SAFE"
    else
        currentValue="${binCrontabFile}\t${binCrontabState}"
        stateArr+=("WARN")
        # securityState1="WARN"
    fi

    # /etc/cron* 파일 소유자 및 권한 확인
    for cronFile in $cronFiles; do
        cronFileOwner=$(stat -c '%U' $cronFile)
        cronFilePerm=$(stat -c '%a' $cronFile)
        cronFileState="$cronFileOwner\t$cronFilePerm"

        # 출력문 정리
        cronFileLen=${#cronFile}
        if [ "$cronFileLen" -le 15 ]; then
            currentValue+="\n\t\t\t${cronFile}\t\t${cronFileState}"
        else
            currentValue+="\n\t\t\t${cronFile}\t${cronFileState}"
        fi

        # /etc/cron* 파일 소유자 및 권한 확인
        if [[ "$cronFileOwner" == "$scrondOwner" && "$cronFilePerm" -eq "$scrondPerm" ]]; then
            stateArr+=("SAFE")
        else
            stateArr+=("WARN")
        fi
    done

    # stateArr 내 WARN이 하나라도 있으면 securityState="WARN"
    securityState="SAFE"
    for state in "${stateArr[@]}"; do
        if [[ "$state" == "WARN" ]]; then
            securityState="WARN"
            break
        fi
    done

    securityLog "U-22|crond 파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"
}


# U-68. 로그온 시 경고 메시지 제공
function U-68() {
    suggestionValue="Administrator Access Only"

    currentValue=$(run-parts --report /etc/update-motd.d/ 2>/dev/null)

    # SAFE(로그온 메시지 내 "Administrator Access Only" 문구가 있는 경우)
    if [[ "$currentValue" == *"$suggestionValue"* ]]; then
        securityState="SAFE"

    # WARN(로그온 메시지 내 "Administrator Access Only" 문구가 없는 경우)
    elif [[ "$currentValue" != *"$suggestionValue"* ]]; then
        securityState="WARN"

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-68|로그온 시 경고 메시지 제공" "$suggestionValue" "$currentValue" "$securityState"
}


function U-72() {
    # 시스템 로깅 설정
    rsyslogValue=("*.info;mail.none;authpriv.none;cron.none /var/log/messages" \
                  "authpriv.* /var/log/secure" \
                  "mail.* /var/log/maillog" \
                  "cron.* /var/log/cron" \
                  "*.alert /dev/console" \
                  "*.emerg *")

    # 시스템 로깅 설정 개수
    rsyslogNum=${#rsyslogValue[@]}

    # 로깅 설정 권장 값 정의
    suggestionValue=""
    for s in "${rsyslogValue[@]}"; do
        suggestionValue+="${s}\n\t\t\t"
    done

    # 현재 정의된 로깅 설정값 확인
    rsyslogConf="/etc/rsyslog.conf"
    currentValue=""
    cRsyslogNum=0
    for c in "${rsyslogValue[@]}"; do
        if result=$(grep "$c" "$rsyslogConf" | grep -v '#'); then
            currentValue+="${result}\n\t\t\t"
            ((cRsyslogNum++))
        fi
    done

    # SAFE(권장 시스템 로깅 설정 갯수와 현재 설정된 시스템 로깅 수가 같을 때)
    if [ "$rsyslogNum" -eq "$cRsyslogNum" ]; then
        securityState="SAFE"
    
    # WARN(권장 시스템 로깅 설정 갯수와 현재 설정된 시스템 로깅 수가 다를 때)
    elif [ "$rsyslogNum" -ne "$cRsyslogNum" ]; then
        securityState="WARN"

    # EXCEPTION
    else
        securityState="ERROR"
    fi
        
    securityLog "U-72|정책에 따른 시스템 로깅 설정" "$suggestionValue" "$currentValue" "$securityState"
}

# 점검 정보 출력
echo -e "#######################################################################################################################################" | tee -a "$logPATH/$checkResultLog1"
echo -e "▶ WINS CLOUD SECURITY CHECK" | tee -a "$logPATH/$checkResultLog1"
echo -e " 1) DATE:\t\t$currentDate" | tee -a "$logPATH/$checkResultLog1"
echo -e " 2) HOSTNAME:\t\t$hostname" | tee -a "$logPATH/$checkResultLog1"
echo -e " 3) OS:\t\t\t$osInfo" | tee -a "$logPATH/$checkResultLog1"
echo -e " 4) LOG:\t\t$logPATH/$checkResultLog1" | tee -a "$logPATH/$checkResultLog1"
echo -e "\n#######################################################################################################################################\n" | tee -a "$logPATH/$checkResultLog1"

echo -e "#######################################################################################################################################" >> "$logPATH/$checkResultLog2"
echo -e "▶ WINS CLOUD SECURITY CHECK" >> "$logPATH/$checkResultLog2"
echo -e " 1) DATE:\t\t$currentDate" >> "$logPATH/$checkResultLog2"
echo -e " 2) HOSTNAME:\t\t$hostname" >> "$logPATH/$checkResultLog2"
echo -e " 3) OS:\t\t\t$osInfo" >> "$logPATH/$checkResultLog2"
echo -e " 4) LOG:\t\t$logPATH/$checkResultLog2" >> "$logPATH/$checkResultLog2"
echo -e "\n#######################################################################################################################################\n" >> "$logPATH/$checkResultLog2"


# 가. 계정관리(11)
U-01     
U-02    
U-03      
U-04      
U-45     
U-46     
U-47     
U-48      
U-49    
U-51      
U-54      

# 나. 파일 및 디렉터리 관리(7)
U-08     
U-09    
U-11     
U-14-1   
U-14-2    
U-18     
U-56     

# 다. 서비스 관리(2)
U-22      
U-68      

# 라. 패치 관리(0)

# 마. 로그 관리(1)
U-72


# 총 점검 항목 수 및 각 점검 결과(SAFE/WARN/PASS) 요약 로깅
safeNum1=$(grep -e "SAFE" $logPATH/$checkResultLog1 | wc -l)
warnNum1=$(grep -e "WARN" $logPATH/$checkResultLog1 | wc -l)
passNum1=$(grep -e "PASS" $logPATH/$checkResultLog1 | wc -l)

safeNum2=$(grep -e "SAFE" $logPATH/$checkResultLog2 | wc -l)
warnNum2=$(grep -e "WARN" $logPATH/$checkResultLog2 | wc -l)
passNum2=$(grep -e "PASS" $logPATH/$checkResultLog2 | wc -l)

sed -i '7s/^/ 5) CHECK RESULT:\t총 점검 항목 '"$Num"' 개(SAFE '"$safeNum1"'\/ WARN '"$warnNum1"'\/ PASS '"$passNum1"')/' "$logPATH/$checkResultLog1"
sed -i '7s/^/ 5) CHECK RESULT:\t총 점검 항목 '"$Num"' 개(SAFE '"$safeNum2"'\/ WARN '"$warnNum2"'\/ PASS '"$passNum2"')/' "$logPATH/$checkResultLog2"
