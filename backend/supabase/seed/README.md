# Pickly Supabase Seed Data

**Purpose:** Automate database initialization with essential master data
**PRD:** v9.9.7 Seed Automation
**Date:** 2025-11-07

---

## 📋 Overview

This directory contains SQL seed scripts that populate Pickly's core master data tables with official, production-ready data. All scripts are **idempotent** (safe to run multiple times).

### Seed Scripts

| File | Purpose | Record Count |
|------|---------|--------------|
| `01_age_categories.sql` | Age categories (연령대) | 6 |
| `02_benefit_categories.sql` | Benefit categories (혜택 분류) | 9 |
| `03_benefit_subcategories.sql` | Benefit subcategories (하위 필터) | 30 |

---

## 🚀 Usage

### Quick Start (Recommended)

```bash
# Navigate to seed directory
cd backend/supabase/seed

# Run all seed scripts
./run_all.sh
```

### Individual Script Execution

```bash
# Via Docker (recommended)
cat 01_age_categories.sql | docker exec -i supabase_db_supabase psql -U postgres -d postgres

# Or direct psql (if local)
psql -U postgres -d postgres -f 01_age_categories.sql
```

---

## 📊 Data Details

### Age Categories (연령대)

| ID | Title | Icon Component | Age Range | Sort Order |
|----|-------|----------------|-----------|------------|
| `cd086d67-3b62-4471-8ffb-32943b406cdd` | 청년 | `youth` | 19-39 | 1 |
| `bbb0dd08-2370-441c-b258-868f1b267bbd` | 신혼부부·예비부부 | `newlywed` | - | 2 |
| `796618c2-95fc-4e9f-ac5f-14bb25c7bab5` | 육아중인 부모 | `baby` | - | 3 |
| `51538f62-a170-4b8d-95f8-83a6294dd4f8` | 다자녀 가구 | `parenting` | - | 4 |
| `49d602bf-2c5f-486d-bf20-e766170a0514` | 어르신 | `senior` | 65+ | 5 |
| `8d6472df-a63b-4397-8c9b-35368bf3bda4` | 장애인 | `disabled` | - | 6 |

**Icon Resolution:**
- `icon_component` → CategoryIcon mapping → Local SVG
- `packages/pickly_design_system/assets/icons/age_categories/{filename}.svg`

### Benefit Categories (혜택 분류)

| ID | Title | Slug | Icon URL | Sort Order |
|----|-------|------|----------|------------|
| `acda5f72-8f5f-4efd-9311-9f7b7fe8ca0d` | 인기 | `popular` | `popular.svg` | 1 |
| `25829394-bfe3-43d9-a2c0-d7ee6c3d81bc` | 주거 | `housing` | `housing.svg` | 2 |
| `8fe9c6e0-d479-4249-80ad-da259e1d7102` | 교육 | `education` | `education.svg` | 3 |
| `2c2ecd65-8cdd-4885-bcbd-47cc5f185498` | 건강 | `health` | `health.svg` | 4 |
| `8a3dd17e-13ae-4abf-beea-f8956b86a1bd` | 교통 | `transportation` | `transportation.svg` | 5 |
| `dc0d8105-8c90-4022-82d6-2b19c2d5104a` | 복지 | `welfare` | `welfare.svg` | 6 |
| `c3138a81-c168-47b9-ba3e-0808b1c7eece` | 취업 | `employment` | `employment.svg` | 7 |
| `71908337-a2bd-41a8-b34d-fb823402ce6b` | 지원 | `support` | `support.svg` | 8 |
| `3ae25143-47df-4c89-9927-3bbbf5d0694e` | 문화 | `culture` | `culture.svg` | 9 |

**Icon Resolution:**
- `icon_url` → MediaResolver → Local SVG or Supabase Storage
- Fallback: `packages/pickly_design_system/assets/icons/{filename}.svg`

### Benefit Subcategories (하위 필터)

**Total:** 30 subcategories across 8 parent categories

| Parent Category | Subcategories | Count |
|----------------|---------------|-------|
| 주거 (Housing) | 행복주택, 국민임대, 전세임대, 매입임대, 장기전세 | 5 |
| 교육 (Education) | 대학 장학금, 고등학생 지원, 유아 교육비, 학자금 대출 | 4 |
| 건강 (Health) | 건강검진, 의료비 지원, 치과 지원, 정신건강 지원 | 4 |
| 교통 (Transportation) | 대중교통 할인, 차량 구매 지원, 유류비 지원 | 3 |
| 복지 (Welfare) | 기초생활수급, 긴급복지지원, 아동수당, 양육수당 | 4 |
| 취업 (Employment) | 직업훈련, 취업성공패키지, 청년내일채움공제, 일자리 매칭 | 4 |
| 지원 (Support) | 돌봄서비스, 생활지원, 법률지원 | 3 |
| 문화 (Culture) | 문화누리카드, 체육시설 이용, 공연/전시 할인 | 3 |

**Schema:**
- Foreign key to `benefit_categories.id`
- Unique constraint on `(category_id, slug)`
- Idempotent inserts with `ON CONFLICT DO UPDATE`

---

## ⚙️ Idempotent Design

All seed scripts use `ON CONFLICT ... DO UPDATE` pattern:

```sql
INSERT INTO table (id, ...) VALUES (...)
ON CONFLICT (id) DO UPDATE SET
  column = EXCLUDED.column,
  updated_at = NOW();
```

**Benefits:**
- ✅ Safe to run multiple times
- ✅ Updates existing records with latest data
- ✅ Preserves UUIDs for referential integrity
- ✅ No duplicate key errors

---

## 🧪 Testing & Verification

### Run Tests

```bash
# Test all seeds
./run_all.sh

# Expected output:
# ✅ Age Categories Seed Complete
# ✅ Benefit Categories Seed Complete
# ✅ Seed Complete: age_categories_count=6, benefit_categories_count=9
```

### Manual Verification

```sql
-- Check age categories
SELECT id, title, icon_component, sort_order
FROM public.age_categories
ORDER BY sort_order;

-- Check benefit categories
SELECT id, title, slug, icon_url, sort_order
FROM public.benefit_categories
WHERE is_active = true
ORDER BY sort_order;
```

---

## 🔄 Database Reset Workflow

When you need to reset the database:

```bash
# 1. Reset database (⚠️ destructive)
cd backend/supabase
supabase db reset

# 2. Auto-restore seed data
cd seed
./run_all.sh

# 3. Verify in Flutter app
# - Age category icons should display
# - Benefit categories should load
# - No errors in logs
```

---

## 📦 Storage Bucket Structure

### Age Icons
- **Bucket:** `age-icons`
- **Files:** (Future Admin Upload)
- **Current:** Uses local assets from Design System

### Benefit Icons
- **Bucket:** `benefit-icons`
- **Files:** (Some in Storage, most local)
- **Current:** Hybrid (local + Storage)

---

## 🗺️ Roadmap

### ✅ Phase 1 - Complete (v9.9.6)
- Local age icon integration
- CategoryIcon mapping system

### ✅ Phase 2 - Complete (v9.9.7)
- Seed script automation
- Idempotent insert pattern
- Auto-recovery on db reset

### ✅ Phase 3 - Complete (v9.9.8)
- Benefit subcategories seed data (30 records)
- Hierarchical filtering structure
- Foreign key relationships established

### 📋 Phase 4 - Planned (v9.9.9)
- Admin CRUD UI for subcategories
- Flutter bottom sheet filter integration
- Real-time synchronization

### 📋 Phase 7 - Future (v9.10.0)
- Admin upload UI for icons
- Storage unification
- Real-time icon updates

---

## 🛠️ Troubleshooting

### Script Execution Fails

```bash
# Check Docker container
docker ps --filter "name=supabase_db_supabase"

# Check psql connection
docker exec supabase_db_supabase psql -U postgres -d postgres -c "SELECT version();"
```

### Data Not Appearing

```bash
# Verify RLS is disabled (dev mode)
docker exec supabase_db_supabase psql -U postgres -d postgres -c "
  SELECT tablename, rowsecurity
  FROM pg_tables
  WHERE schemaname = 'public'
  AND tablename IN ('age_categories', 'benefit_categories');
"
```

### Icon Display Issues

1. Check `icon_component` values match CategoryIcon mapping
2. Verify local SVG files exist in Design System
3. Check MediaResolver logs in Flutter app

---

## 📚 Related Documentation

- **PRD v9.9.6**: Age Icons Local Asset Integration
- **PRD v9.9.7**: Full Seed Automation & Storage Preparation (this document)
- **PRD v9.6.1**: Pickly Integrated System (original schema)

---

**Last Updated:** 2025-11-07
**Maintainer:** Pickly Development Team
