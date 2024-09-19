#!/bin/bash


function U-48() {
    
	suggestionValue="PASS_MIN_DAYS : 90"

	all_safe=false

	CONFIG_FILE="/etc/login.defs"
	
    	currentValue=""


    	if grep -q "^s\?PASS_MIN_DAYS" "$CONFIG_FILE"; then
		currentValue="PASS_MIN_DAYS : $(grep "^s\?PASS_MIN_DAYS" /etc/login.defs | awk -F " " '{print $2}')"
	    	if [ "$currentValue" == "$suggestionValue" ]; then
			all_safe=true
	    	fi
    	fi

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

    securityLog "U-48|패스워드 최소 사용기간 설정" "$suggestionValue" "$currentValue" "$securityState"
}
