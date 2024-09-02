#!/bin/bash

source securityLog.sh

function U-47() {
    suggestionValue="90"

    currentValue=$(cat /etc/login.defs | egrep ^PASS_MAX_DAYS | awk '{print$2}') # 설정 값이 주석인지 확인
    if [ "$currentValue" -gt "$suggestionValue" ]
    then
	    securityState="WARN"
    elif [ "$currentValue" -le "$suggestionValue" ]
    then
	    securityState="SAFE"
    else
	    securityState="ERROR"
    fi


    securityLog "U-47|패스워드 최대 사용기간 설정" "$suggestionValue" "$currentValue" "$securityState"
}


