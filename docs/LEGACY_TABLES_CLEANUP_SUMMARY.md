# 🧹 Legacy Tables Cleanup Summary

**Date**: 2025-11-03
**Status**: ⚠️ **ANALYSIS COMPLETE - AWAITING VERIFICATION**
**PRD Version**: v9.6.1

---

## 📋 Quick Summary

**Findings**:
- ✅ **15 Active Tables** aligned with PRD v9.6.1
- ⚠️ **3 Legacy Tables** found only in TypeScript types (not in migrations)
- 🔴 **1 Critical Issue**: Flutter app queries `benefit_announcements` table

**Risk Level**: 🔴 **HIGH** (Flutter app may be broken)

---

## 🚨 Critical Issue: Flutter App Broken Reference

### Problem
Flutter app queries `benefit_announcements` table **7 times**, but:
- ❌ Table **NOT found** in any migration files
- ❌ Only exists in TypeScript type definitions
- ✅ Admin code uses `announcements` table (correct)

### Impact
- If table doesn't exist in DB: 🔴 **Flutter app is BROKEN**
- If table exists in DB: ⚠️ **Data may be out of sync**

### Solution
1. **Immediate**: Run verification script to check if table exists
2. **If table doesn't exist**: Update Flutter code to use `announcements`
3. **If table exists**: Migrate data to `announcements`, then drop

---

## 📁 Files Generated

### 1. **Main Report** (Comprehensive Analysis)
**File**: `docs/DB_LEGACY_CLEANUP_REPORT.md` (4,000+ lines)

**Contents**:
- Complete table inventory (18 tables analyzed)
- Active vs legacy table classification
- Code usage analysis (Admin + Flutter)
- Foreign key dependency analysis
- Backup procedures
- Cleanup migration script
- Safety checklist
- Rollback plan

### 2. **Verification Script** (SQL)
**File**: `scripts/verify_legacy_tables.sql`

**Purpose**: Check which legacy tables actually exist in database

**Run with**:
```bash
docker exec -i supabase_db_pickly_service psql -U postgres -d postgres -f scripts/verify_legacy_tables.sql
```

**Output**:
- Table existence check
- Row count analysis
- Foreign key dependencies
- Schema comparison
- Sample data preview
- Automated recommendations

### 3. **Backup Script** (Bash)
**File**: `scripts/backup_legacy_tables.sh`

**Purpose**: Export legacy tables to CSV before cleanup

**Run with**:
```bash
./scripts/backup_legacy_tables.sh
```

**Creates**:
- CSV backups of all legacy tables
- Schema exports (.sql files)
- MD5 checksums for verification
- Backup manifest with restoration instructions

---

## 🎯 Next Steps (In Order)

### Step 1: Verify Database State ⚠️ **DO THIS FIRST**

```bash
# Option A: Run SQL verification script
docker exec -i supabase_db_pickly_service psql -U postgres -d postgres \
  -f scripts/verify_legacy_tables.sql

# Option B: Quick check
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "SELECT tablename FROM pg_tables WHERE tablename IN \
   ('benefit_announcements', 'housing_announcements', 'display_order_history');"
```

**Expected Output**:
- If tables don't exist: ✅ PRD v9.6.1 is correct
- If tables exist: ⚠️ Cleanup needed

---

### Step 2: Create Backups (If Tables Exist)

```bash
# Run automated backup script
./scripts/backup_legacy_tables.sh
```

**Creates backups in**: `docs/history/db_backup_legacy_20251103/`

**Files created**:
- `benefit_announcements_backup.csv`
- `benefit_announcements_schema.sql`
- `housing_announcements_backup.csv`
- `housing_announcements_schema.sql`
- `display_order_history_backup.csv`
- `display_order_history_schema.sql`
- `BACKUP_MANIFEST.md`

---

### Step 3: Fix Flutter Code (If `benefit_announcements` Exists)

**File**: `apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart`

**Changes needed**: Replace 7 occurrences of `.from('benefit_announcements')` with `.from('announcements')`

**Lines to update**: 105, 124, 151, 173, 200, 228, 258, 374

**Find and replace**:
```bash
# Preview changes (dry run)
grep -n "\.from('benefit_announcements')" \
  apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart

# Apply changes (use your editor or sed)
# Replace: .from('benefit_announcements')
# With:    .from('announcements')
```

**Test after update**:
```bash
# Build Flutter app
cd apps/pickly_mobile
flutter pub get
flutter build apk --debug

# Test benefit queries
flutter test test/contexts/benefit/
```

---

### Step 4: Regenerate TypeScript Types

```bash
# Regenerate from actual database schema
npx supabase gen types typescript --project-id [YOUR_PROJECT_ID] > \
  apps/pickly_admin/src/types/supabase.ts

# Or if using local Supabase:
npx supabase gen types typescript --local > \
  apps/pickly_admin/src/types/supabase.ts
```

**Result**: Removes legacy table references from TypeScript types

**Verify**:
```bash
# Check that legacy tables are removed
grep -c "benefit_announcements\|housing_announcements\|display_order_history" \
  apps/pickly_admin/src/types/supabase.ts

# Expected: 0 (if tables don't exist in DB)
```

---

### Step 5: Execute Cleanup Migration (Optional)

⚠️ **ONLY IF**:
- ✅ Verification completed (Step 1)
- ✅ Backups created (Step 2)
- ✅ Flutter code updated (Step 3)
- ✅ TypeScript types regenerated (Step 4)
- ✅ Both apps tested

**Migration file**: `backend/supabase/migrations/20251103000002_cleanup_legacy_tables.sql`

**Contents** (see full report):
```sql
-- Drop benefit_announcements (if exists)
DROP TABLE IF EXISTS benefit_announcements CASCADE;

-- Drop housing_announcements (if exists)
DROP TABLE IF EXISTS housing_announcements CASCADE;

-- Drop display_order_history (if exists)
DROP TABLE IF EXISTS display_order_history CASCADE;
```

**Run migration**:
```bash
# Apply migration locally
npx supabase db push

# Or manually:
docker exec -i supabase_db_pickly_service psql -U postgres -d postgres < \
  backend/supabase/migrations/20251103000002_cleanup_legacy_tables.sql
```

---

## 🔧 Quick Commands Reference

### Check if legacy tables exist
```bash
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "SELECT tablename FROM pg_tables WHERE tablename LIKE '%announcement%' ORDER BY tablename;"
```

### Check row counts
```bash
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "SELECT 'announcements' AS table, COUNT(*) FROM announcements \
   UNION ALL \
   SELECT 'benefit_announcements', COUNT(*) FROM benefit_announcements \
   WHERE EXISTS (SELECT 1 FROM pg_tables WHERE tablename = 'benefit_announcements');"
```

### Check Flutter usage
```bash
grep -r "\.from('benefit_announcements')" apps/pickly_mobile/lib/
```

### Check Admin usage
```bash
grep -r "\.from('benefit_announcements')" apps/pickly_admin/src/
```

---

## 📊 Risk Assessment

| Scenario | Risk | Impact | Action |
|----------|------|--------|--------|
| Tables don't exist in DB | 🔴 **HIGH** | Flutter app broken | Update Flutter code immediately |
| Tables exist, data matches | 🟡 **MEDIUM** | Data duplication | Cleanup after migration |
| Tables exist, data differs | 🔴 **HIGH** | Data inconsistency | Investigate before cleanup |
| TypeScript types outdated | 🟢 **LOW** | Type errors only | Regenerate types |

---

## ✅ Safety Checklist

Before executing cleanup:

- [ ] ✅ Verification script executed
- [ ] ✅ Table existence documented
- [ ] ✅ Row counts recorded
- [ ] ✅ Backups created and verified
- [ ] ✅ MD5 checksums calculated
- [ ] ⚠️ Flutter code updated (if needed)
- [ ] ⚠️ Flutter app tested (if code updated)
- [ ] ✅ TypeScript types regenerated
- [ ] ✅ Admin app tested
- [ ] ✅ No foreign key dependencies
- [ ] ✅ Team notified
- [ ] ✅ Rollback plan reviewed

---

## 🔄 Rollback Procedure

If something goes wrong:

### 1. Restore Schema
```bash
docker exec -i supabase_db_pickly_service psql -U postgres -d postgres < \
  docs/history/db_backup_legacy_20251103/[table_name]_schema.sql
```

### 2. Restore Data
```bash
docker cp docs/history/db_backup_legacy_20251103/[table_name]_backup.csv \
  supabase_db_pickly_service:/tmp/

docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "COPY [table_name] FROM '/tmp/[table_name]_backup.csv' DELIMITER ',' CSV HEADER;"
```

### 3. Revert Code Changes
```bash
# Revert Flutter changes
git checkout apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart

# Revert TypeScript types
git checkout apps/pickly_admin/src/types/supabase.ts
```

---

## 📚 Related Documentation

- **Main Report**: `docs/DB_LEGACY_CLEANUP_REPORT.md` - Comprehensive 4,000+ line analysis
- **Verification Script**: `scripts/verify_legacy_tables.sql` - Database verification
- **Backup Script**: `scripts/backup_legacy_tables.sh` - Automated backup
- **Backup Manifest**: `docs/history/db_backup_legacy_20251103/BACKUP_MANIFEST.md` - Restoration guide
- **PRD**: `docs/prd/PRD_v9.6_Pickly_Integrated_System_UPDATED_v9.6.1.md` - Current specification

---

## 🎓 Lessons Learned

### What Went Wrong
1. TypeScript types not regenerated after schema changes
2. Flutter code uses different table name than migrations
3. No migration to drop old tables after renaming

### Best Practices Going Forward
1. ✅ Always regenerate TypeScript types after schema changes
2. ✅ Keep Flutter and Admin table names in sync
3. ✅ Create DROP TABLE migrations when renaming tables
4. ✅ Document table renames in migration comments
5. ✅ Test both Admin and Flutter after schema changes

---

## 📞 Need Help?

**If you encounter issues**:
1. Review the main report: `docs/DB_LEGACY_CLEANUP_REPORT.md`
2. Check verification script output
3. Verify backups were created successfully
4. Review rollback procedure above
5. Test in local environment first

**Critical Questions to Answer**:
- Does `benefit_announcements` table exist in database? *(Run Step 1)*
- Is Flutter app currently working? *(Test benefit queries)*
- Are there foreign key dependencies? *(Check verification output)*

---

**Remember**: This is **READ-ONLY ANALYSIS**. No database changes have been made yet. Always verify before cleanup!
