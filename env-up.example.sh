# SWITCHES
# ========
# you can switch on / off elements of the process here, useful for testing
# all yes/no values

# do the sql dump
export SQL_DUMP=yes
# purge old backups, see OLDER_THAN value
export PURGE_OLD=yes
# run duplicity to back everything up to S3
export BACKUP=yes
# send email with log file
export SENDEMAIL=no

export LOGFILE="/var/log/backup.log"
export DAILYLOGFILE="/var/log/backup.daily.log"
# some descriptor for this host, used in email only
export HOST='<host descriptor>'
export DATE=`date +%Y-%m-%d`

# NEXTCLOUD
# =========
# Path to NextCloud data directory
export DATA_DIR='/var/snap/nextcloud/common/nextcloud/data'

# DB STUFF
# ========
# get these from your instance with `nextcloud.occ config:list --private`
export DB_HOST='localhost'
export DB_USER='nextcloud'
export DB_PASSWORD='<db password>'
export DB_NAME='nextcloud'

# MAILGUN STUFF
# =============
# optional mailgun creds, optional
# set `SENDEMAIL=yes` above if you want to use this
export MAILGUN_API_KEY='<mailgun api key>'
export MAILGUN_EPOINT='<mailgun endpoint>'
export MAILGUN_ADDR='<email address>'

# DUPLICITY / BACKUP
# ==================
# Your GPG key - see README.md
export GPG_KEY_NAME='<gpg key name>'
# How long to keep backups for - see duplicity docs
export OLDER_THAN="3M"
# The destination - see duplicity docs
# usually like `s3://s3.<region>.amazonaws.com/<bucket name>`
# eg: `s3://s3.ap-southeast-1.amazonaws.com/levis-bucket`
export DEST='<s3 dest>'
# AWS Creds - from AWS IAM
export AWS_ACCESS_KEY_ID='<aws access key id>'
export AWS_SECRET_ACCESS_KEY='<aws secret access key>'
# gpg passphrase - see README.md
export PASSPHRASE='<gpg passphrase>'
