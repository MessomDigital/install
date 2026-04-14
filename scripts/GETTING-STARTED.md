# Setup insructions

After running the installation script:
1. Update local_override.properties
2. run 
   ```bash
   ./scripts/download_and_restart_if_new.sh
   ```
3. Update Cron jobs
   ```bash
   crontab scripts/CRON
   ```