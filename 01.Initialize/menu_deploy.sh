source menu.sh

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

function menu_deploy()
{
	while true
	do
		echo -e '\f'
		echo -e "\t\t\t\t*** LINUX Automatically settings Starting... ***\n" # 제목 변수로 변경 예정
		echo -e "\t\t\t\t${CYAN}=================================================${NC}"
        	echo -e "\t\t\t\t\t      ANSIBLE PLAYBOOK DEPLOY"
		echo -e "\t\t\t\t${CYAN}=================================================${NC}"
        	echo -e "\t\t\t\t\t${CYAN}1. ${YELLOW}OS initialize playbook deploy"
		echo -e "\t\t\t\t\t${CYAN}2. ${YELLOW}OS Security check playbook deploy"
		echo -e "\t\t\t\t\t${CYAN}3. ${YELLOW}OS Security meansures playbook deploy"
		echo -e "\t\t\t\t\t${CYAN}4. ${YELLOW}Back to the main menu"
		echo -e "\t\t\t\t${CYAN}=================================================${NC}"
        	echo ''
        	echo -en '\t\t\t\t\t Select an opsion [1-4] >> '
        	read select1
        #########################################################

        	case $select1 in      
			1)
				echo "OS initialize playbook deploy"
				ansible-playbook os_init.yaml
				pause
				;;
			2)
				echo "OS Security check playbook deploy"
				echo "test~"
				pause
				;;
			3)
				echo "OS Security meansures playbook deploy"
				pause
				;;
			4)
				echo "back to the main menu"
				#menu
				break
                        	;;
			*)
				echo "retry choose the option"
				pause
				;;
        	esac

	done
}
