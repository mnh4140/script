#!/bin/sh
###########################################################
# ubuntu22.04_취약점 조치_v0.1.sh
#  1) 업데이트 날짜: 2024/06/12/WED
#  2) 업데이트 내용
#       
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


# checkResultLog="$logPATH/Ubuntu22.04_Security_Check_$hostname.log"
checkResultLog="/home/ubuntu/wins/checkLog.log"
excuteResultLog1="Ubuntu22.04_Security_Excute_${hostname}_${dateFormat}.log"
excuteResultLog2="Ubuntu22.04_Security_Excute_$hostname.log"

# 통합용 로그 초기화
if [ -f "$logPATH/$excuteResultLog2" ]; then
    rm -f "$logPATH/$excuteResultLog2"
fi


# 취약점 조치 로그
# securityLog "점검코드|점검항목명" "BEFORE 설정값" "AFTER 설정값" "Changed OR Already Applied"
function securityLog() {   
    # 로그 폴더 없을시 생성
    if [ ! -d "$logPATH" ]; then
        mkdir -p "$logPATH"
    fi

    ((Num++))
    # 점검코드|점검항목명 로깅
    echo -e " $Num. [$1] " | tee -a "$logPATH/$excuteResultLog1"
    echo -e " $Num. [$1] " >> "$logPATH/$excuteResultLog2"
    
    # 점검 결과 상태 로깅
    if [ "$4" = "Already Applied" ]; then
        echo -e " $Num. [$1] \e[32m$4\e[0m" | tee -a "$logPATH/$excuteResultLog1"
        echo -e " $Num. [$1] \e[32m$4\e[0m" >> "$logPATH/$excuteResultLog2"

    elif [[ "$4" == *"Changed"* ]]; then
        echo -e " $Num. [$1] \e[33m$4\e[0m" | tee -a "$logPATH/$excuteResultLog1"
        echo -e " $Num. [$1] \e[33m$4\e[0m" >> "$logPATH/$excuteResultLog2"

    elif [ "$4" = "ERROR" ]; then
        echo -e " $Num. [$1] \e[31m$4\e[0m" | tee -a "$logPATH/$excuteResultLog1"
        echo -e " $Num. [$1] \e[31m$4\e[0m" >> "$logPATH/$excuteResultLog2"

    else
        echo -e " $Num. [$1] $4" | tee -a "$logPATH/$excuteResultLog1"
        echo -e " $Num. [$1] $4" >> "$logPATH/$excuteResultLog2"
    fi  

    # 권장 설정값 및 현재 설정값 로깅
    echo -e "\t- BEFORE:\t$2" | tee -a "$logPATH/$excuteResultLog1"
    echo -e "\t- AFTER:\t$3" | tee -a "$logPATH/$excuteResultLog1"
    echo -e "\n" | tee -a "$logPATH/$excuteResultLog1"

    echo -e "\t- BEFORE:\t$2" >> "$logPATH/$excuteResultLog2"
    echo -e "\t- AFTER:\t$3" >> "$logPATH/$excuteResultLog2"
    echo -e "\n" >> "$logPATH/$excuteResultLog2"
}


# U-01. root 계정 원격 접속 제한(상)
function U-01() {
    PermitRootLoginValue=$(grep '^PermitRootLogin' /etc/ssh/sshd_config | grep -v '^#' | awk '{print $2}')
    beforeValue="PermitRootLogin $PermitRootLoginValue"

    checkState=$(grep "U-01" $checkResultLog | awk -F '] ' '{print$2}')

    if [ "$checkState" = "SAFE" ]; then
        
    fi



    afterValue="※ 조치 필요시 OS_Security_Excute_U01.yaml"

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



    securityState="PASS(서비스 영향도로 조치 항목 제외)"

    securityLog "U-01|root 계정 원격 접속 제한" "$beforeValue" "$afterValue" "$excuteResult"
}





# # 가. 계정관리(11)
# U-01      # 수동조치 필요
# U-02    
# U-03      
# U-04      
# U-45      # 수동조치 필요     
# U-46     
# U-47     
# U-48      
# U-49    
# U-51      
# U-54      

# # 나. 파일 및 디렉터리 관리(7)
# U-08     
# U-09      # 수동조치 필요
# U-11     
# U-14-1   
# U-14-2    
# U-18      
# U-56     

# # 다. 서비스 관리(2)
# U-22     
# U-68      

# # 라. 패치 관리(0)

# # 마. 로그 관리(1)
# U-72
