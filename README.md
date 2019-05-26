## overview

This is the script I'm using to manage backups for my nextcloud instance to s3, it's easy & reliable.

I'm using the Nextcloud snap for Debian 9, so for other packages you'll need to change the mysqldump command

If you find this helpful please give me a star, if you have any problems please post an issue!

## prerequisites

_programs & packages_

 * *nextcloud instance*
 * *duplicity* - handles the backups `apt install duplicity`
 * *gpg* - dependency for duplicity encryption `apt install gpg`
 * *python-boto* - dependency for duplicity using amazon backend `apt install python-boto`

_other resources_

 * *amazon s3 bucket* - create this first, will need uri, access ID, and secret key
 * *mailgun api credentials* - optional, for emailing backup logs to somewhere

## making this work

 1. [Create a GPG Key](#create_gpg_key)
 2. `cp env-up.sh.example env-up.sh` and edit the new file, setting appropriate values
 3. chmod scripts a la `chmod +x *.sh`
 4. try it out with `./backup.sh`
 5. post an issue on this repo if something doesn't work
 6. [Set up cron](#set_up_cron)

## create GPG key

`gpg --full-gen-key`

 * kind of key: `(2) DSA and Elgamal`
 * keysize: `2048 bits`
 * name
 * email
 * comment: `<empty>`
 * passphrase

output looks like:
```
gpg (GnuPG) 2.2.4; Copyright (C) 2017 Free Software Foundation, Inc.
This is free software: you are free to change and redistribute it.
There is NO WARRANTY, to the extent permitted by law.

Please select what kind of key you want:
   (1) RSA and RSA (default)
   (2) DSA and Elgamal
   (3) DSA (sign only)
   (4) RSA (sign only)
Your selection? 2
DSA keys may be between 1024 and 3072 bits long.
What keysize do you want? (2048)
Requested keysize is 2048 bits
Please specify how long the key should be valid.
         0 = key does not expire
      <n>  = key expires in n days
      <n>w = key expires in n weeks
      <n>m = key expires in n months
      <n>y = key expires in n years
Key is valid for? (0) 0
Key does not expire at all
Is this correct? (y/N) y

GnuPG needs to construct a user ID to identify your key.

Real name: Levi
Email address: levi@foo.com
Comment:
You selected this USER-ID:
    "Levi <levi@foo.com>"

Change (N)ame, (C)omment, (E)mail or (O)kay/(Q)uit? o
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: WARNING: some OpenPGP programs can't handle a DSA key with this digest size
We need to generate a lot of random bytes. It is a good idea to perform
some other action (type on the keyboard, move the mouse, utilize the
disks) during the prime generation; this gives the random number
generator a better chance to gain enough entropy.
gpg: /home/levi/.gnupg/trustdb.gpg: trustdb created
gpg: key 0B9446339A754A66 marked as ultimately trusted
gpg: directory '/home/levi/.gnupg/openpgp-revocs.d' created
gpg: revocation certificate stored as '/home/levi/.gnupg/openpgp-revocs.d/7FBB0B1E7A7D927952B94C570B9448559A754A55.rev'
public and secret key created and signed.

pub   dsa2048 2019-05-25 [SC]
      7FCC0B1E7A7D927953B94C570B9448779A754A55
uid                      Levi <levi@foo.com>
sub   elg2048 2019-05-25 [E]
```

you'll need that key name `0B9446339A754A66`, set it as GPG_KEY_NAME

Duplicity is going to use a GPG key to encrypt your backup, which is great, but you're gonna need that key if you actually want to use your backed up data for anything so maybe store a copy somewhere other than the machine you're backing up!

`gpg --export-secret-keys --output my-secret --armor`
`gpg --export --output my-secret.pub --armor`

## set up cron

 * sort out the time on your server with [timedatectl](https://linuxize.com/post/how-to-set-or-change-timezone-on-debian-9/)
 * crontab -e
 * create new job
 * ctrl-x, then y

If you want to run the cron job at midnight each night, that would be:

`0  0  *   *   *    /root/nextcloud-duplicity/backup.sh`

If you want to run cron every 5 minutes just to see whether it's gonna work, that would look like this:

`*/5 *  *   *   *    /root/nextcloud-duplicity/backup.sh`



## acknowledgements

 * [cenolan script](http://www.cenolan.com/2008/12/how-to-incremental-daily-backups-amazon-s3-duplicity/) this is a fairly thorough general backup script which I used as a starting point.
 * [autoize script](https://gist.github.com/autoize/d39dd9d00150ed3eac69bbfa4dd1b21b) this was helpful for figuring out how to put nextcloud in maintenance mode and dump the db
