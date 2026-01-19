#!/bin/bash

# =========================
# Environment สำหรับ cron
# =========================
PATH=/usr/local/bin:/usr/bin:/bin
BASE_DIR="/home/user/scripts"
LOG_FILE="$BASE_DIR/cron.log"
TARGET_SCRIPT="$BASE_DIR/generate_metadata_V2.sh"

# =========================
# เตรียม environment
# =========================
cd "$BASE_DIR" || exit 1

echo "----------------------------" >> "$LOG_FILE"
echo "Cron trigger start: $(date)" >> "$LOG_FILE"

# =========================
# ตรวจว่า script เป้าหมายมีจริง
# =========================
if [ ! -f "$TARGET_SCRIPT" ]; then
  echo "ERROR: generate_metadata_V2.sh not found" >> "$LOG_FILE"
  exit 1
fi

# =========================
# เรียก script จริง
# =========================
/bin/bash "$TARGET_SCRIPT"

STATUS=$?

echo "Cron trigger end: $(date) | exit code=$STATUS" >> "$LOG_FILE"
exit $STATUS

# ========================
# ตอนเรียน script นี้จาก cron
# ========================
#>  crontab -e
#   บอกให้ทมันทำงานทุกๆ 1 นาที โดยใช้ flock เพื่อป้องกันการรันซ้ำซ้อน
#>  echo "* * * * * flock -n /tmp/generate_metadata.lock /bin/bash /home/nbc_user/upload/scripts/cron_triggering.sh >> /home/nbc_user/upload/scripts/cron.log 2>&1" | crontab -

#   ตรวจสอบ log ว่าทำงานปกติหรือไม่
#>  tail -f cron.log  
# หยุดการทำงานของ cron job
#>  crontab -r
# หรือ
# crontab -l | sed '/cron_triggering.sh/d' | crontab -

