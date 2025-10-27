# 백오피스 TypeScript 에러 트러블슈팅

> **빠른 진단 및 해결 가이드**
>
> 마지막 업데이트: 2025.10.27

---

## 🚨 Quick Diagnosis

### 1분 체크리스트
```bash
cd ~/Desktop/pickly_service/apps/pickly_admin

# 1. 에러 개수 확인
npm run build 2>&1 | grep "error TS" | wc -l

# 2. 에러 타입별 분류
npm run build 2>&1 | grep "error TS" | cut -d':' -f4 | cut -d' ' -f2 | sort | uniq -c

# 3. 가장 많이 발생한 파일
npm run build 2>&1 | grep "error TS" | cut -d'(' -f1 | sort | uniq -c | sort -rn | head -5
```

**결과 해석:**
- 100개 이상: 🚨 DB 스키마 불일치 가능성 높음
- 50-100개: ⚠️ 대규모 리팩토링 필요
- 10-50개: ⚡ 부분 수정 필요
- 10개 이하: ✅ 마이너 이슈

---

## 🔥 TOP 5 Common Errors

### 1. TS2339: Property does not exist (40% of errors)

**증상:**
```typescript
// ❌ Error: Property 'banner_enabled' does not exist on type 'BenefitCategory'
category.banner_enabled
category.banner_image_url
category.banner_link_url
```

**원인:** DB에 없는 필드 사용

**진단 방법:**
```bash
# Step 1: 실제 DB 스키마 확인
cat backend/supabase/migrations/*.sql | grep "CREATE TABLE benefit_categories"

# Step 2: TypeScript 타입 확인
grep -A 20 "benefit_categories" apps/pickly_admin/src/types/database.ts

# Step 3: 불일치 필드 찾기
# DB에는 있는데 코드에서 사용 중인 필드 검색
grep -r "banner_enabled" apps/pickly_admin/src/
```

**해결 방법:**
```typescript
// ✅ Solution 1: 별도 테이블 조회
const banners = await supabase
  .from('category_banners')  // 1:N 관계 테이블
  .select('*')
  .eq('category_id', category.id)

// ✅ Solution 2: JOIN 사용
const { data } = await supabase
  .from('benefit_categories')
  .select(`
    *,
    category_banners (*)
  `)
  .eq('id', categoryId)
```

**예방:**
- ✅ 개발 전 DB 스키마 먼저 확인
- ✅ database.ts 타입 정의 최신화
- ✅ 필요한 필드는 마이그레이션 먼저 추가

---

### 2. TS6133: Unused variable (15% of errors)

**증상:**
```typescript
// ❌ Error: 'BenefitBannerInsert' is declared but its value is never read
import { BenefitBannerInsert } from './api'

// ❌ Error: 'uploadingImage' is assigned a value but never used
const [uploadingImage, setUploadingImage] = useState(false)
```

**원인:** 사용하지 않는 import/변수

**진단 방법:**
```bash
# 모든 TS6133 에러 찾기
npm run build 2>&1 | grep "TS6133"

# 특정 파일의 미사용 항목
npm run build 2>&1 | grep "TS6133" | grep "BannerManager.tsx"
```

**해결 방법:**
```typescript
// ✅ Solution 1: 제거
// import { BenefitBannerInsert } from './api'  // ← 삭제

// ✅ Solution 2: _ prefix (의도적 미사용)
const onError = (_error: Error, _data, context: any) => {
  // _error, _data는 시그니처 때문에 필요하지만 사용 안 함
  console.log(context)
}

// ✅ Solution 3: 사용하기
setUploadingImage(true)
```

**자동화:**
```bash
# ESLint 자동 수정
npx eslint --fix src/**/*.ts src/**/*.tsx
```

---

### 3. TS2345: Argument type mismatch (10% of errors)

**증상:**
```typescript
// ❌ Error: Argument of type 'BenefitCategory' is not assignable to parameter
reset(category)

// ❌ Error: Type 'null' is not assignable to type 'string'
const value: string = category.sort_order
```

**원인:** Null 처리 누락, 타입 불일치

**진단 방법:**
```bash
# TS2345 에러만 추출
npm run build 2>&1 | grep "TS2345"

# 문제 파일 찾기
npm run build 2>&1 | grep "TS2345" | cut -d'(' -f1 | sort | uniq
```

**해결 방법:**
```typescript
// ✅ Solution 1: Null coalescing
const value = category.sort_order ?? 0
const isActive = category.is_active ?? true

// ✅ Solution 2: 명시적 매핑
reset({
  title: category.title,
  description: category.description,
  sort_order: category.sort_order ?? 0,
  is_active: category.is_active ?? true,
})

// ✅ Solution 3: Optional chaining + fallback
const iconUrl = category.icon_url?.trim() || '/default-icon.svg'
```

---

### 4. TS2322: Type not assignable (10% of errors)

**증상:**
```typescript
// ❌ Error: Type 'string | null' is not assignable to type 'string'
link_url: formData.link_url || null

// ❌ Error: Type 'undefined' is not assignable to type 'boolean'
is_active: category.is_active
```

**원인:** Null vs undefined 혼용, 옵셔널 타입 불일치

**해결 방법:**
```typescript
// ✅ 일관된 null/undefined 사용
interface FormData {
  link_url: string | undefined  // DB optional → undefined
  is_active: boolean            // DB non-null → 기본값 사용
}

// ✅ 기본값 패턴
link_url: formData.link_url || undefined
is_active: formData.is_active ?? true

// ✅ Type guard
if (typeof category.is_active === 'boolean') {
  // safe to use
}
```

---

### 5. ParserError (SQL Queries)

**증상:**
```typescript
// ❌ PostgREST ParserError
.select('id, name as title, slug, description')
```

**원인:** PostgREST가 SQL alias 지원 안 함

**진단 방법:**
```bash
# API 파일에서 alias 사용 검색
grep -n "as " apps/pickly_admin/src/api/*.ts
```

**해결 방법:**
```typescript
// ❌ Bad: SQL alias
.select('id, name as title, slug')

// ✅ Good: 실제 필드명 사용 + 코드에서 변환
.select('id, name, slug')

// 컴포넌트에서
const displayName = category.name  // 또는 매핑 로직
```

---

## 📁 File-Specific Troubleshooting

### BenefitCategoryList.tsx

**자주 발생하는 에러:**
- icon, color, sort_order → icon_url, display_order

**체크포인트:**
```typescript
// ✅ Zod schema 검증
const schema = z.object({
  display_order: z.number(),  // ← NOT sort_order
  // color: ...  // ← 삭제 (DB에 없음)
})

// ✅ DataGrid columns
{ field: 'icon_url', headerName: 'Icon' }  // ← NOT icon
```

### MultiBannerManager.tsx

**자주 발생하는 에러:**
- background_color (DB에 없음)
- nullable boolean 처리

**체크포인트:**
```typescript
// ✅ 배경색 제거
bgcolor: '#E3F2FD'  // ← 하드코딩

// ✅ Null 처리
checked={banner.is_active ?? false}
```

### api/banners.ts

**자주 발생하는 에러:**
- Interface에 background_color 포함

**체크포인트:**
```typescript
// ✅ DB 스키마와 100% 일치
export interface BenefitBanner {
  id: string
  title: string
  // background_color: ... // ← 삭제
}
```

---

## 🔧 Large-Scale Error Resolution

### Strategy: 98개 → 12개 (2.5시간)

**Phase 1: 빠른 진단 (30분)**
```bash
# 1. 에러 타입별 분류
npm run build 2>&1 | grep "error TS" | cut -d':' -f4 | cut -d' ' -f2 | sort | uniq -c

# 2. TOP 5 파일 찾기
npm run build 2>&1 | grep "error TS" | cut -d'(' -f1 | sort | uniq -c | sort -rn | head -5

# 3. DB 스키마 확인
cat backend/supabase/migrations/*.sql | grep "CREATE TABLE"
```

**Phase 2: 중복 제거 (20분)**
```bash
# 1. 중복 파일 찾기
find apps/pickly_admin/src -name "*Manager.tsx" -o -name "*Example.tsx"

# 2. 미사용 import 자동 제거
npx eslint --fix "apps/pickly_admin/src/**/*.{ts,tsx}"
```

**Phase 3: 체계적 수정 (80분)**
1. **Step 1**: TS2339 (DB 필드 불일치) - 가장 많은 에러
2. **Step 2**: TS6133 (미사용 코드) - 빠르게 처리 가능
3. **Step 3**: TS2345/TS2322 (타입 불일치) - Null 처리
4. **Step 4**: 파일별 대청소 - 남은 에러 일괄 처리

**Phase 4: 검증 (10분)**
```bash
# 1. 빌드 성공 확인
npm run build

# 2. 개발 서버 실행
npm run dev

# 3. Git 커밋
git add .
git commit -m "fix: resolve XX TypeScript errors"
```

---

## 💡 Prevention Tips

### 1. DB 스키마 First
```bash
# 개발 전 체크리스트
□ backend/supabase/migrations/*.sql 확인
□ src/types/database.ts 재생성
□ npm run build → 에러 0개 확인
```

### 2. Phase 주석 사용
```typescript
// 🚧 PHASE 2: 나중에 추가 예정
/*
application_start_date?: string
application_end_date?: string
*/

// ❌ REMOVED: subtitle + external_url로 대체
// description?: string
```

### 3. 정기 점검 (주 1회)
```bash
# 타입 에러 모니터링
npm run build 2>&1 | grep "error TS" | wc -l

# 결과가 0이 아니면 즉시 수정!
```

---

## 🛠 Tools & Commands

### TypeScript 진단
```bash
# 전체 에러 리스트
npm run build 2>&1 | tee typescript-errors.log

# 에러 타입별 통계
npm run build 2>&1 | grep "error TS" | awk '{print $2}' | sort | uniq -c

# 특정 파일 타입 체크
npx tsc --noEmit src/pages/benefits/BenefitCategoryList.tsx
```

### Supabase 타입 재생성
```bash
cd ~/Desktop/pickly_service/backend/supabase

supabase gen types typescript --local > \
  ../../apps/pickly_admin/src/types/database.ts

cd ../../apps/pickly_admin
npm run build
```

### Git 작업
```bash
# 에러 수정 전후 비교
git diff HEAD --stat

# 변경 파일 리뷰
git diff HEAD -- "*.tsx" "*.ts"

# 커밋
git add .
git commit -m "fix: resolve TypeScript errors (XX→YY)"
```

---

## 📚 Related Docs

- [백오피스 개발 가이드](../prd/admin-development-guide.md)
- [DB 스키마 동기화](../prd/admin-development-guide.md#3-db-스키마-동기화)
- [Git 커밋 가이드](../prd/admin-development-guide.md#6-git-커밋-가이드)

---

**마지막 성공 사례 (2025.10.27):**
- 98개 에러 → 12개 (88% 감소)
- 소요 시간: 2.5시간
- 주요 원인: DB 스키마 불일치 70%, 미사용 코드 15%, Null 처리 15%
