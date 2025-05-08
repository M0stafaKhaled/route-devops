#!/bin/bash


SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_SCRIPT="$SCRIPT_DIR/etc_backup.sh"
EMAIL_CONFIG_SCRIPT="$SCRIPT_DIR/email_config.sh"  

# Define cron jobs
CRON_JOB="0 2 * * * $BACKUP_SCRIPT"
CRON_JOB2="0 2 * * * $EMAIL_CONFIG_SCRIPT"

# Check if scripts exist and are executable
if [ ! -x "$BACKUP_SCRIPT" ]; then
    echo "❌ Backup script not found or not executable: $BACKUP_SCRIPT"
    exit 1
fi

if [ ! -x "$EMAIL_CONFIG_SCRIPT" ]; then
    echo "❌ Email config script not found or not executable: $EMAIL_CONFIG_SCRIPT"
    exit 1
fi

# Check for existing cron jobs
CRON_EXISTS1=$(crontab -l 2>/dev/null | grep -F "$CRON_JOB" || true)
CRON_EXISTS2=$(crontab -l 2>/dev/null | grep -F "$CRON_JOB2" || true)

# Add cron jobs if they don't exist
if [ -z "$CRON_EXISTS1" ]; then
    echo "Adding daily backup cron job..."
    (crontab -l 2>/dev/null; echo "$CRON_JOB") | crontab -
    echo "✅ Cron job added: $CRON_JOB"
else
    echo "⚠️ Backup cron job already exists. No changes made."
fi

if [ -z "$CRON_EXISTS2" ]; then
    echo "Adding daily email config cron job..."
    (crontab -l 2>/dev/null; echo "$CRON_JOB2") | crontab -
    echo "✅ Cron job added: $CRON_JOB2"
else
    echo "⚠️ Email config cron job already exists. No changes made."
fi