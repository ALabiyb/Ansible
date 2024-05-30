#!/bin/bash

#Set to "yes" to produce custom=forma backup files
ENABLE_TAR_BACKUPS=""

# Set the database connection details
DB_NAME="sample"
DB_USER="munim"
#DB_PASSWORD="123wsx"
HOSTNAME="localhost"

# Set the backup directory
BACKUP_DIR="/home/vagrant/postgres_backup"

# Create the backup directory if it doesn't exist
mkdir -p $BACKUP_DIR

# Generate the daily backup file name
DAILY_BACKUP_FILE="$BACKUP_DIR/$(date +%Y-%m-%d)_$DB_NAME"

# Perform the daily backup
echo "Performing daily backup..."
if [ "$ENABLE_TAR_BACKUPS" = "yes" ]; then
    echo "Starting tar format backup of the $DB_NAME database"
    if ! pg_dump -h"$HOSTNAME" -U "$DB_USER" -Ft -d "$DB_NAME" -f "$DAILY_BACKUP_FILE.tar.in_progress"; then
        echo "Failed to produce tar format backup of the $DB_NAME database"
    else
        mv "$DAILY_BACKUP_FILE.tar.in_progress" "$DAILY_BACKUP_FILE.tar"
    fi
else
    pg_dump -U "$DB_USER" -h "$HOSTNAME" -d "$DB_NAME" -f "$DAILY_BACKUP_FILE.sql"
fi


# Check if the daily backup was successful
if [ $? -eq 0 ]; then
  echo "Daily backup completed successfully."
else
  echo "Error: Daily backup failed."
fi

# Check if it's the end of the month
CURRENT_DAY=$(date +%d)
if [ "$CURRENT_DAY" -eq "$(date -d "$(date +%Y-%m-01) + 1 month - 1 day" +%d)" ]; then
 # Generate the monthly backup file name
 MONTHLY_BACKUP_FILE="$BACKUP_DIR/monthly_$(date +%Y-%m)_$DB_NAME"

 # Perform the monthly backup
 echo "Performing monthly backup..."
 if ["$ENABLE_TAR_BACKUPS" = "yes" ]; then
       echo "Starting tar format backup of the $DB_NAME database"
        if ! pg_dump -h"HOSTNAME" -U $DB_USER -d $DB_NAME -f "$MONTHLY_BACKUP_FILE.tar.in_progress"; then
           echo "Failed to produce tar format backup of the $DB_NAME database"
        else
           mv "$MONTHLY_BACKUP_FILE.tar.in_progress" "$MONTHLY_BACKUP_FILE.tar"
        fi
 else
  pg_dump -h"HOSTNAME" -U $DB_USER -d $DB_NAME -f "$MONTHLY_BACKUP_FILE.sql"
 fi

  # Check if the monthly backup was successful
  if [ $? -eq 0 ]; then
    echo "Monthly backup completed successfully."
  else
    echo "Error: Monthly backup failed."
  fi
else
  echo "Skipping monthly backup, as it's not the end of the month."
fi

# Delete expired monthly backups (keep 12 months of backups)
echo "Deleting expired monthly backups..."
find $BACKUP_DIR -type f -name 'monthly_*' -mtime +365 -delete

echo "Backup process completed."