#!/bin/bash


function U-01() {
	# 설정할 파일 경로
        CONFIG_FILE="/etc/security/pwquality.conf"

	# 결과 값
	is_safe=false

	# 취약점 진단 기준 값
        suggestionValue="no"

	# 현재 설정값
	currentValue="$(grep '^\s*PermitRootLogin' $CONFIG_FILE | awk -F " " '{print $2}')"

	# 설정 값이 존재여부 확인
	if [ -e $CONFIG_FILE  ]; then # 설정 파일이 존재여부 확인
		if [ -z "$currentValue" ]; then # 설정값이 없으면
			if grep "^#\s*PermitRootLogin" "$CONFIG_FILE"; then # 주석 처리 검사
				is_comment=true
				currentValue="Comment"
			fi
		else # 설정 값이 존재
			if [ "$suggestionValue" == "$currentValue" ]; then
                		is_safe=true
				currentValue="PermitRootLogin no"

        		fi
		fi

		if $is_comment || $is_safe; then # 설정값이 주석이면 참
			securityState="SAFE"
		elif [ "$currentValue" == "yes" ]; then # 설정값이 yes면 취약
			securityState="WARN"
		else
			securityState="ERROR"
		fi
	else
		securityState="ERROR:설정파일 없음"
	fi

	suggestionValue="Set PermitRootLogin no or Comment"

	securityLog "U-01|root 계정 원격 접속 제한" "$suggestionValue" "$currentValue" "$securityState"
}
#U-01
