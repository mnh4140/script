#!/bin/bash


function U-20() {
	# 설정할 파일 경로
        CONFIG_FILE="/etc/passwd"

	# 결과 값
	is_safe=false

	# 취약점 진단 기준 값
        suggestionValue="/etc/passwd 파일에 ftp 계정 삭제"

	# 현재 설정값
	currentValue="$(grep '^\s*PermitRootLogin' $CONFIG_FILE | awk -F " " '{print $2}')"

	user_ftp=$(grep ftp $CONFIG_FILE | awk -F ":" '{print $1}')

	# ftp or anonymous 계정 여부 확인
	if [ -e $CONFIG_FILE ]; then # 설정 파일이 존재여부 확인
		if [ -n "$user_ftp" ]; then # 계정 존재하면
			is_safe=false
			currentValue="/etc/passwd 파일에 ftp 계정 존재"
		else # 존재 안하면
			is_safe=true
			currentValue="/etc/passwd 파일에 ftp 계정 없음"
		fi
	else
		securityState="ERROR:$CONFIG_FILE 없음"
	fi


	if $is_safe; then # 설정값이 주석이면 참
        	securityState="SAFE"
        else
        	securityState="WARN"
        fi

	securityLog "${FUNCNAME[0]}|Anonymous FTP 비활성화" "$suggestionValue" "$currentValue" "$securityState"

	# 변수 초기화
	init_var
}
