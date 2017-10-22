# System-wide restic backups

# m h dom mon dow user  command
10 0 * * * root /usr/local/bin/daily-restic-backups 2>&1
