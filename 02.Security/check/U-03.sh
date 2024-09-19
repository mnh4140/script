#!/bin/bash


# Rocky Linux 9.x 전용

function U-03() {

	suggestionValue=""
	currentValue=""
	# 설정할 파일 경로
        CONFIG_FILE="/etc/security/faillock.conf"

	all_safe=false

	# 취약점 진단 기준 값
	suggestionValue=5

	# 설정 항목 변수
	SETTING_VALUE="deny"

	# 현재 설정 값
	currentValue=$(grep -E "^\s*$SETTING_VALUE\s*=" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')

	if [ "$suggestionValue" == "$currentValue" ]; then
		all_safe=true
	fi

	# 취약점 점검 결과
	if $all_safe; then
                securityState="SAFE"
	else
		# 설정 값이 주석 처리 되어있는지 확인
		if [ -z $currentValue ]; then
                        securityState="WARN:주석 처리 확인"
                elif [ $suggestionValue != $currentValue ]; then
                        securityState="WARN"
                else
                        securityState="ERROR"
                fi
        fi

	securityLog "U-03|계정 잠금 임계값 설정" "$suggestionValue" "$currentValue" "$securityState"
}
