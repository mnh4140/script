#!/bin/bash


function U-14() {
        # 설정할 파일 경로
        # CONFIG_FILE="/etc/services"


        # 결과 값
        is_safe=true

        # 취약점 진단 기준 값
        #suggestion_permission=644
	#suggestion_owner="root"



	# 환경변수 파일
        env_files=(".bashrc" ".bash_profile" ".bash_logout" ".bash_history")

	# 사용자들의 홈 디렉터리 확인
	for user in $(awk -F: '$3 >= 1000 {print $1}' /etc/passwd); do # /etc/passwd 파일에서 UID 값이 1000 이상인 일반 사용자 홈디렉터리 확인
		# nobody 계정은 예외처리
		if [ "$user" = "nobody" ]; then
        		#echo "Skipping user: $user (nobody account)"
        		continue
    		fi

    		home_dir=$(eval echo ~$user) # 사용자의 홈 디렉터리
    		#echo "Checking home directory for user: $user ($home_dir)"
		
		for env_file in "${env_files[@]}"; do
        		file_path="$home_dir/$env_file"
        
        		if [ -e "$file_path" ]; then
            			#echo "Checking file: $file_path"

				# 파일의 소유자와 권한을 변수로 저장
				owner=$(stat -c "%U" "$file_path")
            			permissions=$(stat -c "%a" "$file_path")

				# 소유자가 root 또는 해당 사용자이고, 권한이 644 이하인지 확인
            			if [ "$owner" = "root" ] || [ "$owner" = "$user" ]; then
                			if [ "$permissions" -le 644 ]; then
                    				#echo "SAFE: $file_path (소유자: $owner, 권한: $permissions)"
						currentValue+="SAFE: $file_path (소유자: $owner, 권한: $permissions)\n\t\t\t"
                			else
                    				#echo "WARN: $file_path 권한이 644를 초과함 (현재 권한: $permissions)"
                    				securityState="WARN: $file_path 권한이 644를 초과함 (현재 권한: $permissions)"
						currentValue+="WARN: $file_path 권한이 644를 초과함 (현재 권한: $permissions)\n\t\t\t"
						is_safe=false
                			fi
            			else
                			#echo "WARN: $file_path 소유자가 root 또는 $user가 아님 (현재 소유자: $owner)"
                			securityState="WARN: $file_path 소유자가 root 또는 $user가 아님 (현재 소유자: $owner)"
					currentValue+="WARN: $file_path 소유자가 root 또는 $user가 아님 (현재 소유자: $owner)\n\t\t\t"
					is_safe=false
            			fi
        		else
            			#echo "파일 $file_path 존재하지 않음"
				currentValue+="ERROR: 파일 $file_path 존재하지 않음\n\t\t\t"
				securityState="ERROR: 파일 $file_path 존재하지 않음"
				is_safe=false
        		fi
            
    		done
	done

	#echo securityState "$securityState"
	if [ -z "$securityState" ]; then
		if $is_safe; then # is_safe값 참이면
        		securityState="SAFE"
		fi
        fi

        suggestionValue="환경변수 파일 소유자가 root 또는 해당 사용자이고, 권한이 644 이하"
        #currentValue="Permission : $permission\n\t\t\tOwner : $owner"

        securityLog "${FUNCNAME[0]}|사용자, 시스템 시작파일 및 환경파일 소유자 및 권한 설정" "$suggestionValue" "$currentValue" "$securityState"
	
	# 변수 초기화
	init_var
}
