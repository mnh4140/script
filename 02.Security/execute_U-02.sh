#!/bin/bash

source securityLog.sh

# Rocky Linux 9.x 전용

# 미완성
function U-02() {

	# 설정할 파일 경로
	CONFIG_FILE="/etc/security/pwquality.conf"

	# 권장 설정 값
	suggestionValue="10-1-1-1-1"

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

	# 각 설정 항목 업데이트 또는 추가
	for key in "${!settings[@]}"; do
	    value="${settings[$key]}"
	    
	    # 주석 처리된 항목이 있는지 확인
	    if grep -q "^#\s*$key" "$CONFIG_FILE"; then
		# 주석을 제거하고 값을 업데이트
		sed -i "s/^#\s*$key.*/$key = $value/" "$CONFIG_FILE"
	    elif grep -q "^$key" "$CONFIG_FILE"; then
		# 항목이 이미 존재하면 값을 업데이트
		sed -i "s/^$key.*/$key = $value/" "$CONFIG_FILE"
	    else
		# 항목이 존재하지 않으면 파일 끝에 추가
		echo "$key = $value" >> "$CONFIG_FILE"
	    fi
	done

	echo "설정이 완료되었습니다."

	# 로깅
	securityLog "U-02|패스워드 복잡성 설정" "$suggestionValue" "$currentValue" "$securityState"

}
