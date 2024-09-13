function filebackup() # 취약점 조치 시, 변경되는 파일 백업 수행
{
        if [ -e $HERE/BACKUP/$1 ]
        then
                echo "$3 Backup Exists    : $2 -> ./BACKUP/$1" >> $LOGFILE
        else
                \cp -rp $2 $HERE/BACKUP/$1

                if [ -e $HERE/BACKUP/$1 ]
                then
                        echo "$3 Backup Completed : $2 -> ./BACKUP/$1" >> $LOGFILE
                else
                        echo "$3 Backup Fail" >> $LOGFILE
                fi
        fi
}

function backup() {

	home_dir=()
	for user in $(awk -F: '$3 >= 1000 {print $1}' /etc/passwd); do
		home_dir+=$(eval echo ~$user)\n
	done

	echo "home_dir $home_dir"



	backup_file=("/etc/ssh/sshd_config" 
	"/etc/security/pwquality.conf"
	"/etc/security/faillock.conf"
	"/etc/passwd"
	"/etc/shadow"
	"/etc/pam.d/su"
	"/etc/login.defs"
	"/etc/profile"
	"/etc/hosts"
	"/etc/xinetd.conf"
	"/etc/rsyslog.conf"
	"/etc/services"
	"/etc/bashrc"
	"/home/$i/.bashrc"
	"/home/$i/.bash_profile"
	"/etc/anacrontab"
	"/etc/cron.deny"
	"/etc/crontab"
	"/etc/cron.d"
	"/etc/cron.allow"
	"/etc/cron.daily"
	"/etc/cron.hourly"
	"/etc/cron.monthly"
	"/etc/cron.weekly"
	"/var/spool/cron/"
	"/var/log/cron"
	"/usr/bin/at"
	"/etc/at.deny"
	"/etc/at.allow"
	"/etc/motd"
	"/etc/issue.net"
	"/etc/issue"
	"/etc/exports")

	echo "backup_file :  ${backup_file[@]}"


}
backup
