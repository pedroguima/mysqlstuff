#!/bin/bash

#######################################
#                                     #
#  https://github.com/pedroguima      #
#                                     #
#######################################

## Variables

DATE=$(date -I)
USER="backups_user"
PW="such_a_strong_password"
BACKUP_DIR=/anydir
RETENTION_DAYS=15
REPORT_EMAIL="your@example.com"
SUBJECT="Backups Report"

## Variables End

MAIL=$(which mail)
MYSQL=$(which mysql)
MYSQLDUMP=$(which mysqldump)
BZIP2=$(which bzip2)

function error {
        echo "DB backups on $(hostname) failed. Please check!" | $MAIL -s "$SUBJECT" $REPORT_EMAIL
        exit 1;
}

DATABASES=$($MYSQL -u $USER -p$PW  -N -e 'select schema_name from information_schema.schemata where schema_name != "information_schema" and schema_name != "mysql"' 2> /dev/null ) || error

for DATABASE in $DATABASES; do
        if [ ! -d $BACKUP_DIR/$DATABASE ]; then
                mkdir -p $BACKUP_DIR/$DATABASE
        else
                find $BACKUP_DIR/$DATABASE -type f -iname "*.bz2" -mtime +$RETENTION_DAYS -exec rm -f {} \;
        fi
        $MYSQLDUMP -u $USER -p$PW $DATABASE --skip-extended-insert 2>/dev/null | $BZIP2 > $BACKUP_DIR/$DATABASE/$DATABASE-$DATE.sql.bz2
        res=$?

        if [ ${PIPESTATUS[0]} -ne 0 ] || [ $res -ne 0 ]; then
                error
        fi
done
