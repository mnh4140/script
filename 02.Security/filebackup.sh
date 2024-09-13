#!/bin/bash

function backup() {
    HERE=$(dirname $(realpath $0))
    BACKUP_DIR="$HERE/BACKUP"
    TIMESTAMP=$(date +%Y%m%d_%H%M%S)
    BACKUP_FILE="$BACKUP_DIR/backup_$TIMESTAMP.tar.gz"

    backup_files=(
        "/etc/ssh/sshd_config"
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
        "/etc/exports"
    )

    : <<'END'
    # 존재하는 파일만 백업할 수 있도록 필터링
    valid_backup_files=()
    for file in "${backup_files[@]}"; do
        if [ -e "$file" ]; then
            valid_backup_files+=("$file")
        else
            echo "파일이 존재하지 않음: $file"
        fi
    done

    # 사용자 홈 디렉터리 추가
    for user in $(awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd); do
        home_dir=$(eval echo ~$user)
        if [ -d "$home_dir" ]; then
            #valid_backup_files+=("$home_dir")
	    env_files=(".bashrc" ".bash_profile" ".bash_logout" ".bash_history")
	    for env_file in "${env_files[@]}"; do
		    valid_backup_files+=("$home_dir/$env_file")
	    done
        fi
    done
END
    # 사용자 홈 디렉터리 추가
    for user in $(awk -F: '$3 >= 1000 && $3 != 65534 {print $1}' /etc/passwd); do
        home_dir=$(eval echo ~$user)
        if [ -d "$home_dir" ]; then
            #valid_backup_files+=("$home_dir")
            env_files=(".bashrc" ".bash_profile" ".bash_logout" ".bash_history")
            for env_file in "${env_files[@]}"; do
                    backup_files+=("$home_dir/$env_file")
            done
        fi
    done

    valid_backup_files=()
    for file in "${backup_files[@]}"; do
        if [ -e "$file" ]; then
            valid_backup_files+=("$file")
        else
            echo "파일이 존재하지 않음: $file"
        fi
    done

    # 백업 디렉터리가 없으면 생성
    if [ ! -d "$BACKUP_DIR" ]; then
        mkdir -p "$BACKUP_DIR"
    fi

    # 유효한 파일만 압축
    tar -czvpf "$BACKUP_FILE" "${valid_backup_files[@]}"

    # 결과 출력
    if [ $? -eq 0 ]; then
        echo "백업 성공: $BACKUP_FILE"
    else
        echo "백업 실패"
    fi
}

backup

