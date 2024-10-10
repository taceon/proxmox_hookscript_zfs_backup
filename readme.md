# Proxmox Backup Server hookscript to backup ZFS

## **Update...**

It seems the hookscript cannot survive a reboot, not sure why... For now I have to use cron to schedule the zfs backup, decoupled from VM backup.

```
crontab -e
```
add this line to the end, run the script every day at 2 am
```
0 2 * * * /var/lib/vz/snippets/shared_folder_backup.sh
```

Will come back to this later about hookscript

Happy proxmoxing!

## Introduction

I have Proxmox Backup Server running to backup all my VMs daily, but I also have a large ZFS dataset I would like to backup at the same time. So far proxmox (8.2) does not provide a fully integrated way to backup ZFS datasets. Hence I have this hookscript setup, somehow integrate ZFS backup job (via ZFS snapshot in script `shared_folder_backup.sh`) with PBS's VM backup process by a hookscript (`vzdump-hook.sh`)

## Steps
```
chmod +x *.sh
cp *.sh /var/lib/vz/snippets/
```

add the vzdump-hook.sh to one of your vm, mine is vm 201
```
qm set 201 --hookscript local:snippets/vzdump-hook.sh
```

to test, run
`
vzdump 201 --mode snapshot --compress lzo
`. 
This creates a backup of vm 201 on my local volumn.
Or trigger a backup in proxmox ui.

You should see something like these below in Tasks output

```
Backup completed for VM 201, executing custom script
Starting ZFS backup job...
Created snapshot: hdd/shared_folder@daily-20241009T145851
Setting backup dataset to read-write...
Sending incremental snapshot from hdd/shared_folder@daily-20241009T135404 to daily-20241009T145851
Setting backup dataset back to read-only...
ZFS backup job completed.
```

## Explain

`shared_folder_backup.sh` create snapshot of your primary server's ZFS dataset and send the snapshot to backup server for backup. It relies on ssh, so make sure create key based ssh access for automation.

`vzdump-hook.sh` is a hook attached to a vm backup process, it calls the `shared_folder_backup.sh` when the backup process finishes.

This way, whenevern the vm backup finishes, the script will also backup the ZFS dataset


Customize to your setup before deploy

