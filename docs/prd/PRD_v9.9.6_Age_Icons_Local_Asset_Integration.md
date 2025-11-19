# PRD v9.9.6 — Age Icons Local Asset Integration

**Status:** ✅ Completed
**Date:** 2025-11-07
**Type:** Quick Fix / Local Asset Migration
**Priority:** Critical (Production Blocker)

---

## 🎯 Goal

Supabase Storage의 Invalid SVG Data 문제를 즉시 해결하기 위해
age-icons를 **로컬 에셋 기반**으로 통합하여 모든 연령대 아이콘이 정상 표시되도록 한다.

---

## 🧱 Summary

PRD v9.9.5에서 확인된 **Invalid SVG Data** 문제는
Storage에 실제 SVG 파일이 비어있거나 손상되어 발생한 것으로,
이번 v9.9.6에서는 **로컬 자산(Local Assets)** 으로 완전 전환하여 해결했습니다.

### Key Changes
1. **CategoryIcon** 내장 매핑 활용 (icon_component → local SVG)
2. **MediaResolver** 제거 (age_category_screen.dart)
3. **Database normalization** (icon_url → empty string)

---

## ✅ Implementation Details

### 1️⃣ Design System Asset Integration

**경로:** `packages/pickly_design_system/assets/icons/age_categories/`

**추가된 파일:**
```
young_man.svg     (3655 bytes) - 청년
bride.svg         (4947 bytes) - 신혼부부·예비부부
baby.svg          (3699 bytes) - 육아중인 부모
kinder.svg        (5864 bytes) - 다자녀 가구
old_man.svg       (3703 bytes) - 어르신
wheel_chair.svg   (2448 bytes) - 장애인
```

### 2️⃣ Flutter Logic Refactor

#### **age_category_screen.dart** (lib/features/onboarding/screens/)

**변경 전 (Broken):**
```dart
// ❌ MediaResolver를 사용한 복잡한 체인
final iconFileName = _getAgeIconFilename(category.iconComponent);

return FutureBuilder<String>(
  future: resolveAgeIconUrl(iconFileName),
  builder: (context, snapshot) {
    final resolvedIconUrl = snapshot.data ?? 'asset://...placeholder.svg';

    return SelectionListItem(
      iconUrl: resolvedIconUrl,  // young_man.svg → Network URL로 오해
      ...
    );
  },
);
```

**변경 후 (Working):**
```dart
// ✅ CategoryIcon 내장 매핑 활용
return SelectionListItem(
  iconComponent: category.iconComponent,  // "youth", "newlywed", etc.
  title: category.title,
  description: category.description,
  isSelected: isSelected,
  onTap: () => _handleCategorySelect(category.id),
);
```

**제거된 코드:**
- `import 'package:pickly_mobile/core/utils/media_resolver.dart'`
- `_getAgeIconFilename()` 매핑 함수
- `FutureBuilder<String>` wrapper

#### **CategoryIcon** (packages/pickly_design_system/lib/widgets/images/)

이미 PRD v9.9.5에서 구현된 age icon 매핑 활용:

```dart
String? _getLocalIconPath(String component) {
  const ageBasePath = 'packages/pickly_design_system/assets/icons/age_categories';

  final ageIconMap = {
    'youth': '$ageBasePath/young_man.svg',
    'baby': '$ageBasePath/baby.svg',
    'newlywed': '$ageBasePath/bride.svg',
    'parenting': '$ageBasePath/kinder.svg',
    'senior': '$ageBasePath/old_man.svg',
    'disabled': '$ageBasePath/wheel_chair.svg',
  };

  return ageIconMap[component];
}
```

### 3️⃣ Database Normalization

**Migration:** `backend/supabase/migrations/20251110000001_age_icons_local_fallback.sql`

```sql
-- 1. 테스트 데이터 제거
DELETE FROM public.age_categories WHERE title = 'test';

-- 2. icon_component 정규화 (대문자 → 소문자)
UPDATE public.age_categories
SET icon_component = CASE
  WHEN title = '청년' THEN 'youth'
  WHEN title = '신혼부부·예비부부' THEN 'newlywed'
  WHEN title = '육아중인 부모' THEN 'baby'
  WHEN title = '다자녀 가구' THEN 'parenting'
  WHEN title = '어르신' THEN 'senior'
  WHEN title = '장애인' THEN 'disabled'
  ELSE icon_component
END;

-- 3. icon_url 초기화 (로컬 에셋 우선)
UPDATE public.age_categories
SET icon_url = ''
WHERE icon_url IS NOT NULL;
```

**실행 결과:**
```
DELETE 1
UPDATE 6
```

---

## 🧩 Verification (Simulator)

### Before Fix (PRD v9.9.5)
```
[ERROR] Unhandled Exception: Invalid argument(s): No host specified in URI young_man.svg
[ERROR] Unhandled Exception: Bad state: Invalid SVG data
```

### After Fix (PRD v9.9.6)
```
✅ Successfully loaded 6 age categories from Supabase
✅ Realtime subscription established for age_categories
(No errors)
```

| 항목 | 결과 | 비고 |
|------|------|------|
| 연령대 선택(Onboarding) | ✅ 6개 아이콘 정상 표시 | Local Assets |
| Invalid SVG Data | ✅ 해결 | Storage 접근 제거 |
| No host specified | ✅ 해결 | CategoryIcon 매핑 사용 |
| Fire.svg 참조 | ⚠️ 별도 이슈 | Home 화면 (다른 작업) |
| Placeholder.svg | ⚠️ 별도 이슈 | 공통 fallback |

---

## ⚙️ Affected Files

### Modified
1. `apps/pickly_mobile/lib/features/onboarding/screens/age_category_screen.dart`
   - Removed `resolveAgeIconUrl()` call chain
   - Removed `_getAgeIconFilename()` mapping
   - Simplified to direct `iconComponent` passing

2. `apps/pickly_mobile/lib/core/utils/media_resolver.dart`
   - Added `age_categories/` folder support (for future use)
   - Added multi-path checking logic

### Created
3. `backend/supabase/migrations/20251110000001_age_icons_local_fallback.sql`
   - Database normalization migration

### Existing (Already in place from v9.9.5)
4. `packages/pickly_design_system/lib/widgets/images/category_icon.dart`
   - Age icon mapping (lines 195-202)
   - Hybrid icon system (iconUrl vs iconComponent)

5. `packages/pickly_design_system/assets/icons/age_categories/*.svg`
   - All 6 age category SVG files

---

## 🧱 Database State (Post-Fix)

```sql
SELECT id, title, icon_component, icon_url, LENGTH(icon_url) as url_length
FROM public.age_categories
ORDER BY sort_order;
```

**Result:**
```
title              | icon_component | icon_url | url_length
-------------------+----------------+----------+-----------
청년               | youth          |          | 0
신혼부부·예비부부  | newlywed       |          | 0
육아중인 부모      | baby           |          | 0
다자녀 가구        | parenting      |          | 0
어르신             | senior         |          | 0
장애인             | disabled       |          | 0
(6 rows)
```

**Key Points:**
- `icon_url` = empty string (`''`) with length 0
- `icon_component` = lowercase keys matching CategoryIcon mapping
- No Storage URLs → Pure local asset resolution

---

## 📊 Technical Architecture

### Icon Resolution Flow (v9.9.6)

```
Database (age_categories)
  ↓
  icon_component: "youth"
  icon_url: ""
  ↓
AgeCategoryScreen
  ↓
  SelectionListItem(iconComponent: "youth")
  ↓
CategoryIcon
  ↓
  _getLocalIconPath("youth")
  ↓
  "packages/pickly_design_system/assets/icons/age_categories/young_man.svg"
  ↓
SvgPicture.asset(...)
  ↓
✅ Icon displayed
```

### Comparison: Old vs New

| Aspect | v9.9.5 (Broken) | v9.9.6 (Fixed) |
|--------|-----------------|----------------|
| Resolution | MediaResolver → Storage URL | CategoryIcon mapping |
| Dependency | FutureBuilder chain | Direct component pass |
| Error Rate | High (Invalid SVG) | Zero |
| Complexity | High (3-layer) | Low (1-layer) |
| Maintainability | Hard | Easy |

---

## 📈 Results

### ✅ Fixed Issues
1. **Invalid SVG Data** - Completely resolved by removing Storage dependency
2. **No host specified in URI** - Fixed by using CategoryIcon's local mapping
3. **Null/empty filename warnings** - Eliminated through simplified flow

### ✅ Improvements
1. **Code Simplification** - Removed unnecessary MediaResolver calls
2. **Performance** - No async Future operations needed
3. **Reliability** - Local assets always available (no network dependency)
4. **Maintainability** - Single source of truth (CategoryIcon mapping)

### ✅ Production Ready
- All 6 age category icons displaying correctly
- No errors in Onboarding flow (Step 1/2)
- Clean logs with no warnings
- Proper fallback structure maintained

---

## 🚧 Known Limitations

### Out of Scope (This PR)
1. **Storage Upload Feature** - Deferred to Phase 7 (v9.10.x)
2. **Admin UI for Icon Management** - Deferred to Phase 7
3. **Seed Scripts** - Deferred to Phase 2 (v9.9.7)
4. **Other icon issues** (fire.svg, placeholder.svg) - Separate PRs needed

### Future Enhancements (Phase 7)
- Admin can upload custom age icons to Storage
- Fallback logic: Storage URL → Local Asset → Placeholder
- Unified icon management across benefit/age categories

---

## 📅 Timeline

| Phase | Version | Status | Duration |
|-------|---------|--------|----------|
| Quick Fix (Local Assets) | v9.9.6 | ✅ Complete | 30 min |
| Seed Scripts | v9.9.7 | 📋 Planned | 1 hour |
| Admin Upload & Storage | v9.10.0 | 📋 Planned | 4-5 hours |

---

## 🔗 Related PRDs

- **PRD v9.9.5**: Icon System Full Stabilization (CategoryIcon implementation)
- **PRD v9.6.1**: Pickly Integrated System (Original icon_url schema)
- **PRD v9.10.0**: (Future) Admin Icon Upload & Storage Integration

---

## 📝 Commit Message

```
feat(v9.9.6): Fix age icons using local assets

BREAKING CHANGES:
- Removed MediaResolver dependency from age_category_screen
- icon_url field now empty (local assets prioritized)
- icon_component is the single source of truth

FIXED:
- Invalid SVG Data errors from Storage
- "No host specified in URI" errors
- Null/empty filename warnings

ADDED:
- Database migration 20251110000001_age_icons_local_fallback.sql
- Normalized icon_component values (youth, newlywed, etc.)

IMPROVED:
- Simplified icon resolution (3-layer → 1-layer)
- Better performance (no async operations)
- Cleaner code (removed mapping function)

Related: PRD v9.9.6, Issue #age-icons-invalid-svg
```

---

## 🎯 Success Criteria

- [x] All 6 age icons display correctly in Onboarding
- [x] No "Invalid SVG Data" errors
- [x] No "No host specified" errors
- [x] Clean logs with no warnings
- [x] Database migration applied successfully
- [x] Code simplified and maintainable
- [x] Documentation updated

---

**Document Created:** 2025-11-07
**Last Updated:** 2025-11-07
**Author:** Claude Code
**Verified By:** Simulator Testing
