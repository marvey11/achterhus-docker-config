# Running Backups Each Night

Create a folder for log files that the unprivileged user can read and write to:

```shell
sudo mkdir -p /var/log/achterhus
sudo chown marvey:marvey /var/log/achterhus
```

Create `/etc/systemd/system/achterhus-backup.service` with the following contents:

```ini
[Unit]
Description=Daily RSync Backup Storage to Backup Drive

[Service]
Type=oneshot
ExecStart=/home/marvey/achterhus-docker-config/scripts/backup-drives.sh
User=marvey
```

Create `/etc/systemd/system/achterhus-backup.timer` with the following contents:

```ini
[Unit]
Description=Run Achterhus Backup Daily

[Timer]
OnCalendar=*-*-* 03:11:00
Persistent=true

[Install]
WantedBy=timers.target
```

Activate the service by running:

```shell
sudo systemctl daemon-reload
sudo systemctl enable --now achterhus-backup.timer
```

This service can also be manually triggered by running:

```shell
sudo systemctl start achterhus-backup.service
```