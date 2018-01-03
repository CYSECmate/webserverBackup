#!/bin/bash

# Date format
date="$(date '+%Y%m%d')"

# Path
mysqldumpPath="$(which mysqldump)"
findPath="$(which find)"
tarPath="$(which tar)"
rsyncPath="$(which rsync)"

# Read config.cfg file within the private directory
source private/config.cfg

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Backup time
echo "$(date +"%Y%m%d%H%M%S") START"

# Create the backup dirs if they don't exist
if [[ ! -d $backupDir ]]
  then
  echo "$(date +"%Y%m%d%H%M%S") Creation folder $backupDir"
  mkdir -p "$backupDir"
fi

# Backup MYSQL
if [ "$mysqlDump" = "true" ]
then
      echo "$(date +"%Y%m%d%H%M%S") MYSQL - Backup Mysql database: $mysqlDatabase"
      $mysqldumpPath --opt --skip-add-locks -h $mysqlHost -u$mysqlUser -p$mysqlPass $mysqlDatabase | gzip > $backupDir$date-mysql.sql.gz

      # Delete old mysql backups
      echo "$(date +"%Y%m%d%H%M%S") MYSQL - Deleting old mysql backups..."

      # List dumps to be deleted to stdout (for report)
      $findPath $backupDir*-mysql.sql.gz -mtime +$keepBackup

      # Delete dumps older than specified number of days
      $findPath $backupDir*-mysql.sql.gz -mtime +$keepBackup -exec rm {} +

fi


if [ "$repositoryDump" == "true" ]
then

  # Backup sites dir
  echo "$(date +"%Y%m%d%H%M%S") REPO  - Backup repository: $repositoryLocation"
  $tarPath -czPf $backupDir$date-repository.tgz $repositoryLocation

  # Delete old sites backups
  echo "$(date +"%Y%m%d%H%M%S") REPO  - Deleting old repository backups..."

  # List files to be deleted to stdout (for report)
  $findPath $backupDir*-repository.tgz -mtime +$keepBackup

  # Delete files older than specified number of days
  $findPath $backupDir*-repository.tgz -mtime +$keepBackup -exec rm {} +

fi


# Rsync everything with another server
if [[ "$rsync" == "true" ]]
then
  echo "$(date +"%Y%m%d%H%M%S") RSYNC - Sending backups to backup server..."
  $rsyncPath --del -aze "ssh -p $rsyncPort" $backupDir/ $rsyncUser@$rsyncServer:$rsyncDir
fi

# Announce the completion time
echo "$(date +"%Y%m%d%H%M%S") FINISH"
