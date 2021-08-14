#!/bin/bash

### SETTINGS
# backup dir
BACKUP_DIR=/media/backup
# last full backup images count
FULL_IMAGES_COUNT=2
# last snapshots count
SNAPSHOT_COUNT=4

### OTHER VARIABLES
# timestamp
TIMESTAMP=`date +%Y%m%d-%H%M%S`
# target vm list (running)
VM_LIST=`virsh list | grep running | awk '{print $2}'`
# log file
LOGFILE="/var/log/kvmbackup.log"

# write log
echo -e "\n**********\n`date`: START BACKUP OF HOST: `hostname`\n"
echo -e "\n**********\n`date`: START BACKUP OF HOST: `hostname`\n" >> $LOGFILE
echo -e "Running VM's:\n`virsh list | grep running | awk '{print "*",$2}'`"
echo -e "Running VM's:\n`virsh list | grep running | awk '{print "*",$2}'`" >> $LOGFILE

for ACTIVEVM in $VM_LIST
    do
        # create directories
        mkdir -p $BACKUP_DIR/$ACTIVEVM/tmp-ext-snap
        mkdir -p $BACKUP_DIR/$ACTIVEVM/config
        mkdir -p $BACKUP_DIR/$ACTIVEVM/image
        # add vm disk names to array
        DISK_ARR=(`virsh domblklist $ACTIVEVM | grep -e vd -e sd | grep -e '/' | awk '{print $1}'`)
        # list vm disk names
        DISK_NAMES=`virsh domblklist $ACTIVEVM | grep -e vd -e sd | grep -e '/' | awk '{print $1}'`
        # list vm disk paths
        DISK_PATH=`virsh domblklist $ACTIVEVM | grep -e vd -e sd | grep -e '/' | awk '{print $2}'`

        ### VM CONFIG BACKUP
        # write log
        echo -e "\n--- `date`: Start VM backup of: $ACTIVEVM\n"
        echo -e "\n--- `date`: Start VM backup of: $ACTIVEVM\n" >> $LOGFILE
        virsh dumpxml $ACTIVEVM > $BACKUP_DIR/$ACTIVEVM/config/$ACTIVEVM-$TIMESTAMP.xml

        ### CREATE SNAPSHOT
        # write log
        echo "`date`: Create VM snapshot of: $ACTIVEVM"
        echo "`date`: Create VM snapshot of: $ACTIVEVM" >> $LOGFILE
        virsh snapshot-create-as --domain $ACTIVEVM --name snapshot-$TIMESTAMP
        sleep 2

        ### CREATE TEMPORARY EXTERNAL SNAPSHOT
        # write log
        echo "`date`: Create temporary external VM snapshot of: $ACTIVEVM"
        echo "`date`: Create temporary external VM snapshot of: $ACTIVEVM" >> $LOGFILE
        for DISK_ARR_ITEM in ${!DISK_ARR[*]}
            do
                DISKSPEC_ARR+=("--diskspec ${DISK_ARR[$DISK_ARR_ITEM]},file=$BACKUP_DIR/$ACTIVEVM/tmp-ext-snap/snapshot-`echo "${DISK_ARR[$DISK_ARR_ITEM]}"`-$TIMESTAMP.qcow2,snapshot=external")
            done
        virsh snapshot-create-as \
            --domain $ACTIVEVM tmp-ext-snap-$TIMESTAMP ${DISKSPEC_ARR[*]} \
            --disk-only \
            --atomic
        # empty array
        unset DISKSPEC_ARR
        sleep 2

        ### VM DISK BACKUP
        for DISK_PATH_ITEM in $DISK_PATH
            do
                # write log
                echo "`date`: Create VM backup of: $ACTIVEVM [$DISK_PATH_ITEM]"
                echo "`date`: Create VM backup of: $ACTIVEVM [$DISK_PATH_ITEM]" >> $LOGFILE
                # get filename from path
                FILENAME=`basename $DISK_PATH_ITEM`
                # save and shrink image
                mkdir -p $BACKUP_DIR/$ACTIVEVM/image/$FILENAME
                qemu-img convert -O qcow2 -c $DISK_PATH_ITEM $BACKUP_DIR/$ACTIVEVM/image/$FILENAME/$FILENAME.$TIMESTAMP.bak
                sleep 2
            done

        ### COMMIT SNAPSHOT
        for DISK_NAMES_ITEM in $DISK_NAMES
            do
                # get path of snapshot
                SNAP_PATH=`virsh domblklist $ACTIVEVM | grep $DISK_NAMES_ITEM | awk '{print $2}'`
                # write log
                echo "`date`: Commit snapshot: $ACTIVEVM [$SNAP_PATH]"
                echo "`date`: Commit snapshot: $ACTIVEVM [$SNAP_PATH]" >> $LOGFILE
                # commit snapshot
                virsh blockcommit $ACTIVEVM $DISK_NAMES_ITEM --active --verbose --pivot
                sleep 2
            done

        ### DELETE TEMPORARY EXTERNAL SNAPSHOTS (VM)
        SNAPSHOT_LIST=`virsh snapshot-list $ACTIVEVM | grep tmp-ext-snap | awk '{print $1}'`
        # write log
        echo "`date`: Delete temporary external snapshot (vm) of: $ACTIVEVM [$SNAPSHOT_LIST]"
        echo "`date`: Delete temporary external snapshot (vm) of: $ACTIVEVM [$SNAPSHOT_LIST]" >> $LOGFILE
        for SNAPSHOT_LIST_ITEM in $SNAPSHOT_LIST
            do
                virsh snapshot-delete $ACTIVEVM $SNAPSHOT_LIST_ITEM --metadata
            done

        ### DELETE TEMPORARY EXTERNAL SNAPSHOTS (FILE)
        # write log
        echo -e "`date`: Delete temporary external snapshot (file) of: $ACTIVEVM"
        echo -e "`date`: Delete temporary external snapshot (file) of: $ACTIVEVM" >> $LOGFILE
        echo -e "`find $BACKUP_DIR/$ACTIVEVM/tmp-ext-snap/* -exec ls -ltrh {} + | awk '{print $9}'`\n"
        echo -e "`find $BACKUP_DIR/$ACTIVEVM/tmp-ext-snap/* -exec ls -ltrh {} + | awk '{print $9}'`\n" >> $LOGFILE
        find $BACKUP_DIR/$ACTIVEVM/tmp-ext-snap/* -exec rm {} \;

        ### DELETE OLD CONFIG FILES
        # write log
        echo "`date`: Delete old config files of: $ACTIVEVM"
        echo "`date`: Delete old config files of: $ACTIVEVM" >> $LOGFILE
        CONFIG_ARR=(`ls $BACKUP_DIR/$ACTIVEVM/config/* -1tr`)
            if (( ${#CONFIG_ARR[*]} > $FULL_IMAGES_COUNT ))
                then
                    echo "* ${CONFIG_ARR[0]} - deleted"
                    rm ${CONFIG_ARR[0]}
                fi

        ### DELETE OLD IMAGES
        # write log
        echo "`date`: Delete old full images of: $ACTIVEVM"
        echo "`date`: Delete old full images of: $ACTIVEVM" >> $LOGFILE
        for DISK_PATH_ITEM in $DISK_PATH
            do
                FILENAME=`basename $DISK_PATH_ITEM`
                IMAGE_ARR=(`ls $BACKUP_DIR/$ACTIVEVM/image/$FILENAME/* -1tr`)
                if (( ${#IMAGE_ARR[*]} > $FULL_IMAGES_COUNT ))
                    then
                        echo "* ${IMAGE_ARR[0]} - deleted"
                        rm ${IMAGE_ARR[0]}
                fi
            done

        ### DELETE OLD SNAPSHOTS
        # write log
        echo "`date`: Delete old snapshots of: $ACTIVEVM"
        echo "`date`: Delete old snapshots of: $ACTIVEVM" >> $LOGFILE
        SNAPSHOT_ARR=(`virsh snapshot-list $ACTIVEVM | grep snapshot | awk '{print $1}'`)
            if (( ${#SNAPSHOT_ARR[*]} > $SNAPSHOT_COUNT ))
                then
                    virsh snapshot-delete $ACTIVEVM ${SNAPSHOT_ARR[0]}
                fi

        ### SNAPSHOT LIST
        # write log
        echo -e "Current snapshot list:\n`virsh snapshot-list $ACTIVEVM`"
        echo -e "Current snapshot list:\n`virsh snapshot-list $ACTIVEVM`" >> $LOGFILE

        ### END BACKUP
        # write log
        echo -e "\n`date`: End VM backup of: $ACTIVEVM"
        echo -e "\n`date`: End VM backup of: $ACTIVEVM" >> $LOGFILE
    done

# write log
echo -e "\n`date`: END BACKUP OF HOST: `hostname`\n**********\n"
echo -e "\n`date`: END BACKUP OF HOST: `hostname`\n**********\n" >> $LOGFILE
