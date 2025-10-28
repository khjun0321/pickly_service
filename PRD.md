# 📘 Pickly PRD v8.2 — 혜택관리 + 연령대관리 통합 시스템 (2025.10.29 업데이트)

## 🧭 개요
본 버전(v8.2)은 **Pickly Admin, Supabase, Flutter** 간의 데이터 구조를 완전 통합한 버전입니다.  
이전 버전(v7.3~v8.1)에서 분리되어 있던 “혜택 관리”, “연령대 관리”, “공고 관리”를  
단일 CRUD/UI 패턴으로 통일하고, **실시간 반영(Realtime Sync)** 체계를 적용했습니다.

---

## 🎯 주요 목표
| 항목 | 내용 |
|------|------|
| 🧠 데이터 일관성 | 모든 관리 항목(`연령대`, `혜택`, `정책`, `공고`)을 단일 스키마로 통합 |
| ⚙️ Supabase 구조 정리 | naming rule(`name→title`, `icon_path→icon_url`, `display_order→sort_order`) 통일 |
| 🔁 실시간 연동 | Admin 변경 즉시 Flutter 반영 (Supabase Realtime 사용) |
| 🧩 UI/UX 일관성 | 연령대 관리 CRUD UX = 혜택 관리 CRUD UX |
| 🧱 확장성 | 정책 세부 구조 및 공고 확장에 유연하게 대응 |
| 🔒 Seed 안정성 | `DELETE + ON CONFLICT` 기반으로 rollback 문제 완전 제거 |

---

## 🧱 통합 데이터 구조

### 1️⃣ 연령대 관리 (age_categories)
```sql
CREATE TABLE age_categories (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  description text,
  icon_component text,
  icon_url text,
  min_age int,
  max_age int,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

### 2️⃣ 혜택 카테고리 (benefit_categories)
```sql
CREATE TABLE benefit_categories (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  title text NOT NULL,
  description text,
  icon_url text,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

### 3️⃣ 혜택 상세 (benefit_details)
```sql
CREATE TABLE benefit_details (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  benefit_category_id uuid REFERENCES benefit_categories(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  icon_url text,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);
```

### 4️⃣ 혜택 공고 (benefit_announcements)
```sql
CREATE TABLE benefit_announcements (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  benefit_detail_id uuid REFERENCES benefit_details(id) ON DELETE CASCADE,
  title text NOT NULL,
  description text,
  link_url text,
  source text,
  start_date date,
  end_date date,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
```

### 5️⃣ 혜택 배너 (category_banners)
```sql
CREATE TABLE category_banners (
  id uuid PRIMARY KEY DEFAULT uuid_generate_v4(),
  benefit_category_id uuid REFERENCES benefit_categories(id) ON DELETE CASCADE,
  title text NOT NULL,
  subtitle text,
  image_url text,
  link_type text,
  link_target text,
  sort_order int DEFAULT 0,
  is_active boolean DEFAULT true,
  created_at timestamptz DEFAULT now()
);
```

---

## 🧩 Naming Rule 통일표
| 구분 | 변경 전 | 변경 후 |
|------|----------|----------|
| 컬럼명 | `name` | **`title`** |
| 컬럼명 | `display_order` | **`sort_order`** |
| 컬럼명 | `icon_path` | **`icon_url`** |
| 컬럼명 | `icon_component` | 유지 (디자인시스템 내 로컬 참조용) |
| 테이블명 | `announcement_types` | **`benefit_details`** |
| 시드파일 | 통합 `seed.sql` + 하위 모듈 `/seeds/` 구조 | ✅ 완료 |

---

## 🧠 Seed 안정화
- `TRUNCATE` → `DELETE` + `ON CONFLICT` 구조로 변경  
- `_stable_seed_v8.1.sql` 생성 (rollback 방지)
- `uuid_generate_v4()` 오류 해결 및 `uuid-ossp`, `pgcrypto` 확장 포함

```
supabase/
├── seed.sql
└── seeds/
    ├── admin_account.sql
    ├── age_categories.sql
    ├── benefit_categories.sql
    ├── benefit_details.sql
    ├── category_banners.sql
    └── benefit_announcements.sql
```

---

## 🧰 Pickly Admin (React + MUI)
```
혜택 관리 (BenefitDashboard)
 ├─ 혜택 카테고리 관리 (benefit_categories)
 ├─ 정책 상세 관리 (benefit_details)
 ├─ 공고 관리 (benefit_announcements)
 └─ 배너 관리 (category_banners)
```
**공통 기능**
- CRUD (추가/수정/삭제)
- SVG 업로드 / Fallback 표시
- sort_order 정렬
- 활성화 토글
- 모달 기반 UX (연령대 관리 동일)

---

## 📱 Pickly Mobile (Flutter)
```
혜택탭 (benefits_screen.dart)
 ├─ 써클탭: benefit_categories
 │   ├─ 하위탭: benefit_details (행복주택, 국민임대주택 등)
 │   │   ├─ 공고리스트: benefit_announcements
 │   │   └─ 상세페이지: 공고별 세부 내용
```

**Provider 구조**
```dart
final benefitCategoriesProvider = FutureProvider<List<BenefitCategory>>(...);
final benefitDetailsProvider = FutureProvider.family<List<BenefitDetail>, String>(...);
final benefitAnnouncementsProvider = FutureProvider.family<List<BenefitAnnouncement>, String>(...);
```

**Realtime 연동**
```dart
supabase.channel('benefit_details')
  .on(SupabaseEventTypes.insert, (_) => ref.invalidate(benefitDetailsProvider))
  .on(SupabaseEventTypes.update, (_) => ref.invalidate(benefitDetailsProvider))
  .on(SupabaseEventTypes.delete, (_) => ref.invalidate(benefitDetailsProvider))
  .subscribe();
```

---

## 🔒 RLS 정책 요약
| 테이블 | 정책 |
|--------|------|
| benefit_categories | Public SELECT / Authenticated CRUD |
| benefit_details | Public SELECT / Authenticated CRUD |
| benefit_announcements | Public SELECT / Authenticated CRUD |
| category_banners | Public SELECT / Authenticated CRUD |
| age_categories | Public SELECT / Authenticated CRUD |

---

## 🚀 브랜치 및 배포 전략
| 항목 | 브랜치 | 설명 |
|------|----------|------|
| Admin | `feature/fix-benefit-admin-structure` | 혜택 CRUD 및 상세정책 UI 통합 |
| Flutter | `feature/benefit-sync-flutter-realtime` | 실시간 반영 로직 |
| DB | `feature/refactor-db-schema` | 통합 스키마 정비 |
| Seed 안정화 | `feature/fix-stable-v8.1` | rollback 방지 seed |
| Main | `main` | 전체 통합 배포 브랜치 |

---

## ✅ 결과 요약
| 항목 | 개선 사항 |
|------|-------------|
| Admin ↔ Supabase ↔ Flutter | 완전한 실시간 연동 |
| UI 일관성 | 연령대 CRUD = 혜택 CRUD 동일 UX |
| Naming Rule | 전체 일관화 완료 |
| Seed 안정성 | rollback 완전 방지 |
| 구조 확장성 | 지자체/기관 혜택까지 대응 가능 |

---

## 📋 Claude 명령 (자동 적용용)
> Claude, please overwrite `/docs/PRD.md` with this v8.2 version.  
> Then sync Supabase schema, Admin UI, and Flutter providers to match this structure.  
> Commit to `feature/benefit-sync-flutter-realtime` and confirm successful migration.
