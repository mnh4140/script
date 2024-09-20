#!/bin/bash

userName=$(whoami)
hostname=$(hostname)
currentDate=$(date)
#osInfo=$(grep PRETTY_NAME /etc/os-release | awk -F '"' '{print $2}')
osname=$(grep "^ID=" /etc/os-release | awk -F '"' '{print $2}')
osname=$(grep "^NAME=" /etc/os-release | awk -F '"' '{print $2}' | sed 's/ /_/g')
osver=$(grep "VERSION_ID=" /etc/os-release | awk -F '"' '{print $2}')


# 텍스트 색상 및 스타일 설정
RESET='\033[0m'       # 기본 색상 및 스타일
BOLD='\033[1m'        # 굵은 글씨
bold=$(tput bold)
UNDERLINE='\033[4m'   # 밑줄
REVERSED='\033[7m'    # 배경색과 글자색 반전

# 색상설정
RED='\033[0;31m'
GREEN='\033[0;92m'
YELLOW='\033[0;93m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'



# 현재 날짜 포맷팅
dateFormat=$(date '+%Y%m%d_%H%M%S')

# 점검 항목 수 카운트
Num=0

# 로그 경로 및 이름 정의
#logPATH="/home/$userName/wins/OS_Security/$hostname"
#checkResultLog1="Ubuntu22.04_Security_Check_${hostname}_${dateFormat}.log"
#checkResultLog2="Ubuntu22.04_Security_Check_$hostname.log"

## 테스트 용 로깅 변수
logPATH="$(pwd)/OS_Security/$hostname"
checkResultLog1="${osname}_${osver}_Check_${hostname}_${dateFormat}.log"
checkResultLog2="${osname}_${osver}_Check_$hostname.log"

# 통합용 로그 초기화
if [ -f "$logPATH/$checkResultLog2" ]; then
    rm -f "$logPATH/$checkResultLog2"
fi

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
        echo -e "\t- Check result:\t${GREEN}$4\e[0m" | tee -a "$logPATH/$checkResultLog1"
        echo -e "\t- Check result:\t${GREEN}$4\e[0m" >> "$logPATH/$checkResultLog2"

    elif [[ "$4" == *"WARN"* ]]; then
        echo -e "\t- Check result:\t${YELLOW}$4\e[0m" | tee -a "$logPATH/$checkResultLog1"
        echo -e "\t- Check result:\t${YELLOW}$4\e[0m" >> "$logPATH/$checkResultLog2"

    elif [ "$4" = "ERROR" ]; then
        echo -e "\t- Check result:\t${RED}$4\e[0m" | tee -a "$logPATH/$checkResultLog1"
        echo -e "\t- Check result:\t${RED}$$4\e[0m" >> "$logPATH/$checkResultLog2"

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
