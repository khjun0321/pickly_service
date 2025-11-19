# 🧭 Pickly Service — PRD v7.3 (2025-10-28 업데이트)
정부 정책 큐레이션 서비스 **Pickly**의 핵심 제품 명세 문서 (Product Requirements Document)

---

## 🎯 프로젝트 개요

### 서비스 목적
정부·지자체의 복잡한 정책과 공고를 사용자에게 **맞춤형으로 큐레이션**해 제공하는 서비스.  
(예: 행복주택, 국민임대, 전세자금, 복지, 취업 지원 등)

### 핵심 가치
1. **개인화** — 사용자 정보 기반 정책 추천  
2. **단순화** — 어려운 공고문을 시각화하여 쉽게 이해  
3. **접근성** — 앱·웹 어디서나 확인 가능  
4. **실용성** — 실제 신청 절차로 바로 연결

---

## 🏗️ 시스템 구성

### 1. 기술 스택
| 구분 | 기술 | 설명 |
|------|------|------|
| Frontend (모바일) | Flutter | iOS / Android / Web 대응 |
| Frontend (관리자) | React + TypeScript | 백오피스용 웹 대시보드 |
| Backend | Supabase (PostgreSQL) | 인증 + DB + Storage + Edge Functions |
| CI/CD | GitHub Actions + Melos | 멀티패키지 자동 빌드 및 배포 |
| 디자인 | Figma + Pickly Design System | 자체 토큰 기반 UI 시스템 |

---

## 🧱 데이터베이스 구조 (Supabase)

### ✅ 테이블: `age_categories`
**역할:** 온보딩 및 정책 추천에서 사용자 연령대 기준 관리

| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | UUID (PK) | 자동 생성 |
| `title` | TEXT | 연령대 명칭 (예: 청년, 어르신 등) |
| `description` | TEXT | 설명 문구 |
| `icon_component` | TEXT | 앱 내 렌더링용 아이콘 컴포넌트명 |
| `icon_url` | TEXT | 업로드된 SVG 아이콘 경로 (Supabase Storage URL) |
| `min_age` | INTEGER | 최소 연령 |
| `max_age` | INTEGER | 최대 연령 |
| `sort_order` | INTEGER | 정렬 순서 |
| `is_active` | BOOLEAN | 활성화 여부 |
| `created_at` | TIMESTAMP | 생성일 |
| `updated_at` | TIMESTAMP | 수정일 |

#### 📦 기본 시드 데이터 (6종)
| 순번 | 연령대 | 설명 | 컴포넌트명 |
|------|--------|------|-------------|
| 1 | 청년 | (만 19세~39세) 대학생·취준생·직장인 | `young_man` |
| 2 | 신혼부부·예비부부 | 결혼 예정 또는 결혼 7년 이내 | `bride` |
| 3 | 육아중인 부모 | 영유아~초등 자녀 양육 중 | `baby` |
| 4 | 다자녀 가구 | 자녀 2명 이상 양육 중 | `kinder` |
| 5 | 어르신 | 만 65세 이상 | `old_man` |
| 6 | 장애인 | 장애인 등록 대상 | `wheel_chair` |

> 데이터 삽입 스크립트: `/supabase/seed_age_categories.sql`

---

## 🆕 v7.3: Benefit Management System (혜택 관리 시스템)

### 개요
사용자에게 정부·지자체 정책 공고를 **카테고리별로 분류**하여 제공하고, **배너/필터/공고 리스트**를 통합 관리하는 시스템.

### 주요 기능
1. **9개 혜택 카테고리** (인기/주거/교육/건강/교통/복지/취업/지원/문화)
2. **카테고리별 배너** (캐러셀 형태, 관리자가 업로드)
3. **공고 유형 필터** (청년/신혼부부/고령자 등 - 다중 선택 가능)
4. **공고 리스트** (LH/SH/GH 등 기관별 공고)
5. **우선 표시** (중요 공고 상단 고정)

---

### 📊 테이블 구조

#### 1️⃣ `benefit_categories` (혜택 카테고리)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | UUID (PK) | 자동 생성 |
| `title` | TEXT | 카테고리 명 (인기/주거/교육 등) |
| `icon_url` | TEXT | 아이콘 URL (Supabase Storage) |
| `sort_order` | INTEGER | 정렬 순서 |
| `is_active` | BOOLEAN | 활성화 여부 |
| `created_at` | TIMESTAMP | 생성일 |
| `updated_at` | TIMESTAMP | 수정일 |

**기본 데이터:**
- 인기, 주거, 교육, 건강, 교통, 복지, 취업, 지원, 문화 (9개)

---

#### 2️⃣ `category_banners` (카테고리별 배너)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | UUID (PK) | 자동 생성 |
| `benefit_category_id` | UUID (FK) | 혜택 카테고리 ID |
| `title` | TEXT | 배너 제목 |
| `subtitle` | TEXT | 부제목 (선택) |
| `image_url` | TEXT | 배너 이미지 URL |
| `link_type` | ENUM | `internal`, `external`, `none` |
| `link_target` | TEXT | 클릭 시 이동할 경로/URL |
| `sort_order` | INTEGER | 정렬 순서 (캐러셀) |
| `is_active` | BOOLEAN | 활성화 여부 |
| `created_at` | TIMESTAMP | 생성일 |
| `updated_at` | TIMESTAMP | 수정일 |

**예시:**
- "청년 주거 지원 종합" 배너 → 주거 카테고리
- "복지 혜택 모음" 배너 → 복지 카테고리

---

#### 3️⃣ `announcement_types` (공고 유형)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | UUID (PK) | 자동 생성 |
| `benefit_category_id` | UUID (FK) | 혜택 카테고리 ID |
| `title` | TEXT | 유형명 (청년/신혼부부/고령자 등) |
| `description` | TEXT | 설명 |
| `sort_order` | INTEGER | 정렬 순서 |
| `is_active` | BOOLEAN | 활성화 여부 |
| `created_at` | TIMESTAMP | 생성일 |
| `updated_at` | TIMESTAMP | 수정일 |

**예시:**
- 주거 카테고리 → 청년, 신혼부부, 고령자 유형
- 복지 카테고리 → 아동, 장애인, 어르신 유형

---

#### 4️⃣ `announcements` (개별 공고)
| 컬럼 | 타입 | 설명 |
|------|------|------|
| `id` | UUID (PK) | 자동 생성 |
| `type_id` | UUID (FK) | 공고 유형 ID |
| `title` | TEXT | 공고 제목 |
| `organization` | TEXT | 발행 기관 (LH/SH/GH) |
| `region` | TEXT | 지역 (서울/경기 등) |
| `thumbnail_url` | TEXT | 썸네일 이미지 |
| `posted_date` | DATE | 게시일 |
| `status` | ENUM | `active`, `closed`, `upcoming` |
| `is_priority` | BOOLEAN | 우선 표시 여부 |
| `detail_url` | TEXT | 상세 페이지 URL |
| `created_at` | TIMESTAMP | 생성일 |
| `updated_at` | TIMESTAMP | 수정일 |

**예시:**
- "2025 행복주택 청년 특별공급" → 주거 카테고리, 청년 유형
- "서울형 육아휴직 지원금" → 복지 카테고리, 육아중인 부모 유형

---

### 📦 Storage Buckets

| 버킷명 | 용도 | 공개 여부 |
|--------|------|----------|
| `benefit-banners` | 카테고리 배너 이미지 | 공개 (Public) |
| `benefit-thumbnails` | 공고 썸네일 이미지 | 공개 (Public) |
| `benefit-icons` | 혜택 카테고리 아이콘 | 공개 (Public) |

**RLS 정책:**
- 읽기: 모든 사용자 허용
- 쓰기/수정/삭제: 인증된 관리자만 허용

---

### 🧩 Admin Interface (관리자 페이지)

#### 1. 배너 관리 (`/admin/banners`)
- 카테고리별 배너 CRUD
- 이미지 업로드 (Supabase Storage)
- 링크 설정 (internal/external/none)
- 순서 조정 (드래그 앤 드롭)

#### 2. 공고 유형 관리 (`/admin/announcement-types`)
- 카테고리별 유형 CRUD
- 유형명, 설명 입력
- 순서 조정

#### 3. 공고 관리 (`/admin/announcements`)
- 공고 CRUD (제목/기관/지역/썸네일/상태)
- 유형 선택 (드롭다운)
- 우선 표시 설정
- 외부 URL 연결

---

### 📱 Flutter App Structure

#### 홈 화면 (`BenefitHomeScreen`)
```
├── AppBar (카테고리 탭)
│   └── [인기] [주거] [교육] [건강] [교통] [복지] [취업] [지원] [문화]
├── 배너 캐러셀 (category_banners)
│   └── PageView + Indicator
├── 필터 버튼 ("필터 선택")
│   └── Bottom Sheet 열기
└── 공고 리스트 (announcements)
    ├── 우선 공고 (is_priority: true)
    └── 일반 공고 (created_at 최신순)
```

#### 필터 Bottom Sheet
- 온보딩에서 사용한 `OnboardingPolicyBottomSheet` 재사용
- 다중 선택 (CheckboxListTile)
- "적용" 버튼 → Riverpod Provider 업데이트
- 선택된 필터: `.in_()` 쿼리로 필터링

#### Riverpod Providers
```dart
// 1. 선택된 카테고리 Provider
final selectedBenefitCategoryProvider = StateProvider<String?>((ref) => '인기');

// 2. 선택된 필터 Provider (다중 선택)
final selectedAnnouncementTypesProvider = StateProvider<List<String>>((ref) => []);

// 3. 공고 리스트 Provider (필터 적용)
final announcementsProvider = FutureProvider.autoDispose<List<Announcement>>((ref) async {
  final category = ref.watch(selectedBenefitCategoryProvider);
  final types = ref.watch(selectedAnnouncementTypesProvider);

  // Supabase query with filters
  var query = supabase
      .from('v_announcements_full')
      .select()
      .eq('category_title', category);

  if (types.isNotEmpty) {
    query = query.in_('type_title', types);
  }

  return (await query).map((e) => Announcement.fromJson(e)).toList();
});
```

---

## 🧩 백오피스 (관리자용)

### ✅ 연령대 관리 (Age Management)
- CRUD 기능 (Create / Read / Update / Delete)
- SVG 아이콘 업로드 (Supabase Storage 연동)
- 제목(title), 설명(description), 아이콘(icon_url) 관리
- 연령 범위(min_age / max_age), 정렬 순서(sort_order), 활성화 여부(is_active)
- 기존 ‘연령 카테고리 관리’ 페이지는 통합되어 완전히 삭제됨

### ⚙️ 공고 관리 (Announcements)
- 공고 목록 및 상세 관리
- LH / SH / GH 등 기관별 정책 공고 분류
- API 매핑 및 필터 탭 구성
- 다중 선택형 써클 탭 구조 (주거 / 복지 / 취업 등)
- 각 공고별 `announcement_type` 연계

---

## 🧩 모바일 앱 (Flutter)

### Onboarding Flow
1. 사용자 유형 선택 (청년, 신혼부부, 고령자 등)
2. 관심 정책 영역 선택 (주거 / 복지 / 취업 등)
3. 맞춤형 공고 추천 리스트 표시

### 공고 상세 화면
- TabBar 구성: 기본 정보 / 자격요건 / 신청방법 / 이미지 / 파일
- 사용자 유형(예: 청년) 기반 우선 표시
- 다른 유형도 탭 전환으로 확인 가능
- Supabase DB의 announcement_sections 구조 기반 렌더링

---

## ⚙️ 자동화 및 배포

### Supabase 설정
- Project Ref: `vymxxpjxrorpywfmqpuk`
- Local DB Container: `supabase_db_supabase`
- Seed File: `supabase/seed_age_categories.sql`
- Migration Script: `/backend/supabase/migrations/20251027000002_add_announcement_types_and_custom_content.sql`

### 자동 배포 스크립트
| 파일 | 역할 | 자동화 여부 |
|------|------|-------------|
| `scripts/auto_setup_v7.3.sh` | v7.3 DB + Storage + PRD + Git 자동 세팅 | ✅ 자동 |
| `scripts/auto_release_v7.2_safe.sh` | v7.2 안전 버전 배포 | ✅ 자동 커밋+푸시 포함 |
| `scripts/auto_deploy_setup.sh` | 초기 자동 배포 환경 구성 | ✅ |
| `scripts/quick_verify.sh` | Supabase 제외 빠른 검증 | ✅ (리포트 커밋만) |

> **v7.3 배포 순서:**
> 1. `bash scripts/auto_setup_v7.3.sh` (DB + Storage + PRD + Git)
> 2. Admin 페이지 구현 (별도 작업)
> 3. Flutter 앱 통합 (별도 작업)
> 4. PR 생성 및 배포

---

## 🧾 문서 및 버전 관리

### PRD 버전 히스토리

| 버전 | 주요 변경 사항 |
|------|----------------|
| **v7.3 (2025-10-28)** | - Benefit Management System 추가<br>- 4개 테이블 (`benefit_categories`, `category_banners`, `announcement_types`, `announcements`)<br>- 3개 Storage 버킷 (`benefit-banners`, `benefit-thumbnails`, `benefit-icons`)<br>- Admin 배너/유형/공고 관리 페이지 계획<br>- Flutter 필터 Bottom Sheet 및 공고 리스트 통합<br>- `auto_setup_v7.3.sh` 자동화 스크립트 생성 |
| **v7.2 (2025-10-28)** | - `age_categories` 구조 업데이트 (name → title 등)<br>- `uuid_generate_v4()` 확장 추가 및 `pgcrypto` 활성화<br>- 기본 연령대 6종 시드 추가<br>- `연령 카테고리` → `연령대 관리` 통합 완료<br>- Admin SVG 업로드 및 CRUD 완성<br>- Supabase 자동 배포 스크립트 완성<br>- PRD / IMPLEMENTATION / DEPLOYMENT 문서 동기화 완료 |
| **v7.1** | 공고 상세 TabBar UI 추가 및 LH API 매핑 구조 설계 |
| **v7.0** | Onboarding Flow & DB 초기 스키마 정의 |
| **v6.x 이하** | 초기 구조 설계 및 Pickly Design System 정의 |

---

## 🧠 운영 및 개발 규칙
- 모든 Supabase 마이그레이션은 `supabase/migrations/` 내 SQL 기반으로 관리  
- PRD 스키마 변경 시 반드시 문서 갱신 후 커밋 (`docs: update table spec …`)
- 자동화 스크립트 실행 전, 로컬 변경사항은 `git status`로 확인 필수
- Claude Flow / Windsurf 에이전트 실행 시, 사용자 승인 없는 DB Drop 금지
- 테이블 구조(title, icon_url 등) 변경 시 사용자 승인 필요

---

## ✅ Phase 1 완료 요약 (v7.2 기준)
| 기능 | 상태 | 비고 |
|------|------|------|
| 연령대 관리 (Age Management) | ✅ 완료 | CRUD + SVG 업로드 완전 통합 |
| Supabase 자동 배포 | ✅ 완료 | 안전 버전 스크립트 실행 검증 |
| 시드 데이터 삽입 | ✅ 완료 | 6개 기본 연령대 정상 반영 |
| DB 확장(uuid, pgcrypto) | ✅ 완료 | 로컬 + 원격 동기화 |
| PRD / Docs 동기화 | ✅ 완료 | v7.2 기준 최신 반영 |

---

## 🚀 Phase 2 진행 중 (v7.3 기준)
| 기능 | 상태 | 비고 |
|------|------|------|
| Benefit Management 테이블 | ✅ 완료 | 4개 테이블 마이그레이션 생성 |
| Storage 버킷 설정 | ✅ 완료 | 3개 버킷 + RLS 정책 |
| Admin 배너 관리 | ⏳ 대기 | React 컴포넌트 구현 예정 |
| Admin 공고 유형 관리 | ⏳ 대기 | React 컴포넌트 구현 예정 |
| Admin 공고 관리 | ⏳ 대기 | React 컴포넌트 구현 예정 |
| Flutter 필터 Bottom Sheet | ⏳ 대기 | 온보딩 컴포넌트 재사용 |
| Flutter 공고 리스트 | ⏳ 대기 | Riverpod Provider 구현 |

---

📄 **최종 업데이트:** 2025-10-28
🧑‍💻 담당: 권현준 (Pickly Project Lead)
🧩 버전: PRD v7.3 (Benefit Management System)