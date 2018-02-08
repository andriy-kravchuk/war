#!/bin/sh
# This script automatically get new file from the new release 
# and prepare it
# by Andriy Kravchuk, UNION, Jan 2018
#
# ver 1.0
#
# Note: this script is an example and must be filled-up with data,
# like BASEDIR, BASEFILE and so on
BASEDIR=""
BASEFILE=""
FTP_SERVER_ADDR=""
FTP_USERNAME=""
FTP_PASSWORD=""
FTP_DOWNLOAD_DIR="/"
NEW_RELEASE=$1
WORKING_DIR="tmp"
RELEASE_FILENAME_PATTERN="x-x-*-x.war"

if [ -z "${NEW_RELEASE}" ]; then 
	echo "Usage example: $0 release-filename-x.x.x.zip"
	exit
fi

UP=`fping -r 1 ${FTP_SERVER_ADDR}`
if [ -z "${UP}" ]; then 
	echo "$FTP_SERVER_ADDR isn't available."
	exit
fi

if [ ! -d "${WORKING_DIR}" ]; then
	mkdir ${WORKING_DIR}
	rm -rf "${WORKING_DIR}/*"
fi

echo "Cleaning up temporary directory"
rm -rf ${WORKING_DIR}/*

if [ ! -e "${WORKING_DIR}/${NEW_RELEASE}" ]; then 
echo "Downloading ${NEW_RELEASE} from FTP..."
ftp -pin $FTP_SERVER_ADDR << EOF
user ${FTP_USERNAME} ${FTP_PASSWORD}
binary
lcd ${WORKING_DIR}		
mget ${NEW_RELEASE}
quit
EOF
else
	echo "Can't copy ${NEW_RELEASE}. Is file exist?"
	exit
fi

echo "Unzipping..."
unzip -o ${WORKING_DIR}/${NEW_RELEASE} -d ${WORKING_DIR} 1>/dev/null

echo "Preparing new WAR files..."
RELEASE_DIRNAME=($(ls -d ${WORKING_DIR}/ehip-*/))
cp ./${RELEASE_DIRNAME}deploy/${RELEASE_FILENAME_PATTERN}.zip ${WORKING_DIR}/
unzip -o ${WORKING_DIR}/${RELEASE_FILENAME_PATTERN}.zip -d ${WORKING_DIR}/ 1>/dev/null

cd ${WORKING_DIR}
NEW_RELEASE_FILE=($(ls ${RELEASE_FILENAME_PATTERN}))
echo "Copying new file '${NEW_RELEASE_FILE}' to ${BASEDIR}"
cp ${NEW_RELEASE_FILE} ${BASEDIR}

echo "Setting permissions and/or re-linking for ${BASEDIR}/${NEW_RELEASE_FILE}"
chmod +x ${BASEDIR}/${NEW_RELEASE_FILE}
cp ${BASEDIR}/${NEW_RELEASE_FILE} ${BASEDIR}/${BASEFILE}

echo "Now, under root: service x-x-x stop && service x-x-x start"
