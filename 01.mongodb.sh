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

echo "Script started execution at $(date +"%F %T")" &>> $logs_file

validate(){
    if [ $1 -ne 0 ]; then
        echo -e "${2}..${R}FAILED${N}" | tee -a $logs_file
        exit 1
    else
        echo -e "${2}..${G}SUCCESS${N}" | tee -a $logs_file
    fi
}

cp mongo.repo /etc/yum.repos.d/mongo.repo
validate $? "Copying mongo repo"  | tee -a $logs_file

dnf install mongodb-org -y
validate $? "Install MongoDB"  | tee -a $logs_file

systemctl enable mongod
systemctl start mongod
validate $? "Enable and start mongoDB"  | tee -a $logs_file

sed -i 's/127.0.0.0/0.0.0.0/g' /etc/mongod.conf
validate $? "updating the remote connection of mongodb"  | tee -a $logs_file

systemctl restart mongod
validate $? "restarting mongodb"  | tee -a $logs_file