#!/bin/bash


function U-69() {
        # 설정할 파일 경로
        CONFIG_FILE="/etc/exports"

	# 결과 값
        is_safe=true

	owner=$(stat -c "%U" "$CONFIG_FILE")
        permissions=$(stat -c "%a" "$CONFIG_FILE")

	if [ -e "$CONFIG_FILE" ]; then
		if [ "$owner" = "root" ]; then
			if [ "$permissions" -le 644 ]; then
				currentValue="SAFE: $CONFIG_FILE (소유자: $owner, 권한: $permissions)\n\t\t\t"
			else
				securityState="WARN: $CONFIG_FILE 권한이 644를 초과함 (현재 권한: $permissions)"
                                currentValue="$CONFIG_FILE 권한이 644를 초과함 (현재 권한: $permissions)\n\t\t\t"
			fi
		else
			securityState="WARN: $CONFIG_FILE 소유자가 root 가 아님 (현재 소유자: $owner)"
                        currentValue="$CONFIG_FILE 소유자가 root 가 아님 (현재 소유자: $owner)\n\t\t\t"
		fi
	else
		securityState="SAFE:파일이 없음"
		currentValue="$CONFIG_FILE \t파일이 없음\n\t\t\t"
	fi
	
	if [ -z "$securityState" ]; then
                if $is_safe; then # is_safe값 참이면
                        securityState="SAFE"
                else
                        securityState="WARN"
                fi
        fi

	suggestionValue="NFS 접근제어 설정파일의 소유자가 root 이고, 권한이 644 이하"
        #currentValue="Permission : $permission\n\t\t\tOwner : $owner"

        securityLog "${FUNCNAME[0]}|NFS설정파일 접근 권한" "$suggestionValue" "$currentValue" "$securityState"
	
	# 변수 초기화
	init_var
}
