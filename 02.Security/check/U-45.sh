#!/bin/bash

# Rocky Linux 9.x 전용

function U-45()
{
	# 설정할 파일 경로
        CONFIG_FILE="/etc/pam.d/su"
   
   	all_safe=false

        # 취약점 진단 기준 값
        suggestionValue="The wheel group exists.\n\t\t\tpam_wheel.so configuration set"

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
