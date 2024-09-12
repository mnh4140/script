#!/bin/bash

source securityLog.sh
source Initialize_variables.sh
function test() {
	test=$'\S\nKernel \\r on an \m'

	if [ "$test" == "$(cat /etc/issue)" ]; then
		echo "same"
	else
		echo "else"
	fi
}

function U-68() {
        # 설정할 파일 경로
        # CONFIG_FILE="/etc/services"
	# at_files=("/etc/at.deny" "/etc/at.allow")
	# at_file="/usr/bin/at"
        
	cmp1=$(cat /etc/motd)
	cmp2=$(cat /etc/issue.net)
	cmp3=$(cat /etc/issue)

	config_files=("/etc/motd" "/etc/issue.net" "/etc/issue")
	#config_files=("/etc/motd" "script_test_config/test" "/etc/issue")

	# /etc/motd : 사용자가 로그인 후에 표시되는 메시지(오늘의 메시지)
	# /etc/issue : 로그인 전 로컬 콘솔에서 표시되는 메시지(운영체제 정보 등)
	# /etc/issue.net : 로그인 전 원격 접속(SSH 등) 시 표시되는 메시지

	# 결과 값
        is_safe=true


	default_set=$'\S\nKernel \\r on an \m'


	for file in "${config_files[@]}"; do
		if [ -e "$file" ]; then
			if [ -z "$(cat $file)" ]; then
				is_safe=false
				currentValue+="$file \t경고 메시지 설정 안됨\n\t\t\t"
			else
				if [ "$default_set" == "$(cat $file)" ]; then
					is_safe=false
					currentValue+="$file \t경고 메시지 설정 안됨\n\t\t\t"
				else
					currentValue+="$file \t경고 메시지 설정됨 \n\t\t\t\t(경고 메시지 일부: $(head -c 50 $file))\n\t\t\t"
				fi
				#currentValue+="$file \t경고 메시지 설정됨 (경고 메시지: $(cat $file))\n\t\t\t"
			fi
		else
			securityState="ERROR:파일이 없음"
			currentValue+="$file \t파일이 없음\n\t\t\t"
		fi
	done
	
	if [ -z "$securityState" ]; then
                if $is_safe; then # is_safe값 참이면
                        securityState="SAFE"
                else
                        securityState="WARN"
                fi
        fi

	suggestionValue="서버 및 Telnet, FTP, SMTP, DNS 서비스에 로그온 메시지가 설정되어 있는 경우"
        #currentValue="Permission : $permission\n\t\t\tOwner : $owner"

        securityLog "${FUNCNAME[0]}|로그온 시 경고 메시지 제공" "$suggestionValue" "$currentValue" "$securityState"
	
	# 변수 초기화
	init_var
}
