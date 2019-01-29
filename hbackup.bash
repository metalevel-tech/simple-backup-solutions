#!/bin/bash

# Stolen from Host.bg
# Location and name: /usr/local/sbin/hbackup
# Triggered by `sudo crontab -e`: 17 4 * * * /usr/local/sbin/hbackup > /dev/null 2>&1

### mysql user and pass
MPASS="Xg***********V0"
MUSER="xw******Cb"
### backup directories
SOURCES="/home /etc /var/www"

BACKUP_DIR="/hostbg_bkps"
todays=$(date +'%Y-%m-%d')
commands="rsync mysql"
counter=0
error=0
######### Variables ##################

#Verifying that which is available.
if [ -x /usr/bin/which ]; then
    echo "      Command \"which\" exists"
else
    echo "      Command \"which\" does not exist, pls install"
    exit 0
fi

#Check whether all necessary commands available.
for command in $commands; do
  echo "        Check for command \"$command\" exists: "
        if which $command >/dev/null ; then
         echo "                          YES"
        else
         echo " Command $command not exists, pls install \"$command\""
         exit 0
        fi
done

#Check folder /hostbg_bkps exist
if [ ! -d "$BACKUP_DIR" ]; then
        echo "  Create folder $BACKUP_DIR"
        mkdir $BACKUP_DIR
else
        echo "  Folder $BACKUP_DIR exist"
fi


rsync_back (){
        last=$(ls -r /hostbg_bkps/sys/| head -1)
        echo "  rsync -va --link-dest=${BACKUP_DIR}/sys/${last} $SOURCES $BACKUP_DIR/${todays} "
        ionice -c 3 nice -n +19 rsync -aq --ignore-errors --link-dest=${BACKUP_DIR}/sys/${last} $SOURCES $BACKUP_DIR/sys/${todays}
        if [ "$?" = 0 ]; then
                echo "  Sucseful execute rsync -va --link-dest=${BACKUP_DIR}/sys/${last} $SOURCES $BACKUP_DIR/${todays}"
        else
                echo "  $counter attempt execute rsync -va --link-dest=${BACKUP_DIR}/sys/${last} $SOURCES $BACKUP_DIR/${todays} !!!"
                if [ $counter != 2 ]; then
                        let counter++
                        rsync_back
                else
                        echo "  Failed execute rsync -va --link-dest=${BACKUP_DIR}/sys/${last} $SOURCES $BACKUP_DIR/${todays}, please contact a system administrator !!!"
                        export counter=1
                        error=1
                fi
        fi

}

mysql_back () {
        #Check folder /hostbg_bkps exist
        if [ ! -d "$BACKUP_DIR/DBS/$todays" ]; then
                echo "  Create folder $BACKUP_DIR/DBS/$todays"
                mkdir $BACKUP_DIR/DBS/$todays
        else
                echo "  Folder $BACKUP_DIR/DBS/$todays exist"
        fi
        # check for work mysql
#       check_mysql_work=$(mysql -uhostbg -p6Vdu2XRGcwf1Zmph -e "select 1 + 1;")
        check_mysql_work=$(mysql -e "select 1 + 1;")
        if [ "$?" = 0 ]; then
                echo
                echo  " Dump MySQL DB"
#               list_dbs=$(mysql -uhostbg -p6Vdu2XRGcwf1Zmph -N -B -e "SHOW DATABASES;")
                list_dbs=$(mysql -N -B -e "SHOW DATABASES;")
                for dump_dbs in $list_dbs; do
                        func_dump_dps () {
#                               mysqldump -uhostbg -p6Vdu2XRGcwf1Zmph -f --skip-lock-tables $dump_dbs | gzip > $BACKUP_DIR/DBS/$todays/${dump_dbs}-${todays}.sql.gz
                                mysqldump -f --skip-lock-tables $dump_dbs | gzip > $BACKUP_DIR/DBS/$todays/${dump_dbs}-${todays}.sql.gz
                                if [ "$?" = 0 ]; then
                                        echo "  Successful dump $dump_dbs"
                                else
                                        echo "  $counter attempt dump $dump_dbs !!!"
                                        if [ $counter != 2 ]; then
                                                let counter++
                                                func_dump_dps
                                        else
                                                echo "  Failed dump $dump_dbs, please contact a system administrator !!!"
                                                mysql -h 87.120.41.23 -u$MUSER -p$MPASS -D bk_monitoring -e "update perms set error_message='Some Data Base is not the dump';"
                                                export counter=0
                                        fi
                                fi
                        }
                func_dump_dps
                done
        else
                mysql -h 87.120.41.23 -u$MUSER -p$MPASS -D bk_monitoring -e "update perms set error_message='Database server problem';"
                error=1
        fi
}

delete_old_back () {
        # Delete backup $BACKUP_DIR/sys/
        folder_for_delete=$(ls -r $BACKUP_DIR/sys/ | tail -n +8)
        if [ -n "$folder_for_delete" ]; then
                for folder in $folder_for_delete; do
                        echo "  Delete folder $BACKUP_DIR/sys/${folder}"
                        rm -rf $BACKUP_DIR/sys/${folder}
                done
        fi
        # Delete backup $BACKUP_DIR/DBS/

        folder_for_delete=$(ls -r $BACKUP_DIR/DBS/ | tail -n +8)
        if [ -n "$folder_for_delete" ]; then
                for folder in $folder_for_delete; do
                        echo "  Delete folder $BACKUP_DIR/DBS/${folder}"
                        rm -rf $BACKUP_DIR/DBS/${folder}
                done
        fi
}

successful_finish () {
        if [ "$error" == "0" ]; then
        # Successful finis backup and update check
        mysql -h 87.120.41.23 -u$MUSER -p$MPASS -D bk_monitoring -e "update perms set error_message='No errors';"
        mysql -h 87.120.41.23 -u$MUSER -p$MPASS -D bk_monitoring -e "update perms set last_backup='$todays';"
        delete_old_back
        # Remount backup disk Read-Only
#       mount -o remount,ro $get_backup_disk $BACKUP_DIR
        fi
}

backup_func () {
        export get_backup_disk="$get_backup_disk"
        mysql_back
        rsync_back
        successful_finish
}

# Check disk it's full
for colone  in `df /hostbg_bkps | tail -n 1`; do
        if [ `echo "$colone" | grep %` ]; then
                get_disk_usage=`echo "$colone" | cut -d"%" -f1`
                if [ $get_disk_usage -ge 90 ];then
                        echo "No disk space in backup disk"
                        mysql -h 87.120.41.23 -u$MUSER -p$MPASS -D bk_monitoring -e "update perms set error_message='No disk space in backup disk';"
                        exit 1
                fi
        fi
done


# Check disk it's exist and mounted
exit_status_mount_hostbg_bkps=`grep $BACKUP_DIR /proc/mounts | grep -oE "ro|rw"`
if [ -n "$exit_status_mount_hostbg_bkps" ];then
        get_backup_disk=`grep $BACKUP_DIR /proc/mounts | awk '{print $1}'`
        if  [ -n "$get_backup_disk" ]; then
                if [ "$exit_status_mount_hostbg_bkps" = "ro" ];then
                        mount -o remount,rw,noatime $get_backup_disk $BACKUP_DIR
                        echo "  Disk $get_backup_disk remount RW"
                        backup_func
                else
                        echo "  Disk $get_backup_disk it's mount RW"
                        backup_func
                fi
        else
                echo "No disk for backup mount"
        fi
else
        backup_disk=$(ls /dev/ | grep ip)
        if [ -n "$backup_disk" ]; then
                echo "  Mount disk $backup_disk in $BACKUP_DIR"
                mount -o noatime /dev/$backup_disk $BACKUP_DIR > /dev/null 2>&1
                backup_func
        else
                echo "  No Disk for mount in ${BACKUP_DIR}"
                mysql -h 87.120.41.23 -u$MUSER -p$MPASS -D bk_monitoring -e "update perms set error_message='No back disk for mount';"
                exit 1
        fi
        echo "  Not success mount back disk"
        mysql -h 87.120.41.23 -u$MUSER -p$MPASS -D bk_monitoring -e "update perms set error_message='Not success mount back disk';"
        exit 1
fi
