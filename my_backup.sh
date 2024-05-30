#!/bin/bash

# Database Credentials
DB_USER="munim"
DB_PASSWD="K1g@mboni"
DB_NAME="accounts"

# Backup Directory
BACKUP_DIR="/home/vagrant/dbbackp"

# Timestamp (to create unique bacckup filenames)
TIMESTAMP=$(date +"%Y%m%d")
#DAILY_BACKUP_FILE="$BACKUP_DIR/$(date +%Y-%m-%d)_$DB_NAME"
#TIMESTAMP=$(date +"%Y%m%d-%H:%M:%S")

# Create Director if doesn't exist
mkdir -p $BACKUP_DIR

# Backup the MySQL Database
mysqldump -u$DB_USER -p$DB_PASSWD $DB_NAME > $BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql

# Compress the backup
#gzip $BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql

# Optionally, you can remove backups older than a certain period
# find $BACKUP_DIR -type f -name "*.gz" -mtime +7 -exec rm {} \;

echo "Backup completed: $BACKUP_DIR/$DB_NAME-$TIMESTAMP.sql.gz"