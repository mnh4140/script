#!/bin/bash

# Rocky Linux 9.x 전용

# 미완성
function U-02() {

	# 설정할 파일 경로
	#CONFIG_FILE="/etc/security/pwquality.conf"
	CONFIG_FILE="testfile"

	# 권장 설정 값
	#suggestionValue="10-1-1-1-1"

	# 설정 항목 순서를 유지하기 위한 배열
        order=("minlen" "dcredit" "ucredit" "lcredit" "ocredit")

	# 설정할 항목과 값
	declare -A settings
	settings=(
	    ["minlen"]=10
	    ["dcredit"]=-1
	    ["ucredit"]=-1
	    ["lcredit"]=-1
	    ["ocredit"]=-1
	)

	is_changed=false

	# 파일이 존재하는지 확인
	if [ ! -f "$CONFIG_FILE" ]; then
	    exit 1
	fi

	for value in "${order[@]}"; do
                recommended_value="${settings[$value]}"
                suggestionValue+="$value : $recommended_value\n\t\t\t"

                # 조치 전 값 저장
                before_value=$(grep -E "^\s*$value\s*=" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
		beforeValue+="$value : $before_value\n\t\t\t"

		# 조치
		# 값이 없으면 추가
		if [ -z $before_value ]; then
			echo "$value = $recommended_value" >> "$CONFIG_FILE"
			is_changed=true
		else
			if [ "$before_value" == "$recommended_value" ]; then
				is_changed="SAFE"
			else
				sed -i -e "s/$value\s=\s$before_value/$value = $recommended_value/g" $CONFIG_FILE
				is_changed=true
			fi
		fi
		after_value=$(grep -E "^\s*$value\s*=" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
                afterValue+="$value : $after_value\n\t\t\t"
	done

	if [ "$is_changed" = "SAFE" ]; then
                securityState="SAFE"
        else
                if $is_changed; then
                        securityState="FIX"
                else
                        securityState="NOT FIX"
                fi
        fi

	# 로깅
	FixLog "U-02|패스워드 복잡성 설정" "$suggestionValue" "$beforeValue" "$afterValue" "$securityState"

}
