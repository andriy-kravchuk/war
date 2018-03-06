#!/usr/bin/bash
# This script uploads logs on demand to the FTP server
# set settings for FTP client such as active/passive
#
# by Andriy Kravchuk
# Union
# 05.03.2018
#
if [ -z "$1" ]; then echo "Usage: $0 20181201"; exit; fi

TIME_NOW=`date '+%Y%m%d_%H%M%S'`
LOGS_PATH="/var/logs"
HOSTNAME=`hostname`
APPLICATION_NAME="connector-1"
ENVIRONMENT="prod"

DATE=$1
LOGS_ARCHIVE_FOLDER="/tmp/${APPLICATION_NAME}-${ENVIRONMENT}-server${SERVER}"
LOGS_ARCHIVE_FILENAME="${APPLICATION_NAME}-${ENVIRONMENT}-${HOSTNAME}_${TIME_NOW}.tgz"
LOGS_FILEMASK="*${APPLICATION_NAME}*"
TMP_FILENAME="/tmp/delme"

FTP_SERVER_ADDR=""
FTP_USERNAME=""
FTP_PASSWORD=""
FTP_UPLOAD_DIR=""
FTP_CLIENT_SETTINGS_ACTIVE="-ivn"
FTP_CLIENT_SETTINGS_PASSIVE="-invp"

MESSAGE="\n\nDobry den,\nlogy su na ceste ftp://${FTP_UPLOAD_DIR}/${LOGS_ARCHIVE_FILENAME}\nAndriy Kravchuk\n\n"


touch $TMP_FILENAME -d "${1}"
if [ -d "$LOGS_ARCHIVE_FOLDER" ]; then rm -rf $LOGS_ARCHIVE_FOLDER; fi
mkdir $LOGS_ARCHIVE_FOLDER

find $LOGS_PATH/ -name $LOGS_FILEMASK -type f -newer $TMP_FILENAME | xargs -I P cp P $LOGS_ARCHIVE_FOLDER
tar -cvjf $LOGS_ARCHIVE_FILENAME $LOGS_ARCHIVE_FOLDER && rm -rf $LOGS_ARCHIVE_FOLDER

ftp $FTP_CLIENT_SETTINGS_PASSIVE $FTP_SERVER_ADDR <<BYE
user $FTP_USERNAME $FTP_PASSWORD
binary
cd $FTP_UPLOAD_DIR
put $LOGS_ARCHIVE_FILENAME
bye
BYE

printf $MESSAGE
rm -f $LOGS_ARCHIVE_FILENAME
