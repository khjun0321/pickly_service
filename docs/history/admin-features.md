# 관리자 기능 가이드

> **버전**: v7.2
> **작성일**: 2025.10.27
> **대상**: 백오피스 관리자, 백엔드 개발자

---

## 1. 개요

이 문서는 Pickly 백오피스의 관리자 기능을 설명합니다. PRD v7.0 기반으로 구현된 Phase 1 MVP 기능들을 다룹니다.

### 주요 기능

- ✅ 연령 카테고리 관리 (CRUD + SVG 업로드)
- ✅ 혜택 카테고리 관리
- ✅ 공고 관리 (Sections + Tabs)
- ✅ 배너 관리
- ✅ 사용자 통계

---

## 2. 연령 카테고리 관리

### 2.1 개요

모바일 앱의 온보딩 화면에서 사용되는 연령 카테고리를 관리합니다.

**테이블**: `age_categories`

**주요 필드**:
- `id` (uuid): 고유 식별자
- `name` (varchar): 카테고리 이름 (예: "청년", "중장년")
- `display_order` (integer): 표시 순서
- `icon_path` (text): SVG 아이콘 경로 (Supabase Storage)
- `age_min` (integer): 최소 연령
- `age_max` (integer): 최대 연령

### 2.2 CRUD 작업

#### 생성 (Create)

```typescript
// apps/pickly_admin/src/api/ageCategories.ts
export async function createAgeCategory(data: {
  name: string;
  display_order: number;
  icon_path?: string;
  age_min?: number;
  age_max?: number;
}) {
  const { data: category, error } = await supabase
    .from('age_categories')
    .insert([data])
    .select()
    .single();

  if (error) throw error;
  return category;
}
```

**UI**:
- 페이지: `apps/pickly_admin/src/pages/categories/CategoryForm.tsx`
- 폼 필드: 이름, 표시 순서, 아이콘 업로드, 나이 범위

#### 읽기 (Read)

```typescript
export async function getAgeCategories() {
  const { data, error } = await supabase
    .from('age_categories')
    .select('*')
    .order('display_order', { ascending: true });

  if (error) throw error;
  return data;
}
```

**UI**:
- 페이지: `apps/pickly_admin/src/pages/categories/CategoryList.tsx`
- 표시: 테이블 형식 (이름, 아이콘, 나이 범위, 순서)

#### 수정 (Update)

```typescript
export async function updateAgeCategory(
  id: string,
  data: Partial<AgeCategory>
) {
  const { data: updated, error } = await supabase
    .from('age_categories')
    .update(data)
    .eq('id', id)
    .select()
    .single();

  if (error) throw error;
  return updated;
}
```

#### 삭제 (Delete)

```typescript
export async function deleteAgeCategory(id: string) {
  const { error } = await supabase
    .from('age_categories')
    .delete()
    .eq('id', id);

  if (error) throw error;
}
```

**주의사항**:
- Foreign key 제약으로 인해 `announcement_tabs`에서 참조 중인 카테고리는 삭제 불가
- 삭제 전 관련 데이터 확인 필요

### 2.3 SVG 아이콘 업로드

#### Storage 구조

**Bucket**: `age-category-icons`
**경로**: `public/{category-id}/{filename}.svg`

#### 업로드 프로세스

```typescript
// 1. SVG 파일 업로드
export async function uploadAgeCategoryIcon(
  categoryId: string,
  file: File
): Promise<string> {
  const fileName = `${Date.now()}-${file.name}`;
  const filePath = `public/${categoryId}/${fileName}`;

  const { data, error } = await supabase.storage
    .from('age-category-icons')
    .upload(filePath, file, {
      cacheControl: '3600',
      upsert: false,
    });

  if (error) throw error;

  // 2. Public URL 반환
  const { data: publicUrl } = supabase.storage
    .from('age-category-icons')
    .getPublicUrl(filePath);

  return publicUrl.publicUrl;
}

// 3. DB 업데이트
await updateAgeCategory(categoryId, {
  icon_path: publicUrl,
});
```

#### UI 컴포넌트

```tsx
// apps/pickly_admin/src/components/AgeIconUpload.tsx
function AgeIconUpload({ categoryId, onUploadComplete }) {
  const handleFileChange = async (e: ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file || !file.type.includes('svg')) {
      alert('SVG 파일만 업로드 가능합니다.');
      return;
    }

    try {
      const url = await uploadAgeCategoryIcon(categoryId, file);
      onUploadComplete(url);
    } catch (error) {
      console.error('Upload failed:', error);
    }
  };

  return (
    <input
      type="file"
      accept=".svg"
      onChange={handleFileChange}
    />
  );
}
```

---

## 3. 공고 관리 (Announcement Types)

### 3.1 개요

공고 시스템은 3개 테이블로 구성됩니다:
- `announcements`: 기본 정보
- `announcement_sections`: 모듈식 섹션
- `announcement_tabs`: 평형별/연령별 탭

### 3.2 공고 기본 정보

**페이지**: `apps/pickly_admin/src/pages/benefits/BenefitAnnouncementForm.tsx`

**필수 필드**:
- `title`: 공고 제목
- `organization`: 발행 기관
- `category_id`: 혜택 카테고리
- `status`: 상태 ('recruiting' | 'closed' | 'draft')

**선택 필드**:
- `subtitle`: 부제목
- `subcategory_id`: 서브 카테고리
- `thumbnail_url`: 썸네일 이미지 URL
- `external_url`: 원본 공고문 링크
- `is_featured`: 인기 탭 노출 여부
- `is_home_visible`: 홈 화면 노출 여부
- `display_priority`: 표시 우선순위 (높을수록 상단)
- `tags`: 태그 배열

#### 생성 예시

```typescript
const announcement = await createAnnouncement({
  title: '2025 서울시 청년 행복주택 입주자 모집',
  subtitle: '16㎡/26㎡ 청년·신혼부부 대상',
  organization: 'LH 한국토지주택공사',
  category_id: 'housing-category-uuid',
  subcategory_id: 'happy-housing-subcategory-uuid',
  status: 'recruiting',
  is_featured: true,
  is_home_visible: true,
  display_priority: 10,
  tags: ['청년', '행복주택', '서울'],
});
```

### 3.3 섹션 관리 (Announcement Sections)

#### 섹션 타입

| Type | 설명 | Content 예시 |
|------|------|--------------|
| `basic_info` | 기본 정보 | `{ "description": "...", "features": [...] }` |
| `schedule` | 일정 | `{ "application_period": {...}, "announcement_date": "..." }` |
| `eligibility` | 신청 자격 | `{ "requirements": [...], "documents": [...] }` |
| `housing_info` | 단지 정보 | `{ "complex_name": "...", "address": "..." }` |
| `location` | 위치 | `{ "latitude": ..., "longitude": ..., "address": "..." }` |
| `attachments` | 첨부 파일 | `{ "files": [{"name": "...", "url": "..."}] }` |

#### 섹션 생성

```typescript
await createAnnouncementSection({
  announcement_id: announcementId,
  section_type: 'schedule',
  title: '일정',
  content: {
    application_period: {
      start: '2025-11-01',
      end: '2025-11-15',
    },
    announcement_date: '2025-11-20',
    move_in_date: '2025-12-01',
  },
  display_order: 1,
  is_visible: true,
});
```

#### 섹션 순서 변경

```typescript
// Drag and drop으로 순서 변경 시
async function reorderSections(sections: AnnouncementSection[]) {
  const updates = sections.map((section, index) => ({
    id: section.id,
    display_order: index + 1,
  }));

  // Batch update
  for (const update of updates) {
    await updateAnnouncementSection(update.id, {
      display_order: update.display_order,
    });
  }
}
```

### 3.4 탭 관리 (Announcement Tabs)

#### 탭 구조

탭은 평형별/연령별 정보를 구분하는 데 사용됩니다.

**예시**:
- "16A 청년" (16㎡, 청년 대상)
- "26B 신혼부부" (26㎡, 신혼부부 대상)
- "일반" (연령 제한 없음)

#### 탭 생성

```typescript
await createAnnouncementTab({
  announcement_id: announcementId,
  tab_name: '16A 청년',
  age_category_id: 'youth-category-uuid',
  unit_type: '16㎡',
  floor_plan_image_url: 'https://storage.supabase.co/.../floor-plan.png',
  supply_count: 150,
  income_conditions: {
    '대학생': '3,284만원 이하',
    '청년(소득)': '3,477만원 이하',
  },
  additional_info: {
    '월 임대료': '18만원',
    '보증금': '1,000만원',
  },
  display_order: 1,
});
```

#### 평면도 업로드

```typescript
async function uploadFloorPlan(
  announcementId: string,
  file: File
): Promise<string> {
  const fileName = `${Date.now()}-${file.name}`;
  const filePath = `floor-plans/${announcementId}/${fileName}`;

  const { data, error } = await supabase.storage
    .from('announcement-files')
    .upload(filePath, file, {
      cacheControl: '3600',
      upsert: false,
    });

  if (error) throw error;

  const { data: publicUrl } = supabase.storage
    .from('announcement-files')
    .getPublicUrl(filePath);

  return publicUrl.publicUrl;
}
```

---

## 4. 배너 관리

### 4.1 개요

카테고리별로 배너를 등록하고 관리합니다.

**테이블**: `category_banners`

**페이지**: `apps/pickly_admin/src/pages/banners/CategoryBannerForm.tsx`

### 4.2 배너 생성

```typescript
await createCategoryBanner({
  category_id: 'housing-category-uuid',
  title: '2025 청년 행복주택 특별 모집',
  subtitle: '지금 신청하세요!',
  image_url: 'https://storage.supabase.co/.../banner.jpg',
  link_url: '/announcements/abc-123',
  display_order: 1,
  is_active: true,
  start_date: '2025-11-01T00:00:00Z',
  end_date: '2025-11-30T23:59:59Z',
});
```

### 4.3 배너 이미지 업로드

**권장 사이즈**: 1200x400px (3:1 비율)

```typescript
async function uploadBannerImage(
  categoryId: string,
  file: File
): Promise<string> {
  const fileName = `${Date.now()}-${file.name}`;
  const filePath = `banners/${categoryId}/${fileName}`;

  const { data, error } = await supabase.storage
    .from('category-banners')
    .upload(filePath, file, {
      cacheControl: '3600',
      upsert: false,
    });

  if (error) throw error;

  const { data: publicUrl } = supabase.storage
    .from('category-banners')
    .getPublicUrl(filePath);

  return publicUrl.publicUrl;
}
```

---

## 5. Storage 관리

### 5.1 Storage Buckets

| Bucket 이름 | 용도 | Public 여부 |
|-------------|------|-------------|
| `age-category-icons` | 연령 카테고리 SVG 아이콘 | Public |
| `category-banners` | 카테고리 배너 이미지 | Public |
| `announcement-files` | 공고 첨부 파일 (평면도, PDF 등) | Public |

### 5.2 업로드 절차

#### 1단계: Bucket 생성 (최초 1회)

```sql
-- Supabase Dashboard > Storage > New Bucket
INSERT INTO storage.buckets (id, name, public)
VALUES
  ('age-category-icons', 'age-category-icons', true),
  ('category-banners', 'category-banners', true),
  ('announcement-files', 'announcement-files', true);
```

#### 2단계: RLS 정책 설정

```sql
-- Public read access
CREATE POLICY "Public read access"
ON storage.objects FOR SELECT
USING (bucket_id IN ('age-category-icons', 'category-banners', 'announcement-files'));

-- Admin write access (인증된 사용자만)
CREATE POLICY "Admin write access"
ON storage.objects FOR INSERT
WITH CHECK (
  bucket_id IN ('age-category-icons', 'category-banners', 'announcement-files')
  AND auth.role() = 'authenticated'
);
```

#### 3단계: 파일 업로드

```typescript
// 공통 업로드 함수
async function uploadFile(
  bucket: string,
  path: string,
  file: File
): Promise<string> {
  const { data, error } = await supabase.storage
    .from(bucket)
    .upload(path, file, {
      cacheControl: '3600',
      upsert: false,
    });

  if (error) throw error;

  const { data: url } = supabase.storage
    .from(bucket)
    .getPublicUrl(path);

  return url.publicUrl;
}
```

### 5.3 파일 삭제

```typescript
async function deleteFile(bucket: string, path: string) {
  const { error } = await supabase.storage
    .from(bucket)
    .remove([path]);

  if (error) throw error;
}
```

---

## 6. TypeScript 타입 정의

### 6.1 AgeCategory

```typescript
// apps/pickly_admin/src/types/database.ts
export interface AgeCategory {
  id: string;
  name: string;
  display_order: number;
  icon_path: string | null;
  age_min: number | null;
  age_max: number | null;
  created_at: string;
  updated_at: string;
}
```

### 6.2 Announcement

```typescript
export interface Announcement {
  id: string;
  title: string;
  subtitle: string | null;
  organization: string;
  category_id: string | null;
  subcategory_id: string | null;
  thumbnail_url: string | null;
  external_url: string | null;
  status: 'recruiting' | 'closed' | 'draft';
  is_featured: boolean;
  is_home_visible: boolean;
  display_priority: number;
  views_count: number;
  tags: string[];
  created_at: string;
  updated_at: string;
}
```

### 6.3 AnnouncementSection

```typescript
export interface AnnouncementSection {
  id: string;
  announcement_id: string;
  section_type: 'basic_info' | 'schedule' | 'eligibility' | 'housing_info' | 'location' | 'attachments';
  title: string | null;
  content: Record<string, any>;  // JSONB
  display_order: number;
  is_visible: boolean;
  created_at: string;
  updated_at: string;
}
```

### 6.4 AnnouncementTab

```typescript
export interface AnnouncementTab {
  id: string;
  announcement_id: string;
  tab_name: string;
  age_category_id: string | null;
  unit_type: string | null;
  floor_plan_image_url: string | null;
  supply_count: number | null;
  income_conditions: Record<string, string> | null;  // JSONB
  additional_info: Record<string, any> | null;       // JSONB
  display_order: number;
  created_at: string;
}
```

---

## 7. 테스트 가이드

### 7.1 관리자 기능 테스트 체크리스트

**연령 카테고리**:
- [ ] 카테고리 생성 (이름, 순서, 나이 범위)
- [ ] SVG 아이콘 업로드 및 표시
- [ ] 카테고리 수정 (이름, 순서 변경)
- [ ] 카테고리 삭제 (참조 없을 때만)

**공고 관리**:
- [ ] 공고 기본 정보 생성
- [ ] 섹션 추가 (6가지 타입)
- [ ] 섹션 순서 변경 (drag & drop)
- [ ] 탭 추가 (평형별)
- [ ] 평면도 업로드
- [ ] 공고 상태 변경 (draft → recruiting → closed)
- [ ] 인기 탭/홈 화면 노출 설정

**배너 관리**:
- [ ] 배너 생성 (이미지 업로드)
- [ ] 배너 순서 변경
- [ ] 배너 활성화/비활성화
- [ ] 기간 설정 (시작일, 종료일)

### 7.2 E2E 테스트 시나리오

```typescript
// 공고 생성 → 모바일 앱에서 확인
describe('Announcement E2E', () => {
  it('should create announcement and display in mobile app', async () => {
    // 1. 백오피스에서 공고 생성
    const announcement = await createAnnouncement({
      title: 'E2E 테스트 공고',
      organization: '테스트 기관',
      category_id: housingCategoryId,
      status: 'recruiting',
      is_featured: true,
    });

    // 2. 섹션 추가
    await createAnnouncementSection({
      announcement_id: announcement.id,
      section_type: 'basic_info',
      title: '기본 정보',
      content: { description: '테스트 설명' },
      display_order: 1,
    });

    // 3. 탭 추가
    await createAnnouncementTab({
      announcement_id: announcement.id,
      tab_name: '테스트 탭',
      display_order: 1,
    });

    // 4. 모바일 앱에서 확인
    const mobileAnnouncements = await fetchAnnouncementsFromMobileApp();
    expect(mobileAnnouncements).toContainEqual(
      expect.objectContaining({ id: announcement.id })
    );
  });
});
```

---

## 8. 문제 해결

### 8.1 자주 발생하는 오류

**Error**: `Foreign key constraint violation`
- **원인**: 참조 중인 카테고리 삭제 시도
- **해결**: 관련 데이터 먼저 삭제 또는 카테고리 변경

**Error**: `File upload failed: Storage bucket not found`
- **원인**: Bucket 미생성
- **해결**: Supabase Dashboard에서 Bucket 생성

**Error**: `RLS policy violation`
- **원인**: RLS 정책 미설정
- **해결**: 5.2절 참고하여 정책 추가

### 8.2 TypeScript 에러

상세 내용은 [TypeScript 에러 트러블슈팅](../troubleshooting/admin-typescript-errors.md) 참고

---

## 9. 참고 자료

- [PRD v7.0](/PRD.md)
- [DB 스키마 v2](../database/schema-v2.md)
- [공고 상세 명세](announcement-detail-spec.md)
- [백오피스 개발 가이드](admin-development-guide.md)
- [Supabase Storage 문서](https://supabase.com/docs/guides/storage)

---

**마지막 업데이트**: 2025.10.27
**작성자**: Documentation Agent
**검토자**: -
