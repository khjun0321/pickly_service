# Database Schema Design - Region Selection Feature

## Overview
This document describes the database schema for the Pickly mobile app's region selection feature, including onboarding tracking and user preferences.

## Schema Version
- **Version**: 6.0
- **Migration**: 002_regions.sql
- **Date**: 2025-10-13
- **Status**: Production Ready

---

## Entity Relationship Diagram

```
┌─────────────────┐
│   auth.users    │ (Supabase Auth)
│─────────────────│
│ id (PK)         │
│ email           │
│ ...             │
└────────┬────────┘
         │
         │ 1:1
         │
┌────────▼────────────────────┐
│    user_profiles            │
│─────────────────────────────│
│ id (PK, FK)                 │◄─────┐
│ selected_age_category_id    │      │
│ onboarding_completed        │      │ FK
│ onboarding_completed_at     │      │
│ created_at                  │      │
│ updated_at                  │      │
└────────┬────────────────────┘      │
         │                            │
         │ 1:N                        │
         │                     ┌──────┴──────────┐
┌────────▼────────────┐        │  age_categories │
│   user_regions      │        │─────────────────│
│─────────────────────│        │ id (PK)         │
│ id (PK)             │        │ name            │
│ user_id (FK)        │        │ min_age         │
│ region_id (FK)      │        │ max_age         │
│ created_at          │        │ ...             │
└────────┬────────────┘        └─────────────────┘
         │
         │ N:1
         │
┌────────▼────────────┐
│      regions        │
│─────────────────────│
│ id (PK)             │
│ code (UNIQUE)       │
│ name                │
│ sort_order          │
│ is_active           │
│ created_at          │
│ updated_at          │
└─────────────────────┘
```

---

## Table Specifications

### 1. `public.regions` (Master Data)

Master table containing all Korean administrative regions.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier (auto-generated) |
| `code` | TEXT | UNIQUE, NOT NULL | Unique code identifier (e.g., 'seoul', 'gyeonggi') |
| `name` | TEXT | NOT NULL | Korean display name (e.g., '서울', '경기') |
| `sort_order` | INTEGER | NOT NULL, >= 0 | Display order for UI (0-based) |
| `is_active` | BOOLEAN | NOT NULL, DEFAULT true | Whether region is currently active/visible |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | Record creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | Record last update timestamp |

**Indexes:**
- `idx_regions_code` - On (code) WHERE is_active = true
- `idx_regions_sort_order` - On (sort_order) WHERE is_active = true
- `idx_regions_is_active` - On (is_active)

**Triggers:**
- `update_regions_updated_at` - Auto-updates updated_at on row changes

**Total Records:** 18 regions (including nationwide)

---

### 2. `public.user_regions` (Junction Table)

Stores user region selections (many-to-many relationship).

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PRIMARY KEY | Unique identifier (auto-generated) |
| `user_id` | UUID | FK → auth.users(id), NOT NULL | Reference to authenticated user |
| `region_id` | UUID | FK → regions(id), NOT NULL | Reference to selected region |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | Selection timestamp |

**Constraints:**
- `user_regions_unique` - UNIQUE(user_id, region_id) - Prevents duplicate selections
- ON DELETE CASCADE on both foreign keys

**Indexes:**
- `idx_user_regions_user_id` - On (user_id)
- `idx_user_regions_region_id` - On (region_id)
- `idx_user_regions_created_at` - On (created_at DESC)
- `idx_user_regions_user_region` - Composite on (user_id, region_id)

---

### 3. `public.user_profiles` (User Extended Data)

Extended user profile data including onboarding status.

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | UUID | PK, FK → auth.users(id) | User identifier (one-to-one with auth.users) |
| `selected_age_category_id` | UUID | FK → age_categories(id), NULL | User's selected age category from onboarding step 1 |
| `onboarding_completed` | BOOLEAN | NOT NULL, DEFAULT false | Whether user completed all onboarding steps |
| `onboarding_completed_at` | TIMESTAMPTZ | NULL | Timestamp when onboarding was completed |
| `created_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | Profile creation timestamp |
| `updated_at` | TIMESTAMPTZ | NOT NULL, DEFAULT NOW() | Profile last update timestamp |

**Constraints:**
- `onboarding_completed_at_check` - Ensures completed_at is set only when completed is true
- ON DELETE CASCADE on auth.users foreign key
- ON DELETE SET NULL on age_categories foreign key

**Indexes:**
- `idx_user_profiles_onboarding_completed` - On (onboarding_completed)
- `idx_user_profiles_age_category` - On (selected_age_category_id)

**Triggers:**
- `update_user_profiles_updated_at` - Auto-updates updated_at on row changes
- `on_auth_user_created` - Auto-creates profile when user signs up

---

## Row Level Security (RLS) Policies

### `regions` Table

| Policy Name | Operation | Rule |
|-------------|-----------|------|
| Anyone can view active regions | SELECT | is_active = true (public data) |
| Only service role can modify regions | ALL | auth.role() = 'service_role' (admin only) |

### `user_regions` Table

| Policy Name | Operation | Rule |
|-------------|-----------|------|
| Users can view their own region selections | SELECT | auth.uid() = user_id |
| Users can insert their own region selections | INSERT | auth.uid() = user_id |
| Users can delete their own region selections | DELETE | auth.uid() = user_id |
| Service role has full access | ALL | auth.role() = 'service_role' |

### `user_profiles` Table

| Policy Name | Operation | Rule |
|-------------|-----------|------|
| Users can view their own profile | SELECT | auth.uid() = id |
| Users can insert their own profile | INSERT | auth.uid() = id |
| Users can update their own profile | UPDATE | auth.uid() = id |
| Service role has full access | ALL | auth.role() = 'service_role' |

---

## Helper Functions

### `get_user_regions(p_user_id UUID)`

Retrieves all selected regions for a user.

**Returns:**
```sql
TABLE (
    region_id UUID,
    region_code TEXT,
    region_name TEXT,
    sort_order INTEGER
)
```

**Usage:**
```sql
SELECT * FROM get_user_regions('user-uuid-here');
```

---

### `set_user_regions(p_user_id UUID, p_region_ids UUID[])`

Replaces all user region selections with new set.

**Parameters:**
- `p_user_id` - User UUID
- `p_region_ids` - Array of region UUIDs

**Usage:**
```sql
SELECT set_user_regions(
    'user-uuid-here',
    ARRAY['region-uuid-1', 'region-uuid-2', 'region-uuid-3']::UUID[]
);
```

---

### `complete_onboarding(p_user_id UUID, p_age_category_id UUID)`

Marks user onboarding as complete and optionally sets age category.

**Parameters:**
- `p_user_id` - User UUID
- `p_age_category_id` - Age category UUID (optional)

**Usage:**
```sql
SELECT complete_onboarding(
    'user-uuid-here',
    'age-category-uuid-here'
);
```

---

## Korean Regions Data

### Region List (18 Total)

| Sort Order | Code | Name | Description |
|------------|------|------|-------------|
| 0 | nationwide | 전국 | Nationwide (all regions) |
| 1 | seoul | 서울 | Seoul Metropolitan City |
| 2 | busan | 부산 | Busan Metropolitan City |
| 3 | daegu | 대구 | Daegu Metropolitan City |
| 4 | incheon | 인천 | Incheon Metropolitan City |
| 5 | gwangju | 광주 | Gwangju Metropolitan City |
| 6 | daejeon | 대전 | Daejeon Metropolitan City |
| 7 | ulsan | 울산 | Ulsan Metropolitan City |
| 8 | sejong | 세종 | Sejong Special Autonomous City |
| 9 | gyeonggi | 경기 | Gyeonggi Province |
| 10 | gangwon | 강원 | Gangwon Province |
| 11 | chungbuk | 충북 | North Chungcheong Province |
| 12 | chungnam | 충남 | South Chungcheong Province |
| 13 | jeonbuk | 전북 | North Jeolla Province |
| 14 | jeonnam | 전남 | South Jeolla Province |
| 15 | gyeongbuk | 경북 | North Gyeongsang Province |
| 16 | gyeongnam | 경남 | South Gyeongsang Province |
| 17 | jeju | 제주 | Jeju Special Self-Governing Province |

---

## Performance Optimization Strategy

### Indexing Strategy

1. **Selective Indexes** - Partial indexes on active regions only
2. **Composite Indexes** - Multi-column indexes for common query patterns
3. **Foreign Key Indexes** - Automatic indexes on all foreign keys
4. **Timestamp Indexes** - DESC indexes for recent-first queries

### Query Optimization

1. **Materialized Views** - Consider for complex aggregations (future enhancement)
2. **Function-based Indexes** - Applied where appropriate (e.g., is_active filter)
3. **Regular ANALYZE** - Automatic statistics updates after bulk operations

### Expected Performance

- **Region Lookup**: < 1ms (18 rows, indexed)
- **User Region Fetch**: < 5ms (JOIN with indexes)
- **User Region Update**: < 10ms (transaction with constraints)
- **Onboarding Completion**: < 15ms (multiple table updates)

---

## Design Decisions & Rationale

### 1. Separate `user_profiles` Table Instead of Extending `auth.users`

**Decision:** Create separate `user_profiles` table rather than directly modifying `auth.users`.

**Rationale:**
- Supabase manages `auth.users` internally
- Extending with custom columns is not recommended
- Separation of concerns (auth vs. business logic)
- Easier to manage custom fields and migrations
- Better RLS policy management

### 2. Junction Table with Composite Unique Constraint

**Decision:** Use `user_regions` junction table with UNIQUE(user_id, region_id).

**Rationale:**
- Enforces data integrity at database level
- Prevents duplicate selections
- Supports efficient many-to-many queries
- Allows easy bulk operations (replace all selections)

### 3. UUID Primary Keys

**Decision:** Use UUID instead of SERIAL/BIGSERIAL.

**Rationale:**
- Globally unique identifiers
- No sequence conflicts in distributed systems
- Security through obscurity (non-guessable IDs)
- Consistent with Supabase auth.users structure

### 4. Soft Delete via `is_active` Flag

**Decision:** Use `is_active` flag instead of hard deletes for regions.

**Rationale:**
- Preserves historical data
- Allows re-activation without losing relationships
- Maintains referential integrity
- Supports audit trails

### 5. Helper Functions with SECURITY DEFINER

**Decision:** Create PL/pgSQL functions with SECURITY DEFINER.

**Rationale:**
- Encapsulates complex business logic
- Ensures atomic operations
- Bypasses RLS for internal operations
- Provides clean API for client code

### 6. Automatic Profile Creation Trigger

**Decision:** Auto-create user profile on auth.users INSERT.

**Rationale:**
- Ensures every user has a profile
- Prevents null reference errors
- Simplifies client logic
- Maintains data consistency

### 7. Timestamp Tracking on All Tables

**Decision:** Include created_at and updated_at on all tables.

**Rationale:**
- Audit trail compliance
- Debugging and troubleshooting
- Data analytics capabilities
- Standard best practice

---

## Migration Instructions

### 1. Run Migration

```bash
# Connect to Supabase database
psql -h db.PROJECT_ID.supabase.co -U postgres -d postgres

# Run migration
\i docs/database/migrations/002_regions.sql

# Run seed data
\i docs/database/seeds/regions.sql
```

### 2. Verify Migration

```sql
-- Check tables exist
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('regions', 'user_regions', 'user_profiles');

-- Check RLS is enabled
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('regions', 'user_regions', 'user_profiles');

-- Check regions count
SELECT COUNT(*) FROM public.regions WHERE is_active = true;
-- Expected: 18
```

### 3. Test RLS Policies

```sql
-- Test as authenticated user
SET ROLE authenticated;
SET request.jwt.claim.sub = 'test-user-uuid';

-- Should return all regions
SELECT * FROM public.regions;

-- Should return only user's selections
SELECT * FROM public.user_regions;

-- Should return only user's profile
SELECT * FROM public.user_profiles;
```

---

## API Integration Examples

### Supabase Client (Flutter/Dart)

```dart
// Fetch all regions
final regions = await supabase
    .from('regions')
    .select()
    .eq('is_active', true)
    .order('sort_order');

// Get user's selected regions
final userRegions = await supabase
    .rpc('get_user_regions', params: {'p_user_id': userId});

// Update user regions
await supabase.rpc('set_user_regions', params: {
  'p_user_id': userId,
  'p_region_ids': [regionId1, regionId2, regionId3]
});

// Complete onboarding
await supabase.rpc('complete_onboarding', params: {
  'p_user_id': userId,
  'p_age_category_id': ageCategoryId
});
```

---

## Future Enhancements

### Phase 2 (Q2 2025)
- [ ] Region popularity analytics
- [ ] Regional content filtering
- [ ] Location-based auto-selection
- [ ] Region hierarchy (cities within provinces)

### Phase 3 (Q3 2025)
- [ ] Multi-language support for region names
- [ ] Region-specific feature flags
- [ ] Regional statistics dashboard
- [ ] Geospatial queries with PostGIS

---

## Maintenance & Monitoring

### Regular Tasks

1. **Weekly:** Review slow queries and optimize indexes
2. **Monthly:** Analyze table statistics and update query planner
3. **Quarterly:** Audit RLS policies and security rules
4. **Annually:** Review schema design and consider refactoring

### Monitoring Queries

```sql
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

-- Check slow queries
SELECT
    query,
    mean_exec_time,
    calls
FROM pg_stat_statements
WHERE query LIKE '%regions%' OR query LIKE '%user_regions%'
ORDER BY mean_exec_time DESC
LIMIT 10;
```

---

## Contact & Support

- **Schema Owner:** System Architect Team
- **Migration Version:** 002_regions.sql (v6.0)
- **Last Updated:** 2025-10-13
- **Status:** ✅ Production Ready
