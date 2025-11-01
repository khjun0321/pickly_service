# Admin Material UI 리팩터링 계획 v8.5

## 📋 문서 정보

- **작성일**: 2025-10-31
- **버전**: v8.5
- **목적**: Pickly Admin React 앱의 Material UI 기반 UI/UX 개선
- **기술 스택**: React 18 + TypeScript 5 + Material UI 5 + TanStack Query v5

---

## 🎯 목표

1. **BenefitAnnouncementList**: D-Day 계산, 지역 필터, 정렬 기능 추가
2. **CategoryBannerList**: 통합 모달 기반 추가/수정 구현 (AgeCategoriesPage 패턴)
3. **공통 컴포넌트**: 재사용 가능한 Material UI 패턴 정립
4. **일관성 유지**: 기존 코드 스타일 및 패턴 준수

---

## 📊 현재 상태 분석

### ✅ 우수 사례: AgeCategoriesPage (529줄)

**완벽하게 구현된 기능**:
- ✅ 통합 Dialog 모달 (추가/수정)
- ✅ SVG 파일 업로드 + 미리보기
- ✅ React Hook Form + Zod 유효성 검사
- ✅ Drag & Drop 아이콘 표시
- ✅ 활성화/비활성화 관리
- ✅ Table UI 사용 (DataGrid 대신)

**핵심 패턴**:
```typescript
// 1. State 관리
const [dialogOpen, setDialogOpen] = useState(false)
const [editingCategory, setEditingCategory] = useState<AgeCategory | null>(null)
const [iconFile, setIconFile] = useState<File | null>(null)
const [iconPreview, setIconPreview] = useState<string | null>(null)

// 2. React Hook Form + Zod
const schema = z.object({
  title: z.string().min(1, '제목을 입력하세요'),
  // ...
})

const { control, handleSubmit, reset, formState: { errors, isSubmitting } } = useForm({
  resolver: zodResolver(schema),
  defaultValues: { /* ... */ }
})

// 3. TanStack Query Mutations
const saveMutation = useMutation({
  mutationFn: async (formData) => { /* ... */ },
  onSuccess: () => {
    toast.success('저장되었습니다')
    queryClient.invalidateQueries({ queryKey: ['age_categories'] })
    handleCloseDialog()
  },
})

// 4. 파일 업로드 처리
const handleIconSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
  const file = event.target.files?.[0]
  if (file.type !== 'image/svg+xml') {
    toast.error('SVG 파일만 업로드 가능합니다')
    return
  }
  setIconFile(file)
  setIconPreview(URL.createObjectURL(file))
}
```

---

### ⚠️ 개선 필요: BenefitAnnouncementList (348줄)

**현재 구현**:
- ✅ 상태 필터 (모집중/마감/임시저장/예정)
- ✅ LH/기존 공고 토글 뷰
- ✅ DataGrid 사용
- ✅ 별도 수정 페이지로 이동 (권장 패턴)

**누락 기능**:
- ❌ D-Day 계산 및 표시
- ❌ 지역(region) 필터
- ❌ 정렬 옵션 (최신순/인기순/마감임박순)
- ❌ 조회수 기반 정렬

**개선 계획**:
1. D-Day 계산 컬럼 추가
2. 지역 필터 드롭다운 추가
3. 정렬 Select 컴포넌트 추가
4. 현재 페이지 기반 수정 유지 (모달 불필요)

---

### ⚠️ 개선 필요: CategoryBannerList (320줄)

**현재 구현**:
- ✅ Drag & Drop 정렬
- ✅ 카테고리 필터
- ✅ 활성/비활성 상태
- ⚠️ 별도 수정 페이지로 이동 (모달 미구현)

**개선 계획**:
1. **AgeCategoriesPage 패턴 적용**
2. 통합 Dialog 모달 추가
3. 이미지 업로드 미리보기
4. React Hook Form + Zod 적용

---

## 🚀 Phase 1: BenefitAnnouncementList 개선

### 1.1 D-Day 계산 추가

**위치**: `apps/pickly_admin/src/pages/benefits/BenefitAnnouncementList.tsx`

**추가할 유틸리티 함수**:
```typescript
// apps/pickly_admin/src/utils/date.ts
import { differenceInDays, isPast } from 'date-fns'

export function calculateDDay(endDate: string | null): {
  dDay: number | null
  label: string
  color: 'error' | 'warning' | 'default'
} {
  if (!endDate) return { dDay: null, label: '-', color: 'default' }

  const end = new Date(endDate)
  const today = new Date()
  today.setHours(0, 0, 0, 0)
  end.setHours(0, 0, 0, 0)

  const dDay = differenceInDays(end, today)

  if (dDay < 0) {
    return { dDay, label: '마감', color: 'error' }
  } else if (dDay === 0) {
    return { dDay, label: 'D-day', color: 'error' }
  } else if (dDay <= 3) {
    return { dDay, label: `D-${dDay}`, color: 'error' }
  } else if (dDay <= 7) {
    return { dDay, label: `D-${dDay}`, color: 'warning' }
  } else {
    return { dDay, label: `D-${dDay}`, color: 'default' }
  }
}
```

**DataGrid 컬럼 추가**:
```typescript
{
  field: 'd_day',
  headerName: 'D-Day',
  width: 100,
  align: 'center',
  headerAlign: 'center',
  renderCell: (params) => {
    const { dDay, label, color } = calculateDDay(params.row.application_end_date)
    return (
      <Chip
        label={label}
        color={color}
        size="small"
        sx={{ fontWeight: 600 }}
      />
    )
  },
  sortComparator: (v1, v2, param1, param2) => {
    const d1 = calculateDDay(param1.row.application_end_date).dDay ?? Infinity
    const d2 = calculateDDay(param2.row.application_end_date).dDay ?? Infinity
    return d1 - d2
  },
}
```

---

### 1.2 지역 필터 추가

**데이터베이스 스키마 확인**:
```sql
-- announcements 테이블에 region 컬럼이 있는지 확인
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'announcements' AND column_name = 'region';
```

**필터 State 추가**:
```typescript
const [regionFilter, setRegionFilter] = useState('all')

// 지역 목록 추출 (고유값)
const regions = useMemo(() => {
  if (!announcements) return []
  const uniqueRegions = [...new Set(announcements.map(a => a.region).filter(Boolean))]
  return uniqueRegions.sort()
}, [announcements])
```

**필터 적용**:
```typescript
const filteredAnnouncements = useMemo(() => {
  if (!announcements) return []

  return announcements.filter((announcement) => {
    const statusMatch = statusFilter === 'all' || announcement.status === statusFilter
    const regionMatch = regionFilter === 'all' || announcement.region === regionFilter
    return statusMatch && regionMatch
  })
}, [announcements, statusFilter, regionFilter])
```

**UI 컴포넌트 추가**:
```typescript
<FormControl sx={{ minWidth: 150 }}>
  <InputLabel id="region-filter-label">지역</InputLabel>
  <Select
    labelId="region-filter-label"
    id="region-filter"
    value={regionFilter}
    label="지역"
    onChange={(e) => setRegionFilter(e.target.value)}
    size="small"
  >
    <MenuItem value="all">전체 지역</MenuItem>
    {regions.map((region) => (
      <MenuItem key={region} value={region}>
        {region}
      </MenuItem>
    ))}
  </Select>
</FormControl>
```

---

### 1.3 정렬 기능 추가

**정렬 옵션 정의**:
```typescript
type SortOption = 'latest' | 'popular' | 'deadline'

const SORT_OPTIONS = [
  { value: 'latest', label: '최신순' },
  { value: 'popular', label: '인기순 (조회수)' },
  { value: 'deadline', label: '마감임박순' },
] as const

const [sortBy, setSortBy] = useState<SortOption>('latest')
```

**정렬 로직**:
```typescript
const sortedAnnouncements = useMemo(() => {
  const filtered = [...filteredAnnouncements]

  switch (sortBy) {
    case 'latest':
      return filtered.sort((a, b) =>
        new Date(b.created_at).getTime() - new Date(a.created_at).getTime()
      )
    case 'popular':
      return filtered.sort((a, b) => (b.view_count || 0) - (a.view_count || 0))
    case 'deadline':
      return filtered.sort((a, b) => {
        const dDayA = calculateDDay(a.application_end_date).dDay ?? Infinity
        const dDayB = calculateDDay(b.application_end_date).dDay ?? Infinity
        return dDayA - dDayB
      })
    default:
      return filtered
  }
}, [filteredAnnouncements, sortBy])
```

**UI 컴포넌트**:
```typescript
<FormControl sx={{ minWidth: 150 }}>
  <InputLabel id="sort-by-label">정렬</InputLabel>
  <Select
    labelId="sort-by-label"
    id="sort-by"
    value={sortBy}
    label="정렬"
    onChange={(e) => setSortBy(e.target.value as SortOption)}
    size="small"
  >
    {SORT_OPTIONS.map((option) => (
      <MenuItem key={option.value} value={option.value}>
        {option.label}
      </MenuItem>
    ))}
  </Select>
</FormControl>
```

---

### 1.4 최종 레이아웃 (Phase 1)

```typescript
<Paper sx={{ p: 2, mb: 2 }}>
  <Stack direction="row" spacing={2} alignItems="center">
    {/* 1. 뷰 모드 토글 */}
    <ToggleButtonGroup
      value={viewMode}
      exclusive
      onChange={(_, newMode) => {
        if (newMode !== null) setViewMode(newMode)
      }}
      size="small"
    >
      <ToggleButton value="benefit">기존 공고</ToggleButton>
      <ToggleButton value="lh">LH 공고</ToggleButton>
    </ToggleButtonGroup>

    {/* 2. 상태 필터 */}
    <FormControl sx={{ minWidth: 150 }}>
      <InputLabel>상태</InputLabel>
      <Select
        value={statusFilter}
        label="상태"
        onChange={(e) => setStatusFilter(e.target.value)}
        size="small"
      >
        {STATUS_OPTIONS.map((opt) => (
          <MenuItem key={opt.value} value={opt.value}>{opt.label}</MenuItem>
        ))}
      </Select>
    </FormControl>

    {/* 3. 지역 필터 */}
    <FormControl sx={{ minWidth: 150 }}>
      <InputLabel>지역</InputLabel>
      <Select
        value={regionFilter}
        label="지역"
        onChange={(e) => setRegionFilter(e.target.value)}
        size="small"
      >
        <MenuItem value="all">전체 지역</MenuItem>
        {regions.map((region) => (
          <MenuItem key={region} value={region}>{region}</MenuItem>
        ))}
      </Select>
    </FormControl>

    {/* 4. 정렬 */}
    <FormControl sx={{ minWidth: 150 }}>
      <InputLabel>정렬</InputLabel>
      <Select
        value={sortBy}
        label="정렬"
        onChange={(e) => setSortBy(e.target.value as SortOption)}
        size="small"
      >
        {SORT_OPTIONS.map((opt) => (
          <MenuItem key={opt.value} value={opt.value}>{opt.label}</MenuItem>
        ))}
      </Select>
    </FormControl>

    <Box sx={{ flexGrow: 1 }} />

    {/* 5. 총 개수 */}
    <Typography variant="body2">
      총 <strong>{sortedAnnouncements.length}</strong>개 공고
    </Typography>
  </Stack>
</Paper>
```

---

## 🚀 Phase 2: CategoryBannerList 모달 추가

### 2.1 AgeCategoriesPage 패턴 적용

**목표**: 별도 페이지 대신 Dialog 모달로 추가/수정

**파일**: `apps/pickly_admin/src/pages/banners/CategoryBannerList.tsx`

**추가할 State**:
```typescript
const [dialogOpen, setDialogOpen] = useState(false)
const [editingBanner, setEditingBanner] = useState<CategoryBanner | null>(null)
const [imageFile, setImageFile] = useState<File | null>(null)
const [imagePreview, setImagePreview] = useState<string | null>(null)
```

---

### 2.2 Form Schema 정의

```typescript
// apps/pickly_admin/src/types/banner.ts
export interface BannerFormData {
  title: string
  subtitle: string | null
  category_id: string
  image_url: string | null
  display_order: number
  is_active: boolean
  link_url: string | null
}
```

**Zod Schema**:
```typescript
import { z } from 'zod'

const bannerSchema = z.object({
  title: z.string().min(1, '제목을 입력하세요'),
  subtitle: z.string().optional().nullable(),
  category_id: z.string().min(1, '카테고리를 선택하세요'),
  image_url: z.string().nullable(),
  display_order: z.number().int().min(0),
  is_active: z.boolean(),
  link_url: z.string().url('올바른 URL을 입력하세요').optional().nullable(),
})
```

---

### 2.3 이미지 업로드 처리

**Storage 업로드 함수**:
```typescript
// apps/pickly_admin/src/utils/storage.ts
import { supabase } from '@/lib/supabase'

export async function uploadBannerImage(file: File): Promise<{ url: string; path: string }> {
  const fileExt = file.name.split('.').pop()
  const fileName = `${Date.now()}-${Math.random().toString(36).substring(7)}.${fileExt}`
  const filePath = `banners/${fileName}`

  const { data, error } = await supabase.storage
    .from('benefit-images')
    .upload(filePath, file, {
      cacheControl: '3600',
      upsert: false,
    })

  if (error) throw error

  const { data: { publicUrl } } = supabase.storage
    .from('benefit-images')
    .getPublicUrl(filePath)

  return { url: publicUrl, path: filePath }
}
```

**이미지 선택 핸들러**:
```typescript
const handleImageSelect = (event: React.ChangeEvent<HTMLInputElement>) => {
  const file = event.target.files?.[0]
  if (!file) return

  // 이미지 파일 검증
  if (!file.type.startsWith('image/')) {
    toast.error('이미지 파일만 업로드 가능합니다')
    return
  }

  // 파일 크기 검증 (최대 5MB)
  if (file.size > 5 * 1024 * 1024) {
    toast.error('파일 크기는 5MB 이하여야 합니다')
    return
  }

  setImageFile(file)
  setImagePreview(URL.createObjectURL(file))
}
```

---

### 2.4 Dialog 모달 UI

```typescript
<Dialog
  open={dialogOpen}
  onClose={handleCloseDialog}
  maxWidth="md"
  fullWidth
>
  <DialogTitle>
    {editingBanner ? '배너 수정' : '배너 추가'}
  </DialogTitle>
  <form onSubmit={handleSubmit(onSubmit)}>
    <DialogContent>
      <Grid container spacing={2}>
        {/* 제목 */}
        <Grid item xs={12}>
          <Controller
            name="title"
            control={control}
            render={({ field }) => (
              <TextField
                {...field}
                fullWidth
                label="제목"
                error={!!errors.title}
                helperText={errors.title?.message}
              />
            )}
          />
        </Grid>

        {/* 부제목 */}
        <Grid item xs={12}>
          <Controller
            name="subtitle"
            control={control}
            render={({ field }) => (
              <TextField
                {...field}
                value={field.value || ''}
                fullWidth
                label="부제목 (선택사항)"
                error={!!errors.subtitle}
                helperText={errors.subtitle?.message}
              />
            )}
          />
        </Grid>

        {/* 카테고리 선택 */}
        <Grid item xs={12}>
          <Controller
            name="category_id"
            control={control}
            render={({ field }) => (
              <FormControl fullWidth error={!!errors.category_id}>
                <InputLabel>카테고리</InputLabel>
                <Select {...field} label="카테고리">
                  {categories?.map((cat) => (
                    <MenuItem key={cat.id} value={cat.id}>
                      {cat.name}
                    </MenuItem>
                  ))}
                </Select>
                {errors.category_id && (
                  <Typography variant="caption" color="error">
                    {errors.category_id.message}
                  </Typography>
                )}
              </FormControl>
            )}
          />
        </Grid>

        {/* 이미지 업로드 */}
        <Grid item xs={12}>
          <Typography variant="body2" gutterBottom>
            배너 이미지
          </Typography>
          {imagePreview && (
            <Paper sx={{ p: 2, mb: 2 }}>
              <img
                src={imagePreview}
                alt="Banner preview"
                style={{
                  width: '100%',
                  maxHeight: 200,
                  objectFit: 'contain',
                }}
              />
            </Paper>
          )}
          <Button
            variant="outlined"
            component="label"
            startIcon={<UploadIcon />}
            fullWidth
          >
            {imagePreview ? '이미지 변경' : '이미지 업로드'}
            <input
              type="file"
              hidden
              accept="image/*"
              onChange={handleImageSelect}
            />
          </Button>
          <Typography variant="caption" color="text.secondary" display="block" mt={1}>
            이미지 파일, 최대 5MB
          </Typography>
        </Grid>

        {/* 링크 URL (선택사항) */}
        <Grid item xs={12}>
          <Controller
            name="link_url"
            control={control}
            render={({ field }) => (
              <TextField
                {...field}
                value={field.value || ''}
                fullWidth
                label="링크 URL (선택사항)"
                placeholder="https://example.com"
                error={!!errors.link_url}
                helperText={errors.link_url?.message}
              />
            )}
          />
        </Grid>

        {/* 정렬 순서 */}
        <Grid item xs={6}>
          <Controller
            name="display_order"
            control={control}
            render={({ field }) => (
              <TextField
                {...field}
                onChange={(e) => field.onChange(parseInt(e.target.value) || 0)}
                fullWidth
                label="정렬 순서"
                type="number"
                error={!!errors.display_order}
                helperText={errors.display_order?.message}
              />
            )}
          />
        </Grid>

        {/* 활성화 */}
        <Grid item xs={6}>
          <Controller
            name="is_active"
            control={control}
            render={({ field }) => (
              <FormControlLabel
                control={<Switch {...field} checked={field.value} />}
                label="활성화"
              />
            )}
          />
        </Grid>
      </Grid>
    </DialogContent>

    <DialogActions>
      <Button onClick={handleCloseDialog}>취소</Button>
      <Button
        type="submit"
        variant="contained"
        disabled={isSubmitting}
      >
        {editingBanner ? '수정' : '추가'}
      </Button>
    </DialogActions>
  </form>
</Dialog>
```

---

### 2.5 Mutation 로직

```typescript
const saveMutation = useMutation({
  mutationFn: async (formData: BannerFormData) => {
    let imageUrl = formData.image_url

    // 새 이미지 업로드
    if (imageFile) {
      const uploadResult = await uploadBannerImage(imageFile)
      imageUrl = uploadResult.url
    }

    const dataToSave = {
      ...formData,
      image_url: imageUrl,
    }

    if (editingBanner) {
      // 수정
      const { data, error } = await supabase
        .from('category_banners')
        .update(dataToSave)
        .eq('id', editingBanner.id)
        .select()
        .single()

      if (error) throw error
      return data
    } else {
      // 추가
      const { data, error } = await supabase
        .from('category_banners')
        .insert(dataToSave)
        .select()
        .single()

      if (error) throw error
      return data
    }
  },
  onSuccess: () => {
    toast.success(editingBanner ? '배너가 수정되었습니다' : '배너가 추가되었습니다')
    queryClient.invalidateQueries({ queryKey: ['category-banners'] })
    handleCloseDialog()
  },
  onError: (error: Error) => {
    toast.error(error.message || '저장에 실패했습니다')
  },
})
```

---

### 2.6 Dialog 열기/닫기 핸들러

```typescript
const handleOpenDialog = (banner?: CategoryBanner) => {
  if (banner) {
    // 수정 모드
    setEditingBanner(banner)
    reset({
      title: banner.title,
      subtitle: banner.subtitle,
      category_id: banner.category_id,
      image_url: banner.image_url,
      display_order: banner.display_order ?? 0,
      is_active: banner.is_active ?? true,
      link_url: banner.link_url,
    })
    setImagePreview(banner.image_url)
  } else {
    // 추가 모드
    setEditingBanner(null)
    reset({
      title: '',
      subtitle: null,
      category_id: '',
      image_url: null,
      display_order: banners?.length || 0,
      is_active: true,
      link_url: null,
    })
    setImagePreview(null)
  }
  setImageFile(null)
  setDialogOpen(true)
}

const handleCloseDialog = () => {
  setDialogOpen(false)
  setEditingBanner(null)
  setImageFile(null)
  setImagePreview(null)
  reset()
}
```

---

### 2.7 DataGrid 수정 아이콘 변경

**기존**:
```typescript
onClick={() => navigate(`/banners/${params.row.id}/edit`)}
```

**변경**:
```typescript
onClick={() => handleOpenDialog(params.row)}
```

---

## 🎯 Phase 3: 공통 컴포넌트 및 패턴

### 3.1 재사용 가능한 유틸리티

**파일 구조**:
```
apps/pickly_admin/src/
├── utils/
│   ├── date.ts          # D-Day 계산, 날짜 포맷
│   ├── storage.ts       # Supabase Storage 업로드
│   └── validation.ts    # 공통 Zod 스키마
├── components/
│   └── common/
│       ├── FileUpload.tsx        # 파일 업로드 공통 컴포넌트
│       ├── ImagePreview.tsx      # 이미지 미리보기
│       └── ConfirmDialog.tsx     # 삭제 확인 Dialog
```

---

### 3.2 공통 FileUpload 컴포넌트

```typescript
// apps/pickly_admin/src/components/common/FileUpload.tsx
import { useState } from 'react'
import { Box, Button, Paper, Typography } from '@mui/material'
import { Upload as UploadIcon } from '@mui/icons-material'

interface FileUploadProps {
  accept?: string
  maxSize?: number // bytes
  preview?: string | null
  onFileSelect: (file: File) => void
  label?: string
  helperText?: string
}

export default function FileUpload({
  accept = 'image/*',
  maxSize = 5 * 1024 * 1024, // 5MB
  preview,
  onFileSelect,
  label = '파일 업로드',
  helperText = '최대 5MB',
}: FileUploadProps) {
  const handleChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    const file = event.target.files?.[0]
    if (!file) return

    // 파일 크기 검증
    if (file.size > maxSize) {
      alert(`파일 크기는 ${maxSize / 1024 / 1024}MB 이하여야 합니다`)
      return
    }

    onFileSelect(file)
  }

  return (
    <Box>
      {preview && (
        <Paper sx={{ p: 2, mb: 2 }}>
          <img
            src={preview}
            alt="Preview"
            style={{
              width: '100%',
              maxHeight: 200,
              objectFit: 'contain',
            }}
          />
        </Paper>
      )}
      <Button
        variant="outlined"
        component="label"
        startIcon={<UploadIcon />}
        fullWidth
      >
        {preview ? '파일 변경' : label}
        <input
          type="file"
          hidden
          accept={accept}
          onChange={handleChange}
        />
      </Button>
      <Typography variant="caption" color="text.secondary" display="block" mt={1}>
        {helperText}
      </Typography>
    </Box>
  )
}
```

**사용 예시**:
```typescript
<FileUpload
  accept="image/*"
  maxSize={5 * 1024 * 1024}
  preview={imagePreview}
  onFileSelect={(file) => {
    setImageFile(file)
    setImagePreview(URL.createObjectURL(file))
  }}
  label="배너 이미지 업로드"
  helperText="이미지 파일, 최대 5MB"
/>
```

---

### 3.3 공통 ConfirmDialog 컴포넌트

```typescript
// apps/pickly_admin/src/components/common/ConfirmDialog.tsx
import {
  Dialog,
  DialogTitle,
  DialogContent,
  DialogContentText,
  DialogActions,
  Button,
} from '@mui/material'

interface ConfirmDialogProps {
  open: boolean
  title: string
  message: string
  onConfirm: () => void
  onCancel: () => void
  confirmText?: string
  cancelText?: string
  confirmColor?: 'primary' | 'error' | 'warning'
}

export default function ConfirmDialog({
  open,
  title,
  message,
  onConfirm,
  onCancel,
  confirmText = '확인',
  cancelText = '취소',
  confirmColor = 'primary',
}: ConfirmDialogProps) {
  return (
    <Dialog open={open} onClose={onCancel}>
      <DialogTitle>{title}</DialogTitle>
      <DialogContent>
        <DialogContentText>{message}</DialogContentText>
      </DialogContent>
      <DialogActions>
        <Button onClick={onCancel} color="inherit">
          {cancelText}
        </Button>
        <Button onClick={onConfirm} color={confirmColor} variant="contained">
          {confirmText}
        </Button>
      </DialogActions>
    </Dialog>
  )
}
```

**사용 예시**:
```typescript
const [confirmOpen, setConfirmOpen] = useState(false)
const [deleteTarget, setDeleteTarget] = useState<string | null>(null)

const handleDeleteClick = (id: string) => {
  setDeleteTarget(id)
  setConfirmOpen(true)
}

const handleConfirmDelete = () => {
  if (deleteTarget) {
    deleteMutation.mutate(deleteTarget)
  }
  setConfirmOpen(false)
  setDeleteTarget(null)
}

// JSX
<ConfirmDialog
  open={confirmOpen}
  title="배너 삭제"
  message="정말 이 배너를 삭제하시겠습니까? 이 작업은 되돌릴 수 없습니다."
  onConfirm={handleConfirmDelete}
  onCancel={() => setConfirmOpen(false)}
  confirmText="삭제"
  confirmColor="error"
/>
```

---

### 3.4 Material UI 스타일 가이드

**일관된 Spacing**:
```typescript
// 페이지 컨테이너
<Box sx={{ p: 3 }}>

// 섹션 간격
<Box sx={{ mb: 3 }}>

// 버튼 그룹
<Stack direction="row" spacing={2}>

// 폼 필드
<Grid container spacing={2}>
```

**색상 팔레트**:
```typescript
// 상태 색상
success: '#4CAF50'  // 활성, 성공
error: '#F44336'    // 비활성, 에러, 마감
warning: '#FF9800'  // 경고, D-7 이하
info: '#2196F3'     // 정보, 예정
default: '#9E9E9E'  // 기본, 중립
```

**Typography 계층**:
```typescript
h4: 페이지 제목
h5: 섹션 제목
h6: 서브섹션 제목
body1: 본문 (기본)
body2: 본문 (작은 크기)
caption: 부가 설명
```

---

## 📝 구현 체크리스트

### Phase 1: BenefitAnnouncementList

- [ ] `apps/pickly_admin/src/utils/date.ts` 생성
  - [ ] `calculateDDay` 함수 구현
  - [ ] 테스트 케이스 작성

- [ ] `BenefitAnnouncementList.tsx` 수정
  - [ ] D-Day 컬럼 추가
  - [ ] 지역 필터 State 추가
  - [ ] 지역 필터 UI 추가
  - [ ] 정렬 State 추가
  - [ ] 정렬 UI 추가
  - [ ] 필터링/정렬 로직 통합

- [ ] 데이터베이스 확인
  - [ ] `announcements` 테이블에 `region` 컬럼 존재 확인
  - [ ] 필요 시 마이그레이션 작성

### Phase 2: CategoryBannerList

- [ ] `apps/pickly_admin/src/types/banner.ts` 생성
  - [ ] `BannerFormData` 타입 정의
  - [ ] Zod 스키마 작성

- [ ] `apps/pickly_admin/src/utils/storage.ts` 수정
  - [ ] `uploadBannerImage` 함수 추가

- [ ] `CategoryBannerList.tsx` 수정
  - [ ] State 추가 (dialog, editing, file, preview)
  - [ ] React Hook Form 설정
  - [ ] Dialog UI 구현
  - [ ] 이미지 업로드 핸들러
  - [ ] Save/Delete Mutation
  - [ ] DataGrid 수정 버튼 변경

### Phase 3: 공통 컴포넌트

- [ ] `apps/pickly_admin/src/components/common/` 디렉토리 생성
- [ ] `FileUpload.tsx` 구현
- [ ] `ConfirmDialog.tsx` 구현
- [ ] `ImagePreview.tsx` 구현 (선택사항)

### 테스트 및 검증

- [ ] TypeScript 컴파일 성공
- [ ] ESLint 0 errors
- [ ] `npm run dev` 실행 확인
- [ ] 브라우저 렌더링 정상
- [ ] D-Day 계산 정확성 검증
- [ ] 필터/정렬 동작 확인
- [ ] 이미지 업로드 테스트
- [ ] 모달 CRUD 동작 확인
- [ ] 반응형 디자인 확인 (1920px, 1440px, 1024px)

---

## 🚨 주의사항 (CRITICAL)

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

### Material UI 패턴

```typescript
// ✅ GOOD
import { Box, Button } from '@mui/material'

// ❌ BAD
import Box from '@mui/material/Box'
import Button from '@mui/material/Button'
```

---

## 🔧 개발 환경 설정

### 필요한 패키지 (이미 설치됨)

```json
{
  "@mui/material": "^5.15.0",
  "@mui/icons-material": "^5.15.0",
  "@mui/x-data-grid": "^6.18.0",
  "react-hook-form": "^7.49.0",
  "zod": "^3.22.0",
  "@hookform/resolvers": "^3.3.0",
  "@tanstack/react-query": "^5.0.0",
  "react-hot-toast": "^2.4.0",
  "date-fns": "^3.0.0"
}
```

### 개발 서버 실행

```bash
cd apps/pickly_admin
npm run dev
```

### 타입 체크

```bash
npm run typecheck
```

### 린트

```bash
npm run lint
```

---

## 📚 참고 문서

### Material UI 공식 문서

- DataGrid: https://mui.com/x/react-data-grid/
- Forms: https://mui.com/material-ui/react-text-field/
- Dialog: https://mui.com/material-ui/react-dialog/
- Select: https://mui.com/material-ui/react-select/

### React Hook Form

- Controller: https://react-hook-form.com/api/usecontroller/controller
- Resolver: https://react-hook-form.com/get-started#SchemaValidation

### Zod

- String validation: https://zod.dev/?id=strings
- Object schema: https://zod.dev/?id=objects

### TanStack Query

- Mutations: https://tanstack.com/query/latest/docs/react/guides/mutations
- Invalidation: https://tanstack.com/query/latest/docs/react/guides/query-invalidation

---

## 🎯 예상 소요 시간

### Phase 1 (BenefitAnnouncementList)
- D-Day 계산: 1시간
- 지역 필터: 1시간
- 정렬 기능: 1시간
- **Total: 3시간**

### Phase 2 (CategoryBannerList)
- 타입/스키마 정의: 30분
- Dialog UI 구현: 2시간
- 이미지 업로드: 1.5시간
- Mutation 로직: 1시간
- **Total: 5시간**

### Phase 3 (공통 컴포넌트)
- FileUpload: 1시간
- ConfirmDialog: 1시간
- 문서화: 1시간
- **Total: 3시간**

### 테스트 및 검증
- **Total: 2시간**

---

**전체 예상 시간: 13시간**

---

## 📝 변경 이력

| 날짜 | 버전 | 변경 내용 | 작성자 |
|------|------|-----------|--------|
| 2025-10-31 | v1.0 | 초안 작성 | Claude |

---

## ✅ 승인 및 리뷰

- [ ] 기획팀 리뷰
- [ ] 디자인팀 리뷰
- [ ] 백엔드팀 리뷰 (DB 스키마 확인)
- [ ] 프론트엔드 리더 승인

---

**문서 작성 완료**
