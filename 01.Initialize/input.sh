#!/bin/bash


# 값 입력 받는 함수
function Input() {
        echo -n "$1"
        read input
        #echo "$1 $input"
        linebreak
}

# 배열 입력 받는 함수
function Input_Array() {
        echo -n "$1"
        read -a input_array
        #echo "$1 ${input_array[@]}"
        linebreak
}

# 키 파일 입력 받는 함수
function Input_Keyfile() {
        Input "1. 키 파일 :"
        keypath=$input
}

# 계정 입력 받는 함수
function Input_Account() {
        Input "2. 계정명 :"
        m_account=$input
}

# IP 입력 받는 함수
function Input_IP() {
        Input_Array "3. IP :"
        index=0
        for i in "${input_array[@]}"
        do
            m_ip[$index]=$i
            index=$((index+1))
        done
}
