#!/bin/bash

source core.sh

# 앤서블 설치함수
function Install_Ansible() {
    echo '### STEP 1 Install Ansible' >> $logfile #로그 저장 용

    STEPNAME="Install Ansible........." # 스텝 이름
    NOWNUM=1 # 스텝 번호
	
    # echo "!) ### STEP 1 앤서블 설치"

    linebreak

    isinstalled=$(dnf info ansible | sed -n '/Installed Packages/p') # 앤서블 패키지 설치 여부 확인

    #테스트
    # echo "테스트 isinstalled : $isinstalled"

    echo '!) EXECUTE COMMAND LOG' >> $logfile

    logtime
	
    echo -e "$ldate\t\tCOMMAND : dnf info ansible | sed -n '/Installed Packages/p'" >> $logfile

    linebreak

    #progress 20
	
    if [ "$isinstalled" == "Installed Packages" ]; then
        # 테스트 echo "Already Installed Ansible" # 이미 설치 되어있으면 출력
        # 테스트 echo "Already Installed Ansible" >> $logfile
	echo '!) COMMAND RESULT' >> $logfile
        echo -e " * RESULT : $(dnf info ansible)" >> $logfile
    else # 설치가 안되어있으면 앤서블 설치
        echo -e "$ldate\t\tCOMMAND : dnf install epel-release -y" >> $logfile
        dnf install epel-release -y > /dev/null 2>&1 # 앤서블 설치를 위한 레포지토리 추가
	echo -e "$ldate\t\tCOMMAND : dnf install ansible -y" >> $logfile
        dnf install ansible -y > /dev/null 2>&1 # 앤서블 설치
	echo -e "$ldate\t\tCOMMAND : ansible -version" >> $logfile
        #ansible -version # 앤서블 버전 확인
	echo '!) COMMAND RESULT' >> $logfile
        echo -e " * RESULT : $(dnf info ansible)" >> $logfile
        echo -e " * RESULT : $(ansible --version)" >> $logfile
    fi
	
    stateary[0]="Done ."
    
    linebreak
	
    # 테스트 echo '!) COMMAND RESULT' >> $logfile
    # 테스트 echo -e " * RESULT : $(dnf info ansible)" >> $logfile
    # 테스트 echo -e " * RESULT : $(ansible --version)" >> $logfile
	
    dash

    ansible --version
}
