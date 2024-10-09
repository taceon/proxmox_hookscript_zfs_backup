#!/bin/bash

# Variables, changes those to your own system
PRIMARY_DATASET="hdd/shared_folder"
BACKUP_SERVER="root@192.168.0.10"
BACKUP_DATASET="hdd/shared_folder_backup"
SNAPSHOT_PREFIX="daily-"
KEEP_COUNT=7

echo "Starting ZFS backup job..." # Log message

# Step 1: Create a new snapshot
SNAPSHOT_NAME="${SNAPSHOT_PREFIX}$(date +%Y%m%dT%H%M%S)"
zfs snapshot ${PRIMARY_DATASET}@${SNAPSHOT_NAME}
echo "Created snapshot: ${PRIMARY_DATASET}@${SNAPSHOT_NAME}" # Log message

# Step 2: Set the backup dataset to read-write (temporarily)
echo "Setting backup dataset to read-write..."
ssh ${BACKUP_SERVER} zfs set readonly=off ${BACKUP_DATASET}

# Step 3: Send the snapshot to the backup server
if [[ $(zfs list -t snapshot -o name -s creation | grep ${PRIMARY_DATASET} | wc -l) -gt 1 ]]; then
    # Send incremental if there's a previous snapshot
    PREVIOUS_SNAPSHOT=$(zfs list -t snapshot -o name -s creation | grep "${PRIMARY_DATASET}@" | tail -2 | head -1)
    echo "Sending incremental snapshot from ${PREVIOUS_SNAPSHOT} to ${SNAPSHOT_NAME}"
    zfs send -i ${PREVIOUS_SNAPSHOT} ${PRIMARY_DATASET}@${SNAPSHOT_NAME} | ssh ${BACKUP_SERVER} zfs receive ${BACKUP_DATASET}
else
    # Send full if this is the first snapshot
    echo "Sending full snapshot: ${SNAPSHOT_NAME}" # Log message
    zfs send ${PRIMARY_DATASET}@${SNAPSHOT_NAME} | ssh ${BACKUP_SERVER} zfs receive ${BACKUP_DATASET}
fi

# Step 4: Set the backup dataset back to read-only
echo "Setting backup dataset back to read-only..."
ssh ${BACKUP_SERVER} zfs set readonly=on ${BACKUP_DATASET}

# Step 5: Clean up old snapshots on the primary server
OLD_SNAPSHOTS=$(zfs list -t snapshot -o name -s creation | grep "${PRIMARY_DATASET}@" | head -n -${KEEP_COUNT})
for SNAPSHOT in ${OLD_SNAPSHOTS}; do
    echo "Deleting old snapshot on primary: ${SNAPSHOT}" # Log message
    zfs destroy ${SNAPSHOT}
done

# Step 6: Clean up old snapshots on the backup server
for SNAPSHOT in ${OLD_SNAPSHOTS}; do
    #SNAPSHOT_NAME=$(basename ${SNAPSHOT})
    #echo "Deleting old snapshot on backup: ${BACKUP_DATASET}@${SNAPSHOT_NAME}" # Log message
    #ssh ${BACKUP_SERVER} zfs destroy ${BACKUP_DATASET}@${SNAPSHOT_NAME}
    # Extract just the snapshot name after the '@'
    SNAPSHOT_ONLY=$(echo "${SNAPSHOT}" | awk -F'@' '{print $2}')
    # Delete the snapshot on the backup server
    echo "Deleting old snapshot on backup: ${BACKUP_DATASET}@${SNAPSHOT_ONLY}"
    ssh ${BACKUP_SERVER} zfs destroy ${BACKUP_DATASET}@${SNAPSHOT_ONLY}
done



echo "ZFS backup job completed." # Log message
