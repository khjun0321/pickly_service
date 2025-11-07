# Legacy Tables Backup Manifest
**Date**: 2025-11-03 06:34:21
**Backup Location**: /docs/history/db_backup_legacy_20251103/
**Container**: supabase_db_pickly_service
**Database**: postgres

---

## Backed Up Tables

### benefit_announcements
- **Exists**: t
- **Rows Backed Up**: 0
- **Files**:
  - `benefit_announcements_backup.csv` - Data dump
  - `benefit_announcements_schema.sql` - Schema definition
- **MD5 Checksum**: [0;34mℹ️  Backing up table: benefit_announcements[0m
[0;34mℹ️    Rows to backup: 0[0m
[0;34mℹ️    Exporting data to CSV...[0m
[0;34mℹ️    Exporting schema...[0m
[0;32m✅   Backup complete![0m
[0;34mℹ️    Files:[0m
[0;34mℹ️      - docs/history/db_backup_legacy_20251103/benefit_announcements_backup.csv (0 rows)[0m
[0;34mℹ️      - docs/history/db_backup_legacy_20251103/benefit_announcements_schema.sql[0m
[0;34mℹ️      - MD5: [0m
- **Reason**: Legacy table, possibly replaced by `announcements`

### housing_announcements
- **Exists**: t
- **Rows Backed Up**: 1
- **Files**:
  - `housing_announcements_backup.csv` - Data dump
  - `housing_announcements_schema.sql` - Schema definition
- **MD5 Checksum**: [0;34mℹ️  Backing up table: housing_announcements[0m
[0;34mℹ️    Rows to backup: 1[0m
[0;34mℹ️    Exporting data to CSV...[0m
[0;34mℹ️    Exporting schema...[0m
[0;32m✅   Backup complete![0m
[0;34mℹ️    Files:[0m
[0;34mℹ️      - docs/history/db_backup_legacy_20251103/housing_announcements_backup.csv (1 rows)[0m
[0;34mℹ️      - docs/history/db_backup_legacy_20251103/housing_announcements_schema.sql[0m
[0;34mℹ️      - MD5: [0m
- **Reason**: Legacy table, possibly old name before v7.3 renaming

### display_order_history
- **Exists**: t
- **Rows Backed Up**: 0
- **Files**:
  - `display_order_history_backup.csv` - Data dump
  - `display_order_history_schema.sql` - Schema definition
- **MD5 Checksum**: [0;34mℹ️  Backing up table: display_order_history[0m
[0;34mℹ️    Rows to backup: 0[0m
[0;34mℹ️    Exporting data to CSV...[0m
[0;34mℹ️    Exporting schema...[0m
[0;32m✅   Backup complete![0m
[0;34mℹ️    Files:[0m
[0;34mℹ️      - docs/history/db_backup_legacy_20251103/display_order_history_backup.csv (0 rows)[0m
[0;34mℹ️      - docs/history/db_backup_legacy_20251103/display_order_history_schema.sql[0m
[0;34mℹ️      - MD5: [0m
- **Reason**: Audit trail, may be archived

---

## Restoration Procedure

If cleanup causes issues, restore with:

```bash
# 1. Restore schema
docker exec -i supabase_db_pickly_service psql -U postgres -d postgres < \
  docs/history/db_backup_legacy_20251103/[table_name]_schema.sql

# 2. Copy CSV to container
docker cp docs/history/db_backup_legacy_20251103/[table_name]_backup.csv supabase_db_pickly_service:/tmp/

# 3. Restore data
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "COPY [table_name] FROM '/tmp/[table_name]_backup.csv' DELIMITER ',' CSV HEADER;"
```

---

## Verification

```bash
# Verify row count matches backup
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "SELECT COUNT(*) FROM [table_name];"

# Verify data integrity
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c \
  "SELECT * FROM [table_name] LIMIT 10;"
```

---

**Backup completed**: 2025-11-03 06:34:21
