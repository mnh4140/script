#!/bin/bash

source securityLog.sh

# Rocky Linux 9.x 전용

function U-04()
{
	# 설정할 파일 경로
        #CONFIG_FILE="/etc/security/faillock.conf"
	shadow_file="/etc/shadow"
        passwd_file="/etc/passwd"
   
   	all_safe=false

        # 취약점 진단 기준 값
        suggestionValue=$(grep -c -v '^$' "$passwd_file")

        # 설정 항목 변수
        SETTING_VALUE="deny"

	# 비밀번호가 암호화 되어 있는 계정 수
	#encrypted_count=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)
	currentValue=$(awk -F: '$2 == "x" {count++} END {print count}' $passwd_file)

	# 전체 계정 수
	#total_accounts=$(grep -c -v '^$' "$passwd_file")

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

        securityLog "U-04|패스워드 파일 보호" "$suggestionValue" "$currentValue" "$securityState"

}
