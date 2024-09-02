#!/bin/bash

source core.sh
source input.sh
source output.sh

# 앤서블 퍼블릭키 생성
function Create_Pubkey() {
    echo '### STEP 2 Create Public Key' >> $logfile #로그 저장 용
	
    linebreak

    echo '!) EXECUTE COMMAND LOG' >> $logfile
    
    logtime
	
    Input_Keyfile
    Input_Account
    Input_IP
    echo ''
    Output

    if [ -e /root/.ssh/id_rsa ]; then # 퍼블릭키 파일 확인 후 키 복사
	    for i in "${m_ip[@]}"
	    do
		    ssh -i "$keypath" $m_account@$i "echo '#Ansible Host $(hostname)' >> ~/.ssh/authorized_keys" # authorized_keys 파일에 구분용 주석 넣어주기
		    cat ~/.ssh/id_rsa.pub | ssh -i "$keypath" $m_account@$i "cat - >> ~/.ssh/authorized_keys" # 생성한 퍼블릭키 매니지드 노드에 등록
		    echo "키 복사 완료"
		    echo -e '$ldate\t\tCOMMAND : cat ~/.ssh/id_rsa.pub | ssh -i "$keypath" $m_account@$i "cat - >> ~/.ssh/authorized_keys"' >> $logfile
	    done

    else
	    ssh-keygen -t rsa -m PEM # 퍼블릭키 생성 
	    echo -e "$ldate\t\tCOMMAND : ssh-keygen -t rsa -m PEM" >> $logfile
	    ls -l ~/.ssh/id_*.pub # 생성된 퍼블릭키 확인
	    echo -e "$ldate\t\tCOMMAND : ls -l ~/.ssh/id_*.pub" >> $logfile
	    for i in "${m_ip[@]}"
	    do
		    ssh -i "$keypath" $m_account@$i "echo '#Ansible Host $(hostname)' >> ~/.ssh/authorized_keys" # authorized_keys 파일에 구분용 주석 넣어주기
                    cat ~/.ssh/id_rsa.pub | ssh -i "$keypath" $m_account@$i "cat - >> ~/.ssh/authorized_keys" # 생성한 퍼블릭키 매니지드 노드에 등록
                    echo "키 복사 완료"
		    echo -e '$ldate\t\tCOMMAND : cat ~/.ssh/id_rsa.pub | ssh -i "$keypath" $m_account@$i "cat - >> ~/.ssh/authorized_keys"' >> $logfile
	    done
    fi

    for i in "${m_ip[@]}"
    do
	    ansible $i -m ping
    done

    linebreak

    dash
}
