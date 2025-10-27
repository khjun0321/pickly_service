# Database Documentation

> **Pickly Service** - Database Schema Documentation
> **Last Updated**: 2025.10.27

---

## Quick Links

- [Schema v2.0 Specification](./schema-v2.md) - 상세 스키마 문서
- [Migration Guide](./MIGRATION_GUIDE.md) - 마이그레이션 실행 가이드
- [Schema Changes Summary](./SCHEMA_CHANGES_SUMMARY.md) - 변경사항 요약
- [Schema Diagram](./schema-diagram.md) - ER 다이어그램
- [Quick Start Guide](./QUICKSTART.md) - 빠른 시작 가이드

---

## Database Schema Versions

### v2.0 (Current) - 2025.10.27

**New Features**:
- `announcement_types` table (공고 유형별 비용 정보)
- `announcement_sections` 확장 (커스텀 섹션 지원)
- `v_announcements_with_types` view (조인 최적화)

**Migration Files**:
- `20251027000002_add_announcement_types_and_custom_content.sql`
- `20251027000003_rollback_announcement_types.sql` (rollback)

**Documentation**:
- [Schema v2.0 Spec](./schema-v2.md)
- [Migration Guide](./MIGRATION_GUIDE.md)
- [Changes Summary](./SCHEMA_CHANGES_SUMMARY.md)

### v1.0 - 2025.10.27

**Initial Schema**:
- Core tables: `announcements`, `announcement_sections`, `announcement_tabs`
- Category system: `benefit_categories`, `benefit_subcategories`
- User system: `age_categories`, `user_profiles`
- Banner system: `category_banners`

**Migration Files**:
- `20251027000001_correct_schema.sql`

---

## Tables Overview

### Core Tables (v2.0)

| Table | Purpose | Rows (est.) |
|-------|---------|-------------|
| `announcements` | 공고 기본 정보 | 100-1000 |
| `announcement_types` | 유형별 비용 정보 | 500-5000 |
| `announcement_sections` | 모듈식 섹션 | 1000-10000 |
| `announcement_tabs` | 평형별 탭 정보 | 500-5000 |

### Category Tables

| Table | Purpose | Rows (est.) |
|-------|---------|-------------|
| `benefit_categories` | 혜택 카테고리 | 10-20 |
| `benefit_subcategories` | 서브 카테고리 | 50-100 |

### User Tables

| Table | Purpose | Rows (est.) |
|-------|---------|-------------|
| `age_categories` | 연령 카테고리 | 5-10 |
| `user_profiles` | 사용자 프로필 | 1000-100000 |

---

## Key Features

### 1. Modular Announcements

공고는 섹션 조합으로 구성:
- `basic_info`: 기본 정보
- `schedule`: 일정
- `eligibility`: 신청 자격
- `housing_info`: 단지 정보
- `location`: 위치
- `attachments`: 첨부 파일
- `custom`: 커스텀 섹션 (v2.0+)

### 2. Type-based Pricing

각 공고의 평형별 비용 정보:
- `announcement_types` 테이블
- 보증금/월세 정보
- 자격 조건

### 3. Custom Content

백오피스에서 자유롭게 섹션 추가:
- `is_custom` flag
- `custom_content` JSONB
- WYSIWYG 에디터 지원 (planned)

---

## Validation

### Check Schema Version

```sql
SELECT comment FROM pg_description
WHERE objoid = 'public'::regnamespace;
```

### Validate Tables

```bash
# Run validation script
psql -f backend/supabase/migrations/validate_schema_v2.sql
```

### Expected Output

```
✅ announcement_types exists
✅ announcement_sections.is_custom exists
✅ announcement_sections.custom_content exists
✅ idx_announcement_types_announcement exists
✅ v_announcements_with_types exists
✅ RLS policy on announcement_types exists
✅ Trigger update_announcement_types_updated_at exists
```

---

## Common Queries

### Get Announcement with Types

```sql
SELECT * FROM v_announcements_with_types
WHERE id = '123e4567-e89b-12d3-a456-426614174000';
```

### Get All Types for Announcement

```sql
SELECT * FROM announcement_types
WHERE announcement_id = '123e4567-e89b-12d3-a456-426614174000'
ORDER BY order_index;
```

### Get Custom Sections

```sql
SELECT * FROM announcement_sections
WHERE announcement_id = '123e4567-e89b-12d3-a456-426614174000'
  AND is_custom = true
ORDER BY display_order;
```

---

## Maintenance

### Backup

```bash
# Full backup
pg_dump -h [HOST] -U [USER] [DB] > backup_$(date +%Y%m%d).sql

# Schema only
pg_dump -h [HOST] -U [USER] --schema-only [DB] > schema_$(date +%Y%m%d).sql
```

### Restore

```bash
psql -h [HOST] -U [USER] -d [DB] < backup_20251027.sql
```

### Analyze Performance

```sql
-- Table sizes
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index usage
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
WHERE schemaname = 'public'
ORDER BY idx_scan DESC;
```

---

## Troubleshooting

### Q: Migration fails with "relation already exists"

**Solution**:
```sql
DROP TABLE IF EXISTS announcement_types CASCADE;
DROP VIEW IF EXISTS v_announcements_with_types;
-- Re-run migration
```

### Q: RLS prevents data access

**Solution**:
```sql
-- Check current policies
SELECT * FROM pg_policies WHERE tablename = 'announcement_types';

-- Disable RLS (dev only!)
ALTER TABLE announcement_types DISABLE ROW LEVEL SECURITY;
```

### Q: View returns empty results

**Solution**:
```sql
-- Check if announcements exist
SELECT COUNT(*) FROM announcements;

-- Check if types exist
SELECT COUNT(*) FROM announcement_types;

-- Manual join test
SELECT a.id, a.title, COUNT(at.id) as types_count
FROM announcements a
LEFT JOIN announcement_types at ON a.id = at.announcement_id
GROUP BY a.id, a.title;
```

---

## Related Documentation

- [PRD v7.0](/PRD.md)
- [Backend Development Guide](/docs/development/backend-guide.md)
- [Testing Guide](/docs/development/testing-guide.md)

---

## Support

For questions or issues:
1. Check [Troubleshooting Section](#troubleshooting)
2. Review [Migration Guide](./MIGRATION_GUIDE.md)
3. Contact Database Architect Agent

---

**Last Updated**: 2025.10.27
**Schema Version**: v2.0
**Migration**: `20251027000002`
