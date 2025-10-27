# ✅ Pickly Mobile 라우팅 구현 체크리스트

**마지막 업데이트**: 2025-10-11
**프로젝트**: Pickly Mobile (Flutter)

---

## 📊 전체 진행 상황

**완료율**: 25% (2/8 화면)

```
████░░░░░░░░░░░░░░░░ 25%
```

---

## 1️⃣ Phase 1: MVP 필수 화면 (우선순위: HIGH)

### ✅ 완료된 화면

| ID | 화면 이름 | 라우트 | 상태 | 완료일 |
|----|---------|-------|------|--------|
| 000 | Splash | `/splash` | ✅ 완료 | 2025-10-11 |
| 003 | Age Category | `/onboarding/age-category` | ✅ 완료 | 2025-10-11 |

### 🔴 미구현 화면 (즉시 필요)

| ID | 화면 이름 | 라우트 | 설정 파일 | 예상 작업 시간 |
|----|---------|-------|----------|--------------|
| 000.5 | Onboarding Start | `/onboarding/start` | ❌ 없음 | 2시간 |
| 001 | Personal Info | `/onboarding/personal-info` | ✅ 001-personal-info.json | 4시간 |
| 002 | Region | `/onboarding/region` | ❌ 없음 | 4시간 |
| - | Home (정책 피드) | `/home` | ❌ 없음 | 8시간 |
| - | Policy Detail | `/policy/:id` | ❌ 없음 | 6시간 |

**Phase 1 총 작업 시간**: 24시간 (3일)

---

## 2️⃣ Phase 2: 확장 기능 (우선순위: MEDIUM)

| ID | 화면 이름 | 라우트 | 예상 작업 시간 |
|----|---------|-------|--------------|
| 004 | Income Level | `/onboarding/income` | 3시간 |
| - | Filter | `/home/filter` | 4시간 |
| - | Search | `/policy/search` | 5시간 |

**Phase 2 총 작업 시간**: 12시간 (1.5일)

---

## 📋 세부 구현 체크리스트

### 화면 000.5: Onboarding Start (환영 화면)

**파일 경로**: `lib/features/onboarding/screens/onboarding_start_screen.dart`

**작업 항목**:
- [ ] 화면 파일 생성
- [ ] 환영 메시지 UI
- [ ] "시작하기" 버튼
- [ ] 브랜드 로고/일러스트레이션
- [ ] 다음 화면 네비게이션 (`/onboarding/personal-info`)
- [ ] 애니메이션 (Fade in)

**UI 구성**:
```dart
- SafeArea
  - Column
    - Spacer (상단 여백)
    - Image.asset('logo.png')
    - Text('Pickly에 오신 것을 환영합니다')
    - Text('나에게 딱 맞는 정책을 찾아드려요')
    - Spacer (중간 여백)
    - ElevatedButton('시작하기')
    - SizedBox (하단 여백)
```

**네비게이션**:
```dart
onPressed: () => context.go(Routes.personalInfo)
```

---

### 화면 001: Personal Info (개인정보 입력)

**파일 경로**: `lib/features/onboarding/screens/personal_info_screen.dart`

**설정 파일**: ✅ `.claude/screens/001-personal-info.json`

**작업 항목**:
- [ ] 화면 파일 생성
- [ ] 이름 입력 필드 (TextField)
- [ ] 나이 입력 필드 (NumberPicker 또는 TextField)
- [ ] 성별 선택 (Radio 또는 ToggleButtons)
- [ ] 유효성 검사 (모든 필드 필수)
- [ ] "다음" 버튼
- [ ] user_profiles 테이블 저장 (Supabase)
- [ ] Provider 생성 (PersonalInfoProvider)
- [ ] Repository 생성 (UserProfileRepository)

**데이터 모델**:
```dart
class PersonalInfo {
  final String name;
  final int age;
  final String gender; // 'male' or 'female'
}
```

**UI 구성** (001 설정 파일 참조):
```dart
- OnboardingHeader(step: 1, totalSteps: 5)
- Form
  - TextFormField(name)
  - TextFormField(age, keyboardType: number)
  - RadioGroup(gender)
- NextButton(onPressed: _onNext)
```

**네비게이션**:
```dart
context.go(Routes.region)
```

---

### 화면 002: Region (지역 선택)

**파일 경로**: `lib/features/onboarding/screens/region_screen.dart`

**설정 파일**: ❌ 생성 필요 (`.claude/screens/002-region.json`)

**작업 항목**:
- [ ] 설정 파일 생성 (002-region.json)
- [ ] 화면 파일 생성
- [ ] 시/도 선택 드롭다운 (1단계)
- [ ] 시/군/구 선택 드롭다운 (2단계)
- [ ] 또는 현재 위치 기반 자동 입력 (geolocator)
- [ ] "다음" 버튼
- [ ] user_profiles.region 필드 업데이트
- [ ] Provider 생성 (RegionProvider)

**데이터 모델**:
```dart
class Region {
  final String province; // 시/도 (예: '서울특별시')
  final String city;     // 시/군/구 (예: '강남구')
}
```

**UI 구성**:
```dart
- OnboardingHeader(step: 2, totalSteps: 5)
- Column
  - DropdownButton(시/도 선택)
  - SizedBox(height: 16)
  - DropdownButton(시/군/구 선택)
  - SizedBox(height: 24)
  - TextButton.icon(현재 위치 사용)
- NextButton(onPressed: _onNext)
```

**네비게이션**:
```dart
context.go(Routes.ageCategory)
```

---

### 화면 004: Income Level (소득 구간) - Phase 2

**파일 경로**: `lib/features/onboarding/screens/income_screen.dart`

**작업 항목**:
- [ ] 설정 파일 생성 (004-income.json)
- [ ] 화면 파일 생성
- [ ] 소득 구간 선택 (예: 0-2천만원, 2-4천만원 등)
- [ ] SelectionCard 위젯 재사용
- [ ] "다음" 버튼 (또는 "건너뛰기")
- [ ] user_profiles.income_level 필드 업데이트

**네비게이션**:
```dart
context.go(Routes.home)
```

---

### 화면: Home (정책 피드)

**파일 경로**: `lib/features/home/screens/home_screen.dart`

**작업 항목**:
- [ ] 화면 파일 생성
- [ ] 상단 AppBar (제목, 필터 버튼)
- [ ] 정책 리스트 (ListView.builder)
- [ ] 정책 카드 위젯 (PolicyCard)
- [ ] 카테고리 탭/칩 (주거, 복지, 교육 등)
- [ ] 무한 스크롤 (Pagination)
- [ ] 당겨서 새로고침 (RefreshIndicator)
- [ ] 정책 클릭 → 상세 페이지 이동
- [ ] Supabase policies 테이블 연동
- [ ] Provider 생성 (PolicyListProvider)
- [ ] Repository 생성 (PolicyRepository)

**UI 구성**:
```dart
- Scaffold
  - AppBar
    - Text('Pickly')
    - IconButton(필터)
  - Body
    - CategoryChips (가로 스크롤)
    - RefreshIndicator
      - ListView.builder
        - PolicyCard (각 정책)
```

**네비게이션**:
```dart
onTap: () => context.go(Routes.policyDetail(policy.id))
```

---

### 화면: Policy Detail (정책 상세)

**파일 경로**: `lib/features/policy/screens/policy_detail_screen.dart`

**작업 항목**:
- [ ] 화면 파일 생성
- [ ] 정책 제목
- [ ] 정책 요약 (summary)
- [ ] 자격 요건 섹션
- [ ] 신청 방법 섹션
- [ ] 마감일 표시
- [ ] "신청하기" 버튼 (외부 링크)
- [ ] 북마크 버튼 (Phase 2)
- [ ] 공유 버튼 (Phase 2)
- [ ] Supabase policies 테이블 조회
- [ ] Provider 생성 (PolicyDetailProvider)

**UI 구성**:
```dart
- Scaffold
  - AppBar(뒤로가기)
  - Body
    - ScrollView
      - Hero(썸네일)
      - Text(제목)
      - Text(요약)
      - Divider
      - Text(자격 요건)
      - Divider
      - Text(신청 방법)
      - Divider
      - Text(마감일)
  - BottomBar
    - ElevatedButton('신청하기')
```

---

## 🛠️ 공통 작업 항목

### 라우터 업데이트

**파일**: `lib/core/router.dart`

- [x] Routes 헬퍼 클래스 생성
- [x] 모든 라우트 경로 정의 (주석 처리)
- [x] 타입 안전 네비게이션 상수
- [ ] 온보딩 완료 상태 체크 로직 구현
- [ ] 리다이렉트 로직 활성화

### 온보딩 상태 서비스

**파일**: `lib/core/services/onboarding_service.dart`

- [ ] OnboardingService 클래스 생성
- [ ] SharedPreferences 의존성 추가
- [ ] `isOnboardingComplete()` 메서드
- [ ] `completeOnboarding()` 메서드
- [ ] Provider 통합

**구현 예시**:
```dart
class OnboardingService {
  static const _key = 'onboarding_complete';

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key) ?? false;
  }

  Future<void> completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, true);
  }

  Future<void> resetOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
```

### 의존성 추가

**파일**: `pubspec.yaml`

```yaml
dependencies:
  shared_preferences: ^2.2.2  # 온보딩 상태 저장
  geolocator: ^10.1.0         # 위치 기반 지역 선택 (선택)
```

---

## 📊 우선순위 매트릭스

### 긴급 & 중요 (이번 주)

1. ✅ 라우터 구조 업데이트
2. Onboarding Start 화면
3. Personal Info 화면
4. Region 화면
5. 온보딩 플로우 통합 테스트

### 중요하지만 긴급하지 않음 (다음 주)

6. Home 화면
7. Policy Detail 화면
8. 온보딩 상태 서비스
9. 전체 네비게이션 E2E 테스트

### 긴급하지만 덜 중요 (2주 후)

10. Filter 화면
11. Search 화면
12. Income 화면

---

## 🧪 테스트 계획

### 단위 테스트

- [ ] `test/core/router_test.dart` - 라우터 네비게이션 테스트
- [ ] `test/features/onboarding/screens/*_test.dart` - 각 화면 위젯 테스트
- [ ] `test/core/services/onboarding_service_test.dart` - 온보딩 상태 서비스 테스트

### 통합 테스트

- [ ] `integration_test/onboarding_flow_test.dart` - 전체 온보딩 플로우 테스트
- [ ] `integration_test/navigation_test.dart` - 앱 전체 네비게이션 테스트

### 테스트 시나리오

```dart
// 온보딩 플로우 테스트
testWidgets('Complete onboarding flow', (tester) async {
  // 1. 스플래시 → 온보딩 시작
  await tester.pumpWidget(const MyApp());
  await tester.pump(Duration(seconds: 2));
  expect(find.byType(OnboardingStartScreen), findsOneWidget);

  // 2. 시작 → 개인정보
  await tester.tap(find.text('시작하기'));
  await tester.pumpAndSettle();
  expect(find.byType(PersonalInfoScreen), findsOneWidget);

  // 3. 개인정보 입력 → 지역 선택
  await tester.enterText(find.byKey(Key('name')), '홍길동');
  await tester.enterText(find.byKey(Key('age')), '25');
  await tester.tap(find.text('남성'));
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();
  expect(find.byType(RegionScreen), findsOneWidget);

  // 4. 지역 선택 → 연령/세대
  await tester.tap(find.text('서울특별시'));
  await tester.tap(find.text('강남구'));
  await tester.tap(find.text('다음'));
  await tester.pumpAndSettle();
  expect(find.byType(AgeCategoryScreen), findsOneWidget);

  // 5. 연령/세대 선택 → 홈
  await tester.tap(find.text('청년'));
  await tester.tap(find.text('완료'));
  await tester.pumpAndSettle();
  expect(find.byType(HomeScreen), findsOneWidget);
});
```

---

## 📅 일정 계획

### Week 1 (2025-10-11 ~ 2025-10-17)

**목표**: 온보딩 플로우 완성

- [x] Day 1: 라우터 구조 분석 및 업데이트
- [ ] Day 2: Onboarding Start 화면 구현
- [ ] Day 3: Personal Info 화면 구현
- [ ] Day 4-5: Region 화면 구현 (드롭다운 + 위치 기반)
- [ ] Day 6: 온보딩 플로우 통합 테스트
- [ ] Day 7: 버그 수정 및 리팩토링

### Week 2 (2025-10-18 ~ 2025-10-24)

**목표**: 메인 앱 구현

- [ ] Day 1-3: Home 화면 구현 (정책 리스트)
- [ ] Day 4-5: Policy Detail 화면 구현
- [ ] Day 6: 온보딩 상태 서비스 구현
- [ ] Day 7: 전체 E2E 테스트

### Week 3 (2025-10-25 ~ 2025-10-31)

**목표**: 확장 기능 및 최적화

- [ ] Day 1-2: Filter 화면
- [ ] Day 3: Search 화면
- [ ] Day 4: Income 화면
- [ ] Day 5-7: 성능 최적화, 애니메이션 추가

---

## 🎯 완료 기준 (Definition of Done)

각 화면이 완료되었다고 판단하는 기준:

- [ ] 화면 파일 생성 및 UI 구현
- [ ] 필요한 Provider/Repository 구현
- [ ] Supabase 연동 (필요 시)
- [ ] 네비게이션 테스트 (이전/다음 화면 이동)
- [ ] 위젯 테스트 작성
- [ ] 코드 리뷰 완료
- [ ] PRD 요구사항 충족
- [ ] 디자인 가이드 준수

---

## 📝 참고 문서

- [라우팅 구조 분석 리포트](/docs/architecture/routing-structure-analysis.md)
- [PRD](/docs/PRD.md) - 섹션 4 (핵심 기능)
- [현재 라우터](/apps/pickly_mobile/lib/core/router.dart)
- [화면 설정 파일](/.claude/screens/)

---

**마지막 업데이트**: 2025-10-11
**다음 리뷰**: 온보딩 플로우 완성 후 (Week 1 종료 시)
