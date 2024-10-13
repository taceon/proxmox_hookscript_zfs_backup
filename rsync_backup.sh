#!/bin/bash

# Set the source directories
SRC1="/hdd"
SRC2="/mnt/media_storage"

# Set the backup destination directory
DEST="/mnt/backup"

# Create a timestamp for logging purposes
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

# Log file location
LOGFILE="/var/log/backup.log"

# Rsync options:
# -a: Archive mode (preserves permissions, symlinks, etc.)
# -v: Verbose (shows progress)
# -h: Human-readable output
# --ignore-existing: Only copy new files, skip existing ones in the destination
# --log-file: Logs rsync output to a log file

rsync -avh --ignore-existing --log-file="$LOGFILE" "$SRC1/" "$DEST/hdd/" 
rsync -avh --ignore-existing --log-file="$LOGFILE" "$SRC2/" "$DEST/media_storage/"

# Logging success message
echo "Backup completed successfully at $TIMESTAMP" >> "$LOGFILE"
