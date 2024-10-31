#!/bin/bash

# Rocky Linux 9.x 전용

function U-45()
{
	# 설정할 파일 경로
        #CONFIG_FILE="/etc/pam.d/su"
        CONFIG_FILE="testfile"

   
   	#all_safe=false
	is_safe=false
	is_changed=false
	is_error=false

        # 취약점 진단 기준 값
        suggestionValue="auth\t\trequired\t\tpam_wheel.so use_uid"

        # 설정 항목 변수
        #SETTING_VALUE="deny"

	# 설정 파일
	# /etc/group
	# /etc/pam.d/su

	#GROUP_CONF=/etc/group
	GROUP_CONF=testfile
	#SU_CONF=/etc/pam.d/su
	SU_CONF=testfile

	# config 파일 유무 확인
	if [ -e "$GROUP_CONF" ]; then
	       if [ -e "$SU_CONF" ]; then
		       # wheel 그룹 유무 확인
		       if grep -q "^wheel:" $GROUP_CONF; then
			       #beforeValue="${BLUE}The wheel group exists.${RESET}"
			       # wheel 그룹 사용 설정 확인
			       if grep -q "^\s*auth\s*required\s*pam_wheel.so*" $SU_CONF; then
				       beforeValue=$(grep "auth\s*required\s*pam_wheel.so use_uid" "$SU_CONF")
				       is_safe=true
			       else
				       beforeValue="${RED}\n\t\t\tpam_wheel.so configuration not set${RESET}"
			       fi
		       else
			       beforeValue="${RED}The wheel group does not exist.${RESET}"
		       fi
	       else
		       is_error=true
	       fi
	else
		is_error=true
	fi

	# 에러 검사(설정 파일 미존재 등)
	if $is_error; then
		securityState="ERROR"
	else
		# 취약점 안전 유무 확인
		if $is_safe; then
			securityState="SAFE"
		else
			sed -i -e "/account/i\$suggestionValue" "$SU_CONF"
			is_changed=true
		fi
	fi

	afterValue=$(grep "^\s*auth\s*required\s*pam_wheel.so*" "$SU_CONF")

	if $is_changed; then
		securityState="FIX"
	else
		securityState="NOT FIX"
	fi
	
        FixLog "${FUNCNAME[0]}|root 계정 su 제한" "$suggestionValue" "$beforeValue" "$afterValue" "$securityState"

}
