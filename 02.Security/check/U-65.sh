#!/bin/bash


function U-65() {
        # 설정할 파일 경로
        # CONFIG_FILE="/etc/services"
	at_files=("/etc/at.deny" "/etc/at.allow")
	at_file="/usr/bin/at"
        
	# 결과 값
        is_safe=true

	if [ -e "$at_file" ]; then
		at_permissions=$(stat -c "%a" "$at_file")
		if [ "$at_permissions" -gt 750 ]; then
			is_safe=false
			currentValue+="$at_file SUID 설정됨 (권한: $at_permissions)\n\t\t\t"
		else
			currentValue+="$at_file SUID 설정 안됨 (권한: $at_permissions)\n\t\t\t"
		fi
	else
		 currentValue+="$at_file 파일 없음\n\t\t\t"
	fi


	for file in "${at_files[@]}"; do
		if [ -e "$file" ]; then
			owner=$(stat -c "%U" "$file")
                        permissions=$(stat -c "%a" "$file")

			if [ "$owner" = "root" ]; then
	                        if [ "$permissions" -le 640 ]; then
					currentValue+="$file (소유자: $owner, 권한: $permissions)\n\t\t\t"
				else
					currentValue+="$file 권한이 640를 초과함 (현재 권한: $permissions)\n\t\t\t"
					is_safe=false
				fi
			else
	                	#echo "WARN: $file_path 소유자가 root 또는 $user가 아님 (현재 소유자: $owner)"
				#securityState="WARN: $file 소유자가 root 또는 $user가 아님 (현재 소유자: $owner)"
                        	currentValue+="$file 소유자가 root 또는 $user가 아님 (현재 소유자: $owner)\n\t\t\t"
                        	is_safe=false
                	fi

		else
                	#echo "파일 $file_path 존재하지 않음"
                        currentValue+="$file 존재하지 않음\n\t\t\t"
                        # securityState="ERROR: $file_path  파일 존재하지 않음"
                        # is_safe=false
                fi

	done

	#echo securityState "$securityState"
	if [ -z "$securityState" ]; then
		if $is_safe; then # is_safe값 참이면
        		securityState="SAFE"
		else
			securityState="WARN"
		fi
        fi

	suggestionValue="at 명령어 일반사용자 금지(SUID 해제) 및 at 관련 파일 640 이하"
        #currentValue="Permission : $permission\n\t\t\tOwner : $owner"

        securityLog "${FUNCNAME[0]}|at 파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"
	
	# 변수 초기화
	init_var
}
