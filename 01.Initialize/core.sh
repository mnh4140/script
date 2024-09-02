#!/bin/bash
#
date=$(date '+%Y%m%d_%H%M')
logfilename="$date"
ldate=`date '+[%Y-%m-%d %H:%M:%S]'`
logfile=$(pwd)/$logfilename.log
#
#
# 프로그래스 바 변수
TOTALNUM=9 	# TOTALNUM : 전체 스탭 수
NOWNUM=1 	# NOWNUM : 현재 스탭
STEPNAME="" # STEPNAME : 진행중인 스탭 이름
stickary=(- \\ \| / - \\ \| /)		# 로딩 휠 - 돌아감
tty=">>>>>--------------------"	# 로딩 바 - 20%
fty=">>>>>>>>>>---------------"	# 로딩 바 - 40%
sty=">>>>>>>>>>>>>>>----------"	# 로딩 바 - 60%
ety=">>>>>>>>>>>>>>>>>>>>-----"	# 로딩 바 - 80%
full=">>>>>>>>>>>>>>>>>>>>>>>>>"	# 로딩 바 - 100%
bar=($tty $fty $sty $ety $full)		# 각 STEP 별 wait/Done 표시
stateary=("wait" "wait" "wait" "wait" "wait" "wait" "wait" "wait" "wait") # 처음에는 wait으로 초기화
#
#
#################################
function linebreak() 	# 줄바꿈 함수
{
	echo '' >> $logfile
}
#
function dash() 		# 대시 출력하는 함수 / 로그 파일에서 경계선 역할로 사용
{
	linebreak
	echo '--------------------------------' >> $logfile
	linebreak
}
#
function logtime()		# 명령어 시작 시간 저장하는 함수
{
        ldate=`date '+[%Y-%m-%d %H:%M:%S]'`
        #echo -e "$ldate"
}
#
function progress()		# 스크립트 실행 시 로딩 바 출력하는 함수
{
        sticknum=0	# 값이 커지면서 로딩 휠 움직임 표현 / stickary 배열 인덱스
		percent=0	# 퍼센트 값 마다 로딩바 출력 / bar 배열 인덱스
        case $1 in	# $1 값 기준으로 퍼센트 별 바 출력 
                20) percent=0 ;;
                40) percent=1 ;;
                60) percent=2 ;;
                80) percent=3 ;;
                100) percent=4 ;;
        esac
        for ((i=0; i<8 ;i++))	# 8의 배수로 올리면 로딩이 길어짐
        do
			# NOWNUM : 현재 스탭
			# TOTALNUM : 전체 스탭 수
			# STEPNAME : 진행중인 스탭 이름
			# $1 : 퍼센테이지 숫자
			echo -e '\f\t\t\t\t*** LINUX Ansible Initial settings Starting... ***\n' # 제목 변수로 변경 예정
			echo -ne '\t\tSTEP '$NOWNUM'/'${TOTALNUM}' '$STEPNAME' '
			echo -ne '\t\t['${bar[$percent]}'] ['$1'%]\t'${stickary[$sticknum]}' '
			#########################################################
			#
			echo ''
			echo ''
			echo ''
			echo -e '\t\t\t\t    STEP 1/'${TOTALNUM}' "Install Ansible........." '${stateary[0]}''
			echo -e '\t\t\t\t    STEP 2/'${TOTALNUM}' "Input PEM KEY..........." '${stateary[1]}''
			echo -e '\t\t\t\t    STEP 3/'${TOTALNUM}' "Input ID................" '${stateary[2]}''
			echo -e '\t\t\t\t    STEP 4/'${TOTALNUM}' "Input IP Addrass........" '${stateary[3]}''
			echo -e '\t\t\t\t    STEP 5/'${TOTALNUM}' "Create Public Key......." '${stateary[4]}''
			#echo -e '\t\t\t\t    STEP 6/'${TOTALNUM}' "Selinux Disable........." '${stateary[5]}''
			#echo -e '\t\t\t\t    STEP 7/'${TOTALNUM}' "Firewalld Disable......." '${stateary[6]}''
			#echo -e '\t\t\t\t    STEP 8/'${TOTALNUM}' "Network Tool Install...." '${stateary[7]}''
			#echo -e '\t\t\t\t    STEP 9/'${TOTALNUM}' "NTP Client Configuration" '${stateary[8]}''
			#
			sleep 0.1	# 로딩 바 움직이는 속도 / 스크립트 전체 속도에 영향을 주어 주석 처리
			#
			if [ $sticknum -gt 7 ]; then	# 배열 크기가 7이므로 7보다 커지면 로딩바가 안나옴
				sticknum=0	# 7이상 커지면 0으로 초기화
			else
				((sticknum++))	# 로딩바 배열 순서 크기 증가
			fi
			#
        done
}

