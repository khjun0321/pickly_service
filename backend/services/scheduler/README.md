# ⏰ Pickly Cron Scheduler

**PRD v9.6.1 - Phase 4D Step 1**

Automated scheduling for API collection and data transformation using node-cron.

---

## 📋 Overview

This service schedules automatic execution of the complete data pipeline:
1. **API Collection** (`npm run collect:api`)
2. **Data Transformation** (`npm run transform:api`)

By default, runs daily at **3:00 AM**, but fully customizable via cron expressions.

---

## 🚀 Usage

### Start Scheduler (Daily at 3:00 AM)

```bash
cd backend
npm run scheduler:run
```

**Output**:
```
╔════════════════════════════════════════════════════════════════╗
║            ⏰ Pickly Cron Scheduler Started                   ║
║              PRD v9.6.1 - Phase 4D Step 1                     ║
╚════════════════════════════════════════════════════════════════╝

⏰ Current Time: 11/2/2025, 6:00:00 PM
📅 Schedule: 0 3 * * * (Daily at 3:00 AM)
🧪 Dry Run Mode: NO

✅ Scheduler initialized successfully
⏰ Next execution: 11/3/2025, 3:00:00 AM

📝 Logs: backend/logs/scheduler.log

💡 Press Ctrl+C to stop the scheduler
```

The scheduler will keep running in the background and execute at 3:00 AM every day.

---

## 🎮 CLI Options

### Dry Run (Test Mode)

Test without actual execution:
```bash
npm run scheduler:run -- --dry-run --now
```

### Execute Immediately

For testing purposes:
```bash
npm run scheduler:run -- --now
```

### Custom Schedule

Run every 6 hours:
```bash
npm run scheduler:run -- --schedule="0 */6 * * *"
```

### Show Help

```bash
npm run scheduler:help
```

---

## 📅 Cron Schedule Format

```
 ┌───────────── minute (0 - 59)
 │ ┌───────────── hour (0 - 23)
 │ │ ┌───────────── day of month (1 - 31)
 │ │ │ ┌───────────── month (1 - 12)
 │ │ │ │ ┌───────────── day of week (0 - 6) (Sunday to Saturday)
 │ │ │ │ │
 * * * * *
```

### Common Schedules

| Schedule | Description |
|----------|-------------|
| `0 3 * * *` | Daily at 3:00 AM (default) |
| `0 */6 * * *` | Every 6 hours |
| `0 0 * * 0` | Every Sunday at midnight |
| `*/30 * * * *` | Every 30 minutes |
| `0 0 1 * *` | First day of every month |
| `0 9,17 * * *` | 9:00 AM and 5:00 PM daily |

---

## 📊 Execution Flow

```
┌─────────────────────────────────────────┐
│  Cron Scheduler (Daily at 3:00 AM)     │
└────────────────┬────────────────────────┘
                 │
        ┌────────▼─────────┐
        │  Step 1: Collect │
        │  npm run collect:api │
        └────────┬─────────┘
                 │ (if successful)
        ┌────────▼─────────┐
        │ Step 2: Transform│
        │npm run transform:api│
        └────────┬─────────┘
                 │
        ┌────────▼─────────┐
        │   Log Results    │
        │ scheduler.log    │
        └──────────────────┘
```

### Sequential Execution

1. **API Collection** runs first
2. If collection **succeeds**, transformation runs
3. If collection **fails**, transformation is skipped
4. All results logged to `backend/logs/scheduler.log`

---

## 📝 Log File

### Location

```
backend/logs/scheduler.log
```

### Log Format

```
[2025-11-02T09:08:49.580Z] ======= Scheduled Job Started (Dry Run: false) =======
[2025-11-02T09:08:50.123Z] SUCCESS: API Collection completed in 2.34s
[2025-11-02T09:08:52.456Z] SUCCESS: Data Transformation completed in 1.12s
[2025-11-02T09:08:52.456Z] SUCCESS: Total execution time 3.46s
[2025-11-02T09:08:52.456Z] ======= Scheduled Job Completed Successfully =======
```

### View Recent Logs

```bash
tail -20 backend/logs/scheduler.log
```

### View Real-Time Logs

```bash
tail -f backend/logs/scheduler.log
```

---

## 🐛 Error Handling

### Collection Failure

If API collection fails:
- ❌ Transformation is **skipped**
- 📝 Error logged with details
- ⏰ Scheduler continues (will retry next cycle)

### Transformation Failure

If transformation fails (but collection succeeded):
- 📝 Partial completion logged
- 📊 Raw data is saved (can retry manually)
- ⏰ Scheduler continues

### Fatal Errors

If the scheduler itself crashes:
- 📝 Error logged to file
- 🔄 Process exits (use process manager to restart)

---

## 🔄 Production Deployment

### Using PM2 (Recommended)

Install PM2:
```bash
npm install -g pm2
```

Start scheduler with PM2:
```bash
pm2 start backend/services/scheduler/runScheduler.ts --name pickly-scheduler --interpreter ts-node
```

View logs:
```bash
pm2 logs pickly-scheduler
```

Stop scheduler:
```bash
pm2 stop pickly-scheduler
```

Restart scheduler:
```bash
pm2 restart pickly-scheduler
```

### Using systemd (Linux)

Create `/etc/systemd/system/pickly-scheduler.service`:

```ini
[Unit]
Description=Pickly Cron Scheduler
After=network.target

[Service]
Type=simple
User=pickly
WorkingDirectory=/path/to/pickly_service/backend
ExecStart=/usr/bin/npm run scheduler:run
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

Enable and start:
```bash
sudo systemctl enable pickly-scheduler
sudo systemctl start pickly-scheduler
```

View logs:
```bash
sudo journalctl -u pickly-scheduler -f
```

### Using Docker

Add to `docker-compose.yml`:

```yaml
services:
  pickly-scheduler:
    image: node:20
    working_dir: /app
    volumes:
      - ./backend:/app
    command: npm run scheduler:run
    environment:
      - NODE_ENV=production
    restart: unless-stopped
```

---

## 🧪 Testing

### Test Dry Run

```bash
npm run scheduler:run -- --dry-run --now
```

**Expected Output**:
```
🧪 [DRY RUN] Would execute:
   1. npm run collect:api
   2. npm run transform:api
```

### Test Immediate Execution

```bash
npm run scheduler:run -- --now
```

**Expected**: Full execution of collect → transform pipeline

### Test Custom Schedule

Test every minute (for quick testing):
```bash
npm run scheduler:run -- --schedule="* * * * *"
```

Wait 1 minute and verify execution in logs.

---

## 📊 Monitoring

### Check if Scheduler is Running

```bash
# Using ps
ps aux | grep runScheduler

# Using PM2
pm2 list
```

### Verify Last Execution

```bash
# Check log file
tail -50 backend/logs/scheduler.log | grep "Scheduled Job"

# Check database records
docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT started_at, status, records_fetched FROM api_collection_logs ORDER BY started_at DESC LIMIT 5;"
```

### Monitor Execution Time

```bash
# Extract timing from logs
grep "Total execution time" backend/logs/scheduler.log | tail -10
```

---

## 🔧 Troubleshooting

### Scheduler Not Running

**Problem**: Scheduler exits immediately

**Solution**: Check for TypeScript errors
```bash
npm run scheduler:run -- --help
```

### Collection Always Fails

**Problem**: API sources return errors

**Solution**: Verify API sources in database
```bash
docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT id, name, is_active, endpoint_url FROM api_sources WHERE is_active = true;"
```

### Logs Not Writing

**Problem**: No logs in `scheduler.log`

**Solution**: Check directory permissions
```bash
ls -la backend/logs/
chmod 755 backend/logs/
```

### Database Connection Errors

**Problem**: "Failed to connect to Supabase"

**Solution**: Verify `.env` configuration
```bash
cat backend/.env | grep SUPABASE
```

---

## 📚 Related Documentation

- **API Collector**: `backend/services/api-collector/README.md`
- **Data Transformer**: `backend/services/data-transformer/README.md`
- **Phase 4D Step 1**: `docs/PHASE4D_STEP1_CRON_SCHEDULER_COMPLETE.md`
- **PRD v9.6.1**: `docs/prd/PRD_CURRENT.md`

---

## 🎯 Best Practices

### 1. Use Process Manager

Don't run scheduler manually in production. Use PM2 or systemd for:
- Auto-restart on failure
- Log rotation
- Resource monitoring

### 2. Monitor Logs

Set up log rotation:
```bash
# Using logrotate
sudo nano /etc/logrotate.d/pickly-scheduler

# Add:
/path/to/backend/logs/scheduler.log {
    daily
    rotate 7
    compress
    missingok
    notifempty
}
```

### 3. Alert on Failures

Set up alerts when jobs fail:
- Email notifications
- Slack webhooks
- PagerDuty integration

### 4. Test Before Deploy

Always test with `--dry-run --now` before deploying schedule changes.

---

**Version**: 1.0.0
**Last Updated**: 2025-11-02
**Status**: Production Ready ✅
