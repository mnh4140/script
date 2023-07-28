date=$(date '+%Y%m%d_%H%M')
logfilename="$date"
#logdate=$(date '+[%Y-%m-%d %H:%M:%S]')
ldate=`date '+[%Y-%m-%d %H:%M:%S]'`
logfile=$(pwd)/$logfilename.log


#################################
function linebreak()
{
	echo '' >> $logfile
}

function dash()
{
	linebreak
	echo '--------------------------------' >> $logfile
	linebreak
}

function test()
{
	linebreak
	linebreak
}

function logtime()
{
        ldate=`date '+[%Y-%m-%d %H:%M:%S]'`
        #echo -e "$ldate"
}

#################################

### STEP 1 #########################

#ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

echo '### STEP 1 UTC to KST Converter' >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log


echo '!) EXECUTE COMMAND LOG' >> $(pwd)/$logfilename.log
logtime
echo -e "$ldate\t\tln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime" >> $(pwd)/$logfilename.log
#echo 'ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime' >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log

echo '!) COMMAND RESULT' >> $(pwd)/$logfilename.log
#timedatectl | grep Time >> $(pwd)/$logfilename.log
timedatectl | awk -F":" '/Time zone/ {print $0}' | sed 's/^ *//g' >> $(pwd)/$logfilename.log
date >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log
echo '--------------------------------' >> $(pwd)/$logfilename.log
echo '' >> $(pwd)/$logfilename.log

#sleep 1

### STEP 2 #########################
echo '### STEP 2 History Time Logging' >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log

echo '!) EXECUTE COMMAND LOG' >> $(pwd)/$logfilename.log
logtime
echo -e "$ldate\t\techo "HISTTIMEFORMAT=\"[%Y-%m-%d_%H:%M:%S]  \"" >> /etc/profile" >> $(pwd)/$logfilename.log
logtime
echo -e "$ldate\t\tsource /etc/profile" >> /etc/profile"" >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log

echo '!) COMMAND RESULT' >> $(pwd)/$logfilename.log
source /etc/profile
history 10 >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log
echo '--------------------------------' >> $(pwd)/$logfilename.log
echo '' >> $(pwd)/$logfilename.log



#sleep 1
#####################################
### STEP 3 #########################

echo '### STEP 3 SSH Password Login' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
logtime
echo -e "$ldate\t\tsed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config" >> $logfile
logtime
echo -e "$ldate\t\tsed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config" >> $logfile
logtime
echo -e "$ldate\t\tsed -i '/PasswordAuthentication no/ s/^/#/' /etc/ssh/sshd_config" >> $logfile
logtime
echo -e "$ldate\t\tsed -i '/GSSAPIAuthentication yes/ s/^/#/' /etc/ssh/sshd_config" >> $logfile
logtime
echo -e "$ldate\t\tsystemctl restart sshd" >> $logfile

echo '' >> $logfile

echo '!) COMMAND RESULT' >> $logfile
sed -n '/PermitRootLogin no/p' /etc/ssh/sshd_config >> $logfile
sed -n '/PasswordAuthentication yes/p' /etc/ssh/sshd_config >> $logfile
sed -n '/GSSAPIAuthentication yes/p' /etc/ssh/sshd_config >> $logfile
systemctl status sshd | awk -F":" '/Active/ {print $0}' | sed 's/^ *//g' >> $logfile

dash
#sleep 1
#####################################
### STEP 4 #########################

echo '### STEP 4 Password Change' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
logtime
echo -e "$ldate\t\techo 'Sniper13@$' | passwd --stdin root" >> $logfile
logtime
echo -e "$ldate\t\techo 'Sniper13@$' | passwd --stdin rocky" >> $logfile

echo '' >> $logfile

echo '!) COMMAND RESULT' >> $logfile
echo 'No Result' >> $logfile

dash
#sleep 1
#####################################
### STEP 5 #########################

echo '### STEP 5 FTP root Login' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
logtime
echo -e "$ldate\t\techo "root" >> /etc/ftpusers" >> $logfile

echo '' >> $logfile

echo '!) COMMAND RESULT' >> $logfile
cat /etc/ftpusers >> $logfile

dash
#sleep 1
##################################


#####################################
### STEP 6 #########################

echo '### STEP 6 Selinux Disable' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
logtime
echo -e "$ldate\t\tsetenforce 0" >> $logfile
logtime
echo -e "$ldate\t\tsed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config" >> $logfile

linebreak

echo '!) COMMAND RESULT' >> $logfile
sed -n '/SELINUX=disabled/p' /etc/selinux/config >> $logfile
linebreak
echo '!!! you must be reboot !!!' >> $logfile

dash
#sleep 1
#####################################
### STEP 7 #########################

echo '### STEP 7 Firewalld Disable' >> $logfile
linebreak


echo '!) EXECUTE COMMAND LOG' >> $logfile
logtime
echo -e "$ldate\t\tsystemctl stop firewalld && systemctl disable firewalld" >> $logfile



linebreak

echo '!) COMMAND RESULT' >> $logfile
systemctl status firewalld >> $logfile # 서비스 없으면 에러 뜸 if문으로 개선 해야될 듯 해

linebreak

dash
#sleep 1
#####################################
### STEP 8 #########################

echo '### STEP 8 Network Tool Install ' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
logtime
echo -e "$ldate\t\tdnf install iputils net-tools tcpdump -y" >> $logfile

linebreak

echo '!) COMMAND RESULT' >> $logfile
dnf info iputils net-tools tcpdump | sed -n '/Name/p' >> $logfile

linebreak

dash
#sleep 1
#####################################
### STEP 9 #########################

echo '### STEP 9 NTP Client Configuration ' >> $logfile
linebreak
echo '!) EXECUTE COMMAND LOG' >> $logfile
logtime
echo -e "$ldate\t\tsystemctl stop chronyd" >> $logfile
logtime
echo -e "$ldate\t\tsed -i '/pool 2.rocky.pool.ntp.org iburst/ s/^/#/' /etc/chrony.conf" >> $logfile
logtime
echo -e "$ldate\t\tsed -i '/pool 2.rocky.pool.ntp.org iburst/a\server time.bora.net iburst' /etc/chrony.conf" >> $logfile
logtime
echo -e "$ldate\t\tsystemctl start chronyd" >> $logfile
logtime
echo -e "$ldate\t\tchronyc sources" >> $logfile

linebreak

echo '!) COMMAND RESULT' >> $logfile
systemctl status chronyd | awk -F":" '/Active/ {print $0}' | sed 's/^ *//g' >> $logfile
sed -n '/iburst/p' /etc/chrony.conf >> $logfile
chronyc sources >> $logfile

linebreak

dash
