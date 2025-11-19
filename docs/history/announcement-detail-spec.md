# 공고 상세 화면 명세서

> **버전**: v7.2
> **작성일**: 2025.10.27
> **관련 PR**: feature/announcement-detail-and-admin-sync

---

## 1. 개요

공고 상세 화면은 사용자에게 정책/혜택 공고의 전체 정보를 제공하는 핵심 화면입니다. PRD v7.0의 모듈식 섹션 시스템을 기반으로 구현되었습니다.

### 주요 특징

- **모듈식 섹션 구조**: `announcement_sections` 테이블 기반 동적 렌더링
- **TabBar 지원**: `announcement_tabs` 테이블로 평형별/연령별 정보 표시
- **커스텀 콘텐츠**: JSONB 기반 유연한 콘텐츠 구조
- **캐시 무효화**: 화면 진입 시 최신 데이터 보장

---

## 2. 데이터 구조

### 2.1 Announcement (공고 기본 정보)

```dart
class Announcement {
  final String id;
  final String title;
  final String? subtitle;
  final String? organization;
  final String? categoryId;
  final String? subcategoryId;
  final String? thumbnailUrl;
  final String? externalUrl;
  final String status;  // 'recruiting' | 'closed' | 'draft'
  final bool isFeatured;
  final bool isHomeVisible;
  final int displayPriority;
  final int viewsCount;
  final List<String> tags;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

### 2.2 AnnouncementSection (섹션)

```dart
class AnnouncementSection {
  final String id;
  final String announcementId;
  final String sectionType;  // 'basic_info' | 'schedule' | 'eligibility' | ...
  final String? title;
  final Map<String, dynamic> content;  // JSONB
  final int displayOrder;
  final bool isVisible;
  final DateTime? createdAt;
  final DateTime? updatedAt;
}
```

**섹션 타입**:
- `basic_info`: 기본 정보
- `schedule`: 일정 (접수 기간, 발표일 등)
- `eligibility`: 신청 자격
- `housing_info`: 단지 정보
- `location`: 위치 정보
- `attachments`: 첨부 파일 (평면도, PDF 등)

### 2.3 AnnouncementTab (탭)

```dart
class AnnouncementTab {
  final String id;
  final String announcementId;
  final String tabName;  // "16A 청년", "신혼부부"
  final String? ageCategoryId;
  final String? unitType;  // "16㎡", "26㎡"
  final String? floorPlanImageUrl;
  final int? supplyCount;
  final Map<String, dynamic>? incomeConditions;  // JSONB
  final Map<String, dynamic>? additionalInfo;    // JSONB
  final int displayOrder;
  final DateTime? createdAt;
}
```

---

## 3. UI 구성

### 3.1 화면 구조

```
┌─────────────────────────────────────┐
│  Header (뒤로가기, 제목)             │
├─────────────────────────────────────┤
│  Thumbnail Image                     │
│                                      │
├─────────────────────────────────────┤
│  Title + Organization + Status       │
├─────────────────────────────────────┤
│  TabBar (if announcement_tabs exist) │
│  [16A 청년] [신혼부부] [일반]        │
├─────────────────────────────────────┤
│  Tab Content (선택된 탭 정보)         │
│  - 평면도 이미지                      │
│  - 공급 호수                          │
│  - 소득 조건                          │
├─────────────────────────────────────┤
│  Sections (동적 렌더링)               │
│  ┌───────────────────────────────┐  │
│  │ Section: 기본 정보             │  │
│  │ (content JSONB 렌더링)         │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Section: 일정                  │  │
│  └───────────────────────────────┘  │
│  ┌───────────────────────────────┐  │
│  │ Section: 신청 자격             │  │
│  └───────────────────────────────┘  │
├─────────────────────────────────────┤
│  External Link Button                │
│  "원본 공고문 보기"                   │
└─────────────────────────────────────┘
```

### 3.2 TabBar 동작

**조건**:
- `announcement_tabs` 테이블에 데이터가 있을 경우에만 표시
- `display_order` 순으로 정렬
- 첫 번째 탭이 기본 선택

**렌더링**:
```dart
// TabBar 표시 여부
final shouldShowTabs = announcement.tabs.isNotEmpty;

// TabBar Widget
if (shouldShowTabs) {
  TabBar(
    tabs: announcement.tabs.map((tab) =>
      Tab(text: tab.tabName)
    ).toList(),
  )
}
```

**탭 콘텐츠 표시**:
```dart
TabBarView(
  children: announcement.tabs.map((tab) =>
    AnnouncementTabContent(tab: tab)
  ).toList(),
)
```

### 3.3 Section 렌더링

**순서**:
- `display_order` ASC로 정렬
- `is_visible = true`인 섹션만 표시

**렌더링 로직**:
```dart
Widget buildSection(AnnouncementSection section) {
  switch (section.sectionType) {
    case 'basic_info':
      return BasicInfoSection(content: section.content);
    case 'schedule':
      return ScheduleSection(content: section.content);
    case 'eligibility':
      return EligibilitySection(content: section.content);
    case 'housing_info':
      return HousingInfoSection(content: section.content);
    case 'location':
      return LocationSection(content: section.content);
    case 'attachments':
      return AttachmentsSection(content: section.content);
    default:
      return CustomSection(section: section);
  }
}
```

### 3.4 커스텀 콘텐츠 예시

**Basic Info Section (JSONB content)**:
```json
{
  "description": "서울시 청년을 위한 행복주택 입주자 모집",
  "features": [
    "저렴한 임대료",
    "편리한 교통",
    "최신 시설"
  ]
}
```

**Schedule Section (JSONB content)**:
```json
{
  "application_period": {
    "start": "2025-11-01",
    "end": "2025-11-15"
  },
  "announcement_date": "2025-11-20",
  "move_in_date": "2025-12-01"
}
```

**Income Conditions (JSONB in announcement_tabs)**:
```json
{
  "대학생": "3,284만원 이하",
  "청년(소득)": "3,477만원 이하",
  "신혼부부": "6,958만원 이하"
}
```

---

## 4. 캐시 무효화 전략

### 4.1 문제

- Riverpod Provider 캐싱으로 인해 상세 화면에서 이전 데이터 표시
- 섹션/탭 변경 사항이 즉시 반영되지 않음

### 4.2 해결 방법

**화면 진입 시 캐시 무효화**:
```dart
@override
void initState() {
  super.initState();

  // 화면 진입 시 캐시 무효화
  WidgetsBinding.instance.addPostFrameCallback((_) {
    ref.invalidate(announcementDetailProvider(widget.announcementId));
  });
}
```

**Provider 정의**:
```dart
@riverpod
Future<AnnouncementDetail> announcementDetail(
  AnnouncementDetailRef ref,
  String announcementId,
) async {
  final repository = ref.watch(announcementRepositoryProvider);
  return await repository.getAnnouncementDetail(announcementId);
}
```

### 4.3 데이터 로딩 플로우

```
User taps announcement card
  ↓
Navigate to detail screen
  ↓
initState() invalidates cache
  ↓
Provider refetches data
  ↓
Render sections + tabs with latest data
```

---

## 5. Repository 구조

### 5.1 AnnouncementRepository

```dart
class AnnouncementRepository {
  final SupabaseClient _client;

  /// 공고 상세 정보 조회 (섹션 + 탭 포함)
  Future<AnnouncementDetail> getAnnouncementDetail(String announcementId) async {
    // 1. 기본 정보 조회
    final announcement = await _client
        .from('announcements')
        .select()
        .eq('id', announcementId)
        .single();

    // 2. 섹션 조회 (display_order 정렬)
    final sections = await _client
        .from('announcement_sections')
        .select()
        .eq('announcement_id', announcementId)
        .eq('is_visible', true)
        .order('display_order');

    // 3. 탭 조회 (display_order 정렬)
    final tabs = await _client
        .from('announcement_tabs')
        .select()
        .eq('announcement_id', announcementId)
        .order('display_order');

    return AnnouncementDetail(
      announcement: Announcement.fromJson(announcement),
      sections: sections.map((s) => AnnouncementSection.fromJson(s)).toList(),
      tabs: tabs.map((t) => AnnouncementTab.fromJson(t)).toList(),
    );
  }

  /// 조회수 증가
  Future<void> incrementViewCount(String announcementId) async {
    await _client.rpc('increment_announcement_views', params: {
      'announcement_id': announcementId,
    });
  }
}
```

---

## 6. 테스트 가이드

### 6.1 단위 테스트

```dart
// Section 렌더링 테스트
test('should render sections in display_order', () {
  final sections = [
    AnnouncementSection(sectionType: 'schedule', displayOrder: 2),
    AnnouncementSection(sectionType: 'basic_info', displayOrder: 1),
  ];

  final sorted = sections.sorted((a, b) => a.displayOrder.compareTo(b.displayOrder));

  expect(sorted.first.sectionType, 'basic_info');
  expect(sorted.last.sectionType, 'schedule');
});

// TabBar 표시 조건 테스트
test('should show TabBar only when tabs exist', () {
  final announcementWithTabs = Announcement(tabs: [tab1, tab2]);
  final announcementWithoutTabs = Announcement(tabs: []);

  expect(announcementWithTabs.shouldShowTabBar, true);
  expect(announcementWithoutTabs.shouldShowTabBar, false);
});
```

### 6.2 통합 테스트

```dart
// 캐시 무효화 테스트
testWidgets('should invalidate cache on screen entry', (tester) async {
  final container = ProviderContainer();

  await tester.pumpWidget(
    ProviderScope(
      parent: container,
      child: AnnouncementDetailScreen(announcementId: 'test-id'),
    ),
  );

  await tester.pumpAndSettle();

  // Cache should be invalidated
  expect(
    container.read(announcementDetailProvider('test-id')),
    isA<AsyncLoading>(),
  );
});
```

### 6.3 E2E 테스트 시나리오

1. **기본 렌더링**:
   - 공고 카드 클릭 → 상세 화면 진입
   - 제목, 썸네일, 상태 표시 확인
   - 외부 링크 버튼 존재 확인

2. **TabBar 동작**:
   - Tabs 있는 공고: TabBar 표시 확인
   - 탭 클릭 → 콘텐츠 변경 확인
   - 평면도 이미지 로딩 확인

3. **Section 렌더링**:
   - display_order 순서 확인
   - is_visible=false 섹션 미표시 확인
   - JSONB 콘텐츠 파싱 확인

4. **캐시 무효화**:
   - 백오피스에서 공고 수정
   - 모바일 앱에서 상세 화면 재진입
   - 최신 데이터 반영 확인

---

## 7. 알려진 제한사항

### 7.1 현재 제한사항

- **이미지 최적화**: 썸네일/평면도 이미지 리사이징 미구현
- **오프라인 지원**: 캐시 정책 미구현
- **북마크**: Phase 2로 연기
- **공유**: Phase 2로 연기
- **댓글/Q&A**: Phase 3로 연기

### 7.2 향후 개선 계획

- Image CDN 도입 (Supabase Storage Transformations)
- Offline-first 캐싱 (Hive/Isar)
- 북마크 기능 (Phase 2)
- 푸시 알림 연동 (Phase 2)
- AI 챗봇 통합 (Phase 3)

---

## 8. 참고 자료

- [PRD v7.0](/PRD.md)
- [DB 스키마 v2](../database/schema-v2.md)
- [관리자 기능 가이드](admin-features.md)
- [테스팅 가이드](../development/testing-guide.md)

---

**마지막 업데이트**: 2025.10.27
**작성자**: Documentation Agent
**검토자**: -
