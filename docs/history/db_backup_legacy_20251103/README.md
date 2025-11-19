# Legacy Tables Backup Directory

**Created**: 2025-11-03
**Purpose**: Backup location for legacy database tables before cleanup
**Status**: 📁 **READY FOR BACKUPS**

---

## 📋 What Goes Here

This directory will contain backups of legacy database tables that don't align with PRD v9.6.1:

### Expected Files (After Running Backup Script)

**Data Backups (CSV)**:
- `benefit_announcements_backup.csv`
- `housing_announcements_backup.csv`
- `display_order_history_backup.csv`

**Schema Backups (SQL)**:
- `benefit_announcements_schema.sql`
- `housing_announcements_schema.sql`
- `display_order_history_schema.sql`

**Documentation**:
- `BACKUP_MANIFEST.md` - Backup metadata and restoration guide

---

## 🚀 How to Create Backups

### Option 1: Automated Backup Script (Recommended)

```bash
# Run from project root
./scripts/backup_legacy_tables.sh
```

This script will:
- ✅ Check which tables exist
- ✅ Export data to CSV
- ✅ Export schemas to SQL
- ✅ Calculate MD5 checksums
- ✅ Create backup manifest
- ✅ Provide restoration instructions

### Option 2: Manual Backup

See detailed instructions in `docs/DB_LEGACY_CLEANUP_REPORT.md` section "Backup Plan"

---

## 🔄 How to Restore from Backups

If cleanup causes issues, restore with:

### Step 1: Restore Schema
```bash
docker exec -i supabase_db_pickly_service psql -U postgres -d postgres < \
  docs/history/db_backup_legacy_20251103/[table_name]_schema.sql
```

### Step 2: Restore Data
```bash
# Copy CSV to container
docker cp docs/history/db_backup_legacy_20251103/[table_name]_backup.csv \
  supabase_db_pickly_service:/tmp/

# Import data
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "COPY [table_name] FROM '/tmp/[table_name]_backup.csv' DELIMITER ',' CSV HEADER;"
```

### Step 3: Verify
```bash
# Check row count
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "SELECT COUNT(*) FROM [table_name];"
```

---

## 📊 Backup Status

Run `./scripts/backup_legacy_tables.sh` to populate this directory.

**Current Status**: ⏳ **Awaiting backup creation**

---

## 📚 Related Documentation

- **Main Analysis**: `docs/DB_LEGACY_CLEANUP_REPORT.md`
- **Quick Summary**: `docs/LEGACY_TABLES_CLEANUP_SUMMARY.md`
- **Verification Script**: `scripts/verify_legacy_tables.sql`
- **Backup Script**: `scripts/backup_legacy_tables.sh`

---

## ⚠️ Important Notes

1. **DO NOT delete this directory** until cleanup is verified successful
2. **Keep backups for at least 30 days** after cleanup
3. **Verify MD5 checksums** before using backups for restoration
4. **Test restoration** in local environment before production

---

**This directory is part of the PRD v9.6.1 database cleanup initiative.**
