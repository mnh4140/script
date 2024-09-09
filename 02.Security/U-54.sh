#!/bin/bash

source securityLog.sh
source textstyle.sh
# Rocky Linux 9.x 전용

function U-54()
{
	# 설정할 파일 경로
        CONFIG_FILE="/etc/profile"
   
   	all_safe=false

        # 취약점 진단 기준 값
	# KISA 권고 사항 : 600(10분) 이하/ 자체 진단 값 : 300(5분) 이하
        #  suggestionValue="Session timeout set.\n\t\t\tTMOUT<=300"

        # 설정 항목 변수
	suggestionValue=""
        currentValue=""
	
	# 값 확인
	if grep -q "^TMOUT" /etc/profile && grep -q "^export\s*TMOUT" /etc/profile; then
		# 설정 값이 있는 지 확인
		issettimeout="${BLUE}Session timeout set.${RESET}"
		# 설정 값 저장
		SETTING_VALUE=$(grep "^TMOUT" /etc/profile | awk -F "=" {'print $2'})
		# 설정값 300 이하면 참
		if [ $SETTING_VALUE -le 300 ]; then
			currentValue="$issettimeout\n\t\t\t${BLUE}TMOUT=$SETTING_VALUE${RESET}"
			all_safe=true
		else
			currentValue="$issettimeout\n\t\t\t${RED}TMOUT=$SETTING_VALUE${RESET}"
		fi
	fi

	

	# 값 비교
	#if [ "$suggestionValue" == "$currentValue" ]; then
        #        all_safe=true
        #fi

	# 취약점 점검 결과
        if $all_safe; then
                securityState="SAFE"
        else
                # 설정 값이 주석 처리 되어있는지 확인
                if [ -z "$currentValue" ]; then
                        securityState="WARN:주석 처리 확인"
                elif [  $SETTING_VALUE -gt 300 ]; then
                        securityState="WARN"
                else
                        securityState="ERROR"
                fi
        fi
	
	suggestionValue="Session timeout set.\n\t\t\tTMOUT<=300"

        securityLog "U-54|Session Timeout 설정" "$suggestionValue" "$currentValue" "$securityState"
	
	# 변수 초기화
	securityState=""
	currentValue=""
	suggestionValue=""
}
