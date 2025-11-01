# 🧭 Pickly Service — PRD v8.4 (2025-11-01 Final)

## 📋 문서 정보

| 항목 | 내용 |
|------|------|
| **버전** | v8.4 (Final Pipeline + Wall + Automation) |
| **작성일** | 2025-11-01 |
| **상태** | Production Ready |
| **적용 범위** | Supabase, Admin (React), Mobile (Flutter), Automation (Claude Flow) |
| **위치** | /docs/prd/PRD_v8.4_Final_Pipeline_Wall.md |

---

## 🎯 서비스 목적

1인 가구 및 청년층을 위한 **실시간 맞춤형 공공 혜택 큐레이션 플랫폼**.

- 🔍 공공 API에서 데이터를 자동 수집
- ⚙️ Admin에서 데이터 정제 및 배포
- 📱 Flutter 앱에서 개인 맞춤 필터로 노출
- 🧠 Claude Flow로 병렬 개발 및 자동 배포

---

## 🧱 시스템 전체 구조 (Pipeline + Wall)

### 🔹 Pipeline (데이터 흐름)

```
공공 API
   ↓ (Supabase Function: fetch-lh-announcements)
Supabase DB (benefit_categories, announcement_types, announcements)
   ↓ (Realtime Sync)
Admin (React) - 데이터 관리 및 SVG 업로드
   ↓ (자동 반영)
Flutter App (사용자 노출)
```

### 🔹 Wall (기능 영역 분리)

| 기능 | 스토리지 버킷 | 경로 예시 | 접근 제한 |
|------|----------------|------------|------------|
| 연령대 아이콘 | pickly-icons/age/ | icons/age/youth.svg | age_categories 전용 |
| 혜택 카테고리 아이콘 | pickly-icons/benefit/ | icons/benefit/housing.svg | benefit_categories 전용 |
| 공고 썸네일 | pickly-thumbnails/ | thumbnails/announcements/uuid.jpg | announcements 전용 |
| 배너 이미지 | pickly-banners/ | banners/housing/banner1.png | category_banners 전용 |

✅ *서로 다른 기능이 동일 버킷을 절대 공유하지 않음.*  
→ SVG 업로드 충돌 문제 해결.  

---

## 🧩 데이터 구조 요약

- **benefit_categories**: 주거/교육/취업 등 대분류
- **announcement_types**: 세부 유형 (예: 청년, 신혼부부)
- **announcements**: 실제 공고 데이터 (상태, 마감일, 조회수 포함)
- **category_banners**: 카테고리별 배너
- **age_categories**: 필터용 연령대 그룹

> 모든 테이블은 PRD v8.3 구조 유지하며, status='recruiting'이 기본 필터.  

---

## 🧠 Repository Pattern (Flutter)

### 목적
Flutter에서 Supabase 직접 접근을 방지하고, 데이터 계층을 분리하기 위함.

### 구조
```
lib/
├── core/supabase/
├── contexts/benefits/repositories/
│   ├── announcement_repository.dart
│   ├── benefit_category_repository.dart
│   └── banner_repository.dart
└── features/benefits/
```

### 규칙
1. Supabase 호출은 Repository 내부에서만 수행.  
2. Riverpod Provider는 Repository를 감싸는 형태로 작성.  
3. 각 Repository는 `Future<T>` 구조를 따름.  
4. 필터링, 정렬, D-day 계산은 Repository에서 처리.  

예: `announcement_repository.dart`
```dart
Future<List<Announcement>> getPopularAnnouncements({
  List<String>? categoryIds,
  int limit = 20,
}) async { ... }
```

---

## 🧩 Admin (React) — UI 플로우 개선

### 변경 요약
| 항목 | 기존 | 변경 |
|------|------|------|
| 공고 수정 | 우측 슬라이드 패널 | 별도 수정 페이지 |
| 카테고리 추가 | 상단 버튼 + 새 페이지 | 상단 모달 (Modal) |
| 배너 관리 | 별도 페이지 | 동일 화면 내 모달 |
| 상태 변경 | 수정페이지 내 | 리스트 인라인 수정 가능 |
| SVG 업로더 | 중복 구현 | 연령대 업로더 재사용 |

### 구조
```
apps/pickly_admin/src/pages/benefits/
├── index.tsx               ← 리스트
├── edit.tsx                ← 수정
├── modals/
│   ├── AddCategoryModal.tsx
│   ├── EditBannerModal.tsx
│   └── SVGUploader.tsx
└── hooks/
```

---

## ⚙️ 자동화 및 Claude Flow 통합

### 개발용 명령
```
claude-flow init
claude-flow hierarchy create pickly-flow
claude-flow spawn backend-architect
claude-flow spawn flutter-developer
claude-flow spawn frontend-architect
claude-flow spawn db-agent
claude-flow spawn pipeline-tester
```

### 병렬 개발 파이프라인
```
backend-architect  → Supabase migration & Functions
flutter-developer  → Repository 및 Riverpod 연결
frontend-architect → Admin 모달 UI 및 Realtime 반영
db-agent           → 마이그레이션 충돌 점검
pipeline-tester    → 전체 데이터 흐름 검증
```

### 배포 자동화
```
bash scripts/auto_setup_v8.4.sh
bash scripts/deploy_frontend_admin.sh
bash scripts/deploy_mobile_flutter.sh
bash scripts/check_integrity.sh
```

---

## 🧩 Supabase 마이그레이션 규칙

| 항목 | 규칙 |
|------|------|
| 기존 SQL 수정 | ❌ 금지 |
| 신규 마이그레이션 | ✅ `YYYYMMDDHHMMSS_feature.sql` 로 추가 |
| seed 데이터 | ✅ `supabase/seeds/` 폴더에 저장 |
| Storage 정책 | ✅ 기능별 버킷 분리 적용 |
| 함수 명명 | ✅ `fetch_`, `update_`, `sync_` 접두사 사용 |

---

## 🧩 테스트 및 검증

| 테스트 항목 | 방법 | 담당 |
|--------------|------|------|
| 데이터 파이프라인 | Claude Flow `pipeline-tester` 실행 | Claude Flow |
| Supabase RLS 정책 | SQL 정책 파일 점검 | db-agent |
| Admin ↔ Flutter 실시간 반영 | Realtime Event Watcher | flutter-developer |
| SVG 업로드 경로 | 버킷별 접근 테스트 | frontend-architect |

---

## 🪄 앱 기능 요약

- 홈 탭: 카테고리별 최신/인기 공고 표시  
- 인기 탭: 조회수순 (주거+취업 통합)  
- 마감임박: deadline_date 기준 D-day 표시  
- 검색: `search_vector` 기반 텍스트 검색  
- 필터: 연령대 + 지역 + 상태  
- 정렬: 최신순 / 조회수순 / 마감임박순  

---

## 🚀 배포 및 운영 정책

| 구분 | 내용 |
|------|------|
| 배포 방식 | Claude Flow → GitHub CI/CD → Supabase + Vercel + Flutter build |
| 환경 구분 | dev / staging / prod |
| 자동 테스트 | pipeline-tester |
| 앱스토어 배포 | Windsurf 또는 Fastlane으로 자동화 |
| 장애 모니터링 | Supabase Logs + Sentry + Flutter Error Reporting |

---

## ✅ 변경 이력

| 버전 | 날짜 | 주요 변경 |
|------|------|-----------|
| **v8.4** | 2025-11-01 | ✅ Pipeline + Wall 구조, Repository 계층, Admin 모달 플로우, Claude Flow 자동화 추가 |
| v8.3 | 2025-10-29 | FrontStable DataPipe 버전 |
| v8.1 | 2025-10-29 | 기존 PRD 기반 초기 완성판 |

---

## ✅ 최종 요약

- **Pipeline**: Supabase → Admin → Flutter 간 데이터 플로우 정리 완료  
- **Wall**: 스토리지 파이프 분리로 충돌 방지  
- **Repository**: Flutter 구조 통합 및 재사용성 확보  
- **Admin**: UX 규칙 명시 (탭 + 모달 구조)  
- **Automation**: Claude Flow 기반 병렬 개발 및 자동 배포 가능  

**문서 경로:** `/docs/prd/PRD_v8.4_Final_Pipeline_Wall.md`  
**작성자:** Pickly Team (with GPT-5 Assistant)
