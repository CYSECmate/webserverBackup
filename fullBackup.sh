#!/bin/bash

# Read config.cfg file within the private directory
source /private/config.cfg

# Backup time
echo "Backup Started: $(date)"

# Create the backup dirs if they don't exist
if [[ ! -d $BACKUP_DIR ]]
  then
  mkdir -p "$BACKUP_DIR"
fi

# Backup MYSQL
if [ "$DUMP_MYSQL" = "true" ]
then
      echo "Dumping: $MYSQL_DATABASE..."
      $MYSQLDUMP_PATH --opt --skip-add-locks -h $MYSQL_HOST -u$MYSQL_USER -p$MYSQL_PASS $MYSQL_DATABASE | gzip > $BACKUP_DIR\_$DATE-mysql.sql.gz

      # Delete old mysql backups
      echo "------------------------------------"
      echo "Deleting old mysql backups..."

      # List dumps to be deleted to stdout (for report)
      $FIND_PATH $BACKUP_DIR*.-mysql.sql.gz -mtime +$KEEP_BACKUP

      # Delete dumps older than specified number of days
      $FIND_PATH $BACKUP_DIR*.-mysql.sql.gz -mtime +$KEEP_BACKUP -exec rm {} +

fi


if [ "$TAR_SITES" == "true" ]
  then

  # Backup sites dir
  echo "------------------------------------"
  echo "Backup sites dir $SITES_DIR"
  $TAR_PATH -czf $BACKUP_DIR/_$DATE-sites.tgz $SITES_DIR

  # Delete old sites backups
  echo "------------------------------------"
  echo "Deleting old sites backups..."

  # List files to be deleted to stdout (for report)
  $FIND_PATH $BACKUP_DIR*.-sites.tgz -mtime +$KEEP_BACKUP

  # Delete files older than specified number of days
  $FIND_PATH $BACKUP_DIR*.-sites.tgz -mtime +$KEEP_BACKUP -exec rm {} +

fi



# Rsync everything with another server
if [[ "$SYNC" == "rsync" ]]
  then
  echo "------------------------------------"
  echo "Sending backups to backup server..."
  $RSYNC_PATH --del -vaze "ssh -p $RSYNC_PORT" $BACKUP_DIR/ $RSYNC_USER@$RSYNC_SERVER:$RSYNC_DIR
fi

# Announce the completion time
echo "------------------------------------"
echo "Backup Completed: $(date)"
