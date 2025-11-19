# Pickly v9.12.0 Production Verification — MANUAL EXECUTION GUIDE
## 벽·파이프 점검 (Wall & Pipe Architecture Validation)

**Date**: 2025-11-12
**Environment**: Production (vymxxpjxrorpywfmqpuk)
**Status**: 🔴 REQUIRES MANUAL EXECUTION
**Mode**: READ-ONLY verification

---

## ⚠️ IMPORTANT NOTICE

Due to system limitations (no direct database access from Claude Code environment), this verification requires **manual execution** using one of the following methods:

1. **Supabase Dashboard** (Recommended)
2. **psql CLI** (Advanced)
3. **Supabase Studio SQL Editor** (Easiest)

---

## 📊 Current Status (Based on Migration List)

### Confirmed via `supabase migration list`:

```
Local          | Remote         | Time (UTC)
20251112000002 | 20251112000002 | 2025-11-12 00:00:02  ✅ APPLIED
20251112090000 |                | 2025-11-12 09:00:00  ⏳ PENDING
20251112090001 |                | 2025-11-12 09:00:01  ⏳ PENDING
```

**Interpretation**:
- ✅ **v9.11.3 is currently deployed** (migration 20251112000002)
- ⏳ **v9.12.0 migrations are ready but NOT YET APPLIED**
- 🟢 **Production is in expected pre-v9.12.0 state**

---

## 🔍 Manual Verification Steps

### Method 1: Supabase Dashboard (Recommended)

1. **Navigate to Supabase Dashboard**:
   - URL: https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk
   - Login with your credentials

2. **Open SQL Editor**:
   - Click "SQL Editor" in left sidebar
   - Create "New query"

3. **Execute Verification Queries** (copy-paste from sections below)

4. **Review Results** and record findings

---

### Method 2: Supabase Studio (Local)

1. **Start Supabase Studio**:
   ```bash
   cd /Users/kwonhyunjun/Desktop/pickly_service/backend
   supabase db remote exec "SELECT version();"
   ```

2. **Open Studio**:
   - Navigate to http://localhost:54323 (if local Studio is running)
   - Or use dashboard method above

---

## 📋 Verification Queries (Execute These)

### Query 1️⃣: Check v9.12.0 Columns in `announcements` Table

**Purpose**: Verify if v9.12.0 schema changes have been applied

**Expected Result (Pre-Deployment)**: 0 rows
**Expected Result (Post-Deployment)**: 6 rows

```sql
SELECT
  column_name,
  data_type,
  is_nullable,
  column_default
FROM information_schema.columns
WHERE table_schema = 'public'
  AND table_name = 'announcements'
  AND column_name IN (
    'thumbnail_url',
    'is_featured',
    'featured_section',
    'featured_order',
    'tags',
    'searchable_text'
  )
ORDER BY ordinal_position;
```

**✅ Pass Criteria**:
- **Pre-Deployment**: Result should be empty (0 rows) ← **EXPECTED NOW**
- **Post-Deployment**: Result should have 6 rows with correct data types

**Record Result**:
```
Column Name       | Data Type | Nullable | Default
------------------|-----------|----------|----------
(empty table expected before deployment)
```

---

### Query 2️⃣: Check `search_index` Table Existence

**Purpose**: Verify if new search_index table has been created

**Expected Result (Pre-Deployment)**: `false`
**Expected Result (Post-Deployment)**: `true`

```sql
SELECT
  EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_schema = 'public'
      AND table_name = 'search_index'
  ) AS search_index_exists;
```

**✅ Pass Criteria**:
- **Pre-Deployment**: `search_index_exists = false` ← **EXPECTED NOW**
- **Post-Deployment**: `search_index_exists = true`

**Record Result**:
```
search_index_exists: _____ (true/false)
```

---

### Query 3️⃣: Check Storage Buckets

**Purpose**: Verify Storage buckets exist (pdfs, images from v9.11.3; thumbnails from v9.12.0)

**Expected Result**:
- **Pre-Deployment**: 2 buckets (announcement-pdfs, announcement-images)
- **Post-Deployment**: 3 buckets (+ announcement-thumbnails)

```sql
SELECT
  id,
  name,
  public,
  file_size_limit,
  array_length(allowed_mime_types, 1) AS mime_type_count
FROM storage.buckets
WHERE id IN (
  'announcement-thumbnails',
  'announcement-pdfs',
  'announcement-images'
)
ORDER BY id;
```

**✅ Pass Criteria**:
- **Pre-Deployment**: 2 buckets exist (pdfs, images) ← **EXPECTED NOW**
- **Post-Deployment**: 3 buckets exist (+ thumbnails)

**Record Result**:
```
Bucket ID              | Public | Size Limit | MIME Types
-----------------------|--------|------------|------------
announcement-images    |  ___   |    ___     |    ___
announcement-pdfs      |  ___   |    ___     |    ___
announcement-thumbnails|  ___   |    ___     |    ___  (should be missing pre-deployment)
```

---

### Query 4️⃣: Check v9.12.0 Functions

**Purpose**: Verify if v9.12.0 functions have been created

**Expected Result (Pre-Deployment)**: 0 rows (or 1 if generate_thumbnail_path exists)
**Expected Result (Post-Deployment)**: 7 rows

```sql
SELECT
  proname AS function_name,
  pg_get_function_identity_arguments(oid) AS arguments
FROM pg_proc
WHERE pronamespace = 'public'::regnamespace
  AND proname IN (
    'sync_search_index_for_announcement',
    'bump_announcements_by_category',
    'bump_announcements_by_subcategory',
    'reindex_announcements',
    'search_announcements',
    'get_featured_announcements',
    'generate_thumbnail_path'
  )
ORDER BY proname;
```

**✅ Pass Criteria**:
- **Pre-Deployment**: 0-1 functions ← **EXPECTED NOW**
- **Post-Deployment**: 7 functions

**Record Result**:
```
Function Name                          | Arguments
---------------------------------------|------------
(empty or minimal expected before deployment)
```

---

### Query 5️⃣: Check v9.12.0 Triggers

**Purpose**: Verify if v9.12.0 triggers (pipes) have been created

**Expected Result (Pre-Deployment)**: 0 rows
**Expected Result (Post-Deployment)**: 3 rows

```sql
SELECT
  trigger_name,
  event_object_table,
  action_timing,
  event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND trigger_name IN (
    'trg_announcements_search_sync',
    'trg_benefit_categories_bump',
    'trg_benefit_subcategories_bump'
  )
ORDER BY trigger_name;
```

**✅ Pass Criteria**:
- **Pre-Deployment**: 0 triggers ← **EXPECTED NOW**
- **Post-Deployment**: 3 triggers

**Record Result**:
```
Trigger Name                    | Table            | Timing | Event
--------------------------------|------------------|--------|-------
(empty expected before deployment)
```

---

### Query 6️⃣: Check v9.12.0 Indexes

**Purpose**: Verify if v9.12.0 GIN and composite indexes have been created

**Expected Result (Pre-Deployment)**: 0 rows
**Expected Result (Post-Deployment)**: 4 rows

```sql
SELECT
  indexname,
  tablename,
  indexdef
FROM pg_indexes
WHERE schemaname = 'public'
  AND (
    indexname LIKE '%searchable%' OR
    indexname LIKE '%tags%' OR
    indexname LIKE '%featured%'
  )
  AND indexname IN (
    'idx_announcements_searchable_text',
    'idx_announcements_tags',
    'idx_search_index_searchable_text',
    'idx_announcements_featured'
  )
ORDER BY indexname;
```

**✅ Pass Criteria**:
- **Pre-Deployment**: 0 indexes ← **EXPECTED NOW**
- **Post-Deployment**: 4 indexes (3 GIN, 1 composite)

**Record Result**:
```
Index Name                       | Table        | Type
---------------------------------|--------------|------
(empty expected before deployment)
```

---

### Query 7️⃣: Check Current Announcements (Data Sanity Check)

**Purpose**: Verify Production data is accessible and intact

**Expected Result**: 3-5 rows (latest announcements)

```sql
SELECT
  id,
  title,
  organization,
  status,
  created_at
FROM public.announcements
ORDER BY created_at DESC
LIMIT 5;
```

**✅ Pass Criteria**:
- Results should show recent announcements
- No errors accessing table
- Data looks reasonable

**Record Result**:
```
ID   | Title (first 30 chars)          | Status    | Created At
-----|----------------------------------|-----------|------------
___  | ________________________________ | _________ | ___________
___  | ________________________________ | _________ | ___________
___  | ________________________________ | _________ | ___________
```

---

### Query 8️⃣: Check RLS Policies on Storage

**Purpose**: Verify Storage RLS policies are correctly configured

**Expected Result**:
- **Pre-Deployment**: 8 policies (4 per existing bucket)
- **Post-Deployment**: 12 policies (4 per bucket × 3 buckets)

```sql
SELECT
  policyname,
  cmd,
  roles
FROM pg_policies
WHERE schemaname = 'storage'
  AND tablename = 'objects'
  AND (
    policyname LIKE '%thumb%' OR
    policyname LIKE '%pdf%' OR
    policyname LIKE '%image%'
  )
ORDER BY policyname;
```

**✅ Pass Criteria**:
- **Pre-Deployment**: 8 policies for pdfs and images ← **EXPECTED NOW**
- **Post-Deployment**: 12 policies (+ 4 for thumbnails)
- Each bucket should have: read public, write auth, update auth, delete auth

**Record Result**:
```
Policy Name           | Command | Roles
----------------------|---------|--------
(list all policies found)
```

---

### Query 9️⃣: Check Applied Migrations

**Purpose**: Verify which migrations have been applied to Production

**Expected Result**: Should show 20251112000002 as latest

```sql
SELECT
  version,
  name,
  inserted_at
FROM supabase_migrations.schema_migrations
WHERE version >= '20251112000000'
ORDER BY version DESC;
```

**✅ Pass Criteria**:
- **Pre-Deployment**: Latest should be 20251112000002 ← **EXPECTED NOW**
- **Post-Deployment**: Should include 20251112090000 and 20251112090001

**Record Result**:
```
Version        | Name                           | Inserted At
---------------|--------------------------------|------------
20251112000002 | add_manual_upload_fields...    | ___________
(20251112090000 and 20251112090001 should be missing pre-deployment)
```

---

### Query 🔟: Summary Report

**Purpose**: Quick status check of all v9.12.0 components

```sql
SELECT
  'announcements.thumbnail_url' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'announcements' AND column_name = 'thumbnail_url'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'announcements.is_featured' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'announcements' AND column_name = 'is_featured'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'announcements.searchable_text' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'announcements' AND column_name = 'searchable_text'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'search_index table' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM information_schema.tables
    WHERE table_name = 'search_index'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'announcement-thumbnails bucket' AS component,
  CASE WHEN EXISTS (
    SELECT 1 FROM storage.buckets WHERE id = 'announcement-thumbnails'
  ) THEN '✅ EXISTS' ELSE '❌ NOT FOUND' END AS status
UNION ALL
SELECT
  'v9.12.0 functions' AS component,
  (SELECT COUNT(*)::TEXT || ' found' FROM pg_proc
   WHERE pronamespace = 'public'::regnamespace
   AND proname IN (
     'sync_search_index_for_announcement',
     'reindex_announcements',
     'search_announcements'
   )) AS status
UNION ALL
SELECT
  'v9.12.0 triggers' AS component,
  (SELECT COUNT(*)::TEXT || ' found' FROM information_schema.triggers
   WHERE trigger_schema = 'public'
   AND trigger_name IN (
     'trg_announcements_search_sync',
     'trg_benefit_categories_bump'
   )) AS status;
```

**✅ Expected Results (Pre-Deployment)**:
```
Component                      | Status
-------------------------------|----------------
announcements.thumbnail_url    | ❌ NOT FOUND
announcements.is_featured      | ❌ NOT FOUND
announcements.searchable_text  | ❌ NOT FOUND
search_index table             | ❌ NOT FOUND
announcement-thumbnails bucket | ❌ NOT FOUND
v9.12.0 functions              | 0 found
v9.12.0 triggers               | 0 found
```

**✅ Expected Results (Post-Deployment)**:
```
Component                      | Status
-------------------------------|----------------
announcements.thumbnail_url    | ✅ EXISTS
announcements.is_featured      | ✅ EXISTS
announcements.searchable_text  | ✅ EXISTS
search_index table             | ✅ EXISTS
announcement-thumbnails bucket | ✅ EXISTS
v9.12.0 functions              | 7 found
v9.12.0 triggers               | 3 found
```

---

## 📊 Manual Verification Checklist

### Pre-Deployment Verification (DO THIS NOW)

- [ ] Query 1️⃣: Announcements v9.12.0 columns → **Expected: 0 rows**
- [ ] Query 2️⃣: search_index table → **Expected: false**
- [ ] Query 3️⃣: Storage buckets → **Expected: 2 buckets (pdfs, images)**
- [ ] Query 4️⃣: v9.12.0 functions → **Expected: 0-1 functions**
- [ ] Query 5️⃣: v9.12.0 triggers → **Expected: 0 triggers**
- [ ] Query 6️⃣: v9.12.0 indexes → **Expected: 0 indexes**
- [ ] Query 7️⃣: Announcements data → **Expected: 3-5 rows, no errors**
- [ ] Query 8️⃣: Storage RLS policies → **Expected: 8 policies (2 buckets × 4)**
- [ ] Query 9️⃣: Applied migrations → **Expected: 20251112000002 latest**
- [ ] Query 🔟: Summary report → **Expected: All ❌ NOT FOUND**

### Post-Deployment Verification (AFTER `supabase db push`)

- [ ] Query 1️⃣: Announcements v9.12.0 columns → **Expected: 6 rows**
- [ ] Query 2️⃣: search_index table → **Expected: true**
- [ ] Query 3️⃣: Storage buckets → **Expected: 3 buckets**
- [ ] Query 4️⃣: v9.12.0 functions → **Expected: 7 functions**
- [ ] Query 5️⃣: v9.12.0 triggers → **Expected: 3 triggers**
- [ ] Query 6️⃣: v9.12.0 indexes → **Expected: 4 indexes**
- [ ] Query 7️⃣: Announcements data → **Expected: Still accessible**
- [ ] Query 8️⃣: Storage RLS policies → **Expected: 12 policies (3 buckets × 4)**
- [ ] Query 9️⃣: Applied migrations → **Expected: Includes 20251112090000, 20251112090001**
- [ ] Query 🔟: Summary report → **Expected: All ✅ EXISTS**

---

## 🎯 Recommended Actions

### Current State: PRE-DEPLOYMENT

Based on `supabase migration list`, Production is currently on v9.11.3 with v9.12.0 migrations pending.

**Recommended Next Steps**:

1. ✅ **Execute Pre-Deployment Verification** (queries above)
   - Confirm all v9.12.0 components are NOT present
   - Document baseline state

2. ✅ **Test on Staging First**:
   ```bash
   cd /Users/kwonhyunjun/Desktop/pickly_service/backend
   supabase link --project-ref <staging-ref>
   supabase db push
   # Run post-deployment verification queries
   # Test Admin UI components end-to-end
   ```

3. ✅ **Deploy to Production** (after Staging validation):
   ```bash
   supabase link --project-ref vymxxpjxrorpywfmqpuk
   supabase db push
   # Run post-deployment verification queries immediately
   # Monitor for 24-48 hours
   ```

4. ✅ **Monitor Production**:
   - Check trigger execution counts (pg_stat_user_functions)
   - Verify no slow queries (pg_stat_statements)
   - Test thumbnail upload via Admin UI
   - Test featured sections display
   - Test search functionality

---

## 📋 Verification Report Template

```
=== Pickly v9.12.0 Production Verification Report ===

**Date**: _______________
**Environment**: vymxxpjxrorpywfmqpuk
**Executed By**: _______________
**Verification Type**: [ ] Pre-Deployment  [ ] Post-Deployment

| Query | Component | Expected | Actual | Pass/Fail |
|-------|-----------|----------|--------|-----------|
| 1️⃣    | v9.12.0 columns | 0 rows | ____ rows | _____ |
| 2️⃣    | search_index table | false | _____ | _____ |
| 3️⃣    | Storage buckets | 2 buckets | ____ buckets | _____ |
| 4️⃣    | v9.12.0 functions | 0-1 | ____ | _____ |
| 5️⃣    | v9.12.0 triggers | 0 | ____ | _____ |
| 6️⃣    | v9.12.0 indexes | 0 | ____ | _____ |
| 7️⃣    | Announcements data | 3-5 rows | ____ rows | _____ |
| 8️⃣    | Storage RLS policies | 8 | ____ | _____ |
| 9️⃣    | Applied migrations | 20251112000002 | __________ | _____ |
| 🔟    | Summary report | All ❌ | __________ | _____ |

**Overall Status**: [ ] ✅ PASS  [ ] ⚠️ PARTIAL  [ ] ❌ FAIL

**Notes**:
_________________________________________________________
_________________________________________________________
_________________________________________________________

**Deployment Decision**: [ ] READY TO DEPLOY  [ ] NEEDS REVIEW  [ ] BLOCKED
```

---

## 🔗 Related Documents

1. [PRD v9.12.0](./PRD_v9.12.0_Admin_Announcement_Search_Extension.md)
2. [Implementation Report v9.12.0](./Pickly_v9.12.0_Implementation_Report.md)
3. [Final Verification Report v9.12.0](./Pickly_v9.12.0_Final_Verification_Report.md)

---

**Document Version**: 1.0 (Manual Execution Guide)
**Last Updated**: 2025-11-12
**Purpose**: Enable manual verification due to system access limitations

---

**END OF MANUAL VERIFICATION GUIDE**
