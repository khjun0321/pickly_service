# [Bug] 백오피스 필드 불일치 해결

## 🐛 문제 설명
DB 리팩토링 후 백오피스에서 59개 TypeScript 타입 에러 발생

## 📊 에러 분류

### 1. announcements 테이블 필드 불일치 (40개)
**문제:**
- 코드에서 사용: `application_period_start`, `application_period_end`
- DB에 없음: 해당 컬럼이 실제 테이블에 존재하지 않음

**영향받는 파일:**
```
src/pages/benefits/BenefitAnnouncementForm.tsx (25개 에러)
src/components/benefits/SortableRow.tsx (2개 에러)
```

**해결 방법 (선택):**
- **Option A**: DB에 컬럼 추가 (마이그레이션 작성)
  ```sql
  ALTER TABLE announcements
    ADD COLUMN application_period_start timestamptz,
    ADD COLUMN application_period_end timestamptz;
  ```
- **Option B**: 코드에서 제거 (announcement_sections로 이동)
  - 날짜 정보를 section의 JSONB 필드로 관리

### 2. category_banners 컬럼명 불일치 (15개)
**문제:**
- 코드에서 사용: `action_url`, `background_color`
- DB 실제 컬럼: `link_url`
- DB에 없음: `background_color`

**영향받는 파일:**
```
src/api/banners.ts (5개 에러)
src/components/benefits/MultiBannerManager.tsx (8개 에러)
src/examples/BannerManager-integration-example.tsx (7개 에러)
```

**해결 방법:**
- DB 스키마 확인 후 코드를 DB에 맞게 수정
  ```typescript
  // Before
  banner.action_url
  banner.background_color

  // After
  banner.link_url
  // background_color 제거 또는 DB에 추가
  ```

### 3. 사용하지 않는 변수 (4개)
**문제:**
- 선언했지만 사용하지 않는 변수들

**해결 방법:**
- 해당 변수 제거 또는 사용
  ```typescript
  // src/components/benefits/MultiBannerManager.tsx
  const [uploadingImage, setUploadingImage] = useState(false) // 미사용

  // src/examples/BannerManager-integration-example.tsx
  const updateMutation = ... // 미사용
  ```

## 🎯 작업 계획

### Step 1: 필드 조사 (15분)
```bash
# announcements 테이블 실제 구조 확인
cd ~/Desktop/pickly_service/backend/supabase
supabase db dump --schema public --table announcements

# category_banners 테이블 구조 확인
supabase db dump --schema public --table category_banners

# 또는 Supabase Studio에서 확인
open http://localhost:54323
```

### Step 2: 수정 방향 결정 (10분)
- [ ] **announcements**: application_period 필드 처리 방법 결정
  - Option A: DB 컬럼 추가 (추천: 기존 코드 유지)
  - Option B: 코드 수정 (섹션으로 이동)
- [ ] **category_banners**: 컬럼명 통일
  - `action_url` → `link_url` 또는 DB 컬럼 rename

### Step 3: 코드 수정 (30분)
- [ ] `src/pages/benefits/BenefitAnnouncementForm.tsx` 수정
- [ ] `src/components/benefits/SortableRow.tsx` 수정
- [ ] `src/api/banners.ts` 수정
- [ ] `src/components/benefits/MultiBannerManager.tsx` 수정
- [ ] `src/examples/BannerManager-integration-example.tsx` 수정

### Step 4: 타입 재생성 (5분)
```bash
cd ~/Desktop/pickly_service/backend/supabase
supabase gen types typescript --local > ../../apps/pickly_admin/src/types/database.ts
```

### Step 5: 빌드 확인 (5분)
```bash
cd ~/Desktop/pickly_service/apps/pickly_admin
npm run build

# 에러 0개 확인
```

### Step 6: 테스트 (10분)
- [ ] 개발 서버 실행: `npm run dev`
- [ ] 공고 등록 화면 테스트
- [ ] 배너 관리 화면 테스트

## 📁 영향받는 파일들

### 우선순위 높음 (필수)
```
src/pages/benefits/BenefitAnnouncementForm.tsx (25개 에러)
src/api/banners.ts (5개 에러)
src/components/benefits/MultiBannerManager.tsx (8개 에러)
```

### 우선순위 중간 (선택)
```
src/components/benefits/SortableRow.tsx (2개 에러)
src/examples/BannerManager-integration-example.tsx (7개 에러)
src/components/benefits/INTEGRATION_EXAMPLE.tsx (4개 에러)
```

### 우선순위 낮음 (경고)
```
src/components/benefits/BenefitBannerManager.tsx (사용 안 함)
src/components/benefits/DynamicColumns.tsx (경고)
src/components/shared/FileUploader.test.tsx (테스트 라이브러리)
```

## 🔧 추천 해결 방법

### Option A: DB 컬럼 추가 (추천) ⭐
**장점:**
- 기존 코드 최소 변경
- 빠른 해결 (1시간)

**단점:**
- DB 마이그레이션 필요
- Phase 1 범위 약간 벗어남

**작업:**
```sql
-- 20251027000002_add_missing_fields.sql
ALTER TABLE announcements
  ADD COLUMN application_period_start timestamptz,
  ADD COLUMN application_period_end timestamptz;

ALTER TABLE category_banners
  ADD COLUMN background_color text;
```

### Option B: 코드 수정 (정석)
**장점:**
- Phase 1 범위 준수
- 모듈식 구조 유지

**단점:**
- 코드 수정 범위 넓음 (2시간)
- 기존 로직 변경 필요

**작업:**
- application_period를 announcement_sections로 이동
- background_color 제거 또는 inline style로 처리

## ⏱️ 예상 소요 시간

**Option A (DB 추가):**
- 총 1시간
  - 마이그레이션 작성: 10분
  - 타입 재생성: 5분
  - 빌드 확인: 5분
  - 테스트: 10분
  - 커밋: 5분

**Option B (코드 수정):**
- 총 2시간
  - 코드 분석: 20분
  - Form 컴포넌트 수정: 40분
  - Banner 컴포넌트 수정: 30분
  - 테스트: 20분
  - 커밋: 10분

## 🏷️ 라벨
`bug`, `backoffice`, `typescript`, `phase-1`, `high-priority`

## 🔗 관련 PR
- #[PR번호]: DB 스키마 v2.0 리팩토링

## 📝 체크리스트
- [ ] 해결 방법 결정 (Option A or B)
- [ ] 코드 또는 DB 수정
- [ ] TypeScript 빌드 통과
- [ ] 개발 서버 테스트
- [ ] PR 생성 및 리뷰
- [ ] 메인 브랜치 머지
