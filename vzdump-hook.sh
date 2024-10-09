#!/bin/bash
# Check if the backup phase is 'pre-stop'
if [ "$2" == "pre-stop" ]; then
    # Only run for VM ID 201
    if [ "$1" == "201" ]; then
        echo "Backup completed for VM 201, executing custom script"
        # Run your backup_shared_folder.sh script
        /var/lib/vz/snippets/shared_folder_backup.sh
    fi
fi
