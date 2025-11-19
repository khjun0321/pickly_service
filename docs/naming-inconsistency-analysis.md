# PRD v7.3 Naming Inconsistency Analysis Report

**생성일:** 2025-10-28
**분석 범위:** Flutter Mobile App + React Admin
**기준:** PRD v7.3 Naming Convention

---

## 📋 Executive Summary

PRD v7.3에서 정의한 네이밍 규칙과 실제 코드베이스 간 **총 147개의 불일치 발견**.

### 주요 불일치 패턴
| 항목 | PRD v7.3 표준 | 현재 사용 중인 이름 | 발견 건수 |
|------|---------------|-------------------|-----------|
| 필드명 | `title` | `name` | 23건 |
| 필드명 | `sort_order` | `displayOrder`, `display_order` | 47건 |
| 필드명 | `icon_url` | `iconUrl`, `iconPath` | 18건 |
| 필드명 | `benefit_category_id` | `categoryId`, `category_id` | 31건 |
| 필드명 | `type_id` | `announcementType` | 12건 |
| 필드명 | `link_target` | `actionUrl`, `link_url` | 16건 |

---

## 🎯 우선순위별 수정 계획

### HIGH Priority (즉시 수정 필요)
**영향도:** 데이터베이스 스키마 불일치로 인한 런타임 에러 발생 가능

#### 1. BenefitCategory Model (Flutter)
**파일:** `/apps/pickly_mobile/lib/contexts/benefit/models/benefit_category.dart`

```dart
// ❌ 현재 (PRD 불일치)
@freezed
class BenefitCategory with _$BenefitCategory {
  const factory BenefitCategory({
    required String id,
    required String name,           // ❌ PRD: title
    required String slug,
    String? description,
    String? iconUrl,                // ✅ OK (but JSON key uses icon_url)
    String? bannerImageUrl,
    String? bannerLinkUrl,
    required DateTime createdAt,
    DateTime? updatedAt,
    @Default(true) bool isActive,
    @Default(0) int displayOrder,   // ❌ PRD: sort_order
  }) = _BenefitCategory;
}
```

**수정 필요 사항:**
- `name` → `title`
- `displayOrder` → `sortOrder`
- JSON 매핑: `@JsonKey(name: 'sort_order')` 추가

**위험도:** ⚠️ HIGH - Freezed 재생성 필요 (`.freezed.dart`, `.g.dart`)

---

#### 2. CategoryBanner Model (React Admin)
**파일:** `/apps/pickly_admin/src/api/banners.ts`

```typescript
// ❌ 현재 (PRD 불일치)
export interface BenefitBanner {
  id: string
  category_id: string              // ❌ PRD: benefit_category_id
  title: string                     // ✅ OK
  subtitle: string | null           // ✅ OK
  image_url: string                 // ✅ OK
  link_url: string | null           // ❌ PRD: link_target
  display_order: number             // ❌ PRD: sort_order
  is_active: boolean                // ✅ OK
  created_at: string                // ✅ OK
  updated_at: string                // ✅ OK
}
```

**수정 필요 사항:**
- `category_id` → `benefit_category_id`
- `link_url` → `link_target`
- `display_order` → `sort_order`
- **추가 필요:** `link_type: BannerLinkType` (PRD에는 있지만 현재 코드에 누락)

**위험도:** ⚠️ HIGH - 데이터베이스 스키마와 직접 연결

---

#### 3. Announcement Model (Flutter - features)
**파일:** `/apps/pickly_mobile/lib/features/benefits/models/announcement.dart`

```dart
// ✅ 이 파일은 PRD v7.3 준수 (최근 리팩토링 완료)
@immutable
class Announcement {
  final String id;
  final String typeId;              // ✅ OK (JSON: type_id)
  final String title;               // ✅ OK
  final String organization;        // ✅ OK
  final String? region;             // ✅ OK
  final String? thumbnailUrl;       // ✅ OK (JSON: thumbnail_url)
  final DateTime postedDate;        // ✅ OK (JSON: posted_date)
  final String status;              // ✅ OK
  final bool isPriority;            // ✅ OK (JSON: is_priority)
  final String? detailUrl;          // ✅ OK (JSON: detail_url)
  final DateTime createdAt;         // ✅ OK
  final DateTime updatedAt;         // ✅ OK
}
```

**상태:** ✅ **최신 PRD 준수 완료**

---

#### 4. Announcement Model (contexts - 레거시)
**파일:** `/apps/pickly_mobile/lib/contexts/benefit/models/announcement.dart`

```dart
// ⚠️ 레거시 모델 (contexts 폴더) - PRD 불일치
@JsonSerializable(fieldRename: FieldRename.snake)
class Announcement {
  final String id;
  final String title;               // ✅ OK
  final String? subtitle;           // ✅ OK
  final String? organization;       // ✅ OK

  @JsonKey(name: 'category_id')
  final String? categoryId;         // ❌ PRD v7.3: 이 필드는 announcements 테이블에 없음

  @JsonKey(name: 'subcategory_id')
  final String? subcategoryId;      // ❌ PRD v7.3: 이 필드 없음

  @JsonKey(name: 'thumbnail_url')
  final String? thumbnailUrl;       // ✅ OK

  @JsonKey(name: 'external_url')
  final String? externalUrl;        // ✅ OK

  final String status;              // ✅ OK

  @JsonKey(name: 'is_featured', defaultValue: false)
  final bool isFeatured;            // ❌ PRD v7.3: is_priority로 변경됨

  @JsonKey(name: 'is_home_visible', defaultValue: false)
  final bool isHomeVisible;         // ❌ PRD v7.3: 이 필드 없음

  @JsonKey(name: 'display_priority', defaultValue: 0)
  final int displayPriority;        // ❌ PRD v7.3: 이 필드 없음
}
```

**수정 필요 사항:**
- **결정:** `/contexts/` 모델은 레거시이므로 `/features/` 모델로 통합 또는 PRD v7.3 기준으로 완전 리팩토링
- `category_id`, `subcategory_id` → `type_id` (PRD v7.3의 announcement_types 연결)
- `is_featured` → `is_priority`
- 불필요한 필드 제거: `is_home_visible`, `display_priority`

**위험도:** ⚠️ CRITICAL - 두 개의 Announcement 모델이 공존 (충돌 위험)

---

### MEDIUM Priority (기능 영향, 단계적 수정 가능)

#### 5. AnnouncementTab Model
**파일:** `/apps/pickly_mobile/lib/contexts/benefit/models/announcement_tab.dart`

```dart
// ⚠️ 일부 불일치
@JsonSerializable(fieldRename: FieldRename.snake)
class AnnouncementTab {
  final String id;

  @JsonKey(name: 'announcement_id')
  final String announcementId;      // ✅ OK

  @JsonKey(name: 'tab_name')
  final String tabName;             // ✅ OK

  @JsonKey(name: 'age_category_id')
  final String? ageCategoryId;      // ✅ OK

  @JsonKey(name: 'display_order', defaultValue: 0)
  final int displayOrder;           // ❌ PRD: sort_order
}
```

**수정 필요 사항:**
- `displayOrder` → `sortOrder`
- JSON 키 매핑: `@JsonKey(name: 'sort_order')` (DB는 이미 sort_order 사용)

**위험도:** ⚠️ MEDIUM - JSON 키 불일치

---

#### 6. database.ts (React Admin)
**파일:** `/apps/pickly_admin/src/types/database.ts`

```typescript
// ⚠️ DB 스키마 타입 정의 - 일부 불일치
benefit_categories: {
  Row: {
    created_at: string | null
    description: string | null
    display_order: number          // ❌ PRD: sort_order
    icon_url: string | null        // ✅ OK
    id: string
    is_active: boolean | null
    name: string                   // ❌ PRD: title
    slug: string                   // ✅ OK
    updated_at: string | null
  }
}
```

**수정 필요 사항:**
- `name` → `title`
- `display_order` → `sort_order`
- **중요:** 이 파일은 Supabase CLI로 자동 생성되므로, **실제 DB 스키마를 먼저 수정**해야 함

**위험도:** ⚠️ MEDIUM - Supabase 타입 생성 파일

---

#### 7. category_banners 테이블 (database.ts)
**파일:** `/apps/pickly_admin/src/types/database.ts`

```typescript
category_banners: {
  Row: {
    category_id: string | null      // ❌ PRD: benefit_category_id
    created_at: string | null
    display_order: number           // ❌ PRD: sort_order
    end_date: string | null         // ❌ PRD v7.3: 이 필드 없음
    id: string
    image_url: string               // ✅ OK
    is_active: boolean | null
    link_url: string | null         // ❌ PRD: link_target
    start_date: string | null       // ❌ PRD v7.3: 이 필드 없음
    subtitle: string | null         // ✅ OK
    title: string                   // ✅ OK
    updated_at: string | null
  }
}
```

**수정 필요 사항:**
- `category_id` → `benefit_category_id`
- `display_order` → `sort_order`
- `link_url` → `link_target`
- **추가 필요:** `link_type: 'internal' | 'external' | 'none'`
- **제거 필요:** `start_date`, `end_date` (PRD v7.3에 없음)

**위험도:** ⚠️ MEDIUM - DB 마이그레이션 필요

---

### LOW Priority (UI 레이어, 안전하게 수정 가능)

#### 8. Provider 파일들
**영향 범위:** 37개 Dart 파일

**패턴:**
```dart
// 공통 패턴 - CamelCase 사용 중
categoryId       // ❌ DB는 category_id
displayOrder     // ❌ DB는 sort_order (또는 sort_order)
announcementType // ❌ DB는 type_id
```

**수정 전략:**
- Dart 모델에서 `@JsonKey(name: 'db_field_name')` 사용하여 변환
- Provider 로직은 Dart 네이밍 유지 (camelCase)
- DB 통신 시에만 스네이크 케이스 적용

**위험도:** ⚠️ LOW - 기존 JSON 직렬화 패턴 활용 가능

---

#### 9. React Admin API 파일들
**영향 범위:** 24개 TypeScript 파일

**주요 불일치:**
```typescript
// categories.ts
display_order  // ❌ PRD: sort_order

// banners.ts
category_id    // ❌ PRD: benefit_category_id
display_order  // ❌ PRD: sort_order
link_url       // ❌ PRD: link_target

// announcements.ts
category_id    // ❌ PRD: type_id (announcements는 category가 아닌 type에 연결)
```

**수정 전략:**
- API 함수 내부에서 필드명 변환
- 타입 정의 수정 후 자동 치환 가능

**위험도:** ⚠️ LOW - TypeScript 컴파일러가 에러 감지

---

## 🔍 상세 분석 결과

### 1. Flutter Models (Contexts)

| 파일 | 불일치 필드 | PRD 표준 | 위험도 |
|------|------------|---------|--------|
| `benefit_category.dart` | `name`, `displayOrder` | `title`, `sort_order` | HIGH |
| `announcement.dart` (contexts) | `categoryId`, `isFeatured` | `type_id`, `is_priority` | CRITICAL |
| `announcement_tab.dart` | `displayOrder` | `sort_order` | MEDIUM |
| `announcement_section.dart` | `displayOrder` | `sort_order` | MEDIUM |

---

### 2. Flutter Models (Features)

| 파일 | 상태 | 비고 |
|------|------|------|
| `category_banner.dart` | ✅ PRD 준수 | 최근 리팩토링 완료 |
| `announcement.dart` (features) | ✅ PRD 준수 | v7.3 기준 최신 |

---

### 3. React Admin Types

| 파일 | 불일치 필드 | PRD 표준 | 위험도 |
|------|------------|---------|--------|
| `database.ts` - `benefit_categories` | `name`, `display_order` | `title`, `sort_order` | MEDIUM |
| `database.ts` - `category_banners` | `category_id`, `link_url`, `display_order` | `benefit_category_id`, `link_target`, `sort_order` | MEDIUM |
| `benefit.ts` - `BenefitCategory` | ✅ PRD 준수 | 최신 타입 정의 |
| `benefit.ts` - `CategoryBanner` | ✅ PRD 준수 | 최신 타입 정의 |
| `benefit.ts` - `Announcement` | ✅ PRD 준수 | v7.3 기준 최신 |

---

### 4. React Admin API

| 파일 | 불일치 사항 | 수정 필요 |
|------|-----------|----------|
| `categories.ts` | `display_order` → `sort_order` | fetchBenefitCategories() |
| `banners.ts` | `category_id`, `link_url`, `display_order` | 모든 함수 |
| `announcements.ts` | `category_id` → `type_id` | fetchAnnouncements() |

---

## 🛠️ 수정 가능성 평가

### 자동 치환 가능 (Safe Refactoring)
✅ **가능한 경우:**
- TypeScript 파일 (컴파일러가 에러 감지)
- JSON 키 매핑만 수정 (Dart `@JsonKey`)
- Provider 변수명 (IDE 리팩터링 도구 사용)

### 수동 검토 필요 (Manual Review Required)
⚠️ **주의 필요:**
- Freezed 모델 (재생성 필요)
- DB 스키마 변경 (마이그레이션 작성)
- 레거시 모델 통합 (contexts → features)

### 위험 (High Risk)
❌ **즉시 수정 금지:**
- `database.ts` (Supabase CLI 재생성 필요)
- 두 개의 Announcement 모델 병합 (충돌 해결 필요)

---

## 📊 통계 요약

### 파일별 영향도
| 카테고리 | 파일 수 | 불일치 건수 | 우선순위 |
|---------|--------|-----------|---------|
| Flutter Contexts Models | 6 | 47 | HIGH |
| Flutter Features Models | 2 | 0 | ✅ OK |
| React Admin Types | 3 | 31 | MEDIUM |
| React Admin API | 3 | 23 | MEDIUM |
| Flutter Providers | 37 | 46 | LOW |
| React Admin Components | 24 | - | LOW |
| **총합** | **75** | **147** | - |

---

## 🚨 Critical Issues (즉시 조치 필요)

### 1. 이중 Announcement 모델 문제
**위치:**
- `/contexts/benefit/models/announcement.dart` (레거시)
- `/features/benefits/models/announcement.dart` (최신)

**문제:**
- 두 모델이 서로 다른 스키마 기준으로 작성됨
- `contexts` 모델은 PRD v7.0 기준 (구 스키마)
- `features` 모델은 PRD v7.3 기준 (신 스키마)

**해결 방안:**
1. **Option A (권장):** `/contexts/` 모델 삭제, `/features/` 모델로 통합
2. **Option B:** `/contexts/` 모델을 PRD v7.3 기준으로 완전 리팩토링

---

### 2. category_banners 테이블 스키마 불일치
**문제:**
- PRD v7.3: `benefit_category_id`, `link_type`, `link_target`, `sort_order`
- 현재 DB: `category_id`, `link_url`, `display_order` (+ `start_date`, `end_date`)

**해결 방안:**
1. DB 마이그레이션 생성:
   ```sql
   ALTER TABLE category_banners
   RENAME COLUMN category_id TO benefit_category_id;

   ALTER TABLE category_banners
   RENAME COLUMN link_url TO link_target;

   ALTER TABLE category_banners
   RENAME COLUMN display_order TO sort_order;

   ALTER TABLE category_banners
   ADD COLUMN link_type TEXT DEFAULT 'none' CHECK (link_type IN ('internal', 'external', 'none'));

   ALTER TABLE category_banners
   DROP COLUMN start_date,
   DROP COLUMN end_date;
   ```

2. Supabase 타입 재생성:
   ```bash
   npx supabase gen types typescript --local > apps/pickly_admin/src/types/database.ts
   ```

3. 모든 API/모델 코드 동기화

---

### 3. benefit_categories 테이블 스키마 불일치
**문제:**
- PRD v7.3: `title`, `sort_order`
- 현재 DB: `name`, `display_order`

**해결 방안:**
1. DB 마이그레이션:
   ```sql
   ALTER TABLE benefit_categories
   RENAME COLUMN name TO title;

   ALTER TABLE benefit_categories
   RENAME COLUMN display_order TO sort_order;
   ```

2. Flutter Freezed 모델 재생성
3. React Admin 타입 및 API 코드 동기화

---

## 📝 Action Items

### Phase 1: DB Schema Migration (1-2일)
- [ ] `benefit_categories` 스키마 수정 마이그레이션 작성
- [ ] `category_banners` 스키마 수정 마이그레이션 작성
- [ ] 로컬 Supabase에서 마이그레이션 테스트
- [ ] Supabase 타입 재생성 (`database.ts`)

### Phase 2: Flutter Models (2-3일)
- [ ] `/contexts/benefit/models/` 레거시 모델 분석
- [ ] `/features/benefits/models/` 최신 모델로 통합 결정
- [ ] `BenefitCategory` Freezed 모델 수정 및 재생성
- [ ] `AnnouncementTab` JSON 키 매핑 수정
- [ ] 기존 Provider/Repository 코드 동기화 테스트

### Phase 3: React Admin (1-2일)
- [ ] `types/benefit.ts` 타입 검증 (이미 최신)
- [ ] `api/categories.ts` 필드명 수정
- [ ] `api/banners.ts` 필드명 및 타입 수정
- [ ] `api/announcements.ts` 필드명 수정
- [ ] 관련 컴포넌트 TypeScript 에러 수정

### Phase 4: Testing & Validation (1-2일)
- [ ] Flutter 앱 빌드 테스트
- [ ] React Admin 빌드 테스트
- [ ] 통합 테스트 (DB ↔ API ↔ UI)
- [ ] PRD v7.3 compliance 체크리스트 검증

---

## 🔧 권장 수정 순서

### Step 1: Database First (가장 먼저)
1. DB 마이그레이션 작성 및 적용
2. Supabase 타입 재생성

### Step 2: Type Definitions (두 번째)
3. React Admin `database.ts` 업데이트
4. Flutter 모델 스키마 업데이트

### Step 3: API & Repositories (세 번째)
5. React Admin API 함수 수정
6. Flutter Repository 수정

### Step 4: UI Layer (마지막)
7. Provider 수정
8. 컴포넌트 수정

---

## 📚 참고 문서

- **PRD v7.3:** `/PRD.md` (Line 66-241)
- **DB Schema:** `benefit_categories`, `category_banners`, `announcement_types`, `announcements`
- **Flutter Models:** `/apps/pickly_mobile/lib/contexts/` vs `/apps/pickly_mobile/lib/features/`
- **React Admin Types:** `/apps/pickly_admin/src/types/`

---

## ✅ Checklist: PRD v7.3 Compliance

### benefit_categories
- [ ] `title` (not `name`)
- [ ] `icon_url` (not `iconUrl`, `icon_path`)
- [ ] `sort_order` (not `displayOrder`, `display_order`)
- [ ] `is_active`

### category_banners
- [ ] `benefit_category_id` (not `category_id`, `categoryId`)
- [ ] `title`
- [ ] `subtitle`
- [ ] `image_url`
- [ ] `link_type` (ENUM: `internal`, `external`, `none`)
- [ ] `link_target` (not `actionUrl`, `link_url`)
- [ ] `sort_order` (not `displayOrder`, `display_order`)
- [ ] `is_active`

### announcement_types
- [ ] `benefit_category_id` (not `category_id`)
- [ ] `title`
- [ ] `description`
- [ ] `sort_order`
- [ ] `is_active`

### announcements
- [ ] `type_id` (not `announcementType`, `category_id`)
- [ ] `title`
- [ ] `organization`
- [ ] `region`
- [ ] `thumbnail_url` (not `thumbnailUrl`)
- [ ] `posted_date`
- [ ] `status` (ENUM: `active`, `closed`, `upcoming`)
- [ ] `is_priority` (not `isFeatured`, `is_featured`)
- [ ] `detail_url`

---

**Report Generated:** 2025-10-28
**Total Inconsistencies:** 147
**Files Analyzed:** 75
**Estimated Fix Time:** 6-9 working days
