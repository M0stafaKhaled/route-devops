#!/bin/bash

set -e

# === CONFIG ===
LOG_FILE="/var/log/postfix_setup.log"

EXPECTED_CONFIG=(
  "myhostname=localhost"
  "mydomain=localdomain"
  "inet_interfaces=loopback-only"
  "mydestination=localhost.localdomain, localhost"
  "relayhost="
  "local_transport=local"
  "mynetworks=127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
  "disable_dns_lookups=yes"
  "home_mailbox=Maildir/"
  "mailbox_command="
)

# === LOGGING ===
log() {
  echo -e "\n[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# === CHECK IF POSTFIX CONFIG MATCHES EXPECTED VALUES ===
check_existing_postfix_config() {
  for config in "${EXPECTED_CONFIG[@]}"; do
    key="${config%%=*}"
    expected="${config#*=}"
    current=$(postconf -h "$key" 2>/dev/null || echo "__not_set__")

    if [[ "$current" != "$expected" ]]; then
      log "Mismatch: $key = '$current' (expected '$expected')"
      return 1
    fi
  done

  return 0
}

# === MAIN LOGIC ===

log "Starting Postfix setup..."

# Skip setup if already configured
if check_existing_postfix_config; then
  log "Postfix is already configured with expected settings. Skipping setup."
  exit 0
fi

# === 1. REMOVE EXISTING POSTFIX INSTALLATION ===
log "[1/8] Removing existing Postfix and related packages..."
systemctl stop postfix || true
systemctl disable postfix || true
apt-get remove --purge -y postfix mailutils s-nail
rm -rf /etc/postfix /var/lib/postfix /etc/aliases.db /etc/mailname

for USER in root; do
  if id "$USER" &>/dev/null; then
    USER_HOME=$(eval echo ~$USER)
    rm -rf "$USER_HOME/Maildir"
    sed -i '/export MAIL=/d' "$USER_HOME/.bashrc"
  fi
done

apt-get autoremove -y
apt-get clean

# === 2. INSTALL POSTFIX ===
log "[2/8] Installing Postfix..."
debconf-set-selections <<< "postfix postfix/mailname string localhost"
debconf-set-selections <<< "postfix postfix/main_mailer_type string Local only"
apt-get update
apt-get install -y postfix mailutils

# === 3. CONFIGURE POSTFIX ===
log "[3/8] Configuring Postfix..."

postconf -e "myhostname = localhost"
postconf -e "mydomain = localdomain"
postconf -e "inet_interfaces = loopback-only"
postconf -e "mydestination = localhost.localdomain, localhost"
postconf -e "relayhost ="
postconf -e "local_transport = local"
postconf -e "mynetworks = 127.0.0.0/8 [::ffff:127.0.0.0]/104 [::1]/128"
postconf -e "disable_dns_lookups = yes"
postconf -e "home_mailbox = Maildir/"
postconf -e "mailbox_command ="

# === 4. CREATE MAILDIR FOR ROOT USER ===
log "[4/8] Creating Maildir for root..."
ROOT_HOME="/root"
mkdir -p "$ROOT_HOME/Maildir"/{cur,new,tmp}
chown -R root:root "$ROOT_HOME/Maildir"

# === 5. SET MAIL ENV VAR FOR ROOT ===
log "[5/8] Setting MAIL environment variable..."
if ! grep -q "export MAIL=" "$ROOT_HOME/.bashrc"; then
  echo "export MAIL=\$HOME/Maildir" >> "$ROOT_HOME/.bashrc"
fi

# === 6. NEWALIASES ===
log "[6/8] Rebuilding aliases..."
newaliases

# === 7. RESTART POSTFIX ===
log "[7/8] Restarting Postfix..."
systemctl enable postfix
systemctl restart postfix

# === 8. FINISHED ===
log "[8/8] Verifying Postfix setup and mail delivery..."

# Wait a moment for mail delivery to complete
sleep 3

# Verify mail delivery in logs
MAIL_LOG_CHECK=$(grep "status=sent" /var/log/mail.log | tail -n 2)
ERROR_LOG_CHECK=$(grep -i "error\|fail\|reject" /var/log/mail.log | tail -n 5)

if [ -n "$MAIL_LOG_CHECK" ]; then
    log "SUCCESS: Mail delivery confirmed in logs"
    log "Last mail delivery entries:"
    log "$MAIL_LOG_CHECK"
else
    log "WARNING: No successful mail delivery found in logs"
fi

if [ -n "$ERROR_LOG_CHECK" ]; then
    log "ERRORS FOUND IN MAIL LOGS:"
    log "$ERROR_LOG_CHECK"
else
    log "No significant errors found in mail logs"
fi

# Verify mail delivery by checking Maildir
for USER in root vagrant; do
    if id "$USER" &>/dev/null; then
        USER_HOME=$(eval echo ~$USER)
        if [ -d "$USER_HOME/Maildir/new" ]; then
            MAIL_COUNT=$(ls -1 "$USER_HOME/Maildir/new" 2>/dev/null | wc -l)
            if [ "$MAIL_COUNT" -gt 0 ]; then
                log "SUCCESS: Found $MAIL_COUNT new message(s) for $USER in Maildir"
            else
                log "WARNING: No new messages found for $USER in Maildir"
            fi
        else
            log "ERROR: Maildir not found for $USER at $USER_HOME/Maildir"
        fi
    fi
done

log "
=== SETUP COMPLETE ===
Postfix configuration log saved to: $LOG_FILE

To check mail:
  For root: sudo  mail
  For user: mail

To monitor logs:
  tail -f /var/log/mail.log

Troubleshooting:
1. If no mail was delivered, check the error messages above
2. Verify Postfix is running: systemctl status postfix
3. Check full mail logs: cat /var/log/mail.log
"