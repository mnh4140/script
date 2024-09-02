#!/bin/bash

source securityLog.sh

function U-01() {
    suggestionValue="PermitRootLogin no"

    PermitRootLoginValue=$(grep '^PermitRootLogin' /etc/ssh/sshd_config | grep -v '^#' | awk '{print $2}')
    currentValue="PermitRootLogin $PermitRootLoginValue"

    # WARN(PermitRootLogin yes)
    if [ "$PermitRootLoginValue" = "yes" ]; then
        securityState="WARN"

    # SAFE(PermitRootLogin no)
    elif [ "$PermitRootLoginValue" = "no" ]; then
        securityState="SAFE"

    # SAFE(PermitRootLogin 설정이 주석처리 됬을 경우 "no"가 디폴트)
    elif [ -z "$PermitRootLoginValue" ]; then
        securityState="SAFE"
        currentValue=$(grep '^#PermitRootLogin' /etc/ssh/sshd_config)

    # EXCEPTION
    else
        securityState="ERROR"
    fi

    securityLog "U-01|root 계정 원격 접속 제한" "$suggestionValue" "$currentValue" "$securityState"
}
