function menu()
{
        echo -e '\f\t\t\t\t*** LINUX Ansible Initial settings Starting... ***\n' # 제목 변수로 변경 예정
        # echo -ne '\t\tSTEP '$NOWNUM'/'${TOTALNUM}' '$STEPNAME' '
        # echo -ne '\t\t['${bar[$percent]}'] ['$1'%]\t'${stickary[$sticknum]}' '
        echo -e '\t\t\t\t\tChoose number\n'
        echo -e '\t\t\t\t\t1. Install Ansible'
        echo -e '\t\t\t\t\t2. Create Public Key'
        echo -e '\t\t\t\t\t3. Ansible Ping Test'
        echo -e '\t\t\t\t\t4. Ansible playbook deploy'
	echo -e '\t\t\t\t\t5. Ansible inventory print'
	echo -e '\t\t\t\t\t6. Exit'
        echo ''
        echo -en '\t\t\t\t\t>> '
        read select
        #########################################################

        case $select in      
                1)
                        echo "select = 1"
			#source Install_Ansible.sh
			source Install_Ansible_v2.sh
			Install_Ansible
			echo -n "back to the manu?(y/n)"
                        read answer
                        if [ "$answer" == "y" ]; then
                                menu
                        fi
                        ;;
                2)
                        echo "select = 2"
			#source Create_PublicKey.sh
			source Create_PublicKey_v2.sh
			Create_Pubkey

			echo -n "back to the manu?(y/n)"
                        read answer
                        if [ "$answer" == "y" ]; then
                                menu
                        fi
			
			menu
                        ;;
                3)
                        echo "select = 3"
			ansible all -m ping
			echo -n "back to the manu?(y/n)"
			read answer
			if [ "$answer" == "y" ]; then
				menu
			fi
                        ;;
		4)
			echo "select = 4"
			ansible-playbook os_init.yaml #>> test1.log
			#cat test1.log
			echo -n "back to the manu?(y/n)"
			read answer
			if [ "$answer" == "y" ]; then
                                menu
                        fi
			;;
		5)
			echo "앤서블 인벤토리 확인"
			ansible-inventory --list -y
			echo -n "back to the manu?(y/n)"
                        read answer
                        if [ "$answer" == "y" ]; then
                                menu
                        fi
                        ;;
                *)
                        echo "Exit"
			break
                        ;;
        esac
}

