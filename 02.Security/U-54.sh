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
        suggestionValue="TMOUT : 500"

        # 설정 항목 변수
        #SETTING_VALUE="deny"

	# wheel 그룹 유무 확인
	if grep -q "^wheel:" /etc/group; then
		currentValue="${BLUE}The wheel group exists.${RESET}"
	else
		currentValue="${RED}The wheel group does not exist.${RESET}"
	fi

	
	# 값 확인
	if grep -q "^wheel:" /etc/group; then
		currentValue="The wheel group exists."
		if grep -q "^\s*auth\s*required\s*pam_wheel.so*" /etc/pam.d/su; then
			currentValue+="\n\t\t\t${BLUE}mpam_wheel.so configuration set${RESET}"
			all_safe=true
		else
			currentValue+="${RED}\n\t\t\tpam_wheel.so configuration not set${RESET}"
		fi
	else
		currentValue="The wheel group does not exist."
	fi

	

	# 값 비교
	if [ "$suggestionValue" == "$currentValue" ]; then
                all_safe=true
        fi

	# 취약점 점검 결과
        if $all_safe; then
                securityState="SAFE"
        else
                # 설정 값이 주석 처리 되어있는지 확인
                if [ -z "$currentValue" ]; then
                        securityState="WARN:주석 처리 확인"
                elif [ "$suggestionValue" != "$currentValue" ]; then
                        securityState="WARN"
                else
                        securityState="ERROR"
                fi
        fi

        securityLog "U-45|root 계정 su 제한" "$suggestionValue" "$currentValue" "$securityState"
	suggestionValue=""
	currentValue=""

}
function SessionTimeOut()
{
	if [ -n "$cmp1" ]
        then
        	cmp1=$(cat /etc/profile | grep TMOUT | awk -F "=" '{print $2}')
        	if [ "$cmp1" -le 300 ]
        	then
        		#안전
        		echo "10.[U-54|Session Timeout 설정] : SAFE\n" >> ./.SecurityInfo
        	else
        		#위험
        		echo "10.[U-54|Session Timeout 설정] : WARN\n" >> ./.SecurityInfo
        	fi
	else
		#위험
        	echo "10.[U-54|Session Timeout 설정] : WARN\n" >> ./.SecurityInfo
        	echo "Value not exist"
        	echo ""
	fi
	echo " *suggest: TMOUT=300 Under value\n" >> ./.SecurityInfo
	echo " *current: $(cat /etc/profile | grep TMOUT=)\n\n" >> ./.SecurityInfo
	Progress=38
	echo $Progress | dialog --backtitle "$BACKTITLE" --title "$TITLE" --gauge "Please wait...\n\n   [U-54|Session Timeout 설정] Check... " 10 95 0
}
