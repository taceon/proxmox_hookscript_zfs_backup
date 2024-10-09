# Proxmox hookscript to back ZFS

## Steps
```
chmod +x *.sh
cp *.sh /var/lib/vz/snippets/
```

add the vzdump-hook.sh to one of your vm, mine is vm 201
```
qm set 201 --hookscript local:snippets/vzdump-hook.sh
```

## Explain

`shared_folder_backup.sh` create snapshot of your primary server's ZFS dataset and send the snapshot to backup server for backup. It relies on ssh, so make sure create key based ssh access for automation.

`vzdump-hook.sh` is a hook attached to a vm backup process, it calls the `shared_folder_backup.sh` when the backup process finishes.

This way, whenevern the vm backup finishes, the script will also backup the ZFS dataset


Customize to your setup before deploy

