#source menu_deploy.sh

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
BLUE='\033[0;34m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color


function pause() {
    #echo -e "${RED}Please any key to continue..."
    #echo -e "${GREEN}Please any key to continue..."
    #echo -e "${YELLOW}Please any key to continue..."
    #echo -e "${BLUE}Please any key to continue..."
    echo -e "\n${CYAN}Please any key to continue..."
    #echo -e "${MAGENTA}Please any key to continue..."
    read -n 1
}


function menu()
{
	while true
	do
		echo -e '\f'
		echo -e "\t\t\t\t*** LINUX Automatically settings Starting... ***\n" # 제목 변수로 변경 예정
		echo -e "\t\t\t\t${CYAN}=================================================${NC}"
        	echo -e "\t\t\t\t                     MAIN MENU          ${RESET}       "
		echo -e "\t\t\t\t${CYAN}================================================="
        	echo -e "\t\t\t\t\t${CYAN}1. ${YELLOW}Install Ansible"
        	echo -e "\t\t\t\t\t${CYAN}2. ${YELLOW}Create Public Key"
        	echo -e "\t\t\t\t\t${CYAN}3. ${YELLOW}Ansible Ping Test"
        	echo -e "\t\t\t\t\t${CYAN}4. ${YELLOW}playbook deploy"
		echo -e "\t\t\t\t\t${CYAN}5. ${YELLOW}Ansible inventory print"
		echo -e "\t\t\t\t\t${CYAN}6. ${YELLOW}Exit"
		echo -e "\t\t\t\t${CYAN}=================================================${NC}"
       		echo ''
        	echo -en "\t\t\t\t\t Select an opsion [1-6] >> "
        	read select
        #########################################################

        	case $select in      
                	1)
                        	echo "select = 1"
				#source Install_Ansible.sh
				source Install_Ansible_v2.sh
				Install_Ansible
				echo -n "back to the manu?(y/n)"
			       # read answer
			       # if [ "$answer" == "y" ]; then
			       #         menu
			       # fi
			       	pause
				;;
			2)
				echo "select = 2"
				#source Create_PublicKey.sh
				source Create_PublicKey_v2.sh
				Create_Pubkey

				#echo -n "back to the manu?(y/n)"
				#read answer
				#if [ "$answer" == "y" ]; then
				#        menu
				#fi
				
				#menu
				pause
				;;
			3)
				echo "select = 3"
				ansible all -m ping
				#echo -n "back to the manu?(y/n)"
				#read answer
				#if [ "$answer" == "y" ]; then
				#	menu
				#fi
				pause
				;;
			4)
				echo "playbook deploy menu"
				source menu_deploy.sh
				menu_deploy
				#ansible-playbook os_init.yaml #>> test1.log
				#cat test1.log
				#echo -n "back to the manu?(y/n)"
				#read answer
				#if [ "$answer" == "y" ]; then
				#        menu
				#fi
				;;
			5)
				echo "앤서블 인벤토리 확인"
				ansible-inventory --list -y
				#echo -n "back to the manu?(y/n)"
				#read answer
				#if [ "$answer" == "y" ]; then
				#        menu
				#fi
				pause
				;;
			*)
				echo "Exit"
				break
				;;
		esac

		#echo 'Please any key to continue...'
		#read -n 1

	done
}
