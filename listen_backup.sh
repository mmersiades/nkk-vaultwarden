#!/bin/bash

# Get the script's directory and set backup path
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/vw-backup"
LOG_FILE="$SCRIPT_DIR/backup-notifications.log"

# Source environment file
ENV_FILE="$SCRIPT_DIR/.env.prod"
if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

# Require NOTIFIER_TARGET_EMAIL environment variable
if [ -z "$NOTIFIER_TARGET_EMAIL" ]; then
    echo "ERROR: NOTIFIER_TARGET_EMAIL environment variable is not set."
    exit 1
fi
EMAIL="$NOTIFIER_TARGET_EMAIL"

# Logging function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

log "Starting backup file monitor on $BACKUP_DIR"

# Check if mutt is installed
if ! command -v mutt &> /dev/null; then
    log "ERROR: mutt is not installed. Please install mutt to send email notifications."
    exit 1
fi

# Check if backup directory exists
if [ ! -d "$BACKUP_DIR" ]; then
    log "ERROR: Backup directory $BACKUP_DIR does not exist."
    exit 1
fi

# Monitor for file close_write events (file completely written)
inotifywait -m "$BACKUP_DIR" -e close_write |
while read path action file; do
    if [[ "$file" == *.gpg ]]; then
        FULL_PATH="$path$file"
        FILE_SIZE=$(du -h "$FULL_PATH" | cut -f1)

        log "New GPG backup detected: $file (size: $FILE_SIZE)"

        # Add small delay to ensure file is completely flushed
        sleep 2

        # Verify file exists and is readable
        if [ ! -r "$FULL_PATH" ]; then
            log "ERROR: Cannot read file $FULL_PATH"
            continue
        fi

        # Send email with attachment
        EMAIL_BODY="Vaultwarden backup created successfully.

Filename: $file
Size: $FILE_SIZE
Timestamp: $(date '+%Y-%m-%d %H:%M:%S')
Path: $FULL_PATH

This is an automated notification from your Vaultwarden backup system."

        if echo "$EMAIL_BODY" | mutt -s "Vaultwarden Backup: $file" -a "$FULL_PATH" -- "$EMAIL" 2>&1 | tee -a "$LOG_FILE"; then
            log "Successfully sent backup email for $file"
        else
            log "ERROR: Failed to send email for $file"
        fi
    fi
done