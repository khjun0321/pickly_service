# PRD v8.1 Implementation Plan

## 개요
혜택 통합관리 시스템 구현 계획서

## Phase 1: 데이터베이스 설계 ✅
### 완료 항목
- [x] `benefit_categories` 테이블 생성
- [x] `benefit_details` 테이블 생성
- [x] `benefit_announcements` 테이블 생성
- [x] `category_banners` 테이블 생성
- [x] RLS 정책 설정
- [x] 외래키 관계 설정

### 마이그레이션 파일
```
backend/supabase/migrations/
├── 20251028000001_unify_naming_prd_v7_3.sql
└── 20251030000001_prd_v8_1_benefit_system.sql
```

## Phase 2: Admin 대시보드 ✅
### 완료 항목
- [x] 혜택 관리 메인 페이지
- [x] 카테고리 목록 및 수정
- [x] 배너 업로드 및 관리
- [x] 공고 등록 폼
- [x] 이미지 업로드 기능
- [x] 실시간 미리보기

### 주요 파일
```
apps/pickly_admin/src/
├── pages/benefits/
│   ├── BenefitManagementPage.tsx
│   ├── BenefitCategoryManager.tsx
│   └── BenefitAnnouncementForm.tsx
├── components/benefits/
│   ├── BannerManager.tsx
│   └── AnnouncementManager.tsx
└── api/
    └── benefits.ts
```

## Phase 3: 모바일 앱 통합 ✅
### 완료 항목
- [x] Benefit Provider 구조
- [x] Realtime 동기화
- [x] 카테고리 화면
- [x] 공고 목록 화면
- [x] 상세 화면

### 주요 파일
```
apps/pickly_mobile/lib/features/benefits/
├── models/
│   ├── benefit_category.dart
│   ├── benefit_detail.dart
│   └── benefit_announcement.dart
├── providers/
│   ├── benefit_category_provider.dart
│   └── benefit_realtime_stream_provider.dart
└── screens/
    └── benefits_screen.dart
```

## Phase 4: 테스트 및 배포 (진행 중)
### 예정 항목
- [ ] 단위 테스트 작성
- [ ] 통합 테스트
- [ ] E2E 테스트
- [ ] 성능 최적화
- [ ] 프로덕션 배포

## 기술적 결정사항

### 1. 상태 관리
- **Admin**: React Context + hooks
- **Mobile**: Riverpod 2.x

### 2. 실시간 동기화
- Supabase Realtime channels
- 자동 재연결 처리
- 에러 핸들링

### 3. 파일 업로드
- Supabase Storage 사용
- 버킷 분리 (banners, thumbnails, icons)
- 파일 크기 제한 (배너 5MB, 썸네일 3MB, 아이콘 1MB)

### 4. 데이터 검증
- DB 레벨: CHECK constraints
- API 레벨: TypeScript types
- Mobile: Freezed validation

## 참고사항
- 모든 테이블에 `created_at`, `updated_at` 자동 관리
- Soft delete 미사용 (완전 삭제)
- 이미지 URL은 Supabase Storage public URL 사용
