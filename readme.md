# Proxmox Backup Server hookscript to backup ZFS

## **Update...**

It seems the hookscript cannot survive a reboot, not sure why... For now I have to use cron to schedule the zfs backup, decoupled from VM backup.

```
crontab -e
```
add this line to the end, run the zfs backup script every day at 2 am and rsync at 3 am
```
0 2 * * * /var/lib/vz/snippets/shared_folder_backup.sh
0 3 * * * /var/lib/vz/snippets/rsync_backup.sh
```

Will come back to this later about hookscript

Happy proxmoxing!

## Introduction

I have Proxmox Backup Server running to backup all my VMs daily, 

But I also have a large ZFS dataset and 
a bunch of folders on normal ext4 partitions I would also like to backup at the same time...

Those are written in `*_backup.sh`. 

So far proxmox (8.2) does not provide a fully integrated way to backup ZFS datasets or any `rsync` folder backup.
Hence I have this `vzdump-hook.sh` hookscript setup, somehow integrate those additional backup job with PBS' VM backup process.

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

`vzdump-hook.sh` is a hookscript attached to VM backup process, 
once the backup process of a certain vm enters a certain stage, `vzdump-hook.sh` will be called.

Customize to your setup before deploy

