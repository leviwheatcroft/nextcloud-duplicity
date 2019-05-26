#!/bin/bash

# Check if running as root

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# env vars
source "${BASH_SOURCE%/*}/env-up.sh"

# Clear the old daily log file
cat /dev/null > ${DAILYLOGFILE}

# Put NextCloud into maintenance mode. 
# This ensures consistency between the database and data directory.

nextcloud.occ maintenance:mode --on

# Trace function for logging, don't change this
trace () {
        stamp=`date +%Y-%m-%d_%H:%M:%S`
        echo "$stamp: $*" >> ${DAILYLOGFILE}
}

# Dump database and backup to S3
if [ $SQL_DUMP == yes ]; then

	# nextcloud in snapd on Debian 9
	nextcloud.mysqldump \
		--single-transaction \
		--host=$DB_HOST \
		--user=$DB_USER \
		--password=$DB_PASSWORD > /var/tmp/nextcloud.sql

	# the following might work for other packages... not sure
	
	# nextcloud \
	#	--single-transaction \
	#	--host=$DB_HOST \
	#	--user=$DB_USER \
	#	--password=$DB_PASSWORD
	#   $DB_NAME > /var/tmp/nextcloud.sql	
fi;

# check whether it's the 1st or 14th day of the month
# if so will do a full backup
FULL=
if [ $(date +%d) -eq 1 ] || [ $(date +%d) -eq 14 ]; then
    FULL=full
fi;

trace "Backup for local filesystem started"

if [ $PURGE_OLD == yes ]; then
	trace "... removing old backups"
	duplicity remove-older-than ${OLDER_THAN} ${DEST} >> ${DAILYLOGFILE} 2>&1
fi;

trace "... backing up filesystem"

if [ $BACKUP == yes ]; then
	duplicity \
		${FULL} \
		--encrypt-key=${GPG_KEY_NAME} \
		--sign-key=${GPG_KEY_NAME} \
		--volsize=250 \
		--include=/var/tmp/nextcloud.sql \
		--include=${DATA_DIR} \
		--exclude=/** \
		/ ${DEST} 2>&1 | tee ${DAILYLOGFILE}
fi;

trace "Backup for local filesystem complete"
trace "------------------------------------"

# unset maintenance mode
nextcloud.occ maintenance:mode --off

# Send the daily log file by email
# cat "$DAILYLOGFILE" | mail -s "Duplicity Backup Log for $HOST - $DATE" $MAILADDR

if [ $SENDEMAIL == yes ]; then
	curl -s --user "api:${MAILGUN_API_KEY}" \
		${MAILGUN_EPOINT}/messages \
		-F from=${MAILGUN_ADDR} \
		-F to=${MAILGUN_ADDR} \
		-F subject="Backup Log ${HOST} ${DATE}" \
		-F text="Backup Log Attached: ${HOST} ${DATE}" \
		-F attachment="@${DAILYLOGFILE}"
fi;

# Append the daily log file to the main log file
cat "$DAILYLOGFILE" >> $LOGFILE

