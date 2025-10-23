# Benefit System API Guide

Quick reference for working with the benefit announcement system database.

---

## 🗄️ Database Schema Overview

```
benefit_categories (카테고리)
    ↓ (1:N)
benefit_announcements (공고)
    ↓ (1:N)
    ├── announcement_unit_types (평수별 정보)
    ├── announcement_sections (커스텀 섹션)
    ├── announcement_comments (댓글)
    └── announcement_ai_chats (AI 챗봇)
```

---

## 📊 Common Queries

### Get All Active Categories
```sql
SELECT *
FROM benefit_categories
WHERE is_active = TRUE
ORDER BY display_order;
```

### Get Published Announcements by Category
```sql
SELECT *
FROM benefit_announcements
WHERE category_id = 'CATEGORY_UUID'
AND status = 'published'
ORDER BY published_at DESC;
```

### Get Featured Announcements
```sql
-- Using view
SELECT * FROM v_featured_announcements;

-- Or direct query
SELECT *
FROM benefit_announcements
WHERE status = 'published'
AND is_featured = TRUE
ORDER BY published_at DESC
LIMIT 10;
```

### Full-Text Search
```sql
-- Search in title, subtitle, summary, organization, and tags
SELECT *
FROM benefit_announcements
WHERE search_vector @@ plainto_tsquery('simple', '주거 지원')
AND status = 'published'
ORDER BY ts_rank(search_vector, plainto_tsquery('simple', '주거 지원')) DESC;
```

### Get Announcement with All Details
```sql
-- Get announcement with category
SELECT
    a.*,
    c.name as category_name,
    c.slug as category_slug
FROM benefit_announcements a
JOIN benefit_categories c ON a.category_id = c.id
WHERE a.id = 'ANNOUNCEMENT_UUID';

-- Get announcement with unit types
SELECT
    a.title,
    u.unit_type,
    u.exclusive_area,
    u.sale_price,
    u.monthly_rent
FROM benefit_announcements a
LEFT JOIN announcement_unit_types u ON a.id = u.announcement_id
WHERE a.id = 'ANNOUNCEMENT_UUID'
ORDER BY u.display_order;

-- Get announcement with sections
SELECT
    a.title,
    s.section_type,
    s.title as section_title,
    s.content,
    s.structured_data
FROM benefit_announcements a
LEFT JOIN announcement_sections s ON a.id = s.announcement_id
WHERE a.id = 'ANNOUNCEMENT_UUID'
AND s.is_visible = TRUE
ORDER BY s.display_order;
```

### Get Category Statistics
```sql
-- Using view
SELECT * FROM v_announcement_stats;

-- Or custom query
SELECT
    c.name,
    COUNT(a.id) as total,
    COUNT(CASE WHEN a.status = 'published' THEN 1 END) as published,
    SUM(a.views_count) as total_views
FROM benefit_categories c
LEFT JOIN benefit_announcements a ON c.id = a.category_id
GROUP BY c.id, c.name
ORDER BY c.display_order;
```

### Get Active Announcements (Application Period)
```sql
SELECT *
FROM benefit_announcements
WHERE status = 'published'
AND application_period_start <= CURRENT_DATE
AND application_period_end >= CURRENT_DATE
ORDER BY application_period_end ASC;
```

---

## 📝 Insert Operations

### Insert New Announcement
```sql
INSERT INTO benefit_announcements (
    category_id,
    title,
    subtitle,
    organization,
    application_period_start,
    application_period_end,
    status,
    summary,
    tags
) VALUES (
    (SELECT id FROM benefit_categories WHERE slug = 'housing'),
    '2024 행복주택 입주자 모집',
    '청년·신혼부부 대상',
    'LH 한국토지주택공사',
    '2024-11-01',
    '2024-11-15',
    'published',
    '청년 및 신혼부부를 위한 행복주택 입주자를 모집합니다.',
    ARRAY['청년', '신혼부부', '임대주택']
) RETURNING id;
```

### Insert Unit Types (Housing)
```sql
INSERT INTO announcement_unit_types (
    announcement_id,
    unit_type,
    exclusive_area,
    supply_area,
    unit_count,
    monthly_rent,
    deposit_amount,
    display_order
) VALUES
    ('ANNOUNCEMENT_UUID', '59㎡', 59.00, 79.00, 100, 350000, 5000000, 1),
    ('ANNOUNCEMENT_UUID', '74㎡', 74.00, 94.00, 80, 450000, 7000000, 2),
    ('ANNOUNCEMENT_UUID', '84㎡', 84.00, 104.00, 50, 550000, 9000000, 3);
```

### Insert Custom Sections
```sql
-- Eligibility section
INSERT INTO announcement_sections (
    announcement_id,
    section_type,
    title,
    content,
    structured_data,
    display_order
) VALUES (
    'ANNOUNCEMENT_UUID',
    'eligibility',
    '신청자격',
    '다음 조건을 모두 충족하는 자',
    '{
        "requirements": [
            "만 19세 이상 39세 이하의 청년",
            "무주택 세대구성원",
            "월평균소득이 전년도 도시근로자 가구당 월평균소득의 100% 이하"
        ]
    }'::jsonb,
    1
);

-- Documents section
INSERT INTO announcement_sections (
    announcement_id,
    section_type,
    title,
    content,
    structured_data,
    display_order
) VALUES (
    'ANNOUNCEMENT_UUID',
    'documents',
    '제출서류',
    '다음 서류를 준비하세요',
    '{
        "documents": [
            {"name": "주민등록등본", "required": true},
            {"name": "가족관계증명서", "required": true},
            {"name": "소득증빙서류", "required": true},
            {"name": "무주택확인서", "required": false}
        ]
    }'::jsonb,
    2
);
```

---

## 🔄 Update Operations

### Increment View Count
```sql
UPDATE benefit_announcements
SET views_count = views_count + 1
WHERE id = 'ANNOUNCEMENT_UUID';
```

### Publish Announcement
```sql
UPDATE benefit_announcements
SET status = 'published',
    published_at = NOW()
WHERE id = 'ANNOUNCEMENT_UUID';
```

### Close Announcement
```sql
UPDATE benefit_announcements
SET status = 'closed'
WHERE id = 'ANNOUNCEMENT_UUID';
```

### Update Search Tags
```sql
UPDATE benefit_announcements
SET tags = ARRAY['청년', '신혼부부', '임대주택', '행복주택']
WHERE id = 'ANNOUNCEMENT_UUID';
-- Note: search_vector will be auto-updated by trigger
```

---

## 🗑️ Delete Operations

### Soft Delete Comment
```sql
UPDATE announcement_comments
SET is_deleted = TRUE,
    deleted_at = NOW()
WHERE id = 'COMMENT_UUID'
AND user_id = 'USER_UUID';
```

### Delete Announcement (Cascade)
```sql
-- This will also delete related unit_types, sections, comments (CASCADE)
DELETE FROM benefit_announcements
WHERE id = 'ANNOUNCEMENT_UUID';
```

---

## 💬 Comment Operations

### Get Comments for Announcement
```sql
SELECT
    c.*,
    (SELECT COUNT(*) FROM announcement_comments WHERE parent_comment_id = c.id) as reply_count
FROM announcement_comments c
WHERE c.announcement_id = 'ANNOUNCEMENT_UUID'
AND c.is_deleted = FALSE
AND c.moderation_status = 'approved'
AND c.parent_comment_id IS NULL
ORDER BY c.created_at DESC;
```

### Get Replies to Comment
```sql
SELECT *
FROM announcement_comments
WHERE parent_comment_id = 'PARENT_COMMENT_UUID'
AND is_deleted = FALSE
AND moderation_status = 'approved'
ORDER BY created_at ASC;
```

### Insert Comment
```sql
INSERT INTO announcement_comments (
    announcement_id,
    user_id,
    content,
    moderation_status
) VALUES (
    'ANNOUNCEMENT_UUID',
    auth.uid(), -- Current authenticated user
    '좋은 혜택이네요!',
    'pending'
) RETURNING id;
```

---

## 🤖 AI Chat Operations

### Get Chat History
```sql
SELECT *
FROM announcement_ai_chats
WHERE session_id = 'SESSION_UUID'
ORDER BY created_at ASC;
```

### Insert Chat Message
```sql
INSERT INTO announcement_ai_chats (
    announcement_id,
    user_id,
    session_id,
    role,
    content,
    model_name
) VALUES (
    'ANNOUNCEMENT_UUID',
    auth.uid(),
    'SESSION_UUID',
    'user',
    '이 공고의 신청 자격이 어떻게 되나요?',
    NULL
) RETURNING id;
```

---

## 🔍 Advanced Queries

### Search with Multiple Filters
```sql
SELECT *
FROM benefit_announcements
WHERE status = 'published'
AND category_id = 'CATEGORY_UUID'
AND application_period_end >= CURRENT_DATE
AND search_vector @@ plainto_tsquery('simple', '청년')
ORDER BY views_count DESC
LIMIT 20;
```

### Get Trending Announcements
```sql
SELECT *
FROM benefit_announcements
WHERE status = 'published'
AND published_at >= NOW() - INTERVAL '30 days'
ORDER BY views_count DESC
LIMIT 10;
```

### Get Announcements Expiring Soon
```sql
SELECT *
FROM benefit_announcements
WHERE status = 'published'
AND application_period_end BETWEEN CURRENT_DATE AND CURRENT_DATE + INTERVAL '7 days'
ORDER BY application_period_end ASC;
```

### Get Announcements by Tag
```sql
SELECT *
FROM benefit_announcements
WHERE status = 'published'
AND '청년' = ANY(tags)
ORDER BY published_at DESC;
```

---

## 🔒 RLS Policy Notes

### Public Access (No Auth Required)
- ✅ Read published announcements
- ✅ Read active categories
- ✅ Read unit types of published announcements
- ✅ Read visible sections of published announcements
- ✅ Read approved comments

### Authenticated Users
- ✅ Insert/Update/Delete their own comments
- ✅ Insert their own AI chat messages
- ✅ Read their own AI chat history

### Admin Access
For admin operations (create/update announcements), you'll need to:
1. Create admin role in Supabase Auth
2. Add RLS policies for admin users
3. Or use service role key (bypass RLS)

---

## 📊 Performance Tips

### Use Prepared Statements
```javascript
// Supabase JS Client Example
const { data, error } = await supabase
  .from('benefit_announcements')
  .select('*')
  .eq('category_id', categoryId)
  .eq('status', 'published')
  .order('published_at', { ascending: false })
  .limit(20);
```

### Use Views for Common Queries
```sql
-- Instead of complex joins, use the pre-built views
SELECT * FROM v_published_announcements
WHERE category_slug = 'housing'
LIMIT 20;
```

### Index Usage
- Search by category: Uses `idx_announcements_category`
- Search by status: Uses `idx_announcements_status`
- Full-text search: Uses `idx_announcements_search`
- Sort by date: Uses `idx_announcements_published_at`
- Filter by tags: Uses `idx_announcements_tags`

---

## 🧪 Testing Queries

### Create Test Data
```sql
-- Use the seed data script or insert manually
BEGIN;

-- Insert test announcement
INSERT INTO benefit_announcements (
    category_id,
    title,
    organization,
    status,
    summary,
    tags
) VALUES (
    (SELECT id FROM benefit_categories WHERE slug = 'housing'),
    'Test 주거 혜택',
    'Test 기관',
    'published',
    'Test 설명',
    ARRAY['test']
) RETURNING id;

COMMIT;
```

### Verify Triggers
```sql
-- Test updated_at trigger
SELECT title, created_at, updated_at
FROM benefit_announcements
WHERE id = 'ANNOUNCEMENT_UUID';

-- Make update
UPDATE benefit_announcements
SET title = 'Updated Title'
WHERE id = 'ANNOUNCEMENT_UUID';

-- Check updated_at changed
SELECT title, created_at, updated_at
FROM benefit_announcements
WHERE id = 'ANNOUNCEMENT_UUID';

-- Test search_vector trigger
SELECT title, search_vector
FROM benefit_announcements
WHERE id = 'ANNOUNCEMENT_UUID';
```

---

## 🔗 Related Files

- **Migration**: `/supabase/migrations/20251024000000_benefit_system.sql`
- **Report**: `/docs/backend/benefit_system_migration_report.md`
- **Schema Diagram**: (To be created)

---

## 📞 Need Help?

- Check table structure: `\d+ table_name`
- Check indexes: `\di`
- Check constraints: `\d+ table_name` (see "Check constraints" section)
- Check RLS policies: `\d+ table_name` (see "Policies" section)
- Supabase Studio: http://localhost:54323
- PostgreSQL: Port 54322

---

**Happy coding!** 🚀
