# CRON101
การใช้งาน CRON แบ่งเป็น 2 ส่วน
1. คือการเขียน script ที่ต้องการให้รันตาม Schedule
2. การตั้งค่าเครื่องให้รันอัตโนมัติ

สมมุติว่าเรามีไฟล์ generate_metadata ที่ต้องการให้เกิดการรันตาม schedule 
## SCRIPT

```python
# =========================
# Environment สำหรับ cron
# =========================
PATH=/usr/local/bin:/usr/bin:/bin
BASE_DIR="/home/user/scripts"
LOG_FILE="$BASE_DIR/cron.log"
TARGET_SCRIPT="$BASE_DIR/generate_metadata_V2.sh"
```

## CONFIG
ในส่วนนี้ เราใช้ 2 Library คือ cron กับ crontab

1. ทำการสั่ง update apt ก่อนที่จะ install cron
   ```bash
   apt update
   apt install -y cron
   ```

2. ประกาศเปิดใช้ crontab <code> crontab -e </code> มันอาจจะขึ้นมาว่าไม่มี editor ให้เราข้ามไปแล้วทำคำสั่งต่อไป
3.  ประกาศรัน Shcedule ผ่านการเขียน CRON 
   สามารถศึกษาเพิ่มเติมดังนี้ <url>https://crontab.guru/</url> 
```bash
echo "* * * * * flock -n /tmp/generate_metadata.lock /bin/bash /home/nbc_user/upload/scripts/cron_triggering.sh >> /home/nbc_user/upload/scripts/cron.log 2>&1" | crontab -
```
โดยการทำ 
```bash
flock -n /tmp/generate_metadata.lock
```
flock : file lock จะช่วยให้สคริปไม่เกิดการรันแล้วทำซ้อนกัน ถ้าเวลาของ cron มันใกล่กันเกินไป (lock ให้ไฟล์ process จนจบก่อนค่อยคลาย lock)

- <code>-n</code> จะทำให้ข้ามการ process ถ้าไฟลฺ์ยังทำไม่เสร็จ แล้วเกิด schedule run อีกรอบ
- <code>/tmp/generate_metadata.lock </code>เป็นการ บอกว่าล็อคไฟล์ไหน
- <code>/bin/bash</code> บอกว่าจะใช้ intepreter เป็นbash ทำการ trigger ไฟล์นี้
- <code>/bin/bash /home/nbc_user/upload/scripts/cron_triggering.sh</code> 
และทำการเก็บ logไว้ที่ <code>/home/nbc_user/upload/scripts/cron.log</code>
- การใช้ <code>2>&1</code>เป็นการเก็บทุกlogรวมถึง error log ด้วย
- <code> | </code> เป็นการสร้าง pipe มารับ context ใน echo ก่อนหน้า
- แล้วมีการใช้ <code>crontab - </code> มาเพื่อเอาข้อมูลจาก pipe ไปใช้งาน ลงในcrontab ไม่ต้องเปิด editor<br>
  *** เนื่องจากตอนทำถ้าใช้ <code> crontab -e </code> มันต้องเปิด editor ***

4. ทำการเช็คผลการทำงานจากไฟล์ log โดยการ <code>tail</code> เพื่อดู output ล่าสุด(ท้ายไฟล์) และ <code>-f</code> ใช่ในการบอกว่า follow ผลลัพธ์ทันที
   ```bash
   tail -f cron.log 
   ```
5. ถ้าจะหยุด cron ให้ใช้เพื่อ remove cron ชื่อนั้นทิ้ง
   ```bash
   crontab -l | sed '/cron_triggering.sh/d' | crontab - 
   ```