#!/bin/bash


# Rocky Linux 9.x 전용

function U-03() {

	suggestionValue=""
	beforeValue=""

	# 설정할 파일 경로
        #CONFIG_FILE="/etc/security/faillock.conf"
	CONFIG_FILE="testfile"

	is_chaged=false

	# 취약점 진단 기준 값
	suggestionValue=5

	# 설정 항목 변수
	SETTING_VALUE="deny"

	# 현재 설정 값
	beforeValue=$(grep -E "^\s*$SETTING_VALUE\s*=" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')

	if [ "$suggestionValue" != "$beforeValue" ]; then
		if [ -z "$beforeValue" ]; then
			echo "$SETTING_VALUE = $suggestionValue" >> $CONFIG_FILE
		else
			sed -i "s/$SETTING_VALUE = $beforeValue/$SETTING_VALUE = $suggestionValue/g" $CONFIG_FILE
		fi

		is_chaged=true
	else
		is_chaged="SAFE"
	fi

	afterValue=$(grep -E "^\s*$SETTING_VALUE\s*=" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')

	if [ "$is_chaged" = "SAFE" ]; then
		securityState="SAFE"
	else
		if $is_chaged; then
			securityState="FIX"
		else
			securityState="NOT FIX"
		fi
	fi


: << END
	if [ "$suggestionValue" == "$beforeValue" ]; then
		all_safe=true
	fi

	# 취약점 점검 결과
	if $all_safe; then
                securityState="SAFE"
	else
		# 설정 값이 주석 처리 되어있는지 확인
		if [ -z $beforeValue ]; then
                        securityState="WARN:주석 처리 확인"
                elif [ $suggestionValue != $beforeValue ]; then
                        securityState="WARN"
                else
                        securityState="ERROR"
                fi
        fi
END
	FixLog "${FUNCNAME[0]}|계정 잠금 임계값 설정" "$suggestionValue" "$beforeValue" "$afterValue" "$securityState"
}
