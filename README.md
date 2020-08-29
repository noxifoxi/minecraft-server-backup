# minecraft-server-backup
Simple backup script for servers running in screen using 7zip for compression.

## Prerequisites
- **p7zip**
- **cron** or similar (for automatic backups)

## Automatic backups
For example use a cronjob to automate the backups:

```bash
$ crontab -e
```

for a backup every 12 hours add:
```cron
0 */12 * * * ./backup.sh
```

or for daily backups at 18:00 (6 pm) add:

```cron
0 18 * * * ./backup.sh
```
