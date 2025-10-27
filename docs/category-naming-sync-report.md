# 카테고리 명칭 동기화 작업 리포트

## 작업 일시
2025-10-24

## 작업 개요
Admin 백오피스와 Mobile 앱의 혜택 카테고리 명칭을 데이터베이스와 동기화

## 변경 사항

### 1. Admin Panel - Sidebar 카테고리 메뉴 정리
**파일**: `apps/pickly_admin/src/components/common/Sidebar.tsx`

**변경 내용**:
- 데이터베이스에 없는 불필요한 카테고리 제거: '지원', '교통', '식품'
- 실제 DB 카테고리와 일치하도록 메뉴 정리

**변경 전**:
```typescript
const benefitMenuItems = [
  { text: '인기', icon: <CategoryIcon />, path: '/benefits/popular' },
  { text: '주거', icon: <CategoryIcon />, path: '/benefits/housing' },
  { text: '교육', icon: <CategoryIcon />, path: '/benefits/education' },
  { text: '지원', icon: <CategoryIcon />, path: '/benefits/support' },
  { text: '교통', icon: <CategoryIcon />, path: '/benefits/transportation' },
  { text: '복지', icon: <CategoryIcon />, path: '/benefits/welfare' },
  { text: '의류', icon: <CategoryIcon />, path: '/benefits/clothing' },
  { text: '식품', icon: <CategoryIcon />, path: '/benefits/food' },
  { text: '문화', icon: <CategoryIcon />, path: '/benefits/culture' },
]
```

**변경 후**:
```typescript
const benefitMenuItems = [
  { text: '인기', icon: <CategoryIcon />, path: '/benefits/popular' },
  { text: '주거', icon: <CategoryIcon />, path: '/benefits/housing' },
  { text: '교육', icon: <CategoryIcon />, path: '/benefits/education' },
  { text: '취업', icon: <CategoryIcon />, path: '/benefits/employment' },
  { text: '복지', icon: <CategoryIcon />, path: '/benefits/welfare' },
  { text: '건강', icon: <CategoryIcon />, path: '/benefits/health' },
  { text: '문화', icon: <CategoryIcon />, path: '/benefits/culture' },
]
```

### 2. Mobile App - 혜택 화면 카테고리 명칭 수정
**파일**: `apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`

#### 2.1 카테고리 탭 레이블 변경

**변경 전**:
```dart
final List<Map<String, String>> _categories = [
  {'label': '인기', 'icon': 'assets/icons/fire.svg'},
  {'label': '주거', 'icon': 'assets/icons/home.svg'},
  {'label': '교육', 'icon': 'assets/icons/book.svg'},
  {'label': '지원', 'icon': 'assets/icons/dollar.svg'},
  {'label': '교통', 'icon': 'assets/icons/bus.svg'},
  {'label': '복지', 'icon': 'assets/icons/heart.svg'},
  {'label': '의류', 'icon': 'assets/icons/shirts.svg'},  // ❌ 잘못된 카테고리
  {'label': '식품', 'icon': 'assets/icons/rice.svg'},    // ❌ 잘못된 카테고리
  {'label': '문화', 'icon': 'assets/icons/speaker.svg'},
];
```

**변경 후**:
```dart
final List<Map<String, String>> _categories = [
  {'label': '인기', 'icon': 'assets/icons/fire.svg'},
  {'label': '주거', 'icon': 'assets/icons/home.svg'},
  {'label': '교육', 'icon': 'assets/icons/book.svg'},
  {'label': '지원', 'icon': 'assets/icons/dollar.svg'},
  {'label': '교통', 'icon': 'assets/icons/bus.svg'},
  {'label': '복지', 'icon': 'assets/icons/heart.svg'},
  {'label': '취업', 'icon': 'assets/icons/dollar.svg'},  // ✅ 올바른 카테고리
  {'label': '건강', 'icon': 'assets/icons/health.svg'},   // ✅ 올바른 카테고리
  {'label': '문화', 'icon': 'assets/icons/speaker.svg'},
];
```

#### 2.2 카테고리 ID 매핑 수정

**변경 전**:
```dart
String _getCategoryId(int index) {
  switch (index) {
    case 0: return 'popular';
    case 1: return 'housing';
    case 2: return 'education';
    case 3: return 'support';
    case 4: return 'transportation';
    case 5: return 'welfare';
    case 6: return 'clothing';  // ❌ DB에 없는 slug
    case 7: return 'food';      // ❌ DB에 없는 slug
    case 8: return 'culture';
    default: return 'popular';
  }
}
```

**변경 후**:
```dart
String _getCategoryId(int index) {
  switch (index) {
    case 0: return 'popular';
    case 1: return 'housing';
    case 2: return 'education';
    case 3: return 'support';
    case 4: return 'transportation';
    case 5: return 'welfare';
    case 6: return 'employment';  // ✅ 올바른 slug
    case 7: return 'health';      // ✅ 올바른 slug
    case 8: return 'culture';
    default: return 'popular';
  }
}
```

#### 2.3 카테고리별 프로그램 타입 정의 업데이트

**변경 전**:
```dart
final Map<int, List<Map<String, String>>> _programTypesByCategory = {
  0: [], // 인기
  1: [...], // 주거
  2: [...], // 교육
  3: [...], // 지원
  4: [...], // 교통
  5: [...], // 복지
  6: [ // 의류 - ❌ 잘못된 타입
    {'icon': 'assets/icons/shirts.svg', 'title': '의류 지원'},
  ],
  7: [ // 식품 - ❌ 잘못된 타입
    {'icon': 'assets/icons/rice.svg', 'title': '식품 지원'},
  ],
  8: [...], // 문화
};
```

**변경 후**:
```dart
final Map<int, List<Map<String, String>>> _programTypesByCategory = {
  0: [], // 인기
  1: [...], // 주거
  2: [...], // 교육
  3: [...], // 지원
  4: [...], // 교통
  5: [...], // 복지
  6: [ // 취업 - ✅ 올바른 타입
    {'icon': 'assets/icons/dollar.svg', 'title': '취업 지원'},
  ],
  7: [ // 건강 - ✅ 올바른 타입
    {'icon': 'assets/icons/health.svg', 'title': '건강 지원'},
  ],
  8: [...], // 문화
};
```

#### 2.4 카테고리 인덱스-ID 역매핑 함수 업데이트

**변경 전**:
```dart
int? _getCategoryIndexFromId(String categoryId) {
  switch (categoryId) {
    case 'popular': return 0;
    case 'housing': return 1;
    case 'education': return 2;
    case 'support': return 3;
    case 'transportation': return 4;
    case 'welfare': return 5;
    case 'clothing': return 6;  // ❌ 잘못된 매핑
    case 'food': return 7;      // ❌ 잘못된 매핑
    case 'culture': return 8;
    default: return null;
  }
}
```

**변경 후**:
```dart
int? _getCategoryIndexFromId(String categoryId) {
  switch (categoryId) {
    case 'popular': return 0;
    case 'housing': return 1;
    case 'education': return 2;
    case 'support': return 3;
    case 'transportation': return 4;
    case 'welfare': return 5;
    case 'employment': return 6;  // ✅ 올바른 매핑
    case 'health': return 7;      // ✅ 올바른 매핑
    case 'culture': return 8;
    default: return null;
  }
}
```

## 데이터베이스 카테고리 스키마 참고

현재 `benefit_categories` 테이블에 존재하는 상위 카테고리 (parent_id IS NULL):
- `popular` (인기)
- `housing` (주거)
- `education` (교육)
- `employment` (취업) ✅
- `welfare` (복지)
- `health` (건강) ✅
- `culture` (문화)

**참고**: `support`, `transportation`, `clothing`, `food` 카테고리는 DB에 없거나 하위 카테고리입니다.

## 영향 범위

### Admin Panel
- ✅ Sidebar 메뉴가 실제 DB 카테고리와 일치
- ✅ 존재하지 않는 카테고리 제거로 혼란 방지
- ✅ 각 카테고리별 배너 관리 가능

### Mobile App
- ✅ 카테고리 탭 레이블이 백오피스와 일치
- ✅ 배너 API 호출 시 올바른 slug 사용
- ✅ 저장된 프로그램 타입이 올바른 카테고리와 매핑
- ✅ 사용자가 선택한 카테고리 설정이 올바르게 로드

## 배너 시스템 동작 확인

변경 후 Flutter 로그에서 확인 가능한 내용:
```
flutter: 🎯 [Banner Filter] Category: employment, Found: 2 banners
flutter: 🎯 [Banner Filter] Category: health, Found: 2 banners
```

**변경 전에는**:
```
flutter: ⚠️ [Banner Filter] No banners for category: clothing
flutter: ⚠️ [Banner Filter] No banners for category: food
```

## 테스트 방법

### 1. Admin Panel 확인
1. Admin panel에서 왼쪽 사이드바 확인
2. "혜택 관리" 메뉴 클릭
3. 드롭다운에서 7개 카테고리 표시 확인: 인기, 주거, 교육, 취업, 복지, 건강, 문화

### 2. Mobile App 확인
1. 앱 실행 후 혜택 화면으로 이동
2. 상단 카테고리 탭 확인:
   - 7번째 탭: "취업" (dollar 아이콘)
   - 8번째 탭: "건강" (health 아이콘)
3. 각 카테고리 선택 시 배너 정상 로드 확인

### 3. 배너 동작 확인
1. Admin panel에서 취업/건강 카테고리에 배너 추가
2. Mobile app에서 해당 카테고리 선택
3. 추가한 배너가 정상 표시되는지 확인

## 관련 파일

### Modified Files
- `apps/pickly_admin/src/components/common/Sidebar.tsx`
- `apps/pickly_mobile/lib/features/benefits/screens/benefits_screen.dart`

### Related Files (참고용)
- `apps/pickly_mobile/lib/features/benefits/repositories/category_banner_repository.dart` (배너 데이터 fetch)
- `apps/pickly_mobile/lib/features/benefits/providers/category_banner_provider.dart` (배너 상태 관리)
- `supabase/migrations/20251025000000_category_banners.sql` (배너 테이블 스키마)

## 후속 작업 제안

### 1. 데이터베이스 정리
현재 앱에서 사용하는 `support`, `transportation` 카테고리는 DB에 없습니다:
- 옵션 A: DB에 해당 카테고리 추가
- 옵션 B: 앱에서 해당 카테고리 제거

### 2. 아이콘 통일
현재 여러 카테고리가 동일한 `dollar.svg` 아이콘 사용:
- '지원' (support)
- '취업' (employment)
각 카테고리에 고유한 아이콘 디자인 추천

### 3. 카테고리 순서 최적화
사용자 행동 분석 후 카테고리 표시 순서 조정 고려

## 참고사항

- 이번 작업은 프론트엔드 레이블/매핑만 수정했으며 DB 스키마 변경 없음
- 기존 사용자 데이터에 영향 없음
- 배너 데이터는 category_id(UUID)로 저장되므로 영향 없음
- 온보딩에서 저장한 사용자 선택은 category slug로 저장되므로 주의 필요

## 작업자
Claude (AI Assistant)

## 승인자
권현준
