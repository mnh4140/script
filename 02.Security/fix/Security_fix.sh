#!/bin/bash

MAIN_DIR="/root/WinsCloud"
SECURITY_DIR="$MAIN_DIR/02.Security"
FIX_DIR="$SECURITY_DIR/fix"

# source "$SECURITY_DIR/module/securityLog.sh"
# source "$SECURITY_DIR/module/Initialize_variables.sh"
source "$FIX_DIR/securityLog.sh"

## 1. 계정 관리
#source "$FIX_DIR/U-01.sh"
source "$FIX_DIR/fix-U-02.sh"
source "$FIX_DIR/fix-U-03.sh"
#source "$FIX_DIR/U-04.sh"
#source "$FIX_DIR/U-45.sh"
#source "$FIX_DIR/U-46.sh"
#source "$FIX_DIR/U-47.sh"
#source "$FIX_DIR/U-48.sh"
#source "$FIX_DIR/U-54.sh"
## 2. 파일 및 디렉터리 관리
#source "$FIX_DIR/U-07.sh"
#source "$FIX_DIR/U-08.sh"
#source "$FIX_DIR/U-09.sh"
#source "$FIX_DIR/U-10.sh"
#source "$FIX_DIR/U-11.sh"
#source "$FIX_DIR/U-12.sh"
#source "$FIX_DIR/U-14.sh"
#source "$FIX_DIR/U-56.sh"
## 3. 서비스 관리
#source "$FIX_DIR/U-20.sh"
#source "$FIX_DIR/U-22.sh"
#source "$FIX_DIR/U-65.sh"
#source "$FIX_DIR/U-68.sh"
#source "$FIX_DIR/U-69.sh"
## 5. 로그 관리 
#source "$FIX_DIR/U-72.sh"

# 함수들

###############################################################################################################\

function fix() {
	echo "# 1. 계정 관리"
	#U-01
	U-02
	U-03
: << END
	U-04
	U-45
	U-46
	U-47
	U-48
	U-54
	echo "# 2. 파일 및 디렉터리 관리"
	U-07
	U-08
	U-09
	U-10
	U-11
	U-12
	U-14
	U-56
	echo "# 3. 서비스 관리"
	U-20
	U-22
	U-65
	U-68
	U-69
	echo "# 5. 로그 관리 "
	U-72
END
}

fix
