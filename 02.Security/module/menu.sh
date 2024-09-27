SCRIPT_DIR=$(dirname "${BASH_SOURCE[0]}")

function pause() {
    echo -e "\n${CYAN}Please any key to continue...${RESET}"
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
				#source $SCRIPT_DIR/filebackup.sh
				source /root/WinsCloud/02.Security/module/filebackup.sh
				backup
			       	pause
				;;
			2)
				source /root/WinsCloud/02.Security/check/Security_check.sh
				check
				pause
				;;
			3)
				source /root/WinsCloud/02.Security/fix/Security_fix.sh
				fix
				pause
				;;
			4)
				ll log/
				pause
				;;
			*)
				echo "Exit"
				break
				;;
		esac
	done
}
