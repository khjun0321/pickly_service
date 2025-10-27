# Database Documentation

> **Supabase PostgreSQL schema and data management**
>
> Last Updated: 2025-10-13
> Platform: Supabase (PostgreSQL 15+)

---

## 📋 Overview

This document describes the database schema, tables, RLS policies, and data management for the Pickly service. The database is hosted on Supabase and uses PostgreSQL with Row Level Security (RLS) for access control.

### Database Structure

```
Pickly Database (Supabase PostgreSQL)
├── auth schema (Supabase managed)
│   └── users (authentication)
│
├── public schema (our tables)
│   ├── Onboarding
│   │   ├── age_categories
│   │   ├── regions
│   │   └── user_regions
│   │
│   ├── User Profiles
│   │   └── user_profiles
│   │
│   └── Policies (future)
│       ├── policies
│       ├── policy_categories
│       └── user_bookmarks
│
└── storage (file uploads, future)
```

---

## 🗂️ Tables

### 1. age_categories

Stores age/generation categories for user filtering (e.g., 청년, 신혼부부).

**Schema:**
```sql
CREATE TABLE public.age_categories (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,              -- 'youth', 'newlywed', 'parenting', etc.
  name TEXT NOT NULL,                     -- '청년', '신혼부부', '육아중', etc.
  description TEXT,                       -- '만 19세 ~ 34세', etc.
  icon_component TEXT,                    -- 'youth', 'newlywed', etc.
  icon_url TEXT,                          -- Asset path for icon
  sort_order INTEGER NOT NULL DEFAULT 0,  -- Display order
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_age_categories_code ON public.age_categories(code);
CREATE INDEX idx_age_categories_sort_order ON public.age_categories(sort_order);
CREATE INDEX idx_age_categories_is_active ON public.age_categories(is_active);

-- Comments
COMMENT ON TABLE public.age_categories IS 'Age/generation categories for user filtering';
COMMENT ON COLUMN public.age_categories.icon_component IS 'Figma icon identifier';
COMMENT ON COLUMN public.age_categories.icon_url IS 'Asset path for SVG icon';
```

**RLS Policies:**
```sql
ALTER TABLE public.age_categories ENABLE ROW LEVEL SECURITY;

-- Public read access for active categories
CREATE POLICY "Age categories are viewable by everyone"
  ON public.age_categories FOR SELECT
  USING (is_active = true);
```

**Seed Data (6 categories):**
```sql
INSERT INTO public.age_categories (code, name, description, icon_component, sort_order) VALUES
  ('youth', '청년', '만 19세 ~ 34세', 'youth', 1),
  ('newlywed', '신혼부부', '혼인 7년 이내', 'newlywed', 2),
  ('parenting', '육아중', '자녀가 있는 가구', 'parenting', 3),
  ('multi_child', '다자녀', '자녀 3명 이상', 'multi_child', 4),
  ('elderly', '어르신', '만 65세 이상', 'elderly', 5),
  ('disability', '장애인', '장애인 등록 대상', 'disability', 6);
```

---

### 2. regions

Stores the list of Korean regions for location-based policy filtering.

**Schema:**
```sql
CREATE TABLE public.regions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  code TEXT UNIQUE NOT NULL,              -- 'seoul', 'busan', 'daegu', etc.
  name TEXT NOT NULL,                     -- '서울', '부산', '대구', etc.
  name_en TEXT,                           -- 'Seoul', 'Busan', 'Daegu', etc.
  sort_order INTEGER NOT NULL DEFAULT 0,  -- Display order
  is_active BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Indexes
CREATE INDEX idx_regions_code ON public.regions(code);
CREATE INDEX idx_regions_sort_order ON public.regions(sort_order);
CREATE INDEX idx_regions_is_active ON public.regions(is_active);

-- Comments
COMMENT ON TABLE public.regions IS 'List of Korean regions for policy filtering';
COMMENT ON COLUMN public.regions.code IS 'Machine-readable region code';
COMMENT ON COLUMN public.regions.name IS 'Display name in Korean';
COMMENT ON COLUMN public.regions.sort_order IS 'Display order in UI (lower first)';
```

**RLS Policies:**
```sql
ALTER TABLE public.regions ENABLE ROW LEVEL SECURITY;

-- Public read access for active regions
CREATE POLICY "Regions are viewable by everyone"
  ON public.regions FOR SELECT
  USING (is_active = true);
```

**Seed Data (17 regions):**
```sql
-- 17 Korean administrative regions
INSERT INTO public.regions (code, name, name_en, sort_order) VALUES
  ('seoul', '서울', 'Seoul', 1),
  ('busan', '부산', 'Busan', 2),
  ('daegu', '대구', 'Daegu', 3),
  ('incheon', '인천', 'Incheon', 4),
  ('gwangju', '광주', 'Gwangju', 5),
  ('daejeon', '대전', 'Daejeon', 6),
  ('ulsan', '울산', 'Ulsan', 7),
  ('sejong', '세종', 'Sejong', 8),
  ('gyeonggi', '경기', 'Gyeonggi', 9),
  ('gangwon', '강원', 'Gangwon', 10),
  ('chungbuk', '충북', 'Chungbuk', 11),
  ('chungnam', '충남', 'Chungnam', 12),
  ('jeonbuk', '전북', 'Jeonbuk', 13),
  ('jeonnam', '전남', 'Jeonnam', 14),
  ('gyeongbuk', '경북', 'Gyeongbuk', 15),
  ('gyeongnam', '경남', 'Gyeongnam', 16),
  ('jeju', '제주', 'Jeju', 17);
```

**Region Breakdown:**
- Special Cities (특별시/광역시): 7 regions
- Special Autonomous City (특별자치시): 1 region
- Provinces (도): 8 regions
- Special Autonomous Province (특별자치도): 1 region
- **Total**: 17 regions

---

### 3. user_regions

Junction table for many-to-many relationship between users and regions.

**Schema:**
```sql
CREATE TABLE public.user_regions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
  region_id UUID NOT NULL REFERENCES public.regions(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),

  -- Prevent duplicate selections
  UNIQUE(user_id, region_id)
);

-- Indexes
CREATE INDEX idx_user_regions_user_id ON public.user_regions(user_id);
CREATE INDEX idx_user_regions_region_id ON public.user_regions(region_id);

-- Comments
COMMENT ON TABLE public.user_regions IS 'User selected regions (many-to-many)';
COMMENT ON COLUMN public.user_regions.user_id IS 'Reference to auth.users';
COMMENT ON COLUMN public.user_regions.region_id IS 'Reference to regions table';
```

**RLS Policies:**
```sql
ALTER TABLE public.user_regions ENABLE ROW LEVEL SECURITY;

-- Users can view their own regions
CREATE POLICY "Users can view their own regions"
  ON public.user_regions FOR SELECT
  USING (auth.uid() = user_id);

-- Users can insert their own regions
CREATE POLICY "Users can insert their own regions"
  ON public.user_regions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Users can delete their own regions
CREATE POLICY "Users can delete their own regions"
  ON public.user_regions FOR DELETE
  USING (auth.uid() = user_id);
```

**Relationship:**
- **User** ←→ **user_regions** ←→ **regions**
- One user can select multiple regions
- One region can be selected by multiple users
- Unique constraint prevents duplicate selections

---

### 4. user_profiles (future)

Will store comprehensive user profile data from onboarding.

**Planned Schema:**
```sql
CREATE TABLE public.user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  age_category_id UUID REFERENCES public.age_categories(id),
  household_size INTEGER,
  income_level TEXT,
  interests TEXT[],
  completed_onboarding BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

---

## 🔒 Row Level Security (RLS)

### Security Model

Pickly uses Supabase RLS to enforce access control at the database level. Every table has RLS enabled with specific policies.

### Policy Patterns

**1. Public Read (Reference Data):**
```sql
-- Tables: age_categories, regions
CREATE POLICY "Public read access"
  ON public.{table} FOR SELECT
  USING (is_active = true);
```

**2. User-Owned Data:**
```sql
-- Tables: user_regions, user_profiles
CREATE POLICY "Users can view their own data"
  ON public.{table} FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert their own data"
  ON public.{table} FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own data"
  ON public.{table} FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own data"
  ON public.{table} FOR DELETE
  USING (auth.uid() = user_id);
```

**3. Admin-Only Access (future):**
```sql
-- Tables: policies, policy_categories
CREATE POLICY "Admins have full access"
  ON public.{table} FOR ALL
  USING (auth.jwt() -> 'role' = 'admin');
```

---

## 📂 Migration Management

### Directory Structure

```
backend/supabase/
├── supabase/
│   ├── migrations/
│   │   ├── 20251007035747_onboarding_schema.sql
│   │   ├── 20251007999999_update_icon_urls.sql
│   │   ├── 20251010000000_age_categories_update.sql
│   │   └── {timestamp}_{description}.sql
│   │
│   └── seed.sql
│
└── config.toml
```

### Creating Migrations

```bash
# Create new migration file
supabase migration new add_regions_tables

# Edit the generated file
# File: supabase/migrations/{timestamp}_add_regions_tables.sql

# Run migrations locally
supabase db reset

# Push to remote
supabase db push
```

### Migration Best Practices

1. **One logical change per migration**
2. **Include rollback logic (if possible)**
3. **Test locally before pushing**
4. **Use descriptive migration names**
5. **Add comments to complex queries**
6. **Version control all migrations**

---

## 🌱 Seed Data Management

### Seed File

**Location**: `backend/supabase/seed.sql`

**Contents:**
```sql
-- Seed age categories (6 categories)
INSERT INTO public.age_categories (code, name, description, icon_component, sort_order)
VALUES
  ('youth', '청년', '만 19세 ~ 34세', 'youth', 1),
  ('newlywed', '신혼부부', '혼인 7년 이내', 'newlywed', 2),
  ('parenting', '육아중', '자녀가 있는 가구', 'parenting', 3),
  ('multi_child', '다자녀', '자녀 3명 이상', 'multi_child', 4),
  ('elderly', '어르신', '만 65세 이상', 'elderly', 5),
  ('disability', '장애인', '장애인 등록 대상', 'disability', 6)
ON CONFLICT (code) DO NOTHING;

-- Seed regions (17 regions)
INSERT INTO public.regions (code, name, name_en, sort_order)
VALUES
  ('seoul', '서울', 'Seoul', 1),
  ('busan', '부산', 'Busan', 2),
  -- ... (all 17 regions)
ON CONFLICT (code) DO NOTHING;
```

### Running Seeds

```bash
# Reset database and run seeds
supabase db reset

# Or manually run seed file
psql -h localhost -U postgres -d postgres -f backend/supabase/seed.sql
```

---

## 🔍 Query Examples

### Fetch User's Regions

```sql
-- Get regions with user selections
SELECT
  r.id,
  r.code,
  r.name,
  EXISTS(
    SELECT 1 FROM user_regions ur
    WHERE ur.region_id = r.id
    AND ur.user_id = auth.uid()
  ) AS is_selected
FROM regions r
WHERE r.is_active = true
ORDER BY r.sort_order;
```

### Fetch User's Age Category

```sql
-- Get user's selected age category
SELECT ac.*
FROM age_categories ac
JOIN user_profiles up ON up.age_category_id = ac.id
WHERE up.id = auth.uid()
AND ac.is_active = true;
```

### Save User Regions (Transaction)

```sql
BEGIN;

-- Delete old selections
DELETE FROM user_regions
WHERE user_id = auth.uid();

-- Insert new selections
INSERT INTO user_regions (user_id, region_id)
VALUES
  (auth.uid(), 'uuid-1'),
  (auth.uid(), 'uuid-2'),
  (auth.uid(), 'uuid-3');

COMMIT;
```

---

## 🛠️ Database Tools

### Supabase CLI

```bash
# Start local Supabase
supabase start

# Stop local Supabase
supabase stop

# Reset database (drop + recreate + seed)
supabase db reset

# Create migration
supabase migration new {description}

# Push migrations to remote
supabase db push

# Pull schema from remote
supabase db pull
```

### psql Commands

```bash
# Connect to local database
psql postgresql://postgres:postgres@localhost:54322/postgres

# Connect to remote database
psql postgresql://[user]:[password]@[host]:5432/postgres

# List tables
\dt public.*

# Describe table
\d public.regions

# Run SQL file
\i path/to/file.sql
```

---

## 📊 Performance Optimization

### Indexes

All tables have indexes on frequently queried columns:

```sql
-- Foreign keys
CREATE INDEX idx_user_regions_user_id ON user_regions(user_id);
CREATE INDEX idx_user_regions_region_id ON user_regions(region_id);

-- Lookup fields
CREATE INDEX idx_regions_code ON regions(code);
CREATE INDEX idx_age_categories_code ON age_categories(code);

-- Sort fields
CREATE INDEX idx_regions_sort_order ON regions(sort_order);
CREATE INDEX idx_age_categories_sort_order ON age_categories(sort_order);

-- Filter fields
CREATE INDEX idx_regions_is_active ON regions(is_active);
CREATE INDEX idx_age_categories_is_active ON age_categories(is_active);
```

### Query Performance Tips

1. **Use indexes for WHERE clauses**
2. **Avoid SELECT * (specify columns)**
3. **Use EXISTS instead of COUNT for boolean checks**
4. **Batch inserts when possible**
5. **Use transactions for multi-step operations**

---

## 🔄 Backup & Recovery

### Automated Backups (Supabase)

Supabase provides automatic daily backups on paid plans.

**Backup Schedule:**
- Daily: 7 days retention
- Weekly: 4 weeks retention
- Monthly: 3 months retention

### Manual Backup

```bash
# Export database schema
pg_dump -h localhost -U postgres -d postgres --schema-only > schema.sql

# Export database data
pg_dump -h localhost -U postgres -d postgres --data-only > data.sql

# Full backup
pg_dump -h localhost -U postgres -d postgres > full_backup.sql
```

### Restore

```bash
# Restore from backup
psql -h localhost -U postgres -d postgres < full_backup.sql
```

---

## 📚 Related Documentation

### Internal Docs
- [v6.0 Region Selection Implementation](../implementation/v6.0-region-selection.md)
- [Onboarding Development Guide](../development/onboarding-development-guide.md)
- [PRD: Database Schema Section](../PRD.md#8-데이터베이스-스키마-주요-테이블)

### External Resources
- [Supabase Documentation](https://supabase.com/docs)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [RLS Guide](https://supabase.com/docs/guides/auth/row-level-security)

---

## 🚀 Future Tables (Planned)

### policies

Will store policy information scraped or manually entered.

```sql
CREATE TABLE public.policies (
  id UUID PRIMARY KEY,
  title TEXT NOT NULL,
  summary TEXT,
  description TEXT,
  category TEXT,
  region_ids UUID[],
  age_category_ids UUID[],
  deadline TIMESTAMPTZ,
  application_url TEXT,
  -- ... more fields
);
```

### user_bookmarks

Will store user-bookmarked policies.

```sql
CREATE TABLE public.user_bookmarks (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  policy_id UUID REFERENCES policies(id),
  created_at TIMESTAMPTZ DEFAULT now(),
  UNIQUE(user_id, policy_id)
);
```

---

**Document Version**: 1.0
**Last Updated**: 2025-10-13
**Next Review**: 2025-11-13
**Maintainer**: Backend Team
