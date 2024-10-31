#!/bin/bash


# Rocky Linux 9.x 전용

function U-04()
{
	# 설정할 파일 경로
        #CONFIG_FILE="/etc/security/faillock.conf"
	shadow_file="/etc/shadow"
        passwd_file="/etc/passwd"
   
   	is_changed=false

        # 취약점 진단 기준 값
        suggestionValue=$(grep -c -v '^$' "$passwd_file") # 빈줄을 제외하고 출력

        # 설정 항목 변수
        # SETTING_VALUE="deny"

	# 비밀번호가 암호화 되어 있는 계정 수
	#encrypted_count=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)
	#currentValue=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)
	beforeValue=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)

	# 전체 계정 수
	#total_accounts=$(grep -c -v '^$' "$passwd_file")

	if [ -e "$shadow_file" ]; then
		if [ "$beforeValue" -eq "$suggestionValue" ]; then
			is_changed="SAFE"
		else
			pwconv
		fi
	else
		pwconv
	fi

	afterValue=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)

	if [ "$is_chaged" = "SAFE" ]; then
                securityState="SAFE"
	else
		if $is_chaged; then
                        securityState="FIX"
                else
                        securityState="NOT FIX"
                fi
        fi

        FixLog "${FUNCNAME[0]}|패스워드 파일 보호" "$suggestionValue" "$beforeValue" "$afterValue" "$securityState"
}
