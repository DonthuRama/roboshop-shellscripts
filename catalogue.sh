#!/bin/bash

ID=$(id -u)
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
MONGODB_HOST=mongodb.ramakhpcl.online

TIMESTAMP=$(date +%F-%H-%M-%S)
LOGFILE="/tmp/$0-$TIMESTAMP.log"

echo "script stareted executing at $TIMESTAMP" &>> $LOGFILE

VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 ... $R FAILED $N"
        exit 1
    else
        echo -e "$2 ... $G SUCCESS $N"
    fi
}

if [ $ID -ne 0 ]
then
    echo -e "$R ERROR:: Please run this script with root access $N"
    exit 1 # you can give other than 0
else
    echo "You are root user"
fi # fi means reverse of if, indicating condition end

dnf module disable nodejs -y &>> $LOGFILE

VALIDATE $? "disable current nodeJS"

dnf module enable nodejs:18 -y &>> $LOGFILE

VALIDATE $? "enable nodeJS18"

dnf install nodejs -y &>> $LOGFILE

VALIDATE $? "install nodeJS18"

useradd roboshop1

VALIDATE $? "creating roboshop user"

mkdir /app

VALIDATE $? "creating a App directory"

curl -o /tmp/catalogue.zip https://roboshop-builds.s3.amazonaws.com/catalogue.zip &>> $LOGFILE

VALIDATE $? "dowloading catalogue application"

cd /app 

unzip /tmp/catalogue.zip &>> $LOGFILE

VALIDATE $? "unzip the catalogue file"

npm install &>> $LOGFILE

VALIDATE $? "install dependendies"

cp /home/centos/roboshop-shellscripts/catalogue.service /etc/systemd/system/catalogue.service &>>$LOGFILE

VALIDATE $? "copieing catalogue.service file"

systemctl daemon-reload &>> $LOGFILE

VALIDATE $? "catalogue daemon reload "

systemctl enable catalogue &>> $LOGFILE

VALIDATE $? "enable catalogue"

systemctl start catalogue &>> $LOGFILE

VALIDATE $? "start catalogue"

cp /home/centos/roboshop-shellscripts/mongo.repo /etc/yum.repos.d/mongo.repo

VALIDATE $? "copying mongo repo" 

dnf install mongodb-org-shell -y &>> $LOGFILE

VALIDATE $? "instaling mongodb client" 

mongo --host $MONGODB_HOST </app/schema/catalogue.js &>> $LOGFILE

VALIDATE $? "loading catlogue data into mongodb"