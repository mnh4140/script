#!/bin/bash


function U-11() {
        # 설정할 파일 경로
        CONFIG_FILE="/etc/rsyslog.conf"

        # 결과 값
        is_safe=false

        # 취약점 진단 기준 값
        suggestion_permission=644
	suggestion_owner="root"

	if [ -e $CONFIG_FILE ]; then # 설정 파일이 존재
		permission=$(stat -c "%a" $CONFIG_FILE)
        	owner=$(stat -c "%U" $CONFIG_FILE)

		if [ "$permission" == "$suggestion_permission" ] && [ "$owner" = "$suggestion_owner" ]; then
			is_safe=true
		fi
	else
		securityState="ERROR:설정파일 없음"
	fi

	if [ -z "$securityState" ]; then # $securityState 값 없으면
                if $is_safe; then # is_safe값 참이면
                        securityState="SAFE"
                else # 거짓이면
                        securityState="WARN"
                fi
        fi

        suggestionValue="Set Permission $suggestion_permission, Owner is $suggestion_owner"
        currentValue="Permission : $permission\n\t\t\tOwner : $owner"

        securityLog "${FUNCNAME[0]}|$CONFIG_FILE 파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"

	init_var
}
