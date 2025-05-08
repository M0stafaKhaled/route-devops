#!/bin/bash

# Exit on any error
set -euo pipefail

# --- Configuration ---
EMAIL_TO="test@test.com"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="$HOME/system_backups/etc"
LOG_FILE="$BACKUP_DIR/backup_$TIMESTAMP.log"
BACKUP_FILE="$BACKUP_DIR/etc_backup_$TIMESTAMP.tar.gz"

# Create necessary directories
mkdir -p "$BACKUP_DIR"

# --- Run Backup ---
{
    echo "=== Starting backup at $(date) ==="

    if tar -cpzf "$BACKUP_FILE" /etc; then
        echo "✅ Backup successful: $BACKUP_FILE"
        mail -s "✅ /etc Backup Successful - $TIMESTAMP" "$EMAIL_TO" < "$LOG_FILE"
    else
        echo "❌ Backup failed."
        mail -s "❌ /etc Backup Failed - $TIMESTAMP" "$EMAIL_TO" < "$LOG_FILE"
        exit 1
    fi

    echo "=== Finished at $(date) ==="
} | tee "$LOG_FILE"
