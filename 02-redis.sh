#!/bin/bash

user_id=$(id -u)
logs_folder="/var/log/shell-practice"
logs_file="${logs_folder}/${0}.log"
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ $user_id -ne 0 ]; then
    echo "Please run this script with sudo access.."
    exit 1
fi

mkdir -p $logs_folder

timestamp(){
    date "+%F %T"
}

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "$(timestamp) [ERROR] ${2}..${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "$(timestamp) [INFO] ${2}..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}

echo "$(timestamp)  [INFO] ===== Script execution started ===="  tee -a $logs_file

dnf module disable redis -y &>> $logs_file
dnf module enable redis:7 -y &>> $logs_file
dnf install redis -y &>> $logs_file
validate $? "default module disable and redis:7, installing redis "  tee -a $logs_file

sed -i -e 's/^bind 127.0.0.1/bind 0.0.0.0/' -e 's/^protected-mode yes/protected-mode no/' /etc/redis/redis.conf &>> $logs_file
validate $? "Allowing remote connections to redis"  tee -a $logs_file

systemctl enable redis &>> $logs_file
systemctl start redis &>> $logs_file
validate $? "enable and start redis" tee -a $logs_file

echo "$(timestamp)  [INFO] script completed in $SECONDS seconds"
echo "$(timestamp) [INFO] === Script completed execution ===" tee -a $logs_file

