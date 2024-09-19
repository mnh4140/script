#!/bin/bash


function U-56() {
        # 설정할 파일 경로
        CONFIG_FILE="/etc/profile"

        # 결과 값
        is_safe=false

        # 취약점 진단 기준 값
	suggestionValue=022

	currentValue=$(grep "umask" "$CONFIG_FILE" | awk -F ' ' '{print $2}')
	#currentValue=$(grep "umask" test | awk -F ' ' '{print $2}')

	if [ -e "$CONFIG_FILE" ]; then # 설정 파일이 존재
		#
		if [ -z "$currentValue" ]; then
			securityState="WARN:값이 설정되어있지 않거나 주석처리 되어있음"
		elif [ "$currentValue" -ge "$suggestionValue" ]; then
			is_safe=true
		else
			securityState="WARN"
		fi
	else
		securityState="ERROR:설정파일 없음"
	fi

	if $is_safe; then # $securityState 값 없으면
                securityState="SAFE"
        fi

        suggestionValue="$CONFIG_FILE UMASK 값이 $suggestionValue 이상로 설정"
        currentValue="$CONFIG_FILE UMASK : $currentValue"

        securityLog "${FUNCNAME[0]}|UMASK 설정 관리" "$suggestionValue" "$currentValue" "$securityState"

	init_var
}
