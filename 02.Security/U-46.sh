#!/bin/bash

source securityLog.sh
source Initialize_variables.sh

function U-46() {
    suggestionValue="10"

    CONFIG_FILE="/etc/security/pwquality.conf"

    is_safe=true

    currentValue=$(grep "^minlen" script_test_config/test | awk -F " " '{print$3}')
    echo "currentValue $currentValue"

    
    if [ "$currentValue" -ge "$suggestionValue" ]; then
	    is_safe=true
    else
	    is_safe=false
    fi



    if $is_safe; then
            securityState="SAFE"
    else
	    if [ -z "$currentValue" ]; then
		    securityState="WARN:주석확인"
	    else
		    securityState="WARN"
	    fi
    fi



    securityLog "${FUNCNAME[0]}|패스워드 최소 길이 설정" "$suggestionValue" "$currentValue" "$securityState"

    init_var
}
