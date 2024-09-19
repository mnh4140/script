#!/bin/bash


function U-72() {
	#var=($var1 "$var2" "$var3" "$var4" "$var5" "$var6")
	#echo "var : $var"

	CONFIG_FILE="/etc/rsyslog.conf"

	# key1=$(grep "^\*\.info;mail.none;authpriv.none;cron.none" /etc/rsyslog.conf | awk -F " " '{print $1}')
	key1="^\*\.info;mail.none;authpriv.none;cron.none"
	#key2=$(grep "^authpriv\.\*" /etc/rsyslog.conf | awk -F " " '{print $1}')
	key2="^authpriv\.\*"
	#key3=$(grep "^mail\.\*" /etc/rsyslog.conf | awk -F " " '{print $1}')
	key3="^mail\.\*"
	#key4=$(grep "^cron\.\*" /etc/rsyslog.conf | awk -F " " '{print $1}')
	key4="^cron\.\*"
	#key5=$(grep "^\*\.alert" /etc/rsyslog.conf | awk -F " " '{print $1}')
	key5="^\*\.alert"
	#key6=$(grep "^\*\.emerg" /etc/rsyslog.conf | awk -F " " '{print $1}')
	key6="^\*\.emerg"

	# value1=$(grep "^\*\.info;mail.none;authpriv.none;cron.none" /etc/rsyslog.conf | awk -F " " '{print $2}')
	value1=$(grep "^\*\.info;mail.none;authpriv.none;cron.none" /etc/rsyslog.conf | awk -F " " '{print $2}')
	value2=$(grep "^authpriv\.\*" /etc/rsyslog.conf | awk -F " " '{print $2}')
	value3=$(grep "^mail\.\*" /etc/rsyslog.conf | awk -F " " '{print $2}')
	value4=$(grep "^cron\.\*" /etc/rsyslog.conf | awk -F " " '{print $2}')
	value5=$(grep "^\*\.alert" /etc/rsyslog.conf | awk -F " " '{print $2}')
	value6=$(grep "^\*\.emerg" /etc/rsyslog.conf | awk -F " " '{print $2}')

	r_value1="/var/log/messages"
        r_value2="/var/log/secure"
        r_value3="/var/log/maillog"
        r_value4="/var/log/cron"
        r_value5="/dev/console"
        r_value6="*"

	var=("$var1" "$var2" "$var3" "$var4" "$var5" "$var6")

	order=("$key1" "$key2" "$key3" "$key4" "$key5" "$key6")
	#order=("$value1" "$value2" "$value3" "$value4" "$value5" "$value6")

	declare -A recommended_settings
        recommended_settings=(
                #["$key1"]="$value1"
                ["$key1"]="$r_value1"
                ["$key2"]="$r_value2"
                ["$key3"]="$r_value3"
                ["$key4"]="$r_value4"
                ["$key5"]="$r_value5"
		["$key6"]="$r_value6"
        )

	#echo "var : ${var[@]}"

        for value in "${order[@]}"; do
		#echo "value : $value"
		recommended_value="${recommended_settings[$value]}"
		#echo "recommended_value : $recommended_value"
		current_value=$(grep "$value" "$CONFIG_FILE" | awk -F " " '{print $2}')
		#echo -e "current_value : $current_value"

		if [ -z $current_value ]; then
                        #currentValue+="$current_value"
			#currentValue+="$value : 없음"
			currentValue+=$(printf "%-45s   %-40s\n\t\t\t" "$value" "없음")
			#echo -e "currentValue : $currentValue"
                else
                        current_key=$(grep "$value" "$CONFIG_FILE" | awk -F " " '{print $1}')
			#echo "current_key : $current_key"

                        #currentValue+="$current_key : $current_value\n\t\t\t"
			currentValue+=$(printf "%-45s   %-40s\n\t\t\t" "$current_key" "$current_value")
			#echo -e "currentValue : $currentValue\n"
                fi

		# 전체 값 비교를 위한 결과 저장
                if [ "$current_value" != "$recommended_value" ]; then
                        all_safe=false

                fi
        done


	if $all_safe; then
                securityState="SAFE"
        else
                if [ -z "$currentValue" ]; then
                        securityState="WARN:주석 처리 확인"
                elif [ "$suggestionValue" != "$currentValue" ]; then
                        securityState="WARN"
                else
                        securityState="ERROR"
                fi
        fi
	
	#suggestionValue="로그 기록 정책이 정책에 따라 설정되어 있으며 보안정책에 따라 로그를 남김"
	suggestionValue="로그 기록 정책이 정책에 따라 설정되어 있으며 보안정책에 따라 로그를 남김\n\t\t\t*.info;mail.none;authpriv.none;cron.none\t/var/log/messages\n\t\t\tauthpriv.*\t\t\t\t\t/var/log/secure\n\t\t\tmail.*\t\t\t\t\t\t/var/log/maillog\n\t\t\tcron.*\t\t\t\t\t\t/var/log/cron\n\t\t\t*.alert\t\t\t\t\t\t/dev/console\n\t\t\t*.emerg\t\t\t\t\t\t*\n"
        #currentValue="Permission : $permission\n\t\t\tOwner : $owner"

        securityLog "${FUNCNAME[0]}|정책에 따른 시스템 로깅 설정" "$suggestionValue" "$currentValue" "$securityState"

        # 변수 초기화
        init_var
}
