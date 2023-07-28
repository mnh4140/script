date=$(date '+%Y%m%d_%H%M')
logfilename="$date"
logdate=$(date '+[%Y-%m-%d %H:%M:%S]')

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
#################################

### STEP 1 #########################

#ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime

echo '### STEP 1 UTC to KST Converter' >> $(pwd)/$logfilename.log

test
echo 'test'
test
test

echo '' >> $(pwd)/$logfilename.log


echo '!) EXECUTE COMMAND LOG' >> $(pwd)/$logfilename.log
echo "$logdate          ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime" >> $(pwd)/$logfilename.log
#echo 'ln -sf /usr/share/zoneinfo/Asia/Seoul /etc/localtime' >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log
echo '!) COMMAND RESULT' >> $(pwd)/$logfilename.log
#timedatectl | grep Time >> $(pwd)/$logfilename.log
timedatectl | awk -F":" '/Time zone/ {print $0}' | sed 's/^ *//g' >> $(pwd)/$logfilename.log
date >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log
echo '--------------------------------' >> $(pwd)/$logfilename.log
echo '' >> $(pwd)/$logfilename.log

### STEP 2 #########################
echo '### STEP 2 History Time Logging' >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log

echo '!) EXECUTE COMMAND LOG' >> $(pwd)/$logfilename.log
echo "$logdate          echo "HISTTIMEFORMAT=\"[%Y-%m-%d_%H:%M:%S]  \"" >> /etc/profile" >> $(pwd)/$logfilename.log
echo "$logdate          source /etc/profile" >> /etc/profile"" >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log

echo '!) COMMAND RESULT' >> $(pwd)/$logfilename.log
source /etc/profile
history 10 >> $(pwd)/$logfilename.log

echo '' >> $(pwd)/$logfilename.log
echo '--------------------------------' >> $(pwd)/$logfilename.log
echo '' >> $(pwd)/$logfilename.log




#####################################
### STEP 3 #########################

echo '### STEP 3 SSH Password Login' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
echo "sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config" >> $logfile
echo "sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config" >> $logfile
echo "sed -i '/PasswordAuthentication no/ s/^/#/' /etc/ssh/sshd_config" >> $logfile
echo "sed -i '/GSSAPIAuthentication yes/ s/^/#/' /etc/ssh/sshd_config" >> $logfile
echo "systemctl restart sshd" >> $logfile

echo '' >> $logfile

echo '!) COMMAND RESULT' >> $logfile
sed -n '/PermitRootLogin no/p' /etc/ssh/sshd_config >> $$logfile
sed -n '/PasswordAuthentication yes/p' /etc/ssh/sshd_config >> $logfile
sed -n '/GSSAPIAuthentication yes/p' /etc/ssh/sshd_config >> $logfile
systemctl status sshd | awk -F":" '/Active/ {print $0}' | sed 's/^ *//g' >> $logfile

dash

#####################################
### STEP 4 #########################

echo '### STEP 4 Password Change' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
echo "echo 'Sniper13@$' | passwd --stdin root" >> $logfile
echo "echo 'Sniper13@$' | passwd --stdin rocky" >> $logfile

echo '' >> $logfile

echo '!) COMMAND RESULT' >> $logfile
echo 'No Result' >> $logfile

dash

#####################################
### STEP 5 #########################

echo '### STEP 5 FTP root Login' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
echo "echo "root" >> /etc/ftpusers" >> $logfile

echo '' >> $logfile

echo '!) COMMAND RESULT' >> $logfile
cat /etc/ftpusers >> $logfile

dash

##################################


#####################################
### STEP 6 #########################

echo '### STEP 6 Selinux Disable' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
echo "setenforce 0" >> $logfile
echo "sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config" >> $logfile

linebreak

echo '!) COMMAND RESULT' >> $logfile
sed -n '/SELINUX=disabled/p' /etc/selinux/config >> $logfile
linebreak
echo '!!! you must be reboot !!!' >> $logfile

dash

#####################################
### STEP 7 #########################

echo '### STEP 7 Firewalld Disable' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
echo "systemctl stop firewalld && systemctl disable firewalld" >> $logfile

linebreak

echo '!) COMMAND RESULT' >> $logfile
systemctl status firewalld >> $logfile
linebreak
echo '!!! you must be reboot !!!' >> $logfile

dash

#####################################
### STEP 8 #########################

echo '### STEP 8 Network Tool Install ' >> $logfile
linebreak

echo '!) EXECUTE COMMAND LOG' >> $logfile
echo "dnf install iputils net-tools tcpdump -y" >> $logfile

linebreak

echo '!) COMMAND RESULT' >> $logfile
systemctl status firewalld >> $logfile
linebreak
echo '!!! you must be reboot !!!' >> $logfile

dash
