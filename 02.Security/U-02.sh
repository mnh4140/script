#!/bin/bash

source securityLog.sh

# Rocky Linux 9.x 전용

function U-02() {
	# 설정할 파일 경로
	CONFIG_FILE="/etc/security/pwquality.conf"
	
	# 설정 항목 순서를 유지하기 위한 배열
	order=("minlen" "dcredit" "ucredit" "lcredit" "ocredit")

	suggestionValue=""
	currentValue=""
	
	# 권장 설정 항목과 값
	declare -A recommended_settings
	recommended_settings=(
		["minlen"]=10
		["dcredit"]=-1
             	["ucredit"]=-1
             	["lcredit"]=-1
             	["ocredit"]=-1
	)

	all_safe=true

	for value in "${order[@]}"; do
		recommended_value="${recommended_settings[$value]}"
		suggestionValue+="$value : $recommended_value\n\t\t\t"

		# 주석이 아닌 설정 값을 찾기
		current_value=$(grep -E "^\s*$value\s*=" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')

		if [ -z $current_value ]; then
			currentValue+="$current_value"
			current_key=$(grep -E "^\s*$value\s*=" "$CONFIG_FILE" | awk -F '=' '{print $1}' | tr -d ' ')
		else
			currentValue+="$current_key : $current_value\n\t\t\t"
		fi

		# 전체 값 비교를 위한 결과 저장
		if [ "$current_value" != "$recommended_value" ]; then
			all_safe=false

		fi
	done


	if $all_safe; then
		securityState="SAFE"
	else
		if [ -z "$currentValue" ]; then
			securityState="WARN:주석 처리 확인"
		elif [ "$suggestionValue" != "$currentValue" ]; then
			securityState="WARN"
		else
			securityState="ERROR"
		fi
	fi

	securityLog "U-02|패스워드 복잡성 설정" "$suggestionValue" "$currentValue" "$securityState"
}
