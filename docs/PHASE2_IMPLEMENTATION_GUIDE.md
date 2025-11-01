# 🚀 Phase 2 Implementation Guide - Benefits Management

## 📋 Overview

**Phase**: Phase 2 - Benefits Management CRUD
**PRD Reference**: PRD v9.6 Section 4.2
**Status**: 🟡 **READY TO START**
**Estimated Time**: 4-6 hours

---

## ✅ Completed Foundation (Phase 2 Prep)

### 1. TypeScript Types ✅
**File**: `apps/pickly_admin/src/types/benefits.ts`

**Types Created** (300+ lines):
- `BenefitCategory` & `BenefitCategoryFormData`
- `BenefitSubcategory` & `BenefitSubcategoryFormData`
- `CategoryBanner` & `CategoryBannerFormData`
- `Announcement` & `AnnouncementFormData`
- `AnnouncementTab` & `AnnouncementTabFormData`
- View models with relations
- Statistics & analytics types
- Upload & filter types

### 2. Upload Components ✅
**Files Created**:
1. `apps/pickly_admin/src/components/common/ImageUploader.tsx`
   - Supports benefit-icons, benefit-thumbnails, benefit-banners buckets
   - Preview, progress, validation
   - Max size configurable
   - MIME type validation

2. `apps/pickly_admin/src/components/common/SVGUploader.tsx`
   - SVG-specific uploader
   - SVG content preview
   - Code preview (first 200 chars)
   - Validation for SVG format

---

## 📦 Implementation Tasks

### Task 1: BenefitCategoryPage ⏳
**File**: `apps/pickly_admin/src/pages/benefits/BenefitCategoryPage.tsx`
**Route**: `/benefits/categories`
**Estimated Time**: 1 hour

#### Features Required:
- ✅ List all benefit_categories with sort_order
- ✅ CRUD operations (Create, Read, Update, Delete)
- ✅ SVG icon upload via SVGUploader component
- ✅ Drag-drop reordering (optional, use sort_order form field)
- ✅ Active/inactive toggle
- ✅ Slug auto-generation from title
- ✅ Real-time query invalidation

#### Database Schema Reference:
```sql
benefit_categories:
  id uuid PRIMARY KEY
  title varchar(100) NOT NULL
  slug varchar(100) NOT NULL UNIQUE
  description text
  icon_url text
  icon_name text
  sort_order integer DEFAULT 0
  is_active boolean DEFAULT true
  created_at timestamptz
  updated_at timestamptz
```

#### Implementation Pattern (from HomeManagementPage):
```typescript
// 1. Data Fetching
const { data: categories = [], isLoading } = useQuery({
  queryKey: ['benefit_categories'],
  queryFn: async () => {
    const { data, error } = await supabase
      .from('benefit_categories')
      .select('*')
      .order('sort_order', { ascending: true })
    if (error) throw error
    return data as BenefitCategory[]
  },
})

// 2. Create/Update Mutation
const saveMutation = useMutation({
  mutationFn: async (data: BenefitCategoryFormData & { id?: string }) => {
    if (data.id) {
      const { error } = await supabase
        .from('benefit_categories')
        .update(data)
        .eq('id', data.id)
      if (error) throw error
    } else {
      const { error } = await supabase
        .from('benefit_categories')
        .insert([data])
      if (error) throw error
    }
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['benefit_categories'] })
    toast.success(editingCategory ? '카테고리가 수정되었습니다' : '카테고리가 추가되었습니다')
    handleCloseDialog()
  },
})

// 3. Delete Mutation
const deleteMutation = useMutation({
  mutationFn: async (id: string) => {
    const { error } = await supabase
      .from('benefit_categories')
      .delete()
      .eq('id', id)
    if (error) throw error
  },
  onSuccess: () => {
    queryClient.invalidateQueries({ queryKey: ['benefit_categories'] })
    toast.success('카테고리가 삭제되었습니다')
  },
})

// 4. Dialog Form Fields
<TextField label="카테고리 제목" value={formData.title} onChange={...} required />
<TextField label="슬러그" value={formData.slug} onChange={...} required />
<TextField label="설명" value={formData.description} multiline rows={3} />
<SVGUploader
  bucket="benefit-icons"
  currentSvgUrl={formData.icon_url}
  onUploadComplete={(url, path) => {
    setFormData({ ...formData, icon_url: url })
  }}
/>
<TextField label="정렬 순서" type="number" value={formData.sort_order} />
<Switch checked={formData.is_active} label="활성 상태" />
```

---

### Task 2: BenefitSubcategoryPage ⏳
**File**: `apps/pickly_admin/src/pages/benefits/BenefitSubcategoryPage.tsx`
**Route**: `/benefits/subcategories`
**Estimated Time**: 45 minutes

#### Features Required:
- List benefit_subcategories with parent category info
- CRUD operations
- Category dropdown (FK to benefit_categories)
- Display order management
- Active/inactive toggle

#### Database Schema Reference:
```sql
benefit_subcategories:
  id uuid PRIMARY KEY
  category_id uuid FK → benefit_categories(id) CASCADE
  name varchar(100) NOT NULL
  slug varchar(100) NOT NULL
  display_order integer DEFAULT 0
  is_active boolean DEFAULT true
  created_at timestamptz
```

#### Additional Query (with category info):
```typescript
const { data: subcategories = [], isLoading } = useQuery({
  queryKey: ['benefit_subcategories'],
  queryFn: async () => {
    const { data, error } = await supabase
      .from('benefit_subcategories')
      .select(`
        *,
        category:benefit_categories(id, title, slug)
      `)
      .order('display_order', { ascending: true })
    if (error) throw error
    return data as BenefitSubcategoryWithCategory[]
  },
})
```

#### Form Fields:
```typescript
<Select label="대분류 카테고리" value={formData.category_id} required>
  {categories.map(cat => (
    <MenuItem key={cat.id} value={cat.id}>{cat.title}</MenuItem>
  ))}
</Select>
<TextField label="하위분류 이름" value={formData.name} required />
<TextField label="슬러그" value={formData.slug} required />
<TextField label="정렬 순서" type="number" value={formData.display_order} />
```

---

### Task 3: BannerManagementPage ⏳
**File**: `apps/pickly_admin/src/pages/benefits/BannerManagementPage.tsx`
**Route**: `/benefits/banners`
**Estimated Time**: 1 hour

#### Features Required:
- List category_banners by category
- CRUD operations
- Image upload via ImageUploader
- Link type selection (internal/external/none)
- Background color picker
- Display order management
- Category filter dropdown

#### Database Schema Reference:
```sql
category_banners:
  id uuid PRIMARY KEY
  category_id uuid FK → benefit_categories(id) CASCADE
  category_slug text NOT NULL
  title text NOT NULL
  subtitle text
  image_url text NOT NULL
  link_url text
  link_type text ('internal'|'external'|'none')
  background_color text DEFAULT '#FFFFFF'
  display_order integer DEFAULT 0
  is_active boolean DEFAULT true
  created_at timestamptz
  updated_at timestamptz
```

#### Form Fields:
```typescript
<Select label="카테고리" value={formData.category_id} required>
  {categories.map(cat => (
    <MenuItem key={cat.id} value={cat.id}>{cat.title}</MenuItem>
  ))}
</Select>
<TextField label="배너 제목" value={formData.title} required />
<TextField label="부제목" value={formData.subtitle} />
<ImageUploader
  bucket="benefit-banners"
  currentImageUrl={formData.image_url}
  onUploadComplete={(url) => setFormData({ ...formData, image_url: url })}
  maxSizeMB={5}
/>
<TextField label="링크 URL" value={formData.link_url} />
<Select label="링크 타입" value={formData.link_type}>
  <MenuItem value="none">없음</MenuItem>
  <MenuItem value="internal">내부 링크</MenuItem>
  <MenuItem value="external">외부 링크</MenuItem>
</Select>
<TextField
  label="배경색"
  type="color"
  value={formData.background_color}
  helperText="헥스 컬러 코드 (예: #FFFFFF)"
/>
<TextField label="정렬 순서" type="number" value={formData.display_order} />
```

---

### Task 4: Enhanced AnnouncementManager ⏳
**File**: `apps/pickly_admin/src/pages/benefits/AnnouncementManager.tsx` (enhance existing)
**Route**: `/benefits/announcements`
**Estimated Time**: 1.5 hours

#### Features to Add/Enhance:
- ✅ Thumbnail upload via ImageUploader
- ✅ Date pickers for application_start_date, application_end_date, deadline_date
- ✅ Status dropdown (recruiting, closed, upcoming, draft)
- ✅ Category and subcategory dropdowns
- ✅ Region field
- ✅ Tags (array input)
- ✅ Content editor (multiline textarea or rich text)
- ✅ Featured, Home Visible, Priority toggles
- ✅ Display priority number
- ✅ Link type selection

#### Database Schema Reference:
```sql
announcements:
  id uuid PRIMARY KEY
  title text NOT NULL
  subtitle text
  organization text NOT NULL
  category_id uuid FK → benefit_categories(id)
  subcategory_id uuid FK → benefit_subcategories(id)
  thumbnail_url text
  external_url text
  detail_url text
  status text ('recruiting'|'closed'|'upcoming'|'draft')
  is_featured boolean DEFAULT false
  is_home_visible boolean DEFAULT false
  is_priority boolean DEFAULT false
  display_priority integer DEFAULT 0
  tags text[]
  content text
  region text
  application_start_date timestamptz
  application_end_date timestamptz
  deadline_date date
  views_count integer DEFAULT 0
  link_type text ('internal'|'external'|'none')
  created_at timestamptz
  updated_at timestamptz
```

#### Form Sections:
```typescript
// 1. Basic Info
<TextField label="공고 제목" value={formData.title} required fullWidth />
<TextField label="부제목" value={formData.subtitle} fullWidth />
<TextField label="주관 기관" value={formData.organization} required />

// 2. Category & Classification
<Select label="대분류" value={formData.category_id}>
  {categories.map(cat => <MenuItem key={cat.id} value={cat.id}>{cat.title}</MenuItem>)}
</Select>
<Select label="하위분류" value={formData.subcategory_id}>
  {subcategories
    .filter(sub => sub.category_id === formData.category_id)
    .map(sub => <MenuItem key={sub.id} value={sub.id}>{sub.name}</MenuItem>)
  }
</Select>

// 3. Media
<ImageUploader
  bucket="benefit-thumbnails"
  currentImageUrl={formData.thumbnail_url}
  onUploadComplete={(url) => setFormData({ ...formData, thumbnail_url: url })}
  maxSizeMB={3}
  label="썸네일 이미지"
/>

// 4. Status & Dates
<Select label="상태" value={formData.status} required>
  <MenuItem value="recruiting">모집 중</MenuItem>
  <MenuItem value="closed">마감</MenuItem>
  <MenuItem value="upcoming">예정</MenuItem>
  <MenuItem value="draft">임시저장</MenuItem>
</Select>
<TextField
  label="신청 시작일"
  type="datetime-local"
  value={formData.application_start_date}
  InputLabelProps={{ shrink: true }}
/>
<TextField
  label="신청 마감일"
  type="datetime-local"
  value={formData.application_end_date}
  InputLabelProps={{ shrink: true }}
/>
<TextField
  label="최종 마감일"
  type="date"
  value={formData.deadline_date}
  InputLabelProps={{ shrink: true }}
/>

// 5. Content
<TextField
  label="공고 내용"
  value={formData.content}
  multiline
  rows={10}
  fullWidth
  helperText="상세 내용을 입력하세요"
/>

// 6. Links
<TextField label="외부 링크 URL" value={formData.external_url} fullWidth />
<Select label="링크 타입" value={formData.link_type}>
  <MenuItem value="none">없음</MenuItem>
  <MenuItem value="internal">내부</MenuItem>
  <MenuItem value="external">외부</MenuItem>
</Select>

// 7. Display Settings
<FormControlLabel
  control={<Switch checked={formData.is_featured} onChange={...} />}
  label="추천 공고"
/>
<FormControlLabel
  control={<Switch checked={formData.is_home_visible} onChange={...} />}
  label="홈 화면 표시"
/>
<FormControlLabel
  control={<Switch checked={formData.is_priority} onChange={...} />}
  label="우선 공고"
/>
<TextField
  label="표시 우선순위"
  type="number"
  value={formData.display_priority}
  helperText="높은 숫자일수록 우선 표시"
/>

// 8. Additional Info
<TextField label="지역" value={formData.region} />
<TextField
  label="태그"
  value={formData.tags?.join(', ')}
  onChange={(e) => setFormData({
    ...formData,
    tags: e.target.value.split(',').map(t => t.trim()).filter(Boolean)
  })}
  helperText="쉼표로 구분 (예: 청년, 주거지원, 신혼부부)"
/>
```

---

### Task 5: AnnouncementTabsManager ⏳
**File**: `apps/pickly_admin/src/pages/benefits/AnnouncementTabsManager.tsx`
**Route**: `/benefits/announcements/:id/tabs`
**Estimated Time**: 1 hour

#### Features Required:
- List announcement_tabs for specific announcement
- CRUD operations for tabs
- Age category dropdown (청년, 신혼부부, 대학생 등)
- Unit type input
- Floor plan image upload
- Supply count input
- Income conditions (JSON field - use JSONEditor or text input)
- Additional info (JSON field)
- Display order

#### Database Schema Reference:
```sql
announcement_tabs:
  id uuid PRIMARY KEY
  announcement_id uuid FK → announcements(id) CASCADE
  tab_name text NOT NULL
  age_category_id uuid FK → age_categories(id)
  unit_type text
  floor_plan_image_url text
  supply_count integer
  income_conditions jsonb
  additional_info jsonb
  display_order integer DEFAULT 0
  created_at timestamptz
```

#### Form Fields:
```typescript
<TextField label="탭 이름" value={formData.tab_name} required />
<Select label="연령 카테고리" value={formData.age_category_id}>
  {ageCategories.map(cat => (
    <MenuItem key={cat.id} value={cat.id}>{cat.name}</MenuItem>
  ))}
</Select>
<TextField label="주택 유형" value={formData.unit_type} />
<ImageUploader
  bucket="benefit-thumbnails"
  currentImageUrl={formData.floor_plan_image_url}
  onUploadComplete={(url) => setFormData({ ...formData, floor_plan_image_url: url })}
  label="평면도 이미지"
/>
<TextField
  label="공급 세대수"
  type="number"
  value={formData.supply_count}
/>
<TextField
  label="소득 조건 (JSON)"
  value={JSON.stringify(formData.income_conditions, null, 2)}
  multiline
  rows={4}
  helperText="JSON 형식으로 입력"
  onChange={(e) => {
    try {
      setFormData({ ...formData, income_conditions: JSON.parse(e.target.value) })
    } catch {}
  }}
/>
<TextField
  label="추가 정보 (JSON)"
  value={JSON.stringify(formData.additional_info, null, 2)}
  multiline
  rows={4}
  onChange={(e) => {
    try {
      setFormData({ ...formData, additional_info: JSON.parse(e.target.value) })
    } catch {}
  }}
/>
<TextField
  label="표시 순서"
  type="number"
  value={formData.display_order}
/>
```

---

## 🛠️ Implementation Steps

### Step 1: Set Up Routes
**File**: `apps/pickly_admin/src/App.tsx`

```typescript
// Add imports
import BenefitCategoryPage from '@/pages/benefits/BenefitCategoryPage'
import BenefitSubcategoryPage from '@/pages/benefits/BenefitSubcategoryPage'
import BannerManagementPage from '@/pages/benefits/BannerManagementPage'
// AnnouncementManager already exists - enhance it
import AnnouncementTabsManager from '@/pages/benefits/AnnouncementTabsManager'

// Add routes (inside PrivateRoute)
<Route path="benefits/categories" element={<BenefitCategoryPage />} />
<Route path="benefits/subcategories" element={<BenefitSubcategoryPage />} />
<Route path="benefits/banners" element={<BannerManagementPage />} />
<Route path="benefits/announcements" element={<BenefitAnnouncementList />} />
<Route path="benefits/announcements/:id/tabs" element={<AnnouncementTabsManager />} />
```

### Step 2: Create Pages (Priority Order)
1. **BenefitCategoryPage** - Foundation for others (categories needed by all)
2. **BenefitSubcategoryPage** - Depends on categories
3. **BannerManagementPage** - Depends on categories
4. **Enhanced AnnouncementManager** - Depends on categories + subcategories
5. **AnnouncementTabsManager** - Depends on announcements + age_categories

### Step 3: Test Each Page
- Create test items
- Update items
- Delete items
- Toggle active/inactive
- Upload images/SVGs
- Verify query invalidation works

---

## 📊 Database Queries Reference

### Fetch with Relations
```typescript
// Categories with counts
const { data } = await supabase
  .from('benefit_categories')
  .select(`
    *,
    subcategories:benefit_subcategories(count),
    banners:category_banners(count),
    announcements:announcements(count)
  `)

// Subcategories with category
const { data } = await supabase
  .from('benefit_subcategories')
  .select(`
    *,
    category:benefit_categories(id, title, slug)
  `)

// Banners with category
const { data } = await supabase
  .from('category_banners')
  .select(`
    *,
    category:benefit_categories(id, title, slug)
  `)

// Announcements with relations
const { data } = await supabase
  .from('announcements')
  .select(`
    *,
    category:benefit_categories(id, title, slug),
    subcategory:benefit_subcategories(id, name, slug),
    tabs:announcement_tabs(count)
  `)

// Announcement tabs with age category
const { data } = await supabase
  .from('announcement_tabs')
  .select(`
    *,
    age_category:age_categories(id, name, slug)
  `)
  .eq('announcement_id', announcementId)
```

---

## 🎨 UI/UX Patterns

### List View Pattern (from HomeManagementPage)
```typescript
<Paper>
  <List>
    {items.map((item) => (
      <ListItem key={item.id}>
        <IconButton sx={{ mr: 1, cursor: 'grab' }}>
          <DragIcon />
        </IconButton>
        <ListItemText
          primary={<Typography variant="h6">{item.title}</Typography>}
          secondary={<Typography>Sort order: {item.sort_order}</Typography>}
        />
        <ListItemSecondaryAction>
          <Switch checked={item.is_active} onChange={...} />
          <IconButton onClick={() => handleEdit(item)}>
            <EditIcon />
          </IconButton>
          <IconButton onClick={() => handleDelete(item.id)} color="error">
            <DeleteIcon />
          </IconButton>
        </ListItemSecondaryAction>
      </ListItem>
    ))}
  </List>
</Paper>
```

### Dialog Form Pattern
```typescript
<Dialog open={dialogOpen} onClose={handleCloseDialog} maxWidth="md" fullWidth>
  <DialogTitle>{editing ? '수정' : '추가'}</DialogTitle>
  <DialogContent>
    <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 2 }}>
      {/* Form fields here */}
    </Box>
  </DialogContent>
  <DialogActions>
    <Button onClick={handleCloseDialog}>취소</Button>
    <Button onClick={handleSave} variant="contained" disabled={saveMutation.isPending}>
      {editing ? '수정' : '추가'}
    </Button>
  </DialogActions>
</Dialog>
```

---

## 🧪 Testing Checklist

### Per Page Testing
- [ ] List displays all items
- [ ] Create new item works
- [ ] Edit existing item works
- [ ] Delete item with confirmation works
- [ ] Toggle active/inactive works
- [ ] Image/SVG upload works
- [ ] Form validation catches errors
- [ ] Query invalidation refreshes list
- [ ] Toast notifications appear
- [ ] RLS policies allow authenticated access

### Integration Testing
- [ ] Categories affect subcategories dropdown
- [ ] Categories affect banners dropdown
- [ ] Categories + subcategories affect announcements
- [ ] Announcements link to tabs page
- [ ] Navigation between pages works

---

## 📚 Reference Files

### Existing Code to Reference
- `apps/pickly_admin/src/pages/home/HomeManagementPage.tsx` - CRUD pattern
- `apps/pickly_admin/src/components/common/Sidebar.tsx` - Navigation
- `apps/pickly_admin/src/types/home.ts` - Type patterns

### New Files Created
- `apps/pickly_admin/src/types/benefits.ts` ✅
- `apps/pickly_admin/src/components/common/ImageUploader.tsx` ✅
- `apps/pickly_admin/src/components/common/SVGUploader.tsx` ✅

### Files to Create
- `apps/pickly_admin/src/pages/benefits/BenefitCategoryPage.tsx`
- `apps/pickly_admin/src/pages/benefits/BenefitSubcategoryPage.tsx`
- `apps/pickly_admin/src/pages/benefits/BannerManagementPage.tsx`
- `apps/pickly_admin/src/pages/benefits/AnnouncementTabsManager.tsx`

### Files to Enhance
- `apps/pickly_admin/src/pages/benefits/BenefitAnnouncementList.tsx` (if exists)
- `apps/pickly_admin/src/App.tsx` (add routes)

---

## 🎯 Success Criteria

- [ ] All 5 pages implemented
- [ ] CRUD operations working for all entities
- [ ] Image/SVG uploads functional
- [ ] Relations between entities working
- [ ] RLS policies tested
- [ ] All routes accessible from sidebar
- [ ] No TypeScript errors
- [ ] React Query caching optimized
- [ ] Toast notifications for all actions
- [ ] Form validation comprehensive

---

## 📝 Next Steps After Phase 2

1. **Phase 2 QA**: Run comprehensive tests similar to Phase 1C
2. **Documentation**: Create Phase 2 completion report
3. **Production Deployment**: Deploy benefits management features
4. **Phase 3 Planning**: Community management (if applicable)

---

**Generated**: 2025-11-02
**Status**: 🟡 **READY TO IMPLEMENT**
**Foundation Complete**: Types + Upload Components ✅
**Estimated Total Time**: 4-6 hours
**Priority**: High (Core admin functionality)
