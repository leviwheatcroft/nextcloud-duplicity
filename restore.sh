#!/bin/bash
# Export some ENV variables so you don't have to type anything
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_ID"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_ACCESS_KEY"
export PASSPHRASE="YOUR_GPG_PASSPHRASE"

# Your GPG key
GPG_KEY=YOUR_GPG_KEY

# The destination
DEST="s3+http://your_s3_bucket_name"

if [ $# -lt 3 ]; then echo "Usage $0 <date> <file> <restore-to>"; exit; fi

duplicity \
    --encrypt-key=${GPG_KEY} \
    --sign-key=${GPG_KEY} \
    --file-to-restore $2 \
    --restore-time $1 \
    ${DEST} $3

# Reset the ENV variables. Don't need them sitting around
export AWS_ACCESS_KEY_ID=
export AWS_SECRET_ACCESS_KEY=
export PASSPHRASE= 