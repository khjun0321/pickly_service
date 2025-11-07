# 🔄 Pickly Data Transformation Service

**PRD v9.6.1 - Phase 4C Step 3**

Transform raw API responses (`raw_announcements`) into structured announcement records using configurable field mapping.

---

## 📋 Overview

This service reads raw API data collected by the API Collector service and transforms it into the standardized `announcements` table format using mapping configurations defined in `api_sources.mapping_config`.

### Purpose

- **Automated Data Washing**: Convert raw API JSON to structured database records
- **Field Mapping**: Apply configurable field mappings from `mapping_config`
- **Validation**: Ensure required fields are present before insertion
- **Deduplication**: Update existing records instead of creating duplicates
- **Error Handling**: Track transformation failures with detailed error logs

---

## 🏗️ Architecture

### Service Components

```
backend/services/data-transformer/
├── supabaseClient.ts      # Shared Supabase client & type definitions
├── transformRaw.ts        # Single record transformation logic
├── runTransformer.ts      # Orchestration & CLI entry point
└── README.md              # This file
```

### Data Flow

```
┌──────────────────┐
│ raw_announcements│  status='fetched'
│  (raw JSON)      │
└────────┬─────────┘
         │
         ├──> 1. Load api_source.mapping_config
         │
         ├──> 2. Apply field mapping
         │         (title, organization, content, etc.)
         │
         ├──> 3. Validate required fields
         │         (title, organization)
         │
         ├──> 4. Check for duplicates
         │         (same title + organization)
         │
         ├──> 5. INSERT or UPDATE announcements
         │
         └──> 6. Update raw_announcements
                   status='processed'
                   processed_at=now()
```

---

## ⚙️ Configuration

### Mapping Config Format

The `api_sources.mapping_config` JSONB field defines how to transform raw API data:

```json
{
  "fields": {
    "title": "response.title",
    "organization": "response.org_name",
    "content": "response.description",
    "application_start_date": "response.start_date",
    "application_end_date": "response.end_date",
    "region": "response.location",
    "tags": "response.keywords"
  },
  "defaults": {
    "status": "recruiting",
    "link_type": "external",
    "is_priority": false
  },
  "target_category": "uuid-of-category",
  "target_subcategory": "uuid-of-subcategory"
}
```

### Field Mapping Rules

**Dot Notation**: Use nested paths to access deep JSON structures
- `"title": "response.title"` → `raw_payload.response.title`
- `"organization": "data.org.name"` → `raw_payload.data.org.name`

**Type Conversion**: Automatic type handling
- **Boolean fields**: `is_featured`, `is_home_visible`, `is_priority` → converted to `true/false`
- **Number fields**: `display_priority`, `views_count` → converted to integers
- **Date fields**: `*_date` fields → converted to ISO 8601 format
- **Tags**: Comma-separated string → split into array

**Defaults**: Fallback values when mapping doesn't provide data
```json
"defaults": {
  "status": "recruiting",
  "link_type": "external"
}
```

**Target Category/Subcategory**: Auto-assign category
```json
"target_category": "uuid-here",
"target_subcategory": "uuid-here"
```

---

## 🚀 Usage

### NPM Scripts

```bash
# Transform all fetched records
npm run transform:api

# Dry run (test without database writes)
npm run transform:api:dry-run

# Transform specific record
npm run transform:api -- --raw-id=550e8400-e29b-41d4-a716-446655440000

# Show help
npm run transform:api:help
```

### CLI Options

| Option | Description | Example |
|--------|-------------|---------|
| `--dry-run` | Test mode (no DB writes) | `npm run transform:api:dry-run` |
| `--raw-id=<uuid>` | Transform specific record | `npm run transform:api -- --raw-id=abc123` |
| `--help`, `-h` | Show help message | `npm run transform:api:help` |

---

## 📊 Example Transformation

### Input (raw_announcements.raw_payload)

```json
{
  "response": {
    "title": "2025 청년 창업 지원 사업",
    "org_name": "중소벤처기업부",
    "description": "청년 창업가를 위한 지원금 및 멘토링 프로그램",
    "start_date": "2025-01-01T00:00:00Z",
    "end_date": "2025-12-31T23:59:59Z",
    "location": "서울",
    "keywords": "창업,지원금,청년"
  }
}
```

### Mapping Config

```json
{
  "fields": {
    "title": "response.title",
    "organization": "response.org_name",
    "content": "response.description",
    "application_start_date": "response.start_date",
    "application_end_date": "response.end_date",
    "region": "response.location",
    "tags": "response.keywords"
  },
  "defaults": {
    "status": "recruiting",
    "link_type": "external"
  }
}
```

### Output (announcements table)

```json
{
  "title": "2025 청년 창업 지원 사업",
  "organization": "중소벤처기업부",
  "content": "청년 창업가를 위한 지원금 및 멘토링 프로그램",
  "application_start_date": "2025-01-01T00:00:00Z",
  "application_end_date": "2025-12-31T23:59:59Z",
  "region": "서울",
  "tags": ["창업", "지원금", "청년"],
  "status": "recruiting",
  "link_type": "external"
}
```

---

## 🔍 Validation Rules

### Required Fields

| Field | Type | Validation |
|-------|------|------------|
| `title` | string | Must not be empty |
| `organization` | string | Must not be empty |

### Enum Validation

| Field | Allowed Values |
|-------|----------------|
| `status` | `recruiting`, `closed`, `upcoming`, `draft` |
| `link_type` | `internal`, `external`, `none` |

### Deduplication

Records are deduplicated based on:
- `title` + `organization` combination

If a matching record exists:
- **Action**: UPDATE existing record
- **Result**: `action: 'updated'`

If no match found:
- **Action**: INSERT new record
- **Result**: `action: 'created'`

---

## 🧪 Testing

### Dry Run Test

```bash
npm run transform:api:dry-run
```

**Expected Output**:
```
╔════════════════════════════════════════════════════════════════╗
║        🔄 Pickly Data Transformation Service                  ║
║              PRD v9.6.1 - Phase 4C Step 3                     ║
╚════════════════════════════════════════════════════════════════╝

⏰ Started at: 11/2/2025, 6:00:00 PM
🧪 Dry Run: YES
🎯 Target: All fetched records

📋 Fetching raw announcements...
✅ Found 3 record(s) to transform

============================================================
📝 Processing 1/3
   Raw ID: abc-123
   Collected: 11/2/2025, 5:30:00 PM
============================================================

🔄 Transforming raw announcement: abc-123
   Source: Public Data Portal - Housing
   Mapping fields: 7
   Mapped fields: 7
🧪 [DRY RUN] Would insert/update announcement:
{
  "title": "2025 청년 창업 지원",
  "organization": "중소벤처기업부",
  ...
}

╔════════════════════════════════════════════════════════════════╗
║              📊 Transformation Summary                        ║
╚════════════════════════════════════════════════════════════════╝

⏱️  Duration: 0.15s

📈 Results:
   Total Records: 3
   ✅ Successful: 3
   ❌ Failed: 0

📝 Actions:
   🆕 Created: 3
   🔄 Updated: 0
   ⏭️  Skipped: 0

✅ All transformations completed successfully!
```

### Database Verification

```bash
# Check transformed announcements
docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT id, title, organization, status, created_at
   FROM announcements
   ORDER BY created_at DESC
   LIMIT 5;"

# Check processing status distribution
docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT status, COUNT(*) as count
   FROM raw_announcements
   GROUP BY status;"

# Check for transformation errors
docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT id, error_log
   FROM raw_announcements
   WHERE status = 'error'
   LIMIT 10;"
```

---

## 🐛 Error Handling

### Error Types

| Error Type | Action | Status Update |
|------------|--------|---------------|
| Missing mapping_config | Skip transformation | `status='fetched'`, `error_log='No mapping_config'` |
| Validation failed | Mark as error | `status='error'`, `error_log='Validation failed: ...'` |
| Database error | Mark as error | `status='error'`, `error_log='DB error: ...'` |

### Error Recovery

```bash
# Re-transform failed records
# 1. Fix the mapping_config in api_sources table
# 2. Reset error records to 'fetched'
docker exec -i supabase_db_supabase psql -U postgres -d postgres -c \
  "UPDATE raw_announcements SET status = 'fetched', error_log = NULL WHERE status = 'error';"

# 3. Re-run transformation
npm run transform:api
```

---

## 📈 Performance

### Processing Speed

- **Single Record**: ~100-200ms (including DB roundtrips)
- **Batch Processing**: ~100ms delay between records to avoid DB overload
- **Recommended Batch Size**: 100-500 records per run

### Database Impact

- **Reads**: 2 queries per record (api_source + existing announcement check)
- **Writes**: 2 queries per record (announcement upsert + raw_announcement update)
- **Indexes Used**:
  - `announcements(title, organization)` for deduplication
  - `raw_announcements(status)` for fetching records

---

## 🔮 Future Enhancements

### Planned Features (Phase 4D+)

1. **Batch Processing**: Process multiple records in single transaction
2. **Parallel Execution**: Transform multiple records concurrently
3. **Custom Validators**: Plugin system for custom validation rules
4. **Transformation Rules**: Complex field transformations (regex, calculations)
5. **Rollback Support**: Undo transformations with transaction logs
6. **AI-Assisted Mapping**: Auto-generate mapping_config from sample data

---

## 📚 Related Documentation

- **API Collection Service**: `backend/services/api-collector/README.md`
- **Phase 4C Step 1**: `docs/PHASE4C_STEP1_RAW_ANNOUNCEMENTS_COMPLETE.md`
- **Phase 4C Step 2**: `docs/PHASE4C_STEP2_API_COLLECTOR_COMPLETE.md`
- **PRD v9.6.1**: `docs/prd/PRD_v9.6_Pickly_Integrated_System_UPDATED.md`

---

## 🆘 Troubleshooting

### No records to transform

**Problem**: "No raw announcements found with status='fetched'"

**Solution**: Run API collector first
```bash
npm run collect:api
```

### Validation errors

**Problem**: "Validation failed: title is required"

**Solution**: Check mapping_config fields
```sql
SELECT mapping_config FROM api_sources WHERE id = 'your-source-id';
```

Ensure `fields.title` and `fields.organization` are mapped.

### TypeScript errors

**Problem**: `Cannot find module '@supabase/supabase-js'`

**Solution**: Install dependencies
```bash
cd backend
npm install
```

---

**Version**: 1.0.0
**Last Updated**: 2025-11-02
**Status**: Production Ready ✅
