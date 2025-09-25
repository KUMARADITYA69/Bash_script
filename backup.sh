#!/bin/bash

# ========================================
# Simple Backup Script
# Author: Sysadmin
# Purpose: Backup a directory to a remote server and log the results
# ========================================

# ------------------------
# CONFIGURATION
# ------------------------
SOURCE_DIR="/path/to/source"           
REMOTE_USER="remote_user"              
REMOTE_HOST="remote.server.com"        
REMOTE_DIR="/path/to/backup"           
LOG_FILE="/var/log/backup_report.log"  
SSH_KEY="/home/your_user/.ssh/id_ed25519"  # Path to your private key

# Timestamp to make backups unique
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')
BACKUP_NAME="backup_$TIMESTAMP.tar.gz"

# ------------------------
# Helper function to log messages
# ------------------------
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# ------------------------
# Step 1: Create backup archive
# ------------------------
log "Starting backup of $SOURCE_DIR..."
tar -czf /tmp/$BACKUP_NAME -C "$SOURCE_DIR" . 2>/tmp/backup_error.log

if [ $? -ne 0 ]; then
    log "Failed to create archive. Check /tmp/backup_error.log for details."
    exit 1
fi

log "Archive created successfully: /tmp/$BACKUP_NAME"

# ------------------------
# Step 2: Transfer backup to remote server
# ------------------------
log "Sending backup to $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR..."
rsync -avz -e "ssh -i $SSH_KEY" /tmp/$BACKUP_NAME $REMOTE_USER@$REMOTE_HOST:$REMOTE_DIR/ 2>/tmp/rsync_error.log

if [ $? -ne 0 ]; then
    log "Backup transfer failed. Check /tmp/rsync_error.log for details."
    exit 1
fi

log "Backup transferred successfully."

# ------------------------
# Step 3: Clean up local temporary archive
# ------------------------
rm -f /tmp/$BACKUP_NAME
log "Local temporary backup removed."

# ------------------------
# Step 4: Finish
# ------------------------
log "Backup operation completed successfully."

