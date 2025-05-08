# /etc Backup Script

This script automates the backup of the `/etc` directory and sends email notifications for both success and failure scenarios. It also logs the backup process for easy monitoring.

---

## Features

- Creates a compressed backup of the `/etc` directory.
- Sends email notifications upon backup success or failure.
- Logs the backup process to a timestamped log file.
- Includes Postfix email configuration for reliable delivery.

---

## How to Run the Script

1. **Make the Script Executable**

   ```bash
   chmod +x etc_backup.sh
   ```

2. **Run the Script**

   ```bash
   ./etc_backup.sh
   ```

---

## To check mail:

- **For root:**
  ```bash
  sudo mail
  ```

- **For user:**
  ```bash
  mail
  ```

---

## To monitor logs:

```bash
tail -f /var/log/mail.log
```

---

## Troubleshooting:

1. If no mail was delivered, check the error messages above.
2. Verify Postfix is running:
   ```bash
   systemctl status postfix
   ```
3. Check full mail logs:
   ```bash
   cat /var/log/mail.log
   ```
