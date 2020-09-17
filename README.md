# minecraft-server-backup
Simple backup script for servers running in screen using 7zip for compression.

## Prerequisites
- **screen**
- **p7zip**
- **cron** or similar (for automatic backups)

## Automatic backups
For example use a cronjob to automate the backups:

```bash
$ crontab -e
```

for a backup every 12 hours add:
```bash
# world backup every 12 hours
0 */12 * * * ./backup.sh
```

or for daily backups at 18:00 (6 pm) add:

```bash
# world backup at 18:00
0 18 * * * ./backup.sh
```

## Autostart server
Autostart the minecraft server after a reboot or a crash:

```bash
$ crontab -e
```

and add:

```bash
# check status every 5 minutes
*/5 * * * * ./autostart.sh
```
