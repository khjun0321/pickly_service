# Admin Material UI 리팩터링 - 완료 가이드

## 📚 문서 인덱스

### 1️⃣ 상세 구현 계획
📄 [admin_material_refactoring_plan.md](./admin_material_refactoring_plan.md)

**내용**:
- 현재 상태 분석 (BenefitAnnouncementList, CategoryBannerList, AgeCategoriesPage)
- Phase 1-3 상세 구현 가이드
- Material UI 패턴 및 코드 예시
- 공통 컴포넌트 설계
- 전체 체크리스트

**예상 소요 시간**: 13시간

---

### 2️⃣ 빠른 시작 가이드
📄 [admin_material_implementation_summary.md](./admin_material_implementation_summary.md)

**내용**:
- 3가지 핵심 작업 요약
- 코드 스니펫 (복사 가능)
- 파일별 수정 사항
- 검증 체크리스트

**예상 소요 시간**: 각 Phase별 시간 표시

---

### 3️⃣ DB 스키마 분석
📄 [admin_material_missing_fields.md](./admin_material_missing_fields.md)

**내용**:
- 현재 `announcements` 테이블 스키마
- 누락된 필드 (region, application_dates, view_count)
- 마이그레이션 SQL
- 필드 사용 사례

**마이그레이션 파일**: `backend/supabase/migrations/20251031000001_add_announcement_fields.sql`

---

## 🚀 Quick Start (5분 시작 가이드)

### Step 1: 마이그레이션 실행 (1분)

```bash
# 1. 로컬 Supabase 리셋 (개발 환경)
cd /Users/kwonhyunjun/Desktop/pickly_service/backend
npx supabase db reset

# 2. 또는 마이그레이션만 적용
npx supabase migration up
```

**결과 확인**:
```sql
-- Supabase Studio에서 확인
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'announcements'
AND column_name IN ('region', 'application_start_date', 'application_end_date', 'view_count');
```

---

### Step 2: 타입 재생성 (1분)

```bash
# Supabase 타입 자동 생성
cd /Users/kwonhyunjun/Desktop/pickly_service
npx supabase gen types typescript --local > apps/pickly_admin/src/types/database.ts
```

---

### Step 3: 개발 서버 실행 (1분)

```bash
cd apps/pickly_admin
npm run dev
```

**브라우저**: http://localhost:5173

---

### Step 4: 문서 읽기 (2분)

1. **빠른 이해**: [admin_material_implementation_summary.md](./admin_material_implementation_summary.md)
2. **상세 구현**: [admin_material_refactoring_plan.md](./admin_material_refactoring_plan.md)
3. **DB 스키마**: [admin_material_missing_fields.md](./admin_material_missing_fields.md)

---

## 📋 Phase별 작업 순서

### Phase 1: BenefitAnnouncementList (3시간)

**파일**: `apps/pickly_admin/src/pages/benefits/BenefitAnnouncementList.tsx`

**작업**:
1. D-Day 계산 유틸리티 생성 (`utils/date.ts`)
2. DataGrid에 D-Day 컬럼 추가
3. 지역 필터 State/UI 추가
4. 정렬 Select 추가 (최신순/인기순/마감임박순)

**참고 문서**: [상세 계획 - Phase 1](./admin_material_refactoring_plan.md#-phase-1-benefitannouncementlist-개선)

---

### Phase 2: CategoryBannerList (5시간)

**파일**: `apps/pickly_admin/src/pages/banners/CategoryBannerList.tsx`

**작업**:
1. Dialog State 추가
2. React Hook Form + Zod 설정
3. Dialog UI 구현 (AgeCategoriesPage 패턴)
4. 이미지 업로드 핸들러
5. Save/Delete Mutation

**참고 문서**: [상세 계획 - Phase 2](./admin_material_refactoring_plan.md#-phase-2-categorybannerlist-모달-추가)

---

### Phase 3: 공통 컴포넌트 (3시간)

**파일**:
- `apps/pickly_admin/src/components/common/FileUpload.tsx`
- `apps/pickly_admin/src/components/common/ConfirmDialog.tsx`
- `apps/pickly_admin/src/utils/date.ts`
- `apps/pickly_admin/src/utils/storage.ts`

**작업**:
1. FileUpload 컴포넌트 생성
2. ConfirmDialog 컴포넌트 생성
3. 유틸리티 함수 작성

**참고 문서**: [상세 계획 - Phase 3](./admin_material_refactoring_plan.md#-phase-3-공통-컴포넌트-및-패턴)

---

## ✅ 최종 검증 체크리스트

### 데이터베이스

- [ ] `announcements` 테이블에 `region` 필드 존재
- [ ] `announcements` 테이블에 `application_start_date` 필드 존재
- [ ] `announcements` 테이블에 `application_end_date` 필드 존재
- [ ] `views_count` → `view_count` 변경 완료
- [ ] `status` 제약조건에 'upcoming' 추가

### Phase 1: BenefitAnnouncementList

- [ ] D-Day 컬럼이 정확하게 표시됨
- [ ] D-3 이하는 빨간색, D-7 이하는 주황색
- [ ] 지역 필터가 동작함
- [ ] 정렬 (최신순/인기순/마감임박순) 동작
- [ ] 모든 필터가 조합 가능

### Phase 2: CategoryBannerList

- [ ] "새 배너" 버튼 클릭 시 Dialog 열림
- [ ] 수정 아이콘 클릭 시 Dialog 열림 (데이터 채워짐)
- [ ] 이미지 업로드 및 미리보기 동작
- [ ] 폼 유효성 검사 동작 (Zod)
- [ ] 저장/수정/삭제 Mutation 동작
- [ ] 성공 시 Toast 메시지 표시

### Phase 3: 공통 컴포넌트

- [ ] FileUpload 컴포넌트 재사용 가능
- [ ] ConfirmDialog 컴포넌트 재사용 가능
- [ ] calculateDDay 함수 정확성 검증
- [ ] uploadBannerImage 함수 동작 확인

### 코드 품질

- [ ] TypeScript 컴파일 성공 (`npm run typecheck`)
- [ ] ESLint 0 errors (`npm run lint`)
- [ ] `npm run dev` 실행 가능
- [ ] 브라우저 콘솔 에러 없음
- [ ] 반응형 디자인 확인 (1920px, 1440px, 1024px)

---

## 🎨 Material UI 스타일 가이드 요약

### Spacing

```typescript
p: 3     // 페이지 컨테이너
mb: 3    // 섹션 간격
spacing={2}  // 버튼/필드 그룹
```

### Colors

```typescript
success: '활성', '성공'
error: '비활성', '에러', '마감'
warning: '경고', 'D-7 이하'
info: '정보', '예정'
```

### Typography

```typescript
h4: 페이지 제목
h5: 섹션 제목
body2: 본문 (작은 크기)
caption: 부가 설명
```

---

## 🚨 주의사항

### 절대 수정 금지

```yaml
❌ apps/pickly_mobile/ 절대 수정 금지
❌ packages/pickly_design_system/ 절대 손대지 마
❌ backend/supabase/migrations/ 기존 마이그레이션 수정 금지
```

### 필수 준수 사항

```yaml
✅ TypeScript strict mode 준수
✅ 절대 경로 import 사용 (@/)
✅ 에러 처리 필수 (try-catch, onError)
✅ 로딩 상태 표시 (isLoading, isSubmitting)
✅ 반응형 디자인 (Material UI Grid/Stack)
✅ ARIA 접근성 (aria-label, role)
✅ 기존 코드 스타일 유지
```

---

## 📚 참고 자료

### Material UI 공식 문서

- **DataGrid**: https://mui.com/x/react-data-grid/
- **Dialog**: https://mui.com/material-ui/react-dialog/
- **Select**: https://mui.com/material-ui/react-select/
- **TextField**: https://mui.com/material-ui/react-text-field/

### React Hook Form

- **Controller**: https://react-hook-form.com/api/usecontroller/controller
- **Resolver**: https://react-hook-form.com/get-started#SchemaValidation

### Zod

- **String validation**: https://zod.dev/?id=strings
- **Object schema**: https://zod.dev/?id=objects

### TanStack Query

- **Mutations**: https://tanstack.com/query/latest/docs/react/guides/mutations
- **Invalidation**: https://tanstack.com/query/latest/docs/react/guides/query-invalidation

### Supabase

- **Migrations**: https://supabase.com/docs/guides/database/migrations
- **Type Generation**: https://supabase.com/docs/guides/api/generating-types
- **Storage**: https://supabase.com/docs/guides/storage

---

## 🕐 예상 소요 시간

| Phase | 작업 | 시간 |
|-------|------|------|
| Setup | DB 마이그레이션 + 타입 생성 | 30분 |
| Phase 1 | BenefitAnnouncementList | 3시간 |
| Phase 2 | CategoryBannerList | 5시간 |
| Phase 3 | 공통 컴포넌트 | 3시간 |
| Test | 전체 테스트 및 검증 | 2시간 |
| **Total** | - | **13.5시간** |

---

## 📝 완료 후 확인 사항

### 1. 스크린샷 촬영

- [ ] BenefitAnnouncementList (필터/정렬 적용된 상태)
- [ ] CategoryBannerList (모달 열린 상태)
- [ ] D-Day 표시 (다양한 상태)
- [ ] 반응형 디자인 (모바일/태블릿)

### 2. 문서 업데이트

- [ ] PRD v8.5 업데이트
- [ ] CHANGELOG.md 작성
- [ ] 구현 완료 체크리스트

### 3. 코드 리뷰 준비

- [ ] 변경 사항 요약
- [ ] 테스트 결과 정리
- [ ] 알려진 이슈/제한사항 문서화

---

## 🎯 다음 단계 (Optional)

### 추가 개선 사항

1. **검색 기능**: 제목/내용 검색
2. **Pagination**: 대량 데이터 처리
3. **Export**: Excel/CSV 다운로드
4. **Batch Actions**: 일괄 삭제/활성화
5. **Advanced Filters**: 날짜 범위, 태그 필터

### 성능 최적화

1. **React.memo**: 컴포넌트 메모이제이션
2. **useMemo/useCallback**: 불필요한 재계산 방지
3. **Virtual Scrolling**: 대량 데이터 렌더링 최적화
4. **Image Optimization**: WebP 변환, Lazy Loading

---

## 📞 지원

문제가 발생하면:

1. **문서 확인**: 상세 계획 문서의 해당 섹션 참조
2. **기존 코드 참고**: AgeCategoriesPage.tsx 패턴 참고
3. **Material UI 문서**: 공식 문서에서 컴포넌트 사용법 확인
4. **타입 에러**: `database.ts` 타입 정의 확인

---

**작성 완료 - 2025-10-31**

**문서 버전**: v1.0

**작성자**: Claude Code Assistant
