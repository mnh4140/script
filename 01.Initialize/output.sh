#!/bin/bash

# 입력 받은 값 출력 하는 함수
function Output() {
        echo "입력한 값은 아래와 같습니다."
        echo -n "키파일 : "
        echo "$keypath"
        echo -n "계정명 : "
        echo "$m_account"
        index=1
        echo "IP 리스트"
        for i in "${m_ip[@]}"
        do
                echo "  $index. $i"
                index=$((index+1))
        done
}
