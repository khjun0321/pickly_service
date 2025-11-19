# 🗂️ Legacy Tables Cleanup Documentation Index

**Date**: 2025-11-03
**PRD Version**: v9.6.1
**Status**: ⚠️ **ANALYSIS COMPLETE - VERIFICATION NEEDED**

---

## 📚 Documentation Overview

This cleanup initiative identifies and safely removes database tables that don't align with PRD v9.6.1.

### 🎯 Quick Start

**IMPORTANT**: Follow these steps **IN ORDER**:

1. ✅ **Read Summary** → `LEGACY_TABLES_CLEANUP_SUMMARY.md` (5 minutes)
2. ✅ **Run Verification** → `scripts/verify_legacy_tables.sql` (2 minutes)
3. ✅ **Create Backups** → `scripts/backup_legacy_tables.sh` (5 minutes)
4. ⚠️ **Review Full Report** → `DB_LEGACY_CLEANUP_REPORT.md` (15 minutes)
5. ⚠️ **Fix Code** (if needed) → Update Flutter/TypeScript (30 minutes)
6. ⚠️ **Execute Cleanup** (optional) → Run migration (5 minutes)

---

## 📄 All Documents

### 1. 📖 Quick Summary (START HERE)
**File**: `docs/LEGACY_TABLES_CLEANUP_SUMMARY.md`

**Size**: ~300 lines
**Read Time**: 5 minutes
**Purpose**: Quick overview and step-by-step guide

**Contents**:
- Critical findings
- Quick commands
- Step-by-step instructions
- Risk assessment
- Rollback procedure

**When to read**: Always start here

---

### 2. 📋 Full Report (COMPREHENSIVE)
**File**: `docs/DB_LEGACY_CLEANUP_REPORT.md`

**Size**: ~4,000 lines
**Read Time**: 15-30 minutes
**Purpose**: Complete analysis and reference documentation

**Contents**:
- Complete table inventory (18 tables)
- Active vs legacy classification
- Code usage analysis (Admin + Flutter)
- Foreign key dependency analysis
- Detailed backup procedures
- Cleanup migration script
- Comprehensive safety checklist
- Rollback plan
- Best practices and lessons learned

**When to read**: Before making any database changes

---

### 3. 🔍 Verification Script (RUN FIRST)
**File**: `scripts/verify_legacy_tables.sql`

**Type**: SQL script
**Runtime**: ~2 minutes
**Purpose**: Check which legacy tables exist in database

**Run with**:
```bash
docker exec -i supabase_db_pickly_service psql -U postgres -d postgres \
  -f scripts/verify_legacy_tables.sql
```

**Output**:
- Table existence check
- Row count analysis
- Foreign key dependencies
- Schema comparison
- Sample data preview
- Automated recommendations

**When to run**: Before any other actions

---

### 4. 💾 Backup Script (RUN SECOND)
**File**: `scripts/backup_legacy_tables.sh`

**Type**: Bash script
**Runtime**: ~5 minutes
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

**Output Location**: `docs/history/db_backup_legacy_20251103/`

**When to run**: After verification, before any code/DB changes

---

### 5. 📁 Backup Directory
**Path**: `docs/history/db_backup_legacy_20251103/`

**Contents** (after running backup script):
- `benefit_announcements_backup.csv`
- `benefit_announcements_schema.sql`
- `housing_announcements_backup.csv`
- `housing_announcements_schema.sql`
- `display_order_history_backup.csv`
- `display_order_history_schema.sql`
- `BACKUP_MANIFEST.md`
- `README.md`

**Purpose**: Safe storage of legacy table data before cleanup

---

## 🚨 Critical Finding

### Flutter App Broken Reference

**Issue**: Flutter app queries `benefit_announcements` table (7 times), but:
- ❌ Table **NOT found** in any migration files
- ❌ Only exists in TypeScript type definitions
- ✅ Admin code correctly uses `announcements` table

**Impact**:
- If table doesn't exist in DB: 🔴 **Flutter app is BROKEN**
- If table exists in DB: ⚠️ **Data may be out of sync**

**Solution**:
1. Run verification script to check if table exists
2. If doesn't exist: Update Flutter code to use `announcements`
3. If exists: Migrate data, then drop table

**Flutter File to Update**: `apps/pickly_mobile/lib/contexts/benefit/repositories/benefit_repository.dart`
**Lines to Change**: 105, 124, 151, 173, 200, 228, 258, 374
**Change**: `.from('benefit_announcements')` → `.from('announcements')`

---

## 📊 Summary Statistics

| Metric | Count | Status |
|--------|-------|--------|
| **Total Tables Analyzed** | 18 | - |
| **Active Tables (PRD v9.6.1)** | 15 | ✅ Keep |
| **Legacy Tables** | 3 | ⚠️ Review |
| **Critical Issues** | 1 | 🔴 Flutter broken reference |
| **Foreign Key Dependencies** | 0 | ✅ Safe to drop |
| **Admin Code References** | 0 | ✅ Safe |
| **Flutter Code References** | 1 | 🔴 `benefit_announcements` |

---

## 🎯 Action Plan

### Phase 1: Verification (Required)
- [ ] Read summary document
- [ ] Run `verify_legacy_tables.sql`
- [ ] Document which tables exist
- [ ] Check row counts

### Phase 2: Backup (Required)
- [ ] Run `backup_legacy_tables.sh`
- [ ] Verify backups created
- [ ] Check MD5 checksums
- [ ] Review backup manifest

### Phase 3: Code Updates (If Needed)
- [ ] Update Flutter code (if `benefit_announcements` exists)
- [ ] Test Flutter benefit queries
- [ ] Regenerate TypeScript types
- [ ] Test Admin app

### Phase 4: Cleanup (Optional)
- [ ] Review full report
- [ ] Complete safety checklist
- [ ] Execute cleanup migration
- [ ] Verify cleanup success

---

## 🔧 Quick Commands

### Check Table Existence
```bash
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "SELECT tablename FROM pg_tables WHERE tablename IN \
   ('benefit_announcements', 'housing_announcements', 'display_order_history');"
```

### Run Full Verification
```bash
docker exec -i supabase_db_pickly_service psql -U postgres -d postgres \
  -f scripts/verify_legacy_tables.sql
```

### Create Backups
```bash
./scripts/backup_legacy_tables.sh
```

### Check Flutter Usage
```bash
grep -r "\.from('benefit_announcements')" apps/pickly_mobile/lib/
```

### Regenerate TypeScript Types
```bash
npx supabase gen types typescript --local > apps/pickly_admin/src/types/supabase.ts
```

---

## 📁 File Structure

```
pickly_service/
├── docs/
│   ├── DB_LEGACY_CLEANUP_REPORT.md          # 📋 Full analysis (4,000 lines)
│   ├── LEGACY_TABLES_CLEANUP_SUMMARY.md     # 📖 Quick summary (300 lines)
│   ├── LEGACY_TABLES_CLEANUP_INDEX.md       # 🗂️ This index file
│   └── history/
│       └── db_backup_legacy_20251103/
│           ├── README.md                     # 📁 Backup directory guide
│           └── BACKUP_MANIFEST.md            # (created by backup script)
├── scripts/
│   ├── verify_legacy_tables.sql             # 🔍 Verification script (SQL)
│   └── backup_legacy_tables.sh              # 💾 Backup script (Bash)
└── backend/supabase/migrations/
    └── 20251103000002_cleanup_legacy_tables.sql  # (optional cleanup migration)
```

---

## ⚠️ Safety Reminders

### ❌ DO NOT:
- Skip verification step
- Drop tables without backups
- Update database without updating code
- Assume TypeScript types match database
- Make changes in production first

### ✅ DO:
- Run verification first
- Create backups before changes
- Update code before dropping tables
- Test in local environment
- Follow safety checklist
- Document all changes

---

## 🔄 Rollback Procedure

If something goes wrong, see detailed rollback instructions in:
- Quick guide: `LEGACY_TABLES_CLEANUP_SUMMARY.md` → "Rollback Procedure"
- Full guide: `DB_LEGACY_CLEANUP_REPORT.md` → "Rollback Plan"

Quick rollback:
```bash
# 1. Restore schema
docker exec -i supabase_db_pickly_service psql -U postgres -d postgres < \
  docs/history/db_backup_legacy_20251103/[table]_schema.sql

# 2. Restore data
docker cp docs/history/db_backup_legacy_20251103/[table]_backup.csv \
  supabase_db_pickly_service:/tmp/
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "COPY [table] FROM '/tmp/[table]_backup.csv' DELIMITER ',' CSV HEADER;"
```

---

## 📞 Need Help?

1. **Start with**: `LEGACY_TABLES_CLEANUP_SUMMARY.md`
2. **Run**: `scripts/verify_legacy_tables.sql`
3. **Review**: `DB_LEGACY_CLEANUP_REPORT.md` (if needed)
4. **Create**: Backups with `scripts/backup_legacy_tables.sh`
5. **Test**: In local environment first

**Critical Questions**:
- Does `benefit_announcements` exist? → Run verification
- Is Flutter app working? → Test benefit queries
- Are there dependencies? → Check verification output

---

## 📚 Related PRD Documentation

- **Current PRD**: `docs/prd/PRD_v9.6_Pickly_Integrated_System_UPDATED_v9.6.1.md`
- **Schema Reference**: Section 5 - DB Schema
- **Phase 4 Docs**:
  - `docs/PHASE4A_API_SOURCES_COMPLETE.md`
  - `docs/PHASE4B_API_COLLECTION_LOGS_COMPLETE.md`

---

## 🎓 Key Takeaways

### What We Found
1. **15 Active Tables** properly aligned with PRD v9.6.1
2. **3 Legacy Tables** exist only in TypeScript types (not in migrations)
3. **1 Critical Issue**: Flutter uses `benefit_announcements` instead of `announcements`

### What We Created
1. **Comprehensive Analysis Report** (4,000+ lines)
2. **Automated Verification Script** (SQL)
3. **Automated Backup Script** (Bash)
4. **Safety Checklists and Rollback Procedures**

### Best Practices Learned
1. ✅ Always regenerate TypeScript types after schema changes
2. ✅ Keep Flutter and Admin table names in sync
3. ✅ Create DROP TABLE migrations when renaming
4. ✅ Test both apps after schema changes
5. ✅ Verify table existence before assuming it's there

---

**Remember**: This is **READ-ONLY ANALYSIS**. No database changes have been made. Always verify before cleanup!

**Status**: ⚠️ **AWAITING STEP 1: RUN VERIFICATION SCRIPT**

---

**Documentation Generated**: 2025-11-03
**Generated By**: Claude Code Quality Analyzer
**Report Version**: 1.0
**PRD Version**: v9.6.1
