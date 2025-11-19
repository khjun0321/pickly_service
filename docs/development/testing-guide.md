# Testing Guide - Pickly Service

> **버전**: v7.2
> **작성일**: 2025.10.27
> **대상**: 개발자, QA 엔지니어

---

## 1. 개요

이 문서는 Pickly Service의 테스팅 전략과 가이드를 제공합니다. v7.2에서 추가된 공고 상세 기능 및 관리자 기능에 대한 테스트 방법을 포함합니다.

---

## 2. 테스트 환경 설정

### 2.1 Flutter Mobile App

```bash
cd apps/pickly_mobile

# 의존성 설치
flutter pub get

# 테스트 실행
flutter test

# 커버리지 생성
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

### 2.2 Admin Backoffice

```bash
cd apps/pickly_admin

# 의존성 설치
npm install

# 테스트 실행
npm test

# 커버리지
npm run test:coverage
```

### 2.3 Supabase Backend

```bash
cd backend/supabase

# 로컬 서버 시작
supabase start

# 마이그레이션 적용
supabase db reset

# pgTAP 테스트 (선택)
supabase test db
```

---

## 3. Mobile App 테스트

### 3.1 공고 상세 화면 테스트

#### 단위 테스트 (Unit Tests)

**테스트 파일**: `test/features/benefit/screens/announcement_detail_screen_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/features/benefit/screens/announcement_detail_screen.dart';

void main() {
  group('AnnouncementDetailScreen', () {
    test('should render sections in display_order', () {
      final sections = [
        AnnouncementSection(
          sectionType: 'schedule',
          displayOrder: 2,
          content: {},
        ),
        AnnouncementSection(
          sectionType: 'basic_info',
          displayOrder: 1,
          content: {},
        ),
      ];

      final sorted = sections
          .sorted((a, b) => a.displayOrder.compareTo(b.displayOrder));

      expect(sorted.first.sectionType, 'basic_info');
      expect(sorted.last.sectionType, 'schedule');
    });

    test('should show TabBar only when tabs exist', () {
      final announcementWithTabs = Announcement(
        id: '1',
        title: 'Test',
        organization: 'Test Org',
        // ... other fields
      );

      final announcementWithoutTabs = Announcement(
        id: '2',
        title: 'Test',
        organization: 'Test Org',
        // ... other fields
      );

      // Mock tabs property
      expect(announcementWithTabs.tabs?.isNotEmpty ?? false, true);
      expect(announcementWithoutTabs.tabs?.isEmpty ?? true, true);
    });

    test('should parse JSONB content correctly', () {
      final section = AnnouncementSection(
        sectionType: 'schedule',
        content: {
          'application_period': {
            'start': '2025-11-01',
            'end': '2025-11-15',
          },
          'announcement_date': '2025-11-20',
        },
        displayOrder: 1,
      );

      expect(section.content['application_period']['start'], '2025-11-01');
      expect(section.content['announcement_date'], '2025-11-20');
    });
  });
}
```

#### 위젯 테스트 (Widget Tests)

**테스트 파일**: `test/features/benefit/widgets/announcement_tab_content_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/features/benefit/widgets/announcement_tab_content.dart';

void main() {
  testWidgets('AnnouncementTabContent displays tab information',
      (WidgetTester tester) async {
    final tab = AnnouncementTab(
      id: '1',
      announcementId: 'ann-1',
      tabName: '16A 청년',
      unitType: '16㎡',
      supplyCount: 150,
      incomeConditions: {
        '대학생': '3,284만원 이하',
        '청년(소득)': '3,477만원 이하',
      },
      displayOrder: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnnouncementTabContent(tab: tab),
        ),
      ),
    );

    // Tab name 표시 확인
    expect(find.text('16A 청년'), findsOneWidget);

    // Unit type 표시 확인
    expect(find.text('16㎡'), findsOneWidget);

    // Supply count 표시 확인
    expect(find.text('공급 150호'), findsOneWidget);

    // Income conditions 표시 확인
    expect(find.text('대학생'), findsOneWidget);
    expect(find.text('3,284만원 이하'), findsOneWidget);
  });

  testWidgets('should display floor plan image when available',
      (WidgetTester tester) async {
    final tab = AnnouncementTab(
      id: '1',
      announcementId: 'ann-1',
      tabName: '16A 청년',
      floorPlanImageUrl: 'https://example.com/floor-plan.png',
      displayOrder: 1,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: AnnouncementTabContent(tab: tab),
        ),
      ),
    );

    // Image widget 확인
    expect(find.byType(Image), findsOneWidget);
  });
}
```

#### 통합 테스트 (Integration Tests)

**테스트 파일**: `integration_test/announcement_detail_flow_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:pickly_mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Announcement Detail Flow', () {
    testWidgets('Complete announcement detail flow',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // 1. Navigate to benefits screen
      final benefitsTab = find.text('혜택');
      await tester.tap(benefitsTab);
      await tester.pumpAndSettle();

      // 2. Tap on announcement card
      final announcementCard = find.byType(AnnouncementCard).first;
      await tester.tap(announcementCard);
      await tester.pumpAndSettle();

      // 3. Verify detail screen loaded
      expect(find.byType(AnnouncementDetailScreen), findsOneWidget);

      // 4. Verify sections rendered
      expect(find.text('기본 정보'), findsWidgets);
      expect(find.text('일정'), findsWidgets);
      expect(find.text('신청 자격'), findsWidgets);

      // 5. If tabs exist, test tab switching
      final tabBar = find.byType(TabBar);
      if (tester.any(tabBar)) {
        final secondTab = find.byType(Tab).at(1);
        await tester.tap(secondTab);
        await tester.pumpAndSettle();

        // Verify tab content changed
        expect(find.byType(TabBarView), findsOneWidget);
      }

      // 6. Tap external link button
      final externalLinkButton = find.text('원본 공고문 보기');
      if (tester.any(externalLinkButton)) {
        await tester.tap(externalLinkButton);
        await tester.pumpAndSettle();
        // Verify URL launcher called (mock required)
      }
    });

    testWidgets('Cache invalidation on detail screen entry',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Navigate to detail screen
      // ... navigation code ...

      // Verify loading indicator shown (cache invalidated)
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pumpAndSettle();

      // Verify fresh data loaded
      expect(find.byType(AnnouncementDetailScreen), findsOneWidget);
    });
  });
}
```

---

### 3.2 Provider 테스트

**테스트 파일**: `test/features/benefit/providers/announcement_provider_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pickly_mobile/features/benefit/providers/announcement_provider.dart';

void main() {
  group('AnnouncementProvider', () {
    test('should fetch announcement detail with sections and tabs', () async {
      final container = ProviderContainer(
        overrides: [
          // Mock repository
          announcementRepositoryProvider.overrideWithValue(
            MockAnnouncementRepository(),
          ),
        ],
      );

      final announcementId = 'test-id';
      final result = await container.read(
        announcementDetailProvider(announcementId).future,
      );

      expect(result.announcement.id, announcementId);
      expect(result.sections, isNotEmpty);
      expect(result.tabs, isNotEmpty);
    });

    test('should invalidate cache on detail screen entry', () async {
      final container = ProviderContainer();

      // Initial load
      await container.read(announcementDetailProvider('id-1').future);

      // Invalidate
      container.invalidate(announcementDetailProvider('id-1'));

      // Verify state reset
      final state = container.read(announcementDetailProvider('id-1'));
      expect(state, isA<AsyncLoading>());
    });
  });
}
```

---

## 4. Admin Backoffice 테스트

### 4.1 연령 카테고리 관리 테스트

**테스트 파일**: `apps/pickly_admin/src/__tests__/AgeCategory.test.tsx`

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import AgeCategoryForm from '../pages/categories/CategoryForm';
import { createAgeCategory, uploadAgeCategoryIcon } from '../api/ageCategories';

jest.mock('../api/ageCategories');

describe('Age Category Management', () => {
  test('should create age category with all fields', async () => {
    const mockCreate = createAgeCategory as jest.MockedFunction<typeof createAgeCategory>;
    mockCreate.mockResolvedValue({
      id: '1',
      name: '청년',
      display_order: 1,
      age_min: 19,
      age_max: 39,
    });

    render(<AgeCategoryForm />);

    // Fill form
    fireEvent.change(screen.getByLabelText('이름'), {
      target: { value: '청년' },
    });
    fireEvent.change(screen.getByLabelText('표시 순서'), {
      target: { value: '1' },
    });
    fireEvent.change(screen.getByLabelText('최소 연령'), {
      target: { value: '19' },
    });
    fireEvent.change(screen.getByLabelText('최대 연령'), {
      target: { value: '39' },
    });

    // Submit
    fireEvent.click(screen.getByText('저장'));

    await waitFor(() => {
      expect(mockCreate).toHaveBeenCalledWith({
        name: '청년',
        display_order: 1,
        age_min: 19,
        age_max: 39,
      });
    });
  });

  test('should upload SVG icon', async () => {
    const mockUpload = uploadAgeCategoryIcon as jest.MockedFunction<
      typeof uploadAgeCategoryIcon
    >;
    mockUpload.mockResolvedValue('https://storage.supabase.co/.../icon.svg');

    render(<AgeCategoryForm categoryId="1" />);

    const file = new File(['<svg></svg>'], 'icon.svg', { type: 'image/svg+xml' });
    const input = screen.getByLabelText('아이콘 업로드') as HTMLInputElement;

    fireEvent.change(input, { target: { files: [file] } });

    await waitFor(() => {
      expect(mockUpload).toHaveBeenCalledWith('1', file);
    });
  });

  test('should reject non-SVG files', async () => {
    render(<AgeCategoryForm categoryId="1" />);

    const file = new File(['image'], 'icon.png', { type: 'image/png' });
    const input = screen.getByLabelText('아이콘 업로드') as HTMLInputElement;

    fireEvent.change(input, { target: { files: [file] } });

    await waitFor(() => {
      expect(screen.getByText('SVG 파일만 업로드 가능합니다.')).toBeInTheDocument();
    });
  });
});
```

### 4.2 공고 관리 테스트

**테스트 파일**: `apps/pickly_admin/src/__tests__/AnnouncementManagement.test.tsx`

```typescript
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import BenefitAnnouncementForm from '../pages/benefits/BenefitAnnouncementForm';
import {
  createAnnouncement,
  createAnnouncementSection,
  createAnnouncementTab,
} from '../api/announcements';

jest.mock('../api/announcements');

describe('Announcement Management', () => {
  test('should create announcement with sections and tabs', async () => {
    const mockCreateAnnouncement = createAnnouncement as jest.MockedFunction<
      typeof createAnnouncement
    >;
    const mockCreateSection = createAnnouncementSection as jest.MockedFunction<
      typeof createAnnouncementSection
    >;
    const mockCreateTab = createAnnouncementTab as jest.MockedFunction<
      typeof createAnnouncementTab
    >;

    mockCreateAnnouncement.mockResolvedValue({ id: 'ann-1', title: 'Test' });
    mockCreateSection.mockResolvedValue({ id: 'sec-1' });
    mockCreateTab.mockResolvedValue({ id: 'tab-1' });

    render(<BenefitAnnouncementForm />);

    // Fill basic info
    fireEvent.change(screen.getByLabelText('제목'), {
      target: { value: '2025 청년 행복주택' },
    });
    fireEvent.change(screen.getByLabelText('기관'), {
      target: { value: 'LH' },
    });

    // Add section
    fireEvent.click(screen.getByText('섹션 추가'));
    fireEvent.change(screen.getByLabelText('섹션 타입'), {
      target: { value: 'schedule' },
    });

    // Add tab
    fireEvent.click(screen.getByText('탭 추가'));
    fireEvent.change(screen.getByLabelText('탭 이름'), {
      target: { value: '16A 청년' },
    });

    // Submit
    fireEvent.click(screen.getByText('등록'));

    await waitFor(() => {
      expect(mockCreateAnnouncement).toHaveBeenCalled();
      expect(mockCreateSection).toHaveBeenCalled();
      expect(mockCreateTab).toHaveBeenCalled();
    });
  });

  test('should reorder sections via drag and drop', async () => {
    // Test implementation for drag and drop reordering
    // ... (requires react-beautiful-dnd testing setup)
  });
});
```

---

## 5. E2E 테스트 시나리오

### 5.1 공고 생성 → 모바일 확인 플로우

```gherkin
Feature: Announcement Creation and Mobile Display

  Scenario: Create announcement in backoffice and view in mobile app
    Given I am logged in as admin in backoffice
    When I create a new announcement with:
      | Title        | 2025 서울시 청년 행복주택     |
      | Organization | LH 한국토지주택공사          |
      | Category     | 주거                        |
      | Status       | recruiting                  |
    And I add a section:
      | Type    | schedule                     |
      | Content | {"application_period": {...}} |
    And I add a tab:
      | Tab Name     | 16A 청년                    |
      | Unit Type    | 16㎡                        |
      | Supply Count | 150                         |
    And I click "등록"
    Then the announcement should be created successfully

    When I open the mobile app
    And I navigate to "혜택" tab
    And I select "주거" category
    Then I should see the announcement in the list

    When I tap the announcement card
    Then I should see the detail screen
    And I should see the section "일정"
    And I should see the tab "16A 청년"
    And the tab should display "공급 150호"
```

### 5.2 연령 카테고리 관리 플로우

```gherkin
Feature: Age Category Management

  Scenario: Create age category with SVG icon
    Given I am logged in as admin
    When I navigate to "연령 카테고리 관리"
    And I click "새 카테고리"
    And I fill in:
      | 이름        | 청년      |
      | 표시 순서   | 1         |
      | 최소 연령   | 19        |
      | 최대 연령   | 39        |
    And I upload SVG icon "youth.svg"
    And I click "저장"
    Then the category should be created
    And the icon should be displayed in the list

    When I open the mobile app
    And I navigate to onboarding
    Then I should see the new category "청년"
    And the SVG icon should be displayed
```

---

## 6. 성능 테스트

### 6.1 공고 상세 로딩 시간

**목표**: 1초 이내

```dart
test('announcement detail should load within 1 second', () async {
  final stopwatch = Stopwatch()..start();

  final detail = await repository.getAnnouncementDetail('test-id');

  stopwatch.stop();

  expect(stopwatch.elapsedMilliseconds, lessThan(1000));
  expect(detail, isNotNull);
});
```

### 6.2 이미지 로딩 최적화

**평면도 이미지**:
- 권장 크기: 800x600px
- 포맷: WebP (fallback: PNG)
- 압축: 85% 품질

```dart
test('should load optimized images', () {
  final imageUrl = 'https://storage.supabase.co/.../floor-plan.webp';

  // Verify WebP format
  expect(imageUrl, contains('.webp'));

  // Test image loading performance
  // ... (requires image loading measurement)
});
```

---

## 7. 테스트 커버리지 목표

### 7.1 Mobile App

- **Overall**: 80% 이상
- **Models**: 100%
- **Repositories**: 90% 이상
- **Providers**: 85% 이상
- **Widgets**: 75% 이상

### 7.2 Admin Backoffice

- **Overall**: 75% 이상
- **API**: 90% 이상
- **Components**: 70% 이상
- **Pages**: 60% 이상

---

## 8. CI/CD 통합

### 8.1 GitHub Actions

```yaml
# .github/workflows/test.yml
name: Test

on: [push, pull_request]

jobs:
  mobile-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.16.0'
      - run: cd apps/pickly_mobile && flutter test --coverage
      - uses: codecov/codecov-action@v3
        with:
          files: ./apps/pickly_mobile/coverage/lcov.info

  admin-test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '18'
      - run: cd apps/pickly_admin && npm ci && npm test
      - uses: codecov/codecov-action@v3
        with:
          files: ./apps/pickly_admin/coverage/lcov.info
```

---

## 9. 문제 해결

### 9.1 자주 발생하는 테스트 오류

**Error**: `ProviderNotFoundException`
- **원인**: Provider scope 설정 누락
- **해결**: `ProviderScope`로 위젯 감싸기

**Error**: `Null check operator used on a null value`
- **원인**: Mock 데이터 불완전
- **해결**: 모든 필수 필드 포함된 Mock 생성

**Error**: `TimeoutException`
- **원인**: Async 작업 완료 대기 부족
- **해결**: `await tester.pumpAndSettle()` 사용

---

## 10. 참고 자료

- [Flutter Testing 공식 문서](https://docs.flutter.dev/testing)
- [Riverpod Testing 가이드](https://riverpod.dev/docs/cookbooks/testing)
- [React Testing Library 문서](https://testing-library.com/docs/react-testing-library/intro/)
- [PRD v7.0](/PRD.md)
- [공고 상세 명세](../prd/announcement-detail-spec.md)

---

**마지막 업데이트**: 2025.10.27
**작성자**: Testing Agent
**검토자**: -
