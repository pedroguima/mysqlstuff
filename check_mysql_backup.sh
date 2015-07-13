#!/bin/sh

#######################################
#                                     #
#  https://github.com/pedroguima      #
#                                     #
#######################################

## This is simple local check for check_mk. Just edit and drop this script in your local checks directory.
## Variables

USER=backups
PW=such_a_strong_password
BACKUPS_DIR=any_dir

DATABASES=$(mysql -u $USER -p$PW  -N -e 'select schema_name from information_schema.schemata where schema_name != "information_schema" and schema_name != "mysql"';)

for DATABASE in $DATABASES; do
        DIR=$BACKPUS_DIR/$DATABASE
        COUNT=$(find $DIR -type f -mtime -2 -size +20k 2>/dev/null  | wc -l)
        res=$?

        if [ $COUNT -eq 0 ] || [ $res -ne 0 ]; then
                echo "2 MySQL_Backups - CRITICAL - No $DATABASE backups found!"
                exit 1;
        fi
done

echo "0 MySQL_Backups - OK - All MySQL backups found."
exit 0;

