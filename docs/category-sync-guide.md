# 카테고리 동기화 가이드

## 📋 개요

Pickly 서비스의 혜택 카테고리는 **모바일 앱**과 **어드민 패널**에서 동일하게 표시되어야 합니다.
이 문서는 카테고리 관리 및 동기화 방법을 설명합니다.

## 🎯 현재 카테고리 구조

### 최종 카테고리 순서
```
0. 인기 (popular)
1. 주거 (housing)
2. 교육 (education)
3. 건강 (health)
4. 교통 (transportation)
5. 복지 (welfare)
6. 취업 (employment)
7. 지원 (support)
8. 문화 (culture)
```

## 📂 관련 파일 위치

### 1. 데이터베이스
- **Migration**: `supabase/migrations/20251025080000_reorder_categories.sql`
- **Seed**: `supabase/seed.sql` (lines 127-148)
- **테이블**: `benefit_categories` (parent_id IS NULL인 레코드만 최상위 카테고리)

### 2. 모바일 앱 (Flutter)
- **화면**: `apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`
- **주요 섹션**:
  - `_categories` (line 125-135): 카테고리 탭 목록
  - `_getCategoryId()` (line 138-151): 인덱스 → slug 매핑
  - `_getCategoryIndexFromId()` (line 61-74): slug → 인덱스 매핑
  - `_getCategoryContent()` (line 464-487): 카테고리별 컨텐츠 위젯

### 3. 어드민 패널 (React)
- **사이드바**: `apps/pickly_admin/src/components/common/Sidebar.tsx`
  - `benefitMenuItems` (line 35-44): 사이드바 메뉴 목록
- **API**: `apps/pickly_admin/src/api/benefits.ts`
  - `fetchBenefitCategories()` (line 8-26): 최상위 카테고리만 조회
- **페이지**: `apps/pickly_admin/src/pages/benefits/BenefitCategoryPage.tsx`
  - `CATEGORY_NAMES` (line 47-56): slug → 한글명 매핑

## ✅ 카테고리 추가/수정 절차

### 1. 데이터베이스 Migration 작성

```sql
-- 새 카테고리 추가 예시
INSERT INTO benefit_categories (name, slug, description, icon_url, display_order, is_active, parent_id) VALUES
('새카테고리', 'new-category', '새로운 카테고리 설명', NULL, 9, true, NULL)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_order = EXCLUDED.display_order;
```

### 2. seed.sql 업데이트

`supabase/seed.sql` 파일의 benefit_categories INSERT 문에 새 카테고리 추가:

```sql
INSERT INTO benefit_categories (name, slug, description, icon_url, display_order, is_active, parent_id) VALUES
-- ... 기존 카테고리들 ...
('새카테고리', 'new-category', '새로운 카테고리 설명', NULL, 9, true, NULL)
ON CONFLICT (slug) DO UPDATE SET
  name = EXCLUDED.name,
  display_order = EXCLUDED.display_order,
  is_active = EXCLUDED.is_active;
```

### 3. 모바일 앱 업데이트

`apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`:

```dart
// 1. 카테고리 목록에 추가
final List<Map<String, String>> _categories = [
  // ... 기존 카테고리들 ...
  {'label': '새카테고리', 'icon': 'assets/icons/new.svg'},
];

// 2. 카테고리 ID 매핑 추가
String _getCategoryId(int index) {
  switch (index) {
    // ... 기존 케이스들 ...
    case 9: return 'new-category';
    default: return 'popular';
  }
}

// 3. 역매핑 추가
int? _getCategoryIndexFromId(String categoryId) {
  switch (categoryId) {
    // ... 기존 케이스들 ...
    case 'new-category': return 9;
    default: return null;
  }
}

// 4. 컨텐츠 위젯 추가
Widget _getCategoryContent() {
  switch (_selectedCategoryIndex) {
    // ... 기존 케이스들 ...
    case 9: return _buildComingSoonContent('새카테고리');
    default: return const PopularCategoryContent();
  }
}
```

### 4. 어드민 패널 업데이트

#### 4-1. Sidebar.tsx
```typescript
const benefitMenuItems = [
  // ... 기존 메뉴들 ...
  { text: '새카테고리', icon: <CategoryIcon />, path: '/benefits/new-category' },
]
```

#### 4-2. BenefitCategoryPage.tsx
```typescript
const CATEGORY_NAMES: Record<string, string> = {
  // ... 기존 매핑들 ...
  'new-category': '새카테고리',
}
```

### 5. Migration 적용

```bash
# 로컬 개발 환경
docker exec supabase_db_pickly_service psql -U postgres -d postgres -f /path/to/migration.sql

# 또는 Supabase CLI 사용
supabase db push
```

## 🔄 순서 변경 시 주의사항

### 1. display_order 일관성 유지
모든 곳에서 동일한 순서를 유지해야 합니다:
- 데이터베이스 `display_order`
- 앱 `_categories` 배열 순서
- 앱 `_getCategoryId()` switch 케이스 순서
- 앱 `_getCategoryContent()` switch 케이스 순서
- 어드민 `benefitMenuItems` 배열 순서

### 2. 인덱스 기반 로직 확인
앱의 경우 배열 인덱스로 카테고리를 관리하므로, 순서 변경 시 모든 매핑 함수를 함께 업데이트해야 합니다.

## 🚨 자주 발생하는 문제

### 문제 1: 어드민에서 카테고리가 보이지 않음
**원인**: `fetchBenefitCategories()`가 `parent_id IS NULL` 필터를 사용하지 않음
**해결**: `apps/pickly_admin/src/api/benefits.ts:14`에서 `.is('parent_id', null)` 확인

### 문제 2: 앱과 어드민의 순서가 다름
**원인**: Sidebar가 하드코딩되어 있음
**해결**: `apps/pickly_admin/src/components/common/Sidebar.tsx`의 `benefitMenuItems` 순서 확인

### 문제 3: 배너가 특정 카테고리에서 안 보임
**원인**: 카테고리 slug 불일치
**해결**:
- 데이터베이스의 slug 확인
- 앱의 `_getCategoryId()` 함수에서 반환하는 slug 확인
- `category_banners` 테이블의 `category_id`가 올바른 카테고리를 참조하는지 확인

## 📊 테스트 체크리스트

카테고리 추가/수정 후 다음 사항을 확인하세요:

- [ ] 데이터베이스에 카테고리가 올바른 순서로 저장됨
- [ ] 앱의 상단 써클탭에 모든 카테고리가 올바른 순서로 표시됨
- [ ] 어드민 사이드바에 모든 카테고리가 올바른 순서로 표시됨
- [ ] 각 카테고리 클릭 시 올바른 컨텐츠가 표시됨
- [ ] 배너가 올바른 카테고리에 표시됨
- [ ] 앱에서 카테고리 전환 시 필터(지역, 연령, 공고타입)가 초기화됨

## 🔧 유용한 SQL 쿼리

### 현재 카테고리 순서 확인
```sql
SELECT display_order, name, slug, id
FROM benefit_categories
WHERE parent_id IS NULL
ORDER BY display_order;
```

### 순서 재정렬
```sql
UPDATE benefit_categories SET display_order = 0 WHERE slug = 'popular' AND parent_id IS NULL;
UPDATE benefit_categories SET display_order = 1 WHERE slug = 'housing' AND parent_id IS NULL;
-- ... (나머지 카테고리)
```

### 카테고리별 배너 개수 확인
```sql
SELECT bc.name, COUNT(cb.id) as banner_count
FROM benefit_categories bc
LEFT JOIN category_banners cb ON bc.id = cb.category_id
WHERE bc.parent_id IS NULL
GROUP BY bc.name
ORDER BY bc.display_order;
```

## 📚 관련 문서

- [개발 베스트 프랙티스](./development-best-practices.md)
- [Storage 설정 가이드](./storage-setup-guide.md)
- [데이터베이스 마이그레이션 리포트](./database-migration-report.md)
