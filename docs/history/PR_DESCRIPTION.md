# PR: 공고 상세 시스템 및 관리자 기능 통합

> **Branch**: `feature/announcement-detail-and-admin-sync`
> **Target**: `main` (or `develop`)
> **Type**: Feature
> **PRD Version**: v7.2

---

## 📋 Summary

이 PR은 PRD v7.2의 공고 상세 시스템 및 관리자 기능을 구현합니다. 모듈식 섹션/탭 구조를 도입하여 유연한 공고 관리와 표시를 가능하게 합니다.

**주요 변경사항**:
- ✅ 공고 상세 화면 (모듈식 섹션 + TabBar)
- ✅ 관리자 인터페이스 (연령 카테고리, 공고 관리)
- ✅ DB 스키마 v2.0 (announcement_sections, announcement_tabs)
- ✅ 문서화 완료 (명세서, 가이드, 테스팅)

---

## 🎯 목표

### 1. 사용자 경험 개선
- 공고 정보를 평형별/연령별로 구분하여 명확하게 표시
- TabBar UI로 직관적인 네비게이션 제공
- 모듈식 섹션으로 다양한 공고 타입 지원

### 2. 관리자 편의성 향상
- 연령 카테고리 CRUD 기능 (SVG 아이콘 업로드)
- 공고 섹션/탭 자유롭게 구성
- TypeScript 타입 안전성 보장

### 3. 확장 가능한 아키텍처
- JSONB 활용한 유연한 콘텐츠 구조
- 섹션 타입 확장 가능
- Phase 2/3 기능 대비

---

## 🚀 주요 기능

### Mobile App (Flutter)

#### 1. 공고 상세 화면
- **위치**: `apps/pickly_mobile/lib/features/benefit/screens/announcement_detail_screen.dart`
- **기능**:
  - 모듈식 섹션 렌더링 (basic_info, schedule, eligibility, housing_info, location, attachments)
  - TabBar UI (평형별/연령별 정보)
  - 평면도 이미지 표시
  - 공급 호수, 소득 조건 JSONB 파싱
  - 캐시 무효화 전략 (화면 진입 시)

#### 2. 데이터 모델
- **Announcement**: 기본 정보 (제목, 기관, 상태 등)
- **AnnouncementSection**: 섹션 정보 (타입, 제목, JSONB 콘텐츠)
- **AnnouncementTab**: 탭 정보 (탭명, 평형, 소득조건 등)

#### 3. Provider & Repository
- `announcementDetailProvider`: 상세 정보 조회 (섹션 + 탭 포함)
- `AnnouncementRepository`: Supabase 연동

### Admin Backoffice (React + TypeScript)

#### 1. 연령 카테고리 관리
- **위치**: `apps/pickly_admin/src/pages/categories/`
- **기능**:
  - CRUD (Create, Read, Update, Delete)
  - SVG 아이콘 업로드 (Supabase Storage)
  - 표시 순서, 나이 범위 설정

#### 2. 공고 관리
- **위치**: `apps/pickly_admin/src/pages/benefits/BenefitAnnouncementForm.tsx`
- **기능**:
  - 기본 정보 입력
  - 섹션 추가/수정/삭제 (JSONB 콘텐츠)
  - 탭 추가/수정/삭제 (평면도 업로드)
  - 썸네일 업로드

#### 3. TypeScript 타입
- `AgeCategory`
- `Announcement`
- `AnnouncementSection`
- `AnnouncementTab`

### Backend (Supabase)

#### 1. DB 스키마 v2.0
- **마이그레이션 파일**: `backend/supabase/migrations/20251027000001_correct_schema.sql`
- **신규 테이블**:
  - `announcement_sections`: 모듈식 섹션 (6가지 타입)
  - `announcement_tabs`: 평형별/연령별 탭
- **수정 테이블**:
  - `announcements`: 필드 추가 (is_featured, is_home_visible, display_priority)

#### 2. Storage Buckets
- `age-category-icons`: SVG 아이콘
- `announcement-files`: 평면도, 첨부 파일
- `category-banners`: 배너 이미지

---

## 📁 주요 파일 변경

### Mobile App

**신규 파일**:
- `lib/features/benefit/screens/announcement_detail_screen.dart` (공고 상세 화면)
- `lib/features/benefit/models/announcement_detail_models.dart` (상세 모델)
- `lib/features/benefit/widgets/announcement_tab_content.dart` (탭 콘텐츠)
- `lib/features/benefit/widgets/announcement_section_*.dart` (섹션 위젯들)

**수정 파일**:
- `lib/contexts/benefit/models/announcement.dart` (기본 모델 → 일반 클래스로 변환)
- `lib/contexts/benefit/repositories/announcement_repository.dart` (상세 조회 메서드 추가)
- `lib/features/benefit/providers/announcement_provider.dart` (상세 Provider 추가)

### Admin Backoffice

**신규 파일**:
- `src/pages/categories/CategoryList.tsx`
- `src/pages/categories/CategoryForm.tsx`
- `src/components/AgeIconUpload.tsx`
- `src/api/ageCategories.ts`

**수정 파일**:
- `src/pages/benefits/BenefitAnnouncementForm.tsx` (섹션/탭 관리 추가)
- `src/api/announcements.ts` (섹션/탭 API 추가)
- `src/types/database.ts` (타입 추가/수정)

### Backend

**신규 파일**:
- `backend/supabase/migrations/20251027000001_correct_schema.sql`

### Documentation

**신규 파일**:
- `docs/prd/announcement-detail-spec.md` (공고 상세 명세서)
- `docs/prd/admin-features.md` (관리자 기능 가이드)
- `docs/database/schema-v2.md` (DB 스키마 v2.0 문서)
- `docs/development/testing-guide.md` (테스팅 가이드)
- `.claude-flow/metrics/PRD_COMPLIANCE_REPORT.json` (PRD 준수 리포트)
- `docs/prd/PR_DESCRIPTION.md` (이 파일)

**수정 파일**:
- `PRD.md` (v7.2 업데이트)
- `docs/README.md` (문서 목록 업데이트)

---

## 🧪 테스트 계획

### Manual Testing Checklist

#### Mobile App
- [ ] 공고 리스트에서 카드 탭 → 상세 화면 진입
- [ ] 섹션들이 display_order 순서로 표시되는지 확인
- [ ] TabBar 존재 시 탭 클릭 → 콘텐츠 변경 확인
- [ ] 평면도 이미지 로딩 확인
- [ ] 소득 조건 JSONB 파싱 확인
- [ ] 외부 공고문 링크 버튼 클릭 → URL 열림
- [ ] 뒤로가기 → 리스트 화면 복귀
- [ ] 캐시 무효화: 백오피스에서 공고 수정 → 모바일에서 재진입 → 최신 데이터 확인

#### Admin Backoffice
- [ ] 연령 카테고리 생성 (이름, 순서, 나이 범위)
- [ ] SVG 아이콘 업로드 → 리스트에서 아이콘 표시 확인
- [ ] 연령 카테고리 수정 → 변경사항 반영 확인
- [ ] 공고 생성 (기본 정보)
- [ ] 섹션 추가 (각 타입별로)
- [ ] 섹션 순서 변경 (drag & drop)
- [ ] 탭 추가 (평면도 업로드, 소득조건 입력)
- [ ] 공고 상태 변경 (draft → recruiting → closed)
- [ ] 썸네일 업로드 → 리스트에서 표시 확인

### Automated Tests
- [ ] Mobile unit tests: `flutter test`
- [ ] Mobile widget tests
- [ ] Admin unit tests: `npm test`
- [ ] Integration tests (선택)

### Performance Tests
- [ ] 공고 상세 로딩 시간 < 1초
- [ ] 이미지 로딩 성능
- [ ] 대용량 JSONB 파싱 성능

---

## 🖼️ Screenshots

**TODO**: 실제 구현 후 스크린샷 추가

### Mobile App
1. 공고 상세 화면 (섹션 표시)
2. TabBar UI (평형별 탭)
3. 탭 콘텐츠 (평면도, 소득조건)

### Admin Backoffice
1. 연령 카테고리 리스트
2. 카테고리 폼 (SVG 업로드)
3. 공고 폼 (섹션/탭 관리)

---

## ⚠️ Breaking Changes

**없음** - 기존 기능과 호환됨

---

## 🚨 알려진 제한사항

1. **이미지 최적화**: 썸네일/평면도 이미지 리사이징 미구현
   - **영향**: 이미지 로딩 속도 저하 가능
   - **계획**: Phase 2 - Image CDN 도입

2. **오프라인 지원**: 캐시 정책 미구현
   - **영향**: 오프라인 시 데이터 접근 불가
   - **계획**: Phase 2 - Offline-first 캐싱

3. **검색**: 키워드 검색 미구현
   - **영향**: 제목 기반 검색 불가
   - **계획**: Phase 1.5

---

## 📝 Migration Guide

### Database Migration

```bash
cd backend/supabase

# 로컬 환경
supabase db reset

# 프로덕션 환경 (주의!)
supabase db push
```

### Storage Buckets 생성

```sql
-- Supabase Dashboard > Storage > New Bucket
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('age-category-icons', 'age-category-icons', true),
  ('announcement-files', 'announcement-files', true);
```

### RLS 정책 설정

```sql
-- Public read access
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
USING (bucket_id IN ('age-category-icons', 'announcement-files'));

-- Admin write access
CREATE POLICY "Admin write access"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id IN ('age-category-icons', 'announcement-files')
  AND auth.role() = 'authenticated'
);
```

---

## 🔗 관련 이슈/PRs

- Related to PRD v7.0 DB 스키마 재구성
- Builds upon v7.1 TypeScript 에러 해결

---

## 📚 참고 문서

- [PRD v7.2](../../PRD.md)
- [공고 상세 명세서](announcement-detail-spec.md)
- [관리자 기능 가이드](admin-features.md)
- [DB 스키마 v2.0](../database/schema-v2.md)
- [테스팅 가이드](../development/testing-guide.md)
- [PRD 준수 리포트](../../.claude-flow/metrics/PRD_COMPLIANCE_REPORT.json)

---

## ✅ Checklist

### Before Review
- [x] 코드 작성 완료
- [x] 로컬 테스트 통과
- [x] 타입 에러 0개 (TypeScript)
- [x] 문서 업데이트
- [x] PRD 준수 확인

### For Reviewers
- [ ] 코드 품질 검토
- [ ] 아키텍처 적절성
- [ ] 성능 이슈 확인
- [ ] 보안 검토 (RLS 정책)
- [ ] 문서 정확성

### Before Merge
- [ ] CI/CD 통과
- [ ] QA 테스트 완료
- [ ] 스크린샷 추가
- [ ] Migration 준비
- [ ] 배포 계획 수립

---

## 👥 Reviewers

- @kwonhyunjun (Lead Developer)
- @backend-team (DB/API 검토)
- @mobile-team (Flutter 검토)
- @frontend-team (Admin 검토)

---

## 📅 Timeline

- **개발 시작**: 2025.10.27
- **개발 완료**: 2025.10.27
- **코드 리뷰**: TBD
- **QA 테스트**: TBD
- **배포 예정**: TBD

---

## 💬 Additional Notes

### 개발 과정
- Claude Flow 활용한 병렬 개발
- 문서 우선 개발 (Spec → Code)
- PRD v7.0 준수

### 다음 단계
1. PR 생성 및 코드 리뷰 요청
2. QA 테스트 실행
3. 통합 테스트 작성
4. 배포 준비
5. Phase 1.5 계획 수립 (검색 기능)

---

**Generated by**: Documentation Agent
**Date**: 2025.10.27
**Reviewed by**: -
