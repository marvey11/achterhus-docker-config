#!/bin/bash

# Configuration
SOURCE="/mnt/storage/"
DEST="/mnt/backup/mirror/"
LOG="/var/log/achterhus/backup.log"

# Create destination if it doesn't exist
mkdir -p $DEST

echo "--- Backup Started: $(date) ---" >> $LOG

# rsync command: 
# -a (archive) 
# -v (verbose) 
# -h (human-readable) 
# -z (compress during transfer)
# --delete (remove files at destination that are gone from source)
# --exclude (exclude specific directories, in this case 'lost+found' and '.deleted/')
rsync -avhz --delete --exclude='lost+found' --exclude='.deleted/' $SOURCE $DEST >> $LOG 2>&1

echo "--- Backup Finished: $(date) ---" >> $LOG
