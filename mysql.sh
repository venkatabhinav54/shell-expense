#!/bin/bash
LOGS_FOLDER="/var/log/shell-script"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
TIMESTAMP=$(date +%Y-%m-%d-%H-%M-%S)
LOG_FILE="$LOGS_FOLDER/$SCRIPT_NAME-$TIMESTAMP.log"
mkdir -p $LOGS_FOLDER 

USERID=$(id -u) #echo "User id is: $USERID"
 
R="\e[31m"
G="\e[32m"
N="\e[0m"
Y="\e[33m"


 CHECK_ROOT(){
    if [ $USERID -ne 0 ]
    then
        echo -e "$R Please run this script with root privelleges $N" | tee -a $LOG_FILE
        exit 1
    fi    
 }

 VALIDATE(){
    if [ $1 -ne 0 ]
    then
        echo -e "$2 is... $R FAILED $N" | tee -a $LOG_FILE
        exit 1
    else 
        echo -e "$2 is...$G SUCCESS $N" | tee -a $LOG_FILE
    fi        
 }

 echo "Script started executing at: $(date)" | tee -a $LOG_FILE

 CHECK_ROOT

 dnf install mysql-server -y &>>$LOG_FILE
 VALIDATE $? "Installing MYSQL Server"

 systemctl enable mysqld &>>$LOG_FILE
 VALIDATE $? "Enable mysql server"

 systemctl start mysqld &>>$LOG_FILE
 VALIDATE $? "Started mysql server"

 mysql -h mysql.devops1289.online -u root -pExpenseApp@1 -e 'show databases;' &>>$LOG_FILE
 if [ $? -ne 0 ]
then 
    echo "Mysql root password is not setup, setting now" &>>$LOG_FILE
    mysql_secure_installation --set-root-pass ExpenseApp@1 
    VALIDATE $? "Setting Up root password"

else 
    echo -e "Mysql root password is already setup ..$Y SKIPPING $N" | tee -a $LOG_FILE
fi        

