#!/bin/bash

source securityLog.sh

function U-46() {
    suggestionValue="10"

    iscomment=$(cat /etc/security/pwquality.conf | grep minlen | awk '{print$1}') # 설정 값이 주석인지 확인
    #echo "iscomment = $iscomment"

    if [ "$iscomment" == "minlen" ]
    then
            #echo "if iscomment : $iscomment"
            currentValue=$(cat /etc/security/pwquality.conf | grep minlen | awk '{print$3}')
            securityState="SAFE"
    elif [ "$iscomment" == "#" ]
    then
            #echo "elif iscomment : $iscomment"
            currentValue=$(cat /etc/security/pwquality.conf | grep minlen | awk '{print$4}')
            securityState="WARN"
    else
            #echo "else iscomment : $iscomment"
            securityState="ERROR"
    fi


    securityLog "U-46|패스워드 최소 길이 설정" "$suggestionValue" "$currentValue" "$securityState"
}
