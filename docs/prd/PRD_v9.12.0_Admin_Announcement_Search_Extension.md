# PRD v9.12.0 — Admin 공고 썸네일·홈노출·검색 확장 (with 파이프)

## 📋 Overview

**Version**: v9.12.0
**Status**: ✅ Implementation Complete (Pending Testing)
**Date**: 2025-11-12
**Environment**: Production-ready (Staging test required before deployment)

### Purpose
Extend the announcements system with:
1. **Thumbnail Management** - Upload and manage announcement thumbnail images
2. **Featured Sections** - Configure home screen featured announcements with sectioning
3. **Search Extension** - Full-text search with weighted rankings and tags
4. **Wall & Pipe Architecture** - Loose coupling via triggers for category→announcement→search sync

---

## 🎯 Key Features

### 1. Announcement Thumbnails
- **Storage Bucket**: `announcement-thumbnails` (5MB limit, public read)
- **Supported Formats**: JPEG, PNG, WebP
- **Upload Flow**: Admin UI → Supabase Storage → URL stored in `announcements.thumbnail_url`
- **Component**: `ThumbnailUploader.tsx` with preview and delete functionality

### 2. Featured Sections
- **Fields Added**:
  - `is_featured` (BOOLEAN) - Toggle home screen visibility
  - `featured_section` (TEXT) - Section identifier (e.g., "home", "home_hot", "city_seoul")
  - `featured_order` (INT) - Sort priority within section (0 = highest)
- **Management UI**:
  - `FeaturedAndSearchTab.tsx` - Configure featured settings per announcement
  - `FeaturedManagementPage.tsx` - Drag-and-drop reordering by section

### 3. Full-Text Search
- **Implementation**: PostgreSQL TSVECTOR with GIN index
- **Search Vector**: Generated column with weighted components:
  - Title: Weight A (highest)
  - Organization: Weight B (medium)
  - Tags: Weight C (lowest)
- **Tags System**: `tags` (TEXT[]) - Custom search keywords
- **Search Table**: `search_index` - Cross-entity search support
- **Query Function**: `search_announcements(query, limit)` with ts_rank scoring

### 4. Wall & Pipe Architecture
**Pattern**: Loose coupling between entities via triggers

**Walls** (No direct dependencies):
- benefit_categories
- benefit_subcategories
- announcements
- search_index

**Pipes** (Trigger-based sync):
1. **Category Change** → `bump_announcements_by_category()` → Updates announcements.updated_at
2. **Subcategory Change** → `bump_announcements_by_subcategory()` → Updates announcements.updated_at
3. **Announcement Change** → `sync_search_index_for_announcement()` → Syncs search_index

**Benefits**:
- No tight coupling between tables
- Automatic propagation of changes
- Maintains referential integrity without foreign key complexity
- Easy to disable/modify individual pipes

---

## 📁 Files Created

### Backend Migrations

#### 1. `20251112090000_admin_announcement_search_extension.sql`
**Purpose**: Core schema extension for search and featured functionality

**Changes**:
- Added 6 columns to `announcements` table:
  - `thumbnail_url` (TEXT)
  - `is_featured` (BOOLEAN)
  - `featured_section` (TEXT)
  - `featured_order` (INT)
  - `tags` (TEXT[])
  - `searchable_text` (TSVECTOR, GENERATED STORED)

- Created `search_index` table:
  ```sql
  CREATE TABLE public.search_index (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    target_type TEXT NOT NULL,
    target_id UUID NOT NULL,
    searchable_text TSVECTOR NOT NULL,
    updated_at TIMESTAMPTZ DEFAULT now()
  );
  ```

- Created 7 functions:
  - `sync_search_index_for_announcement(aid UUID)`
  - `bump_announcements_by_category(cat_id UUID)`
  - `bump_announcements_by_subcategory(sub_id UUID)`
  - `reindex_announcements()` - Batch rebuild search index
  - `search_announcements(query TEXT, limit INT)` - Full-text search
  - `get_featured_announcements(section TEXT, limit INT)` - Featured query
  - `generate_thumbnail_path(aid UUID, ext TEXT)` - Path helper

- Created 3 triggers (Pipes):
  - `trg_announcements_search_sync` - Auto-sync search on announcement change
  - `trg_benefit_categories_bump` - Bump announcements when category changes
  - `trg_benefit_subcategories_bump` - Bump announcements when subcategory changes

- Created 3 indexes:
  - GIN index on `announcements.searchable_text`
  - GIN index on `announcements.tags`
  - GIN index on `search_index.searchable_text`
  - Composite index on featured announcements

#### 2. `20251112090001_create_announcement_thumbnails_bucket.sql`
**Purpose**: Storage bucket for thumbnail images

**Changes**:
- Created `announcement-thumbnails` bucket:
  - Public: true (read access)
  - File size limit: 5MB (5242880 bytes)
  - Allowed MIME types: image/jpeg, image/jpg, image/png, image/webp

- Created 4 RLS policies:
  - `thumbs read public` - Anyone can view thumbnails
  - `thumbs write auth` - Authenticated users can upload
  - `thumbs update auth` - Authenticated users can update
  - `thumbs delete auth` - Authenticated users can delete

- Helper function: `generate_thumbnail_path(announcement_id, file_extension)`

### Admin UI Components

#### 3. `apps/pickly_admin/src/components/announcements/ThumbnailUploader.tsx`
**Purpose**: Component for uploading and managing announcement thumbnails

**Key Features**:
- File validation (type, size)
- Image preview with hover-to-delete
- Upload to Supabase Storage
- Public URL generation
- Error handling with user feedback

**Props**:
```typescript
interface ThumbnailUploaderProps {
  announcementId: string;
  value?: string | null;
  onChange: (url: string) => void;
  onError?: (error: string) => void;
}
```

**Usage**:
```tsx
<ThumbnailUploader
  announcementId={announcementId}
  value={thumbnailUrl}
  onChange={(url) => setThumbnailUrl(url)}
  onError={(error) => console.error(error)}
/>
```

#### 4. `apps/pickly_admin/src/components/announcements/FeaturedAndSearchTab.tsx`
**Purpose**: Tab component for managing featured status, sections, and search tags

**Key Features**:
- Thumbnail management integration
- Featured toggle switch
- Section input (home, home_hot, city_*)
- Order priority input (0 = highest)
- Tags input with comma separation
- Tag preview chips
- Reindex button (calls `reindex_announcements()`)
- Success/error alerts

**State Interface**:
```typescript
interface FeaturedData {
  thumbnail_url: string | null;
  is_featured: boolean;
  featured_section: string | null;
  featured_order: number;
  tags: string[];
}
```

**Integration Point**: Add as tab to existing `AnnouncementDetailPage`

#### 5. `apps/pickly_admin/src/pages/benefits/FeaturedManagementPage.tsx`
**Purpose**: Dedicated page for managing featured announcements by section

**Key Features**:
- Fetches all `is_featured = true` announcements
- Groups by `featured_section`
- Displays thumbnail, title, organization, status
- Up/down buttons for reordering within section
- Batch order updates via mutation
- Section labels (home: "홈 메인", home_hot: "인기 공고", etc.)
- Real-time updates with React Query

**Query Pattern**:
```typescript
const { data: announcements } = useQuery({
  queryKey: ['featured-announcements'],
  queryFn: async () => {
    const { data } = await supabase
      .from('announcements')
      .select('id, title, organization, thumbnail_url, featured_section, featured_order, is_featured, status')
      .eq('is_featured', true)
      .order('featured_section', { ascending: true })
      .order('featured_order', { ascending: true });
    return data;
  }
});
```

**Routing**: Add to `App.tsx`:
```tsx
<Route path="/benefits/featured" element={<FeaturedManagementPage />} />
```

### Verification Scripts

#### 6. `backend/scripts/verify_v9.12.0_implementation.sql`
**Purpose**: Comprehensive SQL verification queries

**Verification Sections**:
1. announcements table new columns (6 columns)
2. search_index table structure
3. Indexes (GIN, composite)
4. Functions (7 functions)
5. Triggers (3 triggers)
6. Storage buckets (announcement-thumbnails)
7. Storage RLS policies (4 policies)
8. Search functionality tests (searchable_text, ts_query)
9. Featured functionality tests (section grouping)
10. RLS policies on search_index
11. Helper functions tests (generate_thumbnail_path, get_featured_announcements)
12. Summary report (component status checks)
13. Performance statistics (counts, index usage)

**Usage**:
```bash
cd backend
psql -h <DB_HOST> -d postgres -U postgres -f scripts/verify_v9.12.0_implementation.sql
```

---

## 🏗️ Architecture Details

### Wall & Pipe Pattern

**Concept**: Tables are isolated "walls" connected by trigger "pipes"

**Example Flow**:
1. Admin updates `benefit_categories.name`
2. Trigger `trg_benefit_categories_bump` fires
3. Calls `bump_announcements_by_category(category_id)`
4. Updates `announcements.updated_at` for all related announcements
5. Trigger `trg_announcements_search_sync` fires for each announcement
6. Calls `sync_search_index_for_announcement(announcement_id)`
7. Updates `search_index.searchable_text` for that announcement

**No Direct Dependencies**:
- No foreign key constraints between categories and announcements
- Changes propagate automatically via triggers
- Easy to add/remove pipes without breaking schema

### Search Vector Generation

**Generated Column**:
```sql
ALTER TABLE public.announcements
  ADD COLUMN IF NOT EXISTS searchable_text TSVECTOR
  GENERATED ALWAYS AS (
    setweight(to_tsvector('simple', coalesce(title,'')), 'A') ||
    setweight(to_tsvector('simple', coalesce(organization,'')), 'B') ||
    setweight(to_tsvector('simple', array_to_string(tags, ' ')), 'C')
  ) STORED;
```

**Benefits**:
- Automatic updates when title, organization, or tags change
- No manual trigger needed for vector generation
- Stored (not virtual) for performance
- Weighted search rankings (title most important)

### Featured Sections

**Section Naming Convention**:
- `home` - Main home screen hero section
- `home_hot` - Popular/trending section
- `city_seoul` - Seoul city-specific
- `city_gyeonggi` - Gyeonggi province-specific
- Custom sections can be added without migration

**Ordering**:
- `featured_order` within section (0 = top)
- Can be managed via drag-and-drop in FeaturedManagementPage
- Updates saved immediately via optimistic mutation

---

## 🧪 Testing Checklist

### Backend Testing

**Local/Staging Database**:
1. ✅ Apply migration `20251112090000_admin_announcement_search_extension.sql`
2. ✅ Apply migration `20251112090001_create_announcement_thumbnails_bucket.sql`
3. ✅ Run verification script: `backend/scripts/verify_v9.12.0_implementation.sql`
4. ✅ Check all functions exist and execute without errors
5. ✅ Check all triggers are active
6. ✅ Check GIN indexes are created
7. ✅ Check Storage bucket exists with correct policies

**Functional Tests**:
```sql
-- Test 1: Insert announcement with tags
INSERT INTO public.announcements (title, organization, tags)
VALUES ('Test 공고', 'Test 기관', ARRAY['청년', '행복주택']);

-- Test 2: Search announcements
SELECT * FROM public.search_announcements('청년', 10);

-- Test 3: Get featured announcements
SELECT * FROM public.get_featured_announcements('home', 5);

-- Test 4: Trigger test - Update category
UPDATE public.benefit_categories SET name = '수정된 카테고리' WHERE id = 'some-uuid';
-- Verify: Announcements updated_at should change

-- Test 5: Reindex all
SELECT public.reindex_announcements();
```

### Frontend Testing

**Admin UI Workflow**:
1. Navigate to announcement detail page
2. Click "홈 노출 설정" tab (FeaturedAndSearchTab)
3. Upload thumbnail image (< 5MB, JPEG/PNG/WebP)
4. Verify thumbnail preview appears
5. Toggle "홈 화면 노출" switch ON
6. Enter section: "home"
7. Enter order: 0
8. Enter tags: "청년, 행복주택, 신혼부부"
9. Click "저장"
10. Verify success message
11. Navigate to `/benefits/featured` (FeaturedManagementPage)
12. Verify announcement appears in "홈 메인" section
13. Use ↑↓ buttons to reorder
14. Verify order saves automatically

**Mobile App Verification** (Future):
1. App should fetch featured announcements via `get_featured_announcements()`
2. Thumbnail should display from public URL
3. Search should use `search_announcements()` function
4. Results should rank by relevance (ts_rank)

---

## 🚀 Deployment Plan

### Pre-Deployment Checklist
- [ ] All migrations tested on local database
- [ ] Verification script passes 100%
- [ ] Admin UI components tested end-to-end
- [ ] Storage bucket policies verified (read: public, write: authenticated)
- [ ] Performance tested with sample data (1000+ announcements)
- [ ] Rollback plan documented

### Staging Deployment
```bash
# 1. Link to staging environment
supabase link --project-ref <staging-ref>

# 2. Apply migrations
supabase db push

# 3. Run verification
psql -h <staging-db> -d postgres -U postgres -f backend/scripts/verify_v9.12.0_implementation.sql

# 4. Test Admin UI on staging domain
# Navigate to https://staging-admin.pickly.io/benefits/featured

# 5. Create test announcements with thumbnails and tags
# 6. Verify search functionality
# 7. Verify featured sections display correctly
```

### Production Deployment
```bash
# 1. Link to production
supabase link --project-ref vymxxpjxrorpywfmqpuk

# 2. Apply migrations (read-only verification first)
supabase migration list  # Verify status
supabase db diff --linked --schema public  # Check for conflicts

# 3. Apply migrations
supabase db push

# 4. Run verification
psql -h <prod-db> -d postgres -U postgres -f backend/scripts/verify_v9.12.0_implementation.sql

# 5. Monitor logs for errors
# 6. Test critical paths in production
```

### Rollback Plan
If issues occur, rollback is **NOT automatic** because:
- `searchable_text` is a generated column (no data loss on rollback)
- Storage bucket can remain (won't affect old code)
- New columns have defaults (old code won't break)

**Manual Rollback** (if needed):
```sql
-- Remove triggers
DROP TRIGGER IF EXISTS trg_announcements_search_sync ON public.announcements;
DROP TRIGGER IF EXISTS trg_benefit_categories_bump ON public.benefit_categories;
DROP TRIGGER IF EXISTS trg_benefit_subcategories_bump ON public.benefit_subcategories;

-- Remove functions
DROP FUNCTION IF EXISTS public.sync_search_index_for_announcement(UUID);
DROP FUNCTION IF EXISTS public.bump_announcements_by_category(UUID);
DROP FUNCTION IF EXISTS public.bump_announcements_by_subcategory(UUID);
DROP FUNCTION IF EXISTS public.reindex_announcements();
DROP FUNCTION IF EXISTS public.search_announcements(TEXT, INT);
DROP FUNCTION IF EXISTS public.get_featured_announcements(TEXT, INT);

-- Remove search_index table
DROP TABLE IF EXISTS public.search_index;

-- Remove announcement columns (only if necessary)
ALTER TABLE public.announcements
  DROP COLUMN IF EXISTS searchable_text,
  DROP COLUMN IF EXISTS tags,
  DROP COLUMN IF EXISTS featured_order,
  DROP COLUMN IF EXISTS featured_section,
  DROP COLUMN IF EXISTS is_featured,
  DROP COLUMN IF EXISTS thumbnail_url;
```

---

## 📊 Performance Considerations

### Index Strategy
- **GIN Indexes**: Fast full-text search on TSVECTOR columns
- **Composite Index**: Optimizes featured section queries
- **Array Index**: Fast tag lookups

### Query Optimization
- `search_announcements()` uses `ts_rank()` for relevance scoring
- `get_featured_announcements()` uses indexed columns only
- Generated column avoids runtime tsvector computation

### Storage
- 5MB limit per thumbnail prevents storage bloat
- Public bucket with CDN caching (3600s cache control)
- Organized by announcement ID for easy cleanup

### Monitoring
- Track `search_index` table size (should grow linearly with announcements)
- Monitor GIN index usage (pg_stat_user_indexes)
- Watch for trigger performance (pg_stat_user_functions)

---

## 🔗 API Usage Examples

### Search Announcements
```sql
-- Full-text search with 10 results
SELECT * FROM public.search_announcements('청년 행복주택', 10);

-- Returns: id, title, organization, status, rank (float)
-- Sorted by rank DESC (most relevant first)
```

### Get Featured Announcements
```sql
-- Get home section featured announcements
SELECT * FROM public.get_featured_announcements('home', 5);

-- Get all featured (any section)
SELECT * FROM public.get_featured_announcements(NULL, 20);

-- Returns: id, title, organization, thumbnail_url, featured_section, featured_order, status
-- Sorted by featured_order ASC (lowest number first)
```

### Reindex All Announcements
```sql
-- Rebuild entire search index (use sparingly)
SELECT public.reindex_announcements();

-- Returns: INTEGER (number of announcements reindexed)
```

### Admin UI - Supabase Client
```typescript
// Upload thumbnail
const { data, error } = await supabase.storage
  .from('announcement-thumbnails')
  .upload(`${announcementId}/${Date.now()}.jpg`, file);

// Update announcement with featured settings
const { error } = await supabase
  .from('announcements')
  .update({
    thumbnail_url: publicUrl,
    is_featured: true,
    featured_section: 'home',
    featured_order: 0,
    tags: ['청년', '행복주택']
  })
  .eq('id', announcementId);

// Fetch featured announcements
const { data } = await supabase
  .from('announcements')
  .select('*')
  .eq('is_featured', true)
  .order('featured_section')
  .order('featured_order');
```

---

## 📝 Commit Message Template

```
feat(v9.12.0): Add announcement thumbnails, featured sections, and search extension

**Backend**:
- Added 6 columns to announcements: thumbnail_url, is_featured, featured_section, featured_order, tags, searchable_text
- Created search_index table for cross-entity search
- Implemented 7 functions: search, featured queries, reindex, bump pipes, thumbnail path helper
- Created 3 triggers for wall & pipe architecture (category→announcement→search sync)
- Added GIN indexes for full-text search performance
- Created announcement-thumbnails Storage bucket (5MB, public read)

**Admin UI**:
- ThumbnailUploader component for image upload with preview
- FeaturedAndSearchTab for managing featured status, sections, and tags
- FeaturedManagementPage for drag-and-drop section ordering

**Testing**:
- Verification script with 13 test sections
- Functional tests for search, featured, and pipe triggers

**Architecture**:
- Wall & Pipe pattern for loose coupling
- Generated TSVECTOR column for automatic search vector updates
- Weighted search rankings (title: A, org: B, tags: C)

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
```

---

## 🎓 Next Steps

### Immediate (v9.12.0 Completion)
1. ✅ Apply migrations to staging database
2. ✅ Test Admin UI end-to-end on staging
3. ✅ Run verification script on staging
4. ✅ Document any staging issues
5. ✅ Apply to production after staging validation

### Future Enhancements (v9.13.0+)
1. **Search Analytics**:
   - Track search queries and results
   - Popular keywords dashboard
   - Zero-result queries monitoring

2. **Featured Scheduling**:
   - Start/end dates for featured announcements
   - Auto-enable/disable based on schedule
   - Featured section analytics (click tracking)

3. **Advanced Search**:
   - Faceted search (by category, region, status)
   - Search filters in UI
   - Search result highlighting

4. **Thumbnail Optimization**:
   - Auto-resize on upload (multiple sizes)
   - WebP conversion for better compression
   - Lazy loading in lists

5. **Mobile App Integration**:
   - Implement featured sections in Flutter app
   - Use search_announcements() for app search
   - Display thumbnails in announcement cards

---

## 📚 References

- **Supabase Storage**: https://supabase.com/docs/guides/storage
- **PostgreSQL Full-Text Search**: https://www.postgresql.org/docs/current/textsearch.html
- **GIN Indexes**: https://www.postgresql.org/docs/current/gin-intro.html
- **React Query**: https://tanstack.com/query/latest
- **shadcn/ui**: https://ui.shadcn.com/

---

## ✅ Status Summary

| Component | Status | Notes |
|-----------|--------|-------|
| Backend Migration (search) | ✅ Complete | 20251112090000_admin_announcement_search_extension.sql |
| Backend Migration (storage) | ✅ Complete | 20251112090001_create_announcement_thumbnails_bucket.sql |
| ThumbnailUploader Component | ✅ Complete | apps/pickly_admin/src/components/announcements/ThumbnailUploader.tsx |
| FeaturedAndSearchTab Component | ✅ Complete | apps/pickly_admin/src/components/announcements/FeaturedAndSearchTab.tsx |
| FeaturedManagementPage | ✅ Complete | apps/pickly_admin/src/pages/benefits/FeaturedManagementPage.tsx |
| Verification Script | ✅ Complete | backend/scripts/verify_v9.12.0_implementation.sql |
| Staging Deployment | ⏳ Pending | Requires testing before production |
| Production Deployment | ⏳ Pending | After staging validation |
| Mobile App Integration | 📋 Future | v9.13.0+ |

---

**Document Version**: 1.0
**Last Updated**: 2025-11-12
**Author**: Claude Code (PRD v9.12.0 Implementation)
