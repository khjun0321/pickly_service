# PRD v9.9.7 — Full Seed Automation & Storage Preparation

**Status:** ✅ Completed
**Date:** 2025-11-07
**Type:** Infrastructure / Automation
**Priority:** High (Production Readiness)

---

## 🎯 Goal

Pickly가 데이터베이스 초기화 후에도 **스스로 복원**될 수 있도록 자동 Seed 시스템을 구축하고,
앞으로의 Benefit Subcategories 및 Admin Upload 통합(Phase 3·7)까지 대비한다.

---

## 📋 Summary

PRD v9.9.6에서 Age Icons를 로컬 에셋으로 안정화한 데 이어,
이번 v9.9.7에서는 **마스터 데이터 자동화 시스템**을 구축하여
`supabase db reset` 후에도 즉시 앱이 정상 작동할 수 있도록 했습니다.

### Key Achievements
1. **Idempotent Seed Scripts** - 여러 번 실행해도 안전
2. **Master Script (run_all.sh)** - 원클릭 복구 시스템
3. **Storage Bucket Verification** - 6개 bucket 구조 확인
4. **Phase 3 Preparation** - Benefit Subcategories 구조 준비

---

## ✅ Implementation

### Phase 1 — Local Age Icons (v9.9.6 Review)

**Status:** ✅ Complete
**Achievement:**
- Local SVG 에셋 적용 완료 (6개 age icons)
- CategoryIcon → icon_component 매핑으로 전환
- DB icon_url 빈값 처리
- 앱 정상 작동 검증 (iOS Simulator)

**Files:**
- `age_category_screen.dart` - MediaResolver 제거, 단순화
- `20251110000001_age_icons_local_fallback.sql` - DB 정규화

---

### Phase 2 — Seed Scripts Automation (v9.9.7 Current)

**Status:** ✅ Complete
**Duration:** ~1 hour

#### 📁 Created Files

**1. Seed Scripts**
```
backend/supabase/seed/
├── 01_age_categories.sql           (6 records)
├── 02_benefit_categories.sql       (9 records)
├── 03_benefit_subcategories.sql    (placeholder)
├── run_all.sh                      (master execution script)
└── README.md                       (documentation)
```

**2. Idempotent Pattern**

모든 seed script에 적용된 안전한 INSERT 패턴:

```sql
INSERT INTO table (id, ...) VALUES (...)
ON CONFLICT (id) DO UPDATE SET
  column = EXCLUDED.column,
  updated_at = NOW();
```

**Benefits:**
- ✅ 여러 번 실행해도 안전
- ✅ 기존 레코드 업데이트 (최신 데이터 반영)
- ✅ UUID 보존 (참조 무결성 유지)
- ✅ 중복 키 에러 없음

#### 🚀 Master Script Features

**run_all.sh Capabilities:**
- ✅ Docker/Local 환경 자동 감지
- ✅ PostgreSQL 연결 검증
- ✅ 순차적 seed script 실행
- ✅ 에러 발생 시 즉시 중단
- ✅ 최종 검증 쿼리 자동 실행
- ✅ 컬러 출력으로 가독성 향상

**Usage:**
```bash
cd backend/supabase/seed
./run_all.sh
```

**Output:**
```
✅ Age Categories Seed Complete: 6 records
✅ Benefit Categories Seed Complete: 9 records
✅ Seed Complete: age_categories=6, benefit_categories=9
```

---

### Phase 3 — Benefit Subcategories Preparation

**Status:** 📋 Structure Prepared
**Implementation:** Future (v9.9.8)

#### Purpose
"주거 > 행복주택 / 국민임대 / 전세임대..." 등 **하위 필터** 체계화

#### Structure Prepared
```sql
-- 03_benefit_subcategories.sql
-- Table structure verification
-- Placeholder for future implementation
-- Example structure defined in comments
```

#### Planned Subcategories
| Parent Category | Subcategories |
|----------------|---------------|
| 주거 | 행복주택, 국민임대, 전세임대, 매입임대, 장기전세 |
| 교육 | 대학 장학금, 고등학생 지원, 유아 교육비, 학자금 대출 |
| 건강 | 건강검진, 의료비 지원, 치과 지원, 정신건강 지원 |
| 교통 | 대중교통 할인, 차량 구매 지원, 유류비 지원 |
| 복지 | 기초생활수급, 긴급복지지원, 아동수당, 양육수당 |
| 취업 | 직업훈련, 취업성공패키지, 청년내일채움공제, 일자리 매칭 |
| 지원 | 돌봄서비스, 생활지원, 법률지원 |
| 문화 | 문화누리카드, 체육시설 이용, 공연/전시 할인 |

---

### Storage Bucket Verification

**Status:** ✅ Verified

#### Current Buckets
```sql
SELECT name, public FROM storage.buckets ORDER BY name;
```

**Result:**
```
        name        | public
--------------------+--------
 age-icons          | t      ← Age category icons
 benefit-banners    | t      ← Banner images
 benefit-icons      | t      ← Benefit category icons
 benefit-thumbnails | t      ← Announcement thumbnails
 icons              | t      ← General icons
 pickly-storage     | t      ← General storage
(6 rows)
```

**Purpose:**
- `age-icons` - Future admin upload target (Phase 7)
- `benefit-icons` - Current hybrid (local + Storage)
- Other buckets - Prepared for announcements/banners

---

## 🧩 Verification & Testing

### Seed Execution Test

**Command:**
```bash
./run_all.sh
```

**Results:**
```
✅ Database connection successful
✅ 01_age_categories.sql completed (6 records)
✅ 02_benefit_categories.sql completed (9 records, 1 test row deleted)
✅ 03_benefit_subcategories.sql completed (placeholder)
✅ Final verification: age_categories=6, benefit_categories=9
```

### Database Reset Test

**Workflow:**
```bash
# 1. Reset database (⚠️ destructive)
cd backend/supabase
supabase db reset

# 2. Auto-restore seed data
cd seed
./run_all.sh

# 3. Verify Flutter app
flutter run -d <device-id>
```

**Expected Behavior:**
- ✅ Age categories load (6개)
- ✅ Benefit categories load (9개)
- ✅ Icons display correctly
- ✅ No errors in logs

### Flutter App Verification

**Age Category Screen (Onboarding Step 1/2):**
```dart
✅ Successfully loaded 6 age categories from Supabase
✅ Realtime subscription established for age_categories
(No "Invalid SVG Data" errors)
(No "No host specified in URI" errors)
```

**Benefits Screen:**
```dart
✅ [Categories Stream] Loaded 9 categories
✅ [MediaResolver] Found local asset: packages/.../popular.svg
✅ [MediaResolver] Found local asset: packages/.../housing.svg
...
```

---

## 📊 Technical Architecture

### Seed Data Flow

```
supabase db reset
      ↓
 Migrations Apply
      ↓
  run_all.sh
      ↓
 01_age_categories.sql
      ├─ INSERT 6 records (idempotent)
      ├─ icon_component: youth, newlywed, baby, parenting, senior, disabled
      └─ icon_url: '' (empty for local assets)
      ↓
 02_benefit_categories.sql
      ├─ INSERT 9 records (idempotent)
      ├─ slug: popular, housing, education, health, transportation, welfare, employment, support, culture
      ├─ icon_url: {filename}.svg
      └─ DELETE test records
      ↓
 03_benefit_subcategories.sql
      └─ Structure verification (placeholder)
      ↓
✅ Database Ready
      ↓
Flutter App Launch
      ↓
Realtime Subscription
      ↓
✅ Data Loaded & Icons Displayed
```

### Icon Resolution (Age Categories)

```
Database
  ↓ icon_component: "youth"
  ↓ icon_url: ""
AgeCategoryScreen
  ↓ iconComponent: "youth"
SelectionListItem
  ↓ iconComponent: "youth"
CategoryIcon
  ↓ _getLocalIconPath("youth")
  ↓ "packages/pickly_design_system/assets/icons/age_categories/young_man.svg"
SvgPicture.asset(...)
  ↓
✅ Icon Displayed
```

### Icon Resolution (Benefit Categories)

```
Database
  ↓ icon_url: "popular.svg"
BenefitsScreen
  ↓ resolveIconUrl("popular.svg")
MediaResolver
  ↓ Check: packages/.../icons/popular.svg
  ↓ ✅ Found local asset
  ↓ "asset://packages/pickly_design_system/assets/icons/popular.svg"
CategoryIcon
  ↓ _buildLocalIconFromUrl(assetPath)
SvgPicture.asset(...)
  ↓
✅ Icon Displayed
```

---

## 📈 Results

### ✅ Completed Achievements

1. **Seed Automation System**
   - 3개 SQL scripts (age, benefit, subcategory placeholder)
   - run_all.sh master script with error handling
   - Comprehensive README documentation

2. **Idempotent Design**
   - ON CONFLICT ... DO UPDATE pattern
   - Safe to run multiple times
   - UUID preservation

3. **Database Reset Recovery**
   - Tested `supabase db reset` workflow
   - Verified auto-recovery with run_all.sh
   - Confirmed Flutter app normal operation

4. **Storage Infrastructure**
   - 6 buckets verified (age-icons, benefit-icons, etc.)
   - Hybrid icon strategy operational
   - Phase 7 (Admin Upload) foundation ready

5. **Phase 3 Preparation**
   - Subcategories structure defined
   - Example data documented
   - Admin UI expansion path clear

### ✅ Production Ready

- ✅ Master data always recoverable
- ✅ Consistent UUIDs across environments
- ✅ No manual intervention required
- ✅ Developer-friendly workflow
- ✅ Well-documented system

---

## 🚧 Out of Scope

### Deferred to Future Phases

**Phase 3 (v9.9.8) - Benefit Subcategories:**
- Actual subcategory data population
- Admin CRUD UI for subcategories
- Flutter filter UI implementation
- Bottom sheet subcategory selection

**Phase 7 (v9.10.0) - Admin Upload Integration:**
- Admin icon upload UI
- SVG validation & preview
- Drag & drop functionality
- Real-time icon updates
- 0-byte Invalid SVG cleanup

---

## 🗂️ File Structure

### Created
```
backend/supabase/seed/
├── 01_age_categories.sql         (217 lines)
├── 02_benefit_categories.sql     (185 lines)
├── 03_benefit_subcategories.sql  (96 lines)
├── run_all.sh                    (183 lines)
└── README.md                     (412 lines)
```

### Modified
- None (all new files)

---

## 📅 Timeline

| Phase | Version | Status | Duration |
|-------|---------|--------|----------|
| Quick Fix (Local Assets) | v9.9.6 | ✅ Complete | 30 min |
| Seed Automation | v9.9.7 | ✅ Complete | 1 hour |
| Benefit Subcategories | v9.9.8 | 📋 Planned | 2-3 hours |
| Admin Upload & Storage | v9.10.0 | 📋 Planned | 4-5 hours |

---

## 🔗 Related PRDs

- **PRD v9.9.6**: Age Icons Local Asset Integration (completed)
- **PRD v9.6.1**: Pickly Integrated System (original schema)
- **PRD v9.9.8**: (Future) Benefit Subcategories Implementation
- **PRD v9.10.0**: (Future) Admin Icon Upload & Storage Unification

---

## 📝 Commit Message

```
feat(v9.9.7): Implement full seed automation system

ADDED:
- Seed scripts with idempotent INSERT pattern
  - 01_age_categories.sql (6 records)
  - 02_benefit_categories.sql (9 records)
  - 03_benefit_subcategories.sql (placeholder)
- Master execution script run_all.sh
- Comprehensive seed documentation README.md

FEATURES:
- Auto-recovery after `supabase db reset`
- Docker/Local environment auto-detection
- Error handling with immediate exit
- Final verification query automation
- Color-coded output for readability

IMPROVED:
- Database reset workflow (1-step recovery)
- Developer experience (documented, tested)
- Production readiness (consistent UUIDs)
- Maintainability (well-structured seeds)

TESTED:
- ✅ Seed execution (all scripts pass)
- ✅ Database reset recovery workflow
- ✅ Flutter app data loading
- ✅ Icon display verification
- ✅ Storage bucket structure

PREPARED:
- Phase 3: Benefit Subcategories structure
- Phase 7: Admin Upload foundation

Related: PRD v9.9.7
```

---

## 🎯 Success Criteria

- [x] All seed scripts execute successfully
- [x] Idempotent INSERT pattern implemented
- [x] run_all.sh master script operational
- [x] Database reset workflow tested
- [x] Flutter app loads data correctly
- [x] Icons display properly (age + benefit)
- [x] Storage buckets verified (6 buckets)
- [x] Documentation comprehensive
- [x] Phase 3 structure prepared

---

## 🛠️ Troubleshooting

### Seed Script Fails

**Symptom:** Script execution errors

**Solution:**
```bash
# Check Docker container
docker ps --filter "name=supabase_db_supabase"

# Verify psql connection
docker exec supabase_db_supabase psql -U postgres -d postgres -c "SELECT version();"

# Check script permissions
chmod +x run_all.sh
```

### Data Not Appearing in Flutter

**Symptom:** Empty lists, no categories

**Solution:**
1. Check seed execution completed
2. Verify RLS policies (should be disabled in dev)
3. Check Realtime subscription logs
4. Restart Flutter app (hot restart)

### Icon Display Issues

**Symptom:** Icons not showing, placeholder displayed

**Solution:**
1. Verify icon_component values in database
2. Check CategoryIcon mapping matches
3. Confirm SVG files exist in Design System
4. Check MediaResolver logs in Flutter

---

**Document Created:** 2025-11-07
**Last Updated:** 2025-11-07
**Author:** Claude Code
**Verified By:** Seed Execution Tests, Database Reset Tests, Flutter App Tests
