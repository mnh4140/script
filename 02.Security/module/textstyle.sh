#!/bin/bash

# 텍스트 색상 및 스타일 설정
RESET='\033[0m'       # 기본 색상 및 스타일
BOLD='\033[1m'        # 굵은 글씨
bold=$(tput bold)
UNDERLINE='\033[4m'   # 밑줄
REVERSED='\033[7m'    # 배경색과 글자색 반전

# 색상설정
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
