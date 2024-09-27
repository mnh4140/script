#!/bin/bash

source securityLog.sh

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

	# 파일이 존재하는지 확인
	if [ ! -f "$CONFIG_FILE" ]; then
	    echo "$CONFIG_FILE 파일을 찾을 수 없습니다."
	    exit 1
	fi

	for value in "${order[@]}"; do
                recommended_value="${settings[$value]}"
                suggestionValue+="$value : $recommended_value\n\t\t\t"

                # 조치 전 값 저장
                before_value=$(grep -E "^\s*$value\s*=" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
		beforeValue+="$value : $before_value\n\t\t\t"

		echo "stsrt if"
		# 조치
		# 값이 없으면 추가
		if [ -z $before_value ]; then
			echo "before_value : $before_value"
			echo "$value = $recommended_value" >> "$CONFIG_FILE"
			#afterValue+="$value : $before_value\n\t\t\t"
		else
			if [ "$before_value" = "$recommended_value" ]; then
				echo "권장 설정 값으로 설정되어 있습니다."
				#afterValue+="$value : $before_value\n\t\t\t"
			else
				echo "권장 설정값과 다릅니다."
				echo "설정을 변경합니다."
				sed -i -e "s/$value\s=\s$before_value/$value = $recommended_value/g" $CONFIG_FILE
				#after_value=$(grep -E "^\s*$value\s*=" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
				#afterValue+="$value : $after_value\n\t\t\t"
			fi
		fi
		after_value=$(grep -E "^\s*$value\s*=" "$CONFIG_FILE" | awk -F '=' '{print $2}' | tr -d ' ')
                afterValue+="$value : $after_value\n\t\t\t"
	done
: << "END"
                if [ -z $current_value ]; then
                        currentValue+="$current_value"
                        current_key=$(grep -E "^\s*$value\s*=" "$CONFIG_FILE" | awk -F '=' '{print $1}' | tr -d ' ')
                else
                        currentValue+="$value : $current_value\n\t\t\t"
                fi

                # 전체 값 비교를 위한 결과 저장
                if [ "$current_value" != "$recommended_value" ]; then
                        all_safe=false

                fi
        done

: << "END"
	# 각 설정 항목 업데이트 또는 추가
	for key in "${!settings[@]}"; do
	    value="${settings[$key]}"
	    
	    # 주석 처리된 항목이 있는지 확인
	    if grep -q "^#\s*$key" "$CONFIG_FILE"; then
		# 주석을 제거하고 값을 업데이트
		echo "주석을 제거하고 값을 업데이트"
		sed -i "s/^#\s*$key.*/$key = $value/" "$CONFIG_FILE"
	    elif grep -q "^$key" "$CONFIG_FILE"; then
		# 항목이 이미 존재하면 값을 업데이트
		echo "항목이 이미 존재하면 값을 업데이트"
		sed -i "s/^$key.*/$key = $value/" "$CONFIG_FILE"
	    else
		# 항목이 존재하지 않으면 파일 끝에 추가
		echo "항목이 존재하지 않으면 파일 끝에 추가"
		echo "$key = $value" >> "$CONFIG_FILE"
	    fi
	    currentValue+="$value"
	done
END
	echo "설정이 완료되었습니다."

	# 로깅
	FixLog "U-02|패스워드 복잡성 설정" "$suggestionValue" "$beforeValue" "$afterValue" "$securityState"

}
U-02
