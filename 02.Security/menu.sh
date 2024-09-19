#source menu_deploy.sh
source textstyle.sh

# 텍스트 색상 및 스타일 설정
#RESET='\033[0m'       # 기본 색상 및 스타일
#BOLD='\033[1m'        # 굵은 글씨
#bold=$(tput bold)
#UNDERLINE='\033[4m'   # 밑줄
#REVERSED='\033[7m'    # 배경색과 글자색 반전

# 색상설정
#RED='\033[0;31m'
#GREEN='\033[0;32m'
#YELLOW='\033[1;33m'
#BLUE='\033[0;34m'
#CYAN='\033[0;36m'
#MAGENTA='\033[0;35m'
#NC='\033[0m' # No Color


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
		echo -e "\t\t\t\t${CYAN}=================================================${RESET}"
        	echo -e "\t\t\t\t                     MAIN MENU          ${RESET}       "
		echo -e "\t\t\t\t${CYAN}================================================="
        	echo -e "\t\t\t\t\t${CYAN}1. ${YELLOW}Config file backup"
        	echo -e "\t\t\t\t\t${CYAN}2. ${YELLOW}Security check"
        	echo -e "\t\t\t\t\t${CYAN}3. ${YELLOW}Security measures"
        	echo -e "\t\t\t\t\t${CYAN}4. ${YELLOW}Show Logfile"
		echo -e "\t\t\t\t\t${CYAN}5. ${YELLOW}Exit"
		#echo -e "\t\t\t\t\t${CYAN}6. ${YELLOW}Exit"
		echo -e "\t\t\t\t${CYAN}=================================================${RESET}"
       		echo ''
        	echo -en "\t\t\t\t\t Select an opsion [1-6] >> "
        	read select
        #########################################################

        	case $select in      
                	1)
                        	#echo "select = 1"
				#source Install_Ansible.sh
				source filebackup.sh
				backup
			       # read answer
			       # if [ "$answer" == "y" ]; then
			       #         menu
			       # fi
			       	pause
				;;
			2)
				#echo "select = 2"
				source Security_check.sh
				check
				pause
				;;
			3)
				#echo "select = 3"
				source Security_fix.sh
				fix
				pause
				;;
			4)
				#echo "playbook deploy menu"
				#source menu_deploy.sh
				#menu_deploy
				ll log/
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
