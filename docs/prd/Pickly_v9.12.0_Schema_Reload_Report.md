# Pickly v9.12.0 - Schema Reload Verification Report

**Date:** 2025-11-12
**Project:** vymxxpjxrorpywfmqpuk (Production)
**Mode:** Safe (Read-Only, Cache Reload Only)
**Status:** ❌ **FAILED - Root Cause: Migration Not Applied**

---

## 📋 Executive Summary

PostgREST API restart 및 NOTIFY pgrst 명령 실행 후에도 PGRST205 오류가 지속되어 근본 원인을 조사한 결과, **캐시 문제가 아닌 마이그레이션 미적용 문제**로 확인되었습니다.

### ⚠️ Critical Findings

1. **Production DB에는 `profiles` 테이블만 존재**
2. **`announcements`, `benefit_categories`, `age_categories` 테이블이 DB에 존재하지 않음**
3. **최근 마이그레이션 파일들이 reverted 상태**

---

## 🔍 Verification Process

### 1️⃣ Initial State (Before API Restart)

**Date:** 2025-11-12
**Test:** PostgREST schema cache check

```
❌ announcements table:      Not accessible (PGRST205)
❌ benefit_categories table:  Not accessible (PGRST205)
❌ age_categories table:      Not accessible (PGRST205)
```

**Error Details:**
```
Error: Could not find the table 'public.announcements' in the schema cache
Error Code: PGRST205
```

---

### 2️⃣ First Attempt: NOTIFY Command via Service Role

**Action:** Executed in Supabase SQL Editor with Service Role key
```sql
NOTIFY pgrst, 'reload schema';
```

**Wait Time:** 20 seconds
**Result:** ❌ **FAILED**

```
❌ announcements table:      Still not accessible
❌ benefit_categories table:  Still not accessible
❌ age_categories table:      Still not accessible
```

---

### 3️⃣ Second Attempt: Dashboard API Restart

**Action:** Clicked "Restart API" button in Supabase Dashboard
**URL:** https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/settings/api

**Wait Time:** 30 seconds
**Result:** ❌ **FAILED**

```
❌ announcements table:      Still not accessible
❌ benefit_categories table:  Still not accessible
❌ age_categories table:      Still not accessible
```

---

### 4️⃣ Root Cause Analysis

#### PostgREST Schema Inspection

**Command:**
```bash
curl https://vymxxpjxrorpywfmqpuk.supabase.co/rest/v1/
```

**Result:** Only `profiles` table exposed in OpenAPI schema

```json
{
  "paths": {
    "/profiles": { /* ... */ }
    // ❌ No /announcements
    // ❌ No /benefit_categories
    // ❌ No /age_categories
  }
}
```

#### Migration Status Check

**Command:**
```bash
supabase db remote commit
```

**Result:** Migration history mismatch detected

```
The remote database's migration history does not match local files

Make sure your local git repo is up-to-date. If the error persists, try repairing:
supabase migration repair --status reverted 20251112000002
```

**Key Finding:** Migration `20251112000002_add_manual_upload_fields_to_announcements.sql` is in **reverted** state.

---

## 📊 Before/After Comparison

| Metric | Before API Restart | After API Restart | Expected |
|--------|-------------------|-------------------|----------|
| **announcements** | ❌ Not accessible | ❌ Not accessible | ✅ Accessible |
| **benefit_categories** | ❌ Not accessible | ❌ Not accessible | ✅ Accessible |
| **age_categories** | ❌ Not accessible | ❌ Not accessible | ✅ Accessible |
| **Supabase Connection** | ✅ Connected | ✅ Connected | ✅ Connected |
| **PostgREST API** | 🔴 Schema outdated | 🔴 Schema outdated | 🟢 READY |

---

## 🔍 Root Cause Analysis

### Problem: Tables Do Not Exist in Production DB

**Evidence:**
1. PostgREST OpenAPI schema only shows `profiles` table
2. PGRST205 error indicates table not found in schema cache
3. Migration `20251112000002` is in reverted state
4. Recent migrations not applied to production:
   - `20251112000002_add_manual_upload_fields_to_announcements.sql`
   - `20251112090000_admin_announcement_search_extension.sql`
   - `20251112090001_create_announcement_thumbnails_bucket.sql`

### Why Cache Reload Failed

**Cache reload commands (NOTIFY/API Restart) cannot fix missing tables.**

- ✅ Cache reload: Refreshes PostgREST's view of existing schema
- ❌ Cache reload: **Cannot create missing tables**
- ✅ Required: Apply migrations to create tables first

---

## 🎯 Conclusion

### Issue Summary

**❌ This is NOT a cache problem**
**✅ This is a migration deployment problem**

The core issue is that essential tables (`announcements`, `benefit_categories`, `age_categories`) **do not exist** in the Production database because migrations have not been applied.

### Cache Reload Results

| Action | Result | Reason |
|--------|--------|--------|
| NOTIFY pgrst | ❌ Failed | Tables don't exist in DB |
| API Restart | ❌ Failed | Tables don't exist in DB |
| 30s Wait Time | ❌ Failed | Tables don't exist in DB |

---

## 🔧 Recommended Actions

### ⚠️ DO NOT PROCEED WITH CACHE RELOAD

Cache reload commands are ineffective because the underlying issue is missing tables, not stale cache.

### ✅ Required Steps (In Order)

#### 1. Verify Migration History

```bash
cd ~/Desktop/pickly_service/backend/supabase
supabase migration list --db-url "postgresql://postgres.[PROJECT-REF]:[PASSWORD]@aws-0-ap-northeast-2.pooler.supabase.com:6543/postgres"
```

#### 2. Check Migration Status

```bash
supabase db remote commit
```

**Expected Output:** List of migrations needing repair or application

#### 3. Repair Migration History (If Needed)

```bash
supabase migration repair --status reverted 20251112000002
```

#### 4. Apply Missing Migrations

```bash
supabase db push
```

**⚠️ WARNING:** This will modify Production database. Backup first!

#### 5. Verify Tables Created

```bash
cd ~/Desktop/pickly_service/apps/pickly_admin
./verify-schema-reload.sh
```

**Expected Output:**
```
✅ announcements table accessible
✅ benefit_categories table accessible
✅ age_categories table accessible
🟢 Supabase connection: READY
```

---

## 📁 Generated Logs

**Before Check:** `/tmp/schema_check_before.log`
**After Check:** `/tmp/schema_check_after.log`

Both logs show identical results (all tables inaccessible), confirming cache reload had no effect.

---

## 🎓 Lessons Learned

### What Worked
- ✅ Systematic verification process
- ✅ Clear Before/After comparison
- ✅ Root cause analysis via PostgREST schema inspection

### What Didn't Work
- ❌ NOTIFY pgrst command (wrong approach for this issue)
- ❌ Dashboard API Restart (wrong approach for this issue)
- ❌ Waiting longer (won't fix missing tables)

### Key Insight

**PGRST205 Error Can Mean Two Things:**
1. **Schema cache is stale** → Fix: NOTIFY/API Restart ✅
2. **Table doesn't exist in DB** → Fix: Apply migrations ✅

This was case #2, not case #1.

---

## 📝 Next Steps

**Immediate Action Required:**
1. ⚠️ **STOP** attempting cache reloads
2. ✅ **START** migration deployment process
3. 📋 **CREATE** backup of Production DB first
4. 🔍 **VERIFY** migration files are correct
5. 🚀 **DEPLOY** migrations to Production
6. ✅ **TEST** table accessibility after deployment

**Estimated Time:** 30-60 minutes (including backup and verification)

---

## 📊 Environment Details

**Project ID:** vymxxpjxrorpywfmqpuk
**Region:** ap-northeast-2 (Seoul)
**PostgREST Version:** 13.0.4
**Database:** PostgreSQL (Supabase-managed)
**Local Project:** `~/Desktop/pickly_service`

---

## ✅ Safe Mode Compliance

This report was generated in **Safe (Read-Only) Mode**:
- ✅ No database writes performed
- ✅ No schema modifications attempted
- ✅ Only cache reload commands executed
- ✅ No RLS policy changes
- ✅ Verification scripts only read data

---

**Report Generated:** 2025-11-12
**Author:** Claude Code (Automated Analysis)
**Status:** Investigation Complete - Requires Migration Deployment
