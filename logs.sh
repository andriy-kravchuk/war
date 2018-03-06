#!/usr/bin/bash
# This script uploads logs on demand to the FTP server
# set settings for FTP client such as active/passive
# change SERVER to 1 or 2 depends where this script is running
#
# by Andriy Kravchuk
# Union
# 05.03.2018
#
if [ -z "$1" ]; then echo "Usage: $0 20181201"; exit; fi
TOUCH="/usr/gnu/bin/touch"
FIND="/usr/gnu/bin/find"
TIME_NOW=`date '+%Y%m%d_%H%M%S'`
INSTANCE_1_LOGS_PATH="/var/nodes/servers/test-instance1/logs"
INSTANCE_2_LOGS_PATH=`echo $INSTANCE_1_LOGS_PATH | sed -e 's/1/2/g'`
HOSTNAME=`hostname`

DATE=$1
LOGS_ARCHIVE_FOLDER=/tmp/app-server${SERVER}
LOGS_ARCHIVE_FILENAME="app-uat-${HOSTNAME}_${TIME_NOW}.tgz"
TMP_FILENAME="/tmp/delme"
LOGS_FILEMASK="*server.log*"

FTP_SERVER_ADDR=""
FTP_USERNAME=""
FTP_PASSWORD=""
FTP_UPLOAD_DIR=""
FTP_CLIENT_SETTINGS_ACTIVE="-ivn"
FTP_CLIENT_SETTINGS_PASSIVE="-invp"

$TOUCH $TMP_FILENAME -d "${1}"
if [ -d "$LOGS_ARCHIVE_FOLDER" ]; then rm -rf $LOGS_ARCHIVE_FOLDER; fi
mkdir $LOGS_ARCHIVE_FOLDER
mkdir $LOGS_ARCHIVE_FOLDER/instance1 $LOGS_ARCHIVE_FOLDER/instance2

$FIND $INSTANCE_1_LOGS_PATH/ -name $LOGS_FILEMASK -type f -newer $TMP_FILENAME | xargs -I P cp P $LOGS_ARCHIVE_FOLDER/instance1
$FIND $INSTANCE_2_LOGS_PATH/ -name $LOGS_FILEMASK -type f -newer $TMP_FILENAME | xargs -I P cp P $LOGS_ARCHIVE_FOLDER/instance2
tar -cvjf $LOGS_ARCHIVE_FILENAME $LOGS_ARCHIVE_FOLDER && rm -rf $LOGS_ARCHIVE_FOLDER

ftp $FTP_CLIENT_SETTINGS_PASSIVE $FTP_SERVER_ADDR <<BYE
user $FTP_USERNAME $FTP_PASSWORD
binary
cd $FTP_UPLOAD_DIR
put $LOGS_ARCHIVE_FILENAME
bye
BYE

rm -f $LOGS_ARCHIVE_FILENAME
