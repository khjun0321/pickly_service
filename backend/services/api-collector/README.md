# Pickly API Collector Service
## PRD v9.6.1 - Phase 4C Step 2

Automated API collection service that fetches data from external APIs and stores raw responses in the database for processing.

---

## 📋 Overview

The API Collector Service is part of the Pickly data pipeline:

```
[External APIs] → [API Collector] → [raw_announcements] → [Transformation Service] → [announcements] → [Flutter App]
                      ↓
              [api_collection_logs]
```

### Purpose

- Fetch data from configured API sources (`api_sources` table)
- Store raw API responses in `raw_announcements` table
- Track execution history in `api_collection_logs` table
- Handle authentication (API Key, Bearer Token, OAuth)
- Support scheduled collection (future: cron/GitHub Actions)

---

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd backend
npm install
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env and add your SUPABASE_SERVICE_ROLE_KEY
```

### 3. Run Collection

```bash
# Collect from all active sources
npm run collect:api

# Dry run (test without saving)
npm run collect:api:dry-run

# Collect from specific source
npm run collect:api -- --source-id=<uuid>

# Show help
npm run collect:api:help
```

---

## 📁 File Structure

```
backend/services/api-collector/
├── supabaseClient.ts      # Supabase client configuration
├── fetchApiSource.ts      # Single source collection logic
├── runCollection.ts       # Main orchestrator (CLI entry point)
└── README.md              # This file
```

---

## 🔧 How It Works

### Collection Flow

1. **Fetch Active Sources**
   ```sql
   SELECT * FROM api_sources WHERE is_active = true;
   ```

2. **Create Collection Log** (status: `running`)
   ```sql
   INSERT INTO api_collection_logs (api_source_id, status, started_at)
   VALUES ($1, 'running', now());
   ```

3. **HTTP Request**
   - Method: GET (POST support coming soon)
   - Headers: Content-Type, User-Agent, Authentication
   - Timeout: 30 seconds
   - Response: JSON only

4. **Store Raw Data**
   ```sql
   INSERT INTO raw_announcements (api_source_id, collection_log_id, raw_payload, status)
   VALUES ($1, $2, $3, 'fetched');
   ```

5. **Update Collection Log** (status: `success`/`partial`/`failed`)
   ```sql
   UPDATE api_collection_logs
   SET status = 'success', records_fetched = $1, completed_at = now()
   WHERE id = $2;
   ```

6. **Update Last Collected**
   ```sql
   UPDATE api_sources SET last_collected_at = now() WHERE id = $1;
   ```

---

## 🔐 Authentication Support

### None
```typescript
// No authentication required
headers = { 'Content-Type': 'application/json' }
```

### API Key
```typescript
auth_type: 'api_key'
auth_key: 'your-api-key'

// Adds header:
headers['X-API-Key'] = auth_key
```

### Bearer Token
```typescript
auth_type: 'bearer'
auth_key: 'your-token'

// Adds header:
headers['Authorization'] = 'Bearer ' + auth_key
```

### OAuth (Future)
```typescript
auth_type: 'oauth'
// OAuth flow implementation coming in Phase 4D
```

---

## 📊 Response Handling

The collector automatically detects array format:

### Direct Array
```json
[
  {"id": 1, "name": "Item 1"},
  {"id": 2, "name": "Item 2"}
]
```

### Nested Data
```json
{
  "data": [
    {"id": 1, "name": "Item 1"},
    {"id": 2, "name": "Item 2"}
  ]
}
```

### Pagination Support (Detected Keys)
- `data`
- `items`
- `results`

### Single Record
```json
{
  "id": 1,
  "name": "Single Item"
}
```

---

## ⚠️ Error Handling

### HTTP Errors
- **4xx**: Client error (invalid endpoint, auth failure)
- **5xx**: Server error (API unavailable)
- **Timeout**: 30 second limit

### JSON Parsing Errors
- Invalid content-type (not `application/json`)
- Malformed JSON response

### Database Errors
- Duplicate records (handled gracefully)
- Foreign key violations
- RLS policy issues (use service role key!)

### Error Logging
All errors are stored in `api_collection_logs`:
```sql
SELECT error_message, error_summary
FROM api_collection_logs
WHERE status = 'failed'
ORDER BY started_at DESC;
```

---

## 📈 Monitoring

### View Collection Logs
```sql
SELECT
  acl.id,
  s.name as api_source,
  acl.status,
  acl.records_fetched,
  acl.records_processed,
  acl.records_failed,
  acl.started_at,
  acl.completed_at
FROM api_collection_logs acl
JOIN api_sources s ON s.id = acl.api_source_id
ORDER BY acl.started_at DESC
LIMIT 20;
```

### View Raw Data
```sql
SELECT
  ra.id,
  s.name as api_source,
  ra.status,
  ra.collected_at,
  jsonb_pretty(ra.raw_payload) as payload
FROM raw_announcements ra
JOIN api_sources s ON s.id = ra.api_source_id
ORDER BY ra.collected_at DESC
LIMIT 10;
```

### Success Rate
```sql
SELECT
  s.name,
  COUNT(*) FILTER (WHERE acl.status = 'success') as success,
  COUNT(*) FILTER (WHERE acl.status = 'failed') as failed,
  ROUND(
    COUNT(*) FILTER (WHERE acl.status = 'success')::numeric /
    NULLIF(COUNT(*), 0) * 100,
    2
  ) as success_rate
FROM api_collection_logs acl
JOIN api_sources s ON s.id = acl.api_source_id
WHERE acl.created_at > now() - interval '7 days'
GROUP BY s.name
ORDER BY success_rate DESC;
```

---

## 🔄 Scheduled Collection (Future)

### Option 1: Cron Job
```bash
# Add to crontab
0 */6 * * * cd /path/to/pickly && npm run collect:api >> /var/log/pickly-collector.log 2>&1
```

### Option 2: GitHub Actions
```yaml
name: API Collection
on:
  schedule:
    - cron: '0 */6 * * *'  # Every 6 hours
  workflow_dispatch:

jobs:
  collect:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
      - run: cd backend && npm install
      - run: npm run collect:api
        env:
          SUPABASE_URL: ${{ secrets.SUPABASE_URL }}
          SUPABASE_SERVICE_ROLE_KEY: ${{ secrets.SUPABASE_SERVICE_ROLE_KEY }}
```

### Option 3: Supabase Edge Function
```typescript
// Coming in Phase 4D
import { serve } from 'https://deno.land/std@0.168.0/http/server.ts'
import { runCollection } from './api-collector/runCollection.ts'

serve(async (req) => {
  await runCollection({ dryRun: false, sourceId: null, help: false })
  return new Response('Collection completed', { status: 200 })
})
```

---

## 🧪 Testing

### Dry Run Mode
```bash
npm run collect:api:dry-run
```
- Fetches API sources
- Logs would-be actions
- **Does not** save to database
- Safe for testing

### Single Source Test
```bash
# Get source ID from database
npm run collect:api -- --source-id=<uuid>
```

### Manual Database Check
```bash
# Check collection logs
docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT id, api_source_id, status, started_at FROM api_collection_logs ORDER BY started_at DESC LIMIT 10;"

# Check raw announcements
docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT id, status, collected_at FROM raw_announcements ORDER BY collected_at DESC LIMIT 10;"
```

---

## 🐛 Troubleshooting

### "SUPABASE_SERVICE_ROLE_KEY must be set"
**Solution**: Create `.env` file with valid service role key

### "No active API sources found"
**Solution**: Enable API sources in database
```sql
UPDATE api_sources SET is_active = true WHERE id = '<uuid>';
```

### "HTTP 401 Unauthorized"
**Solution**: Check `auth_type` and `auth_key` in `api_sources` table

### "HTTP 429 Too Many Requests"
**Solution**: Add delay between sources (already implemented: 2s)

### "Failed to insert into raw_announcements"
**Solution**: Check if using service role key (bypasses RLS)

---

## 📚 Related Documentation

- **Phase 4A**: API Source Management (`docs/PHASE4A_API_SOURCES_COMPLETE.md`)
- **Phase 4B**: Collection Logs (`docs/PHASE4B_API_COLLECTION_LOGS_COMPLETE.md`)
- **Phase 4C Step 1**: Raw Announcements (`docs/PHASE4C_STEP1_RAW_ANNOUNCEMENTS_COMPLETE.md`)
- **Phase 4C Step 2**: This service (`docs/PHASE4C_STEP2_API_COLLECTOR_COMPLETE.md`)
- **PRD v9.6.1**: Product Requirements (`docs/prd/PRD_v9.6_Pickly_Integrated_System_UPDATED_v9.6.1.md`)

---

## 🎯 Next Steps

- **Phase 4C Step 3**: Data Transformation Service
  - Read from `raw_announcements` (status: `fetched`)
  - Apply `mapping_config` transformations
  - Create/update `announcements` records
  - Update status to `processed`

---

**Version**: 1.0.0
**Last Updated**: 2025-11-02
**Status**: ✅ Production Ready
