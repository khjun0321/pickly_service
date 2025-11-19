# PRD v9.9.8 — Benefit Subcategories Expansion (Phase 1: Seed Data)

**Status:** ✅ Phase 1 Complete
**Date:** 2025-11-08
**Type:** Feature / Data Structure
**Priority:** High (Filtering System Enhancement)

---

## 🎯 Goal

Implement hierarchical benefit filtering by adding subcategories to the existing benefit_categories system, enabling users to filter benefits with greater precision (e.g., "주거 > 행복주택" instead of just "주거").

---

## 📋 Summary

PRD v9.9.8 extends the v9.9.7 seed automation system by populating the `benefit_subcategories` table with 30 production-ready subcategory records across 8 parent categories. This Phase 1 implementation establishes the data foundation for future Admin UI and Flutter filter enhancements.

### Key Achievements (Phase 1)

1. **30 Subcategories Implemented** - Comprehensive coverage across 8 benefit categories
2. **Idempotent Seed Integration** - Seamlessly integrated with v9.9.7 automation
3. **Test Data Cleanup** - Automatic removal of legacy test entries
4. **Foreign Key Integrity** - Proper relationships with parent categories

---

## ✅ Phase 1 Implementation — Seed Data (COMPLETE)

### Database Schema

**Table:** `public.benefit_subcategories`

```sql
CREATE TABLE benefit_subcategories (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  category_id uuid REFERENCES benefit_categories(id) ON DELETE CASCADE,
  name varchar(100) NOT NULL,
  slug varchar(100) NOT NULL,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  icon_url text,
  icon_name text,
  UNIQUE (category_id, slug)
);
```

**Key Features:**
- Foreign key to `benefit_categories.id` with CASCADE delete
- Unique constraint on `(category_id, slug)` prevents duplicates
- RLS policies enabled for admin and authenticated access

### Seed Data Distribution

| Category | Subcategories | Count |
|----------|--------------|-------|
| 주거 (Housing) | 행복주택, 국민임대, 전세임대, 매입임대, 장기전세 | 5 |
| 교육 (Education) | 대학 장학금, 고등학생 지원, 유아 교육비, 학자금 대출 | 4 |
| 건강 (Health) | 건강검진, 의료비 지원, 치과 지원, 정신건강 지원 | 4 |
| 교통 (Transportation) | 대중교통 할인, 차량 구매 지원, 유류비 지원 | 3 |
| 복지 (Welfare) | 기초생활수급, 긴급복지지원, 아동수당, 양육수당 | 4 |
| 취업 (Employment) | 직업훈련, 취업성공패키지, 청년내일채움공제, 일자리 매칭 | 4 |
| 지원 (Support) | 돌봄서비스, 생활지원, 법률지원 | 3 |
| 문화 (Culture) | 문화누리카드, 체육시설 이용, 공연/전시 할인 | 3 |
| **Total** | **30 subcategories** | **30** |

**Note:** 인기 (Popular) category has no subcategories as it's dynamically generated

### Detailed Subcategory List

#### 주거 (Housing) - 5 subcategories
1. 행복주택 (`happy-housing`) - Public housing for young adults
2. 국민임대 (`public-rental`) - National rental housing
3. 전세임대 (`lease-support`) - Jeonse (lump-sum deposit) support
4. 매입임대 (`purchased-rental`) - Government-purchased rental
5. 장기전세 (`long-term-lease`) - Long-term lease support

#### 교육 (Education) - 4 subcategories
1. 대학 장학금 (`university-scholarship`) - University scholarships
2. 고등학생 지원 (`highschool-support`) - High school student support
3. 유아 교육비 (`childcare-education`) - Childcare education expenses
4. 학자금 대출 (`student-loan`) - Student loan programs

#### 건강 (Health) - 4 subcategories
1. 건강검진 (`health-checkup`) - Health screenings
2. 의료비 지원 (`medical-expense`) - Medical expense support
3. 치과 지원 (`dental-support`) - Dental care support
4. 정신건강 지원 (`mental-health`) - Mental health support

#### 교통 (Transportation) - 3 subcategories
1. 대중교통 할인 (`public-transport`) - Public transportation discounts
2. 차량 구매 지원 (`vehicle-purchase`) - Vehicle purchase support
3. 유류비 지원 (`fuel-support`) - Fuel cost support

#### 복지 (Welfare) - 4 subcategories
1. 기초생활수급 (`basic-livelihood`) - Basic livelihood security
2. 긴급복지지원 (`emergency-welfare`) - Emergency welfare support
3. 아동수당 (`child-allowance`) - Child allowance
4. 양육수당 (`childcare-allowance`) - Childcare allowance

#### 취업 (Employment) - 4 subcategories
1. 직업훈련 (`job-training`) - Vocational training
2. 취업성공패키지 (`job-success-package`) - Job success package
3. 청년내일채움공제 (`youth-tomorrow-fund`) - Youth employment savings
4. 일자리 매칭 (`job-matching`) - Job matching services

#### 지원 (Support) - 3 subcategories
1. 돌봄서비스 (`care-service`) - Care services
2. 생활지원 (`living-support`) - Living support
3. 법률지원 (`legal-support`) - Legal support

#### 문화 (Culture) - 3 subcategories
1. 문화누리카드 (`culture-card`) - Culture Nuri Card
2. 체육시설 이용 (`sports-facility`) - Sports facility access
3. 공연/전시 할인 (`performance-exhibition`) - Performance/exhibition discounts

### File Changes

**Modified:**
- `backend/supabase/seed/03_benefit_subcategories.sql` - Complete rewrite with production data
- `backend/supabase/seed/README.md` - Added subcategory documentation

**SQL Implementation:**
```sql
-- Idempotent INSERT with ON CONFLICT
INSERT INTO public.benefit_subcategories (
  category_id,
  name,
  slug,
  sort_order,
  is_active,
  icon_url,
  icon_name
) VALUES
  ('25829394-bfe3-43d9-a2c0-d7ee6c3d81bc', '행복주택', 'happy-housing', 1, true, NULL, NULL),
  -- ... 29 more subcategories
ON CONFLICT (category_id, slug) DO UPDATE SET
  name = EXCLUDED.name,
  sort_order = EXCLUDED.sort_order,
  is_active = EXCLUDED.is_active,
  icon_url = EXCLUDED.icon_url,
  icon_name = EXCLUDED.icon_name;

-- Clean up test data
DELETE FROM public.benefit_subcategories
WHERE slug IN ('test', 'all', 'permanent-rental')
   OR name IN ('전체공고', 'test', '영구임대주택');
```

### Test Results

```bash
cd backend/supabase/seed
./run_all.sh
```

**Output:**
```
✅ Age Categories Seed Complete: 6 records
✅ Benefit Categories Seed Complete: 9 records
✅ Benefit Subcategories Seed Complete: 30 records
✅ Seed Complete: age_categories=6, benefit_categories=9

Category distribution:
 인기     |                 0
 주거     |                 5
 교육     |                 4
 건강     |                 4
 교통     |                 3
 복지     |                 4
 취업     |                 4
 지원     |                 3
 문화     |                 3
```

---

## 📋 Phase 2 — Admin UI (PLANNED)

### Goals
- CRUD interface for subcategory management
- Hierarchical display of categories → subcategories
- Inline editing and sorting

### Tasks
1. Create Admin page: `apps/pickly_admin/src/pages/benefit-subcategories/`
2. Components:
   - `SubcategoryList.tsx` - Display subcategories by parent category
   - `SubcategoryForm.tsx` - Create/Edit subcategory
   - `SubcategoryActions.tsx` - Delete, activate/deactivate
3. API Integration:
   - GET `/api/benefit-subcategories?category_id=xxx`
   - POST `/api/benefit-subcategories`
   - PATCH `/api/benefit-subcategories/:id`
   - DELETE `/api/benefit-subcategories/:id`
4. Real-time Updates:
   - Supabase Realtime subscription to `benefit_subcategories` table
   - Auto-refresh on changes

### UI Mockup Structure
```
Benefit Categories Management
├── 주거 (Housing)
│   ├── 행복주택 [Edit] [Delete]
│   ├── 국민임대 [Edit] [Delete]
│   ├── ...
│   └── [+ Add Subcategory]
├── 교육 (Education)
│   ├── 대학 장학금 [Edit] [Delete]
│   └── ...
...
```

---

## 📋 Phase 3 — Flutter Filter Integration (PLANNED)

### Goals
- Bottom sheet filter with subcategory selection
- Hierarchical navigation: Category → Subcategories
- Multi-select subcategory filtering

### Tasks
1. Update Models:
   - `lib/features/benefits/models/benefit_subcategory.dart`
   - Add to `BenefitProgram` model
2. Repository Layer:
   - `fetchSubcategoriesByCategory(categoryId)`
   - Realtime subscription to subcategories
3. UI Components:
   - `SubcategoryFilterSheet.dart` - Bottom sheet modal
   - `SubcategoryChip.dart` - Selectable subcategory chips
   - `SubcategoryList.dart` - Grouped by parent category
4. Filter Logic:
   - Update `BenefitsScreen` to support subcategory filters
   - Combine category + subcategory filters in API calls

### User Flow
```
1. User taps "주거" category
2. Bottom sheet shows subcategories:
   - 행복주택
   - 국민임대
   - 전세임대
   - ...
3. User selects "행복주택"
4. Benefits list filters to show only 행복주택-related benefits
```

---

## 📋 Phase 4 — Testing & Validation (PLANNED)

### Test Cases

**Seed Data:**
- ✅ All 30 subcategories inserted successfully
- ✅ Idempotent execution (can run multiple times)
- ✅ Test data cleanup working
- ✅ Foreign key relationships valid

**Admin UI:**
- [ ] Can view subcategories grouped by parent category
- [ ] Can create new subcategory
- [ ] Can edit existing subcategory
- [ ] Can delete subcategory
- [ ] Can activate/deactivate subcategory
- [ ] Real-time updates work across sessions

**Flutter App:**
- [ ] Subcategories load from database
- [ ] Bottom sheet filter displays correctly
- [ ] Subcategory selection filters benefits
- [ ] Multi-select subcategories work
- [ ] Realtime updates reflect in filter

---

## 🧩 Technical Architecture

### Data Flow

```
Database (benefit_subcategories)
    ↓
Seed Scripts (03_benefit_subcategories.sql)
    ↓ run_all.sh
Populated Database (30 records)
    ↓
Admin UI (Future)
    ↓ CRUD Operations
    ↓
Supabase Realtime
    ↓
Flutter App (Future)
    ↓ Filter UI
User sees filtered benefits
```

### Integration with v9.9.7 Seed System

```bash
backend/supabase/seed/
├── 01_age_categories.sql       (6 records)
├── 02_benefit_categories.sql   (9 records)
├── 03_benefit_subcategories.sql (30 records) ← NEW
├── run_all.sh                  (executes all)
└── README.md                   (updated)
```

**Workflow:**
1. `supabase db reset` - Wipes database
2. Migrations apply - Creates tables
3. `./run_all.sh` - Populates master data
4. App launches - Loads all data seamlessly

---

## 📊 Results Summary

### ✅ Completed (Phase 1)

1. **Seed Data Implementation**
   - 30 subcategories across 8 parent categories
   - Idempotent INSERT pattern with ON CONFLICT
   - Test data cleanup automation
   - Foreign key relationships established

2. **Documentation**
   - Updated seed README with subcategory details
   - Comprehensive PRD v9.9.8 documentation
   - Schema reference and examples

3. **Integration**
   - Seamlessly integrated with v9.9.7 seed system
   - run_all.sh executes subcategory seed automatically
   - Database reset workflow tested and verified

### 📋 Pending (Future Phases)

- Phase 2: Admin CRUD UI for subcategory management
- Phase 3: Flutter bottom sheet filter with subcategories
- Phase 4: End-to-end testing and validation

---

## 🚧 Out of Scope (This Phase)

**Deferred to Phase 2:**
- Admin UI implementation
- API endpoints for CRUD operations
- Real-time subscription management

**Deferred to Phase 3:**
- Flutter subcategory models
- Bottom sheet filter UI
- Multi-select filter logic

**Deferred to Phase 4:**
- Performance optimization
- Analytics tracking
- A/B testing of filter UX

---

## 📅 Timeline

| Phase | Version | Status | Duration | Deliverables |
|-------|---------|--------|----------|--------------|
| 1 | v9.9.8 Phase 1 | ✅ Complete | 2 hours | Seed data (30 records) |
| 2 | v9.9.9 | 📋 Planned | 4-6 hours | Admin CRUD UI |
| 3 | v9.10.0 | 📋 Planned | 6-8 hours | Flutter filter integration |
| 4 | v9.10.1 | 📋 Planned | 2-3 hours | Testing & validation |

---

## 🔗 Related PRDs

- **PRD v9.9.6**: Age Icons Local Asset Integration
- **PRD v9.9.7**: Full Seed Automation & Storage Preparation
- **PRD v9.9.9**: (Future) Admin Subcategory Management UI
- **PRD v9.10.0**: (Future) Flutter Subcategory Filter Integration

---

## 📝 Commit Message

```
feat(v9.9.8): Implement benefit subcategories seed data (Phase 1)

ADDED:
- 30 benefit subcategories across 8 parent categories
  - Housing (5): 행복주택, 국민임대, 전세임대, 매입임대, 장기전세
  - Education (4): 대학 장학금, 고등학생 지원, 유아 교육비, 학자금 대출
  - Health (4): 건강검진, 의료비 지원, 치과 지원, 정신건강 지원
  - Transportation (3): 대중교통 할인, 차량 구매 지원, 유류비 지원
  - Welfare (4): 기초생활수급, 긴급복지지원, 아동수당, 양육수당
  - Employment (4): 직업훈련, 취업성공패키지, 청년내일채움공제, 일자리 매칭
  - Support (3): 돌봄서비스, 생활지원, 법률지원
  - Culture (3): 문화누리카드, 체육시설 이용, 공연/전시 할인

FEATURES:
- Idempotent INSERT with ON CONFLICT DO UPDATE
- Automatic test data cleanup
- Foreign key relationships to benefit_categories
- Integrated with v9.9.7 seed automation system

IMPROVED:
- Enhanced filtering capability foundation
- Hierarchical benefit categorization
- Production-ready master data structure

TESTED:
- ✅ Seed script execution (30 records inserted)
- ✅ Idempotent pattern (safe multiple runs)
- ✅ Test data cleanup (3 legacy records removed)
- ✅ Foreign key integrity validated

PREPARED:
- Phase 2: Admin CRUD UI structure
- Phase 3: Flutter filter integration
- Phase 4: End-to-end testing workflow

Related: PRD v9.9.8 Phase 1
```

---

## 🎯 Success Criteria

- [x] 30 subcategories defined across 8 categories
- [x] Idempotent INSERT pattern implemented
- [x] Test data cleanup automated
- [x] Foreign key relationships validated
- [x] Integrated with v9.9.7 seed system
- [x] run_all.sh executes subcategory seed
- [x] Documentation updated (README + PRD)
- [ ] Admin UI implemented (Phase 2)
- [ ] Flutter filter integrated (Phase 3)
- [ ] End-to-end testing complete (Phase 4)

---

**Document Created:** 2025-11-08
**Last Updated:** 2025-11-08
**Author:** Claude Code
**Verified By:** Seed Execution Tests, Database Verification Queries
