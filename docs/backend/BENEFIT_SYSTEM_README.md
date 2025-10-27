# Benefit Announcement System - Backend Database

**Status**: ✅ **PRODUCTION READY**
**Version**: 1.0.0
**Migration Date**: 2025-10-23
**Database**: PostgreSQL (Supabase)

---

## 🎯 Overview

The Benefit Announcement System is a comprehensive database schema designed to manage and deliver government benefit information to users. The system supports multiple benefit categories, detailed announcements, housing unit types, custom sections, user comments, and AI-powered chatbot interactions.

---

## 📦 What's Included

### Database Tables (6)
1. **benefit_categories** - Benefit categories (주거, 복지, 교육, 취업, 건강, 문화)
2. **benefit_announcements** - Main announcement information
3. **announcement_unit_types** - Housing unit details (평수별 정보)
4. **announcement_sections** - Custom sections (eligibility, documents, etc.)
5. **announcement_comments** - User comments and discussions
6. **announcement_ai_chats** - AI chatbot conversations

### Utility Views (3)
1. **v_published_announcements** - Published announcements with category info
2. **v_featured_announcements** - Featured announcements for homepage
3. **v_announcement_stats** - Category-wise statistics

### Features
- ✅ Full-text search (Korean + English)
- ✅ Row Level Security (RLS) policies
- ✅ Auto-updating timestamps
- ✅ Tag-based categorization
- ✅ Flexible JSONB data structures
- ✅ Nested comment threads
- ✅ View count tracking
- ✅ Application period validation
- ✅ Comprehensive indexing (36 indexes)
- ✅ Soft deletion support

---

## 🚀 Quick Start

### 1. Verify Installation
```bash
# Check if migration was applied
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c "\dt" | grep benefit

# Expected output:
# benefit_announcements
# benefit_categories
# announcement_unit_types
# announcement_sections
# announcement_comments
# announcement_ai_chats
```

### 2. View Initial Data
```bash
# Check categories
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c "SELECT name, slug FROM benefit_categories ORDER BY display_order;"
```

### 3. Access Supabase Studio
```
URL: http://localhost:54323
Database: postgres
Port: 54322
```

---

## 📖 Documentation

### Comprehensive Guides
1. **[Migration Report](./benefit_system_migration_report.md)** - Detailed migration documentation
2. **[API Guide](./benefit_system_api_guide.md)** - SQL queries and usage examples

### Quick Reference

#### Get Published Announcements
```sql
SELECT * FROM v_published_announcements
WHERE category_slug = 'housing'
ORDER BY published_at DESC
LIMIT 20;
```

#### Full-Text Search
```sql
SELECT * FROM benefit_announcements
WHERE search_vector @@ plainto_tsquery('simple', '청년 주거')
AND status = 'published';
```

#### Get Featured Content
```sql
SELECT * FROM v_featured_announcements;
```

---

## 🏗️ Schema Architecture

```
benefit_categories
    ├── id (UUID, PK)
    ├── name (주거, 복지, 교육, 취업, 건강, 문화)
    ├── slug (housing, welfare, education, etc.)
    └── display_order
        ↓
benefit_announcements
    ├── id (UUID, PK)
    ├── category_id (FK)
    ├── title, subtitle, organization
    ├── application_period (start/end dates)
    ├── status (draft, published, closed, archived)
    ├── tags (array)
    ├── search_vector (full-text search)
    └── views_count
        ├──→ announcement_unit_types (평수 정보)
        │       ├── unit_type (59㎡, 84㎡, etc.)
        │       ├── exclusive_area, supply_area
        │       └── sale_price, monthly_rent
        │
        ├──→ announcement_sections (커스텀 섹션)
        │       ├── section_type (eligibility, documents, etc.)
        │       ├── title, content
        │       └── structured_data (JSONB)
        │
        ├──→ announcement_comments (댓글)
        │       ├── user_id, content
        │       ├── parent_comment_id (nested)
        │       └── moderation_status
        │
        └──→ announcement_ai_chats (AI 챗봇)
                ├── session_id
                ├── role (user/assistant/system)
                └── context_data (JSONB)
```

---

## 🔒 Security

### Row Level Security (RLS)
All tables have RLS enabled with appropriate policies:

**Public Access (No Authentication)**
- ✅ Read published announcements
- ✅ Read active categories
- ✅ Read approved comments
- ✅ Read visible sections

**Authenticated Users**
- ✅ Create, read, update, delete their own comments
- ✅ Create and read their own AI chat sessions

**Admin Operations**
- Requires service role key or custom admin policies
- Create/update/delete announcements
- Moderate comments
- Manage categories

---

## 📊 Performance

### Optimization Features
- **36 Indexes** for fast queries
- **GIN Indexes** for full-text search, JSONB, and arrays
- **Partial Indexes** for filtered queries (featured, published, active)
- **Composite Indexes** for multi-column queries
- **Trigger-based** auto-updates (no application logic needed)

### Expected Performance
- Category listing: <10ms
- Announcement search: <50ms (with full-text search)
- Single announcement fetch: <20ms
- Comment listing: <30ms

---

## 🧪 Testing

### Verify Database Health
```bash
# Run comprehensive verification
docker exec supabase_db_pickly_service psql -U postgres -d postgres -c "
SELECT 'Tables' as item, COUNT(*) as count
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name LIKE '%benefit%' OR table_name LIKE '%announcement%'
UNION ALL
SELECT 'Views', COUNT(*)
FROM information_schema.views
WHERE table_schema = 'public'
AND table_name LIKE 'v_%'
UNION ALL
SELECT 'Categories', COUNT(*)
FROM benefit_categories;
"
```

### Test Data Insertion
```sql
-- Insert test announcement
BEGIN;

INSERT INTO benefit_announcements (
    category_id,
    title,
    organization,
    status,
    summary
) VALUES (
    (SELECT id FROM benefit_categories WHERE slug = 'housing'),
    'Test Announcement',
    'Test Organization',
    'published',
    'Test summary'
) RETURNING id;

COMMIT;
```

---

## 🔄 Migration Management

### Migration File
**Location**: `/supabase/migrations/20251024000000_benefit_system.sql`

### Apply Migration (If Needed)
```bash
# Copy to container
docker cp /path/to/migration.sql supabase_db_pickly_service:/tmp/migration.sql

# Execute
docker exec supabase_db_pickly_service psql -U postgres -d postgres -f /tmp/migration.sql
```

### Rollback (If Needed)
```sql
-- Drop all tables (CASCADE will remove related objects)
DROP TABLE IF EXISTS benefit_categories CASCADE;
DROP TABLE IF EXISTS benefit_announcements CASCADE;
DROP TABLE IF EXISTS announcement_unit_types CASCADE;
DROP TABLE IF EXISTS announcement_sections CASCADE;
DROP TABLE IF EXISTS announcement_comments CASCADE;
DROP TABLE IF EXISTS announcement_ai_chats CASCADE;

-- Drop views
DROP VIEW IF EXISTS v_published_announcements;
DROP VIEW IF EXISTS v_featured_announcements;
DROP VIEW IF EXISTS v_announcement_stats;

-- Drop functions
DROP FUNCTION IF EXISTS update_updated_at_column();
DROP FUNCTION IF EXISTS update_announcement_search_vector();
```

---

## 📈 Future Enhancements

### Planned Features
1. **Notification System**
   - User subscriptions to categories/announcements
   - Email/push notifications for new announcements
   - Application deadline reminders

2. **Advanced Search**
   - Faceted search with multiple filters
   - Geographic search (region-based)
   - Income-based eligibility matching

3. **User Engagement**
   - Bookmarks/favorites
   - Share functionality
   - Application tracking

4. **Analytics**
   - User behavior tracking
   - Popular announcements
   - Search query analysis
   - Conversion metrics

5. **Admin Dashboard**
   - Announcement management UI
   - Comment moderation tools
   - Analytics dashboard
   - Bulk import/export

---

## 🛠️ Maintenance

### Regular Tasks
- **Daily**: Monitor query performance
- **Weekly**: Review comment moderation queue
- **Monthly**: Analyze search patterns, optimize indexes
- **Quarterly**: Archive old announcements

### Monitoring Queries
```sql
-- Check database size
SELECT pg_size_pretty(pg_database_size('postgres'));

-- Check table sizes
SELECT
    schemaname,
    tablename,
    pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Check index usage
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

## 📞 Support & Resources

### Documentation
- [Migration Report](./benefit_system_migration_report.md) - Full technical details
- [API Guide](./benefit_system_api_guide.md) - SQL query examples
- [Supabase Docs](https://supabase.com/docs) - Official documentation

### Database Access
- **Supabase Studio**: http://localhost:54323
- **PostgreSQL Port**: 54322
- **REST API**: http://localhost:54321

### Common Issues

**Issue**: RLS policies blocking queries
**Solution**: Use service role key or add appropriate policies

**Issue**: Slow full-text search
**Solution**: Ensure pg_trgm extension is installed and indexes exist

**Issue**: Migration already applied error
**Solution**: Check `supabase_migrations.schema_migrations` table

---

## ✅ Verification Checklist

- [x] All 6 tables created
- [x] All 3 views created
- [x] 6 initial categories inserted
- [x] 36 indexes created
- [x] RLS enabled on all tables
- [x] 10 RLS policies configured
- [x] 7 triggers created
- [x] Full-text search enabled
- [x] JSONB support enabled
- [x] Documentation complete

---

## 📝 Changelog

### Version 1.0.0 (2025-10-23)
- ✅ Initial schema creation
- ✅ 6 tables with comprehensive constraints
- ✅ Full-text search implementation
- ✅ RLS policies for security
- ✅ Utility views for common queries
- ✅ Trigger-based auto-updates
- ✅ JSONB support for flexible data
- ✅ Initial 6 categories seeded

---

**Database Schema Version**: 1.0.0
**Migration ID**: 20251024000000
**Status**: ✅ Production Ready
**Last Updated**: 2025-10-23

---

**Need help?** Check the [API Guide](./benefit_system_api_guide.md) or [Migration Report](./benefit_system_migration_report.md) for detailed information.
