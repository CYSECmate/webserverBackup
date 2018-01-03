# Backup script for web server

* Create backup directory
* Mysql database dump
* Directory (usually your website folder) dump
* Sync with external server (use Rsync)
* Deletes database dumps older than a specified number of days from the backup directory
* Deletes repository (website folder) dumps older than a specified number of days from the backup directory


# Installation

* Rename the repository named "priv" to "private"
* Modify the file private/config.cfg  
    
# Configuration

All the variables within this config file can be modifiable.

# Running with cron (recommended)

It is highly recommended to run this script every night for instance using cron.

Example of cron which run every morning at 2:30AM:
    30 2 * * * root /home/user/backup.sh
    

