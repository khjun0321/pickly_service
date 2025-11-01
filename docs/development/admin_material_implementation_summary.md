# Admin Material UI 구현 요약

## 📋 Quick Reference

**작성일**: 2025-10-31
**상세 문서**: [admin_material_refactoring_plan.md](./admin_material_refactoring_plan.md)

---

## 🎯 3가지 핵심 작업

### 1️⃣ BenefitAnnouncementList 개선 (3시간)

**목표**: D-Day, 지역 필터, 정렬 추가

**핵심 코드**:
```typescript
// D-Day 계산 (utils/date.ts)
export function calculateDDay(endDate: string | null) {
  const dDay = differenceInDays(new Date(endDate), new Date())
  if (dDay < 0) return { label: '마감', color: 'error' }
  if (dDay === 0) return { label: 'D-day', color: 'error' }
  if (dDay <= 3) return { label: `D-${dDay}`, color: 'error' }
  if (dDay <= 7) return { label: `D-${dDay}`, color: 'warning' }
  return { label: `D-${dDay}`, color: 'default' }
}

// DataGrid 컬럼 추가
{
  field: 'd_day',
  headerName: 'D-Day',
  renderCell: (params) => {
    const { label, color } = calculateDDay(params.row.application_end_date)
    return <Chip label={label} color={color} />
  }
}

// 필터링
const [regionFilter, setRegionFilter] = useState('all')
const [sortBy, setSortBy] = useState<'latest' | 'popular' | 'deadline'>('latest')
```

**체크리스트**:
- [ ] D-Day 컬럼 추가
- [ ] 지역 필터 드롭다운
- [ ] 정렬 Select (최신순/인기순/마감임박순)

---

### 2️⃣ CategoryBannerList 모달 추가 (5시간)

**목표**: AgeCategoriesPage 패턴으로 모달 구현

**핵심 패턴**:
```typescript
// 1. State
const [dialogOpen, setDialogOpen] = useState(false)
const [editingBanner, setEditingBanner] = useState<Banner | null>(null)
const [imageFile, setImageFile] = useState<File | null>(null)
const [imagePreview, setImagePreview] = useState<string | null>(null)

// 2. Form Schema (Zod)
const bannerSchema = z.object({
  title: z.string().min(1),
  category_id: z.string().min(1),
  image_url: z.string().nullable(),
  // ...
})

// 3. Mutation
const saveMutation = useMutation({
  mutationFn: async (formData) => {
    if (imageFile) {
      const { url } = await uploadBannerImage(imageFile)
      formData.image_url = url
    }
    return editingBanner
      ? updateBanner(editingBanner.id, formData)
      : createBanner(formData)
  },
  onSuccess: () => {
    queryClient.invalidateQueries(['category-banners'])
    handleCloseDialog()
  }
})

// 4. Dialog UI
<Dialog open={dialogOpen} onClose={handleCloseDialog}>
  <form onSubmit={handleSubmit(onSubmit)}>
    <DialogContent>
      {/* 제목, 카테고리, 이미지 업로드 */}
    </DialogContent>
    <DialogActions>
      <Button onClick={handleCloseDialog}>취소</Button>
      <Button type="submit" variant="contained">저장</Button>
    </DialogActions>
  </form>
</Dialog>
```

**체크리스트**:
- [ ] Dialog 모달 UI
- [ ] React Hook Form + Zod
- [ ] 이미지 업로드 + 미리보기
- [ ] Save/Delete Mutation

---

### 3️⃣ 공통 컴포넌트 (3시간)

**목표**: 재사용 가능한 Material UI 컴포넌트

**생성 파일**:
```
apps/pickly_admin/src/
├── components/common/
│   ├── FileUpload.tsx        # 파일 업로드 + 미리보기
│   └── ConfirmDialog.tsx     # 삭제 확인 Dialog
└── utils/
    ├── date.ts               # D-Day 계산
    └── storage.ts            # Supabase Storage 업로드
```

**FileUpload 예시**:
```typescript
<FileUpload
  accept="image/*"
  maxSize={5 * 1024 * 1024}
  preview={imagePreview}
  onFileSelect={(file) => setImageFile(file)}
  label="배너 이미지 업로드"
/>
```

---

## 📁 파일별 수정 사항

### 수정할 파일

| 파일 | 작업 | 난이도 |
|------|------|--------|
| `BenefitAnnouncementList.tsx` | D-Day/필터/정렬 추가 | 중 |
| `CategoryBannerList.tsx` | 모달 추가 | 중 |
| `utils/date.ts` | 신규 생성 | 쉬움 |
| `utils/storage.ts` | uploadBannerImage 추가 | 쉬움 |
| `types/banner.ts` | 신규 생성 | 쉬움 |
| `components/common/FileUpload.tsx` | 신규 생성 | 쉬움 |
| `components/common/ConfirmDialog.tsx` | 신규 생성 | 쉬움 |

### 절대 수정 금지

```
❌ apps/pickly_mobile/
❌ packages/pickly_design_system/
❌ backend/supabase/migrations/ (기존 파일)
```

---

## 🚀 빠른 시작 가이드

### Step 1: Phase 1 구현 (3시간)

```bash
# 1. date.ts 생성
touch apps/pickly_admin/src/utils/date.ts

# 2. calculateDDay 함수 작성

# 3. BenefitAnnouncementList.tsx 수정
# - D-Day 컬럼 추가
# - 지역 필터 State/UI
# - 정렬 State/UI
```

### Step 2: Phase 2 구현 (5시간)

```bash
# 1. banner.ts 타입 정의
touch apps/pickly_admin/src/types/banner.ts

# 2. storage.ts에 uploadBannerImage 추가

# 3. CategoryBannerList.tsx 수정
# - Dialog State 추가
# - React Hook Form 설정
# - Dialog UI 구현
# - Mutation 로직
```

### Step 3: Phase 3 구현 (3시간)

```bash
# 1. 공통 컴포넌트 디렉토리 생성
mkdir -p apps/pickly_admin/src/components/common

# 2. FileUpload 컴포넌트
touch apps/pickly_admin/src/components/common/FileUpload.tsx

# 3. ConfirmDialog 컴포넌트
touch apps/pickly_admin/src/components/common/ConfirmDialog.tsx
```

---

## 🎨 Material UI 패턴 요약

### 일관된 Spacing

```typescript
<Box sx={{ p: 3 }}>              // 페이지 컨테이너
<Box sx={{ mb: 3 }}>             // 섹션 간격
<Stack direction="row" spacing={2}>  // 버튼 그룹
<Grid container spacing={2}>     // 폼 필드
```

### 상태 색상

```typescript
success: '활성', '성공'
error: '비활성', '에러', '마감'
warning: '경고', 'D-7 이하'
info: '정보', '예정'
default: '기본', '중립'
```

### Import 순서

```typescript
// 1. React
import { useState } from 'react'

// 2. 외부 라이브러리
import { useQuery } from '@tanstack/react-query'
import { Box, Button } from '@mui/material'

// 3. 내부 절대 경로
import { fetchData } from '@/api/data'

// 4. 상대 경로
import './styles.css'
```

---

## ✅ 검증 체크리스트

### 기능 검증

- [ ] D-Day 계산이 정확한가?
- [ ] 필터가 동작하는가?
- [ ] 정렬이 동작하는가?
- [ ] 모달이 열리고 닫히는가?
- [ ] 이미지 업로드가 되는가?
- [ ] CRUD 동작이 정상인가?

### 코드 품질

- [ ] TypeScript 컴파일 성공
- [ ] ESLint 0 errors
- [ ] `npm run dev` 실행 가능
- [ ] 브라우저 렌더링 정상
- [ ] 반응형 동작 확인

### UX

- [ ] 로딩 상태 표시
- [ ] 에러 메시지 표시
- [ ] 성공 토스트 표시
- [ ] 확인 Dialog 표시
- [ ] ARIA 접근성

---

## 🕐 예상 소요 시간

| Phase | 작업 | 시간 |
|-------|------|------|
| 1 | BenefitAnnouncementList | 3h |
| 2 | CategoryBannerList | 5h |
| 3 | 공통 컴포넌트 | 3h |
| - | 테스트 및 검증 | 2h |
| **Total** | - | **13h** |

---

## 📚 핵심 참고 문서

- **상세 계획**: [admin_material_refactoring_plan.md](./admin_material_refactoring_plan.md)
- **Material UI DataGrid**: https://mui.com/x/react-data-grid/
- **React Hook Form**: https://react-hook-form.com/
- **Zod**: https://zod.dev/

---

## 🎯 다음 단계

1. **Phase 1 완료 후**: BenefitAnnouncementList 테스트
2. **Phase 2 완료 후**: CategoryBannerList 테스트
3. **Phase 3 완료 후**: 전체 통합 테스트
4. **최종**: PRD v8.5 문서 업데이트

---

**작성 완료 - 2025-10-31**
