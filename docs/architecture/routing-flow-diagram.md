# 🗺️ Pickly Mobile 라우팅 플로우 다이어그램

**마지막 업데이트**: 2025-10-11

---

## 📱 전체 네비게이션 맵

```
┌─────────────────────────────────────────────────────────────────┐
│                      Pickly Mobile App                          │
│                     Navigation Structure                         │
└─────────────────────────────────────────────────────────────────┘

                    ┌──────────────┐
                    │   /splash    │
                    │ SplashScreen │
                    │   (2초 대기)  │
                    └──────┬───────┘
                           │
                     ┌─────▼─────┐
                     │ 온보딩 완료? │
                     └─────┬─────┘
                    No ◄───┴───► Yes
                     │           │
        ┌────────────▼─────┐     │
        │  /onboarding/    │     │
        │      start       │     │
        │ OnboardingStart  │     │
        └────────┬─────────┘     │
                 │                │
        ┌────────▼───────────┐   │
        │  /onboarding/      │   │
        │  personal-info     │   │
        │ PersonalInfoScreen │   │
        │  (이름, 나이, 성별)  │   │
        └────────┬───────────┘   │
                 │                │
        ┌────────▼───────────┐   │
        │  /onboarding/      │   │
        │     region         │   │
        │   RegionScreen     │   │
        │   (지역 선택)       │   │
        └────────┬───────────┘   │
                 │                │
        ┌────────▼───────────┐   │
        │  /onboarding/      │   │
        │  age-category      │   │
        │ AgeCategoryScreen  │◄──┘ (기존 사용자)
        │  (연령/세대 선택)   │
        └────────┬───────────┘
                 │
        ┌────────▼───────────┐
        │  /onboarding/      │
        │     income         │ (Optional, Phase 2)
        │   IncomeScreen     │
        │  (소득 구간 선택)   │
        └────────┬───────────┘
                 │
                 │
        ┌────────▼───────────┐
        │      /home         │
        │    HomeScreen      │
        │  (정책 피드 리스트)  │
        └────────┬───────────┘
                 │
         ┌───────┼───────┐
         │       │       │
    ┌────▼────┐ │  ┌────▼────┐
    │ /home/  │ │  │ /policy │
    │ filter  │ │  │  /:id   │
    │ Filter  │ │  │ Detail  │
    │         │ │  │         │
    └─────────┘ │  └─────────┘
                │
         ┌──────▼──────┐
         │  /policy/   │
         │   search    │
         │ SearchScreen│
         │             │
         └─────────────┘
```

---

## 🔄 온보딩 플로우 (상세)

```
┌─────────────────────────────────────────────────────────────────┐
│                  Onboarding Flow (First Time)                   │
└─────────────────────────────────────────────────────────────────┘

Step 0           Step 1              Step 2              Step 3
━━━━━━━         ━━━━━━━━━━━━━      ━━━━━━━━━━━━━      ━━━━━━━━━━━━━
 Splash    →    Start Screen  →    Personal Info  →    Region

┌──────┐       ┌──────────┐       ┌──────────┐       ┌──────────┐
│      │       │          │       │          │       │          │
│ Logo │       │ Welcome  │       │ 이름:    │       │ 시/도:   │
│      │ 2초   │ Message  │ 시작   │ 나이:    │ 다음   │ 시/군/구: │
│      │ ───►  │          │ ───►  │ 성별:    │ ───►  │          │
│      │       │ [시작]   │       │          │       │ [현위치] │
│      │       │          │       │ [다음]   │       │ [다음]   │
└──────┘       └──────────┘       └──────────┘       └──────────┘
  Auto           Manual             Form Input        Selection


Step 4              Step 5 (Optional)      Complete
━━━━━━━━━━━━━      ━━━━━━━━━━━━━━━━━      ━━━━━━━━━━
Age Category  →      Income Level    →      Home

┌──────────┐       ┌──────────┐       ┌──────────┐
│          │       │          │       │          │
│ □ 청년   │       │ □ 0-2천  │       │ 맞춤형   │
│ □ 신혼   │ 완료   │ □ 2-4천  │ 완료   │ 정책     │
│ □ 육아   │ ───►  │ □ 4-6천  │ ───►  │ 리스트   │
│ □ 다자녀 │       │          │       │          │
│ □ 노인   │       │ [건너뛰기]│       │ [필터]   │
│ □ 장애인 │       │ [완료]   │       │          │
└──────────┘       └──────────┘       └──────────┘
Multi-select       Single-select      Main App
```

---

## 🏠 메인 앱 플로우

```
┌─────────────────────────────────────────────────────────────────┐
│                    Main App Navigation Flow                     │
└─────────────────────────────────────────────────────────────────┘

                    ┌──────────────┐
                    │   /home      │
                    │  HomeScreen  │
                    │              │
                    │ ┌──────────┐ │
                    │ │ [필터]   │ │
                    │ └──────────┘ │
                    │              │
                    │  정책 1       │
                    │  정책 2       │
                    │  정책 3 ◄──┐ │
                    │     ...     │ │
                    └──────┬──────┘ │
                           │        │
                    ┌──────┼────────┼──────┐
                    │      │        │      │
              ┌─────▼───┐  │  ┌─────▼───┐ │
              │ /policy │  │  │ /home/  │ │
              │  /:id   │  │  │ filter  │ │
              │         │  │  │         │ │
              │ 정책상세 │  │  │ 필터화면 │ │
              │         │  │  │         │ │
              │ [신청]  │  │  │ [적용]  │─┘
              │ [공유]  │  │  │         │
              │ [북마크]│  │  │         │
              └─────────┘  │  └─────────┘
                           │
                    ┌──────▼──────┐
                    │  /policy/   │
                    │   search    │
                    │             │
                    │ SearchScreen│
                    │             │
                    │ [검색결과]  │
                    └─────────────┘
```

---

## 🔐 라우팅 가드 (Redirect Logic)

```
┌─────────────────────────────────────────────────────────────────┐
│                      Routing Guard Logic                        │
└─────────────────────────────────────────────────────────────────┘

사용자 접근 시도
      │
      ▼
┌─────────────┐
│ 요청 경로가  │      No
│ /splash?    │ ──────────► ┌─────────────┐
└─────┬───────┘             │ 온보딩 완료?│
      │ Yes                 └─────┬───────┘
      ▼                           │
  /splash 표시          ┌─────────┼─────────┐
      │              No │                   │ Yes
      │ (2초 후)        ▼                   ▼
      │         /onboarding/start   요청한 페이지 표시
      │              표시                   │
      │                │                   │
      └────────────────┴───────────────────┘
                       │
                       ▼
                  페이지 렌더링


특수 케이스:
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. 직접 URL 접근 (딥링크)
   - /policy/123 접근 시
   → 온보딩 미완료면 /onboarding/start로 리다이렉트
   → 완료 시 정상 표시

2. 뒤로가기 (Back navigation)
   - 온보딩 중 뒤로가기
   → 이전 온보딩 단계로 이동
   - 홈에서 뒤로가기
   → 앱 종료

3. 에러 발생 시
   - 404 Not Found
   → ErrorScreen 표시
   → "홈으로 돌아가기" 버튼으로 /home 이동
```

---

## 📊 라우트 계층 구조 (Tree View)

```
/
├─ splash                       (레벨 1: 진입점)
│
├─ onboarding                   (레벨 1: 온보딩 루트)
│  ├─ start                     (레벨 2: 환영)
│  ├─ personal-info             (레벨 2: 개인정보)
│  ├─ region                    (레벨 2: 지역)
│  ├─ age-category             (레벨 2: 연령/세대) ✅
│  └─ income                    (레벨 2: 소득) [Phase 2]
│
├─ home                         (레벨 1: 메인 앱)
│  └─ filter                    (레벨 2: 필터)
│
└─ policy                       (레벨 1: 정책)
   ├─ :id                       (레벨 2: 상세) [동적 경로]
   └─ search                    (레벨 2: 검색)
```

---

## 🎯 화면별 상태 및 네비게이션

| 화면 | 경로 | 진입 조건 | 이전 화면 | 다음 화면 | 상태 저장 |
|------|------|----------|----------|----------|----------|
| Splash | `/splash` | 항상 | - | Onboarding Start 또는 Home | - |
| Onboarding Start | `/onboarding/start` | 온보딩 미완료 | Splash | Personal Info | - |
| Personal Info | `/onboarding/personal-info` | - | Onboarding Start | Region | user_profiles 테이블 |
| Region | `/onboarding/region` | - | Personal Info | Age Category | user_profiles.region |
| Age Category | `/onboarding/age-category` | - | Region | Income 또는 Home | user_profiles.selected_categories |
| Income | `/onboarding/income` | - | Age Category | Home | user_profiles.income_level |
| Home | `/home` | 온보딩 완료 | - | Policy Detail, Filter, Search | - |
| Policy Detail | `/policy/:id` | 온보딩 완료 | Home | - | analytics 이벤트 |
| Filter | `/home/filter` | - | Home | Home | 필터 설정 |
| Search | `/policy/search` | - | Home | Policy Detail | 검색어 히스토리 |

---

## 🔄 네비게이션 메서드 사용법

### 기본 네비게이션

```dart
// 1. context.go() - 스택 대체 (뒤로가기 불가)
context.go(Routes.home);

// 2. context.push() - 스택에 추가 (뒤로가기 가능)
context.push(Routes.policyDetail('123'));

// 3. context.pop() - 이전 화면으로
context.pop();

// 4. context.replace() - 현재 화면 대체
context.replace(Routes.home);
```

### 온보딩 플로우 예시

```dart
// ✅ 올바른 사용: 순차적 진행 (go 사용)
// OnboardingStartScreen
ElevatedButton(
  onPressed: () => context.go(Routes.personalInfo),
  child: Text('시작하기'),
)

// PersonalInfoScreen
ElevatedButton(
  onPressed: () {
    // 데이터 저장 후
    context.go(Routes.region);
  },
  child: Text('다음'),
)

// ❌ 잘못된 사용: push 사용 시 스택 누적
context.push(Routes.personalInfo); // 뒤로가기 시 Start로 돌아감
```

### 메인 앱 예시

```dart
// ✅ 정책 상세로 이동 (push 사용 - 뒤로가기 필요)
// HomeScreen
GestureDetector(
  onTap: () => context.push(Routes.policyDetail(policy.id)),
  child: PolicyCard(policy: policy),
)

// PolicyDetailScreen
AppBar(
  leading: IconButton(
    icon: Icon(Icons.arrow_back),
    onPressed: () => context.pop(), // 홈으로 돌아가기
  ),
)
```

---

## 🧪 네비게이션 테스트 시나리오

### 시나리오 1: 신규 사용자 (온보딩)

```
1. 앱 실행
   → /splash (2초 대기)

2. 자동 이동
   → /onboarding/start

3. "시작하기" 탭
   → /onboarding/personal-info

4. 정보 입력 후 "다음" 탭
   → /onboarding/region

5. 지역 선택 후 "다음" 탭
   → /onboarding/age-category

6. 카테고리 선택 후 "완료" 탭
   → /home (온보딩 완료 플래그 저장)

✅ 성공 조건:
- 모든 화면 전환이 부드럽게 이루어짐
- 데이터가 Supabase에 정상 저장됨
- 온보딩 완료 플래그가 SharedPreferences에 저장됨
```

### 시나리오 2: 기존 사용자 (재방문)

```
1. 앱 실행
   → /splash (2초 대기)

2. 온보딩 완료 확인
   → /home (즉시 이동)

3. 정책 카드 탭
   → /policy/123

4. 뒤로가기 버튼 탭
   → /home

✅ 성공 조건:
- 온보딩 화면이 표시되지 않음
- 바로 홈 화면으로 이동
- 정책 상세 → 홈으로 복귀 정상 작동
```

### 시나리오 3: 딥링크 접근

```
1. 외부 링크로 /policy/123 접근

2. 온보딩 미완료 감지
   → /onboarding/start로 리다이렉트

3. 온보딩 완료

4. 원래 요청한 /policy/123로 이동
   (TODO: Phase 2에서 구현)

✅ 성공 조건:
- 리다이렉트가 정상 작동
- 온보딩 완료 후 원래 경로로 복귀 (선택)
```

### 시나리오 4: 에러 처리

```
1. 존재하지 않는 경로 접근
   → /non-existent-path

2. ErrorScreen 표시
   - 에러 메시지: "페이지를 찾을 수 없습니다"
   - 경로 표시: Path: /non-existent-path

3. "홈으로 돌아가기" 버튼 탭
   → /home

✅ 성공 조건:
- 앱이 크래시되지 않음
- 에러 화면이 정상 표시됨
- 홈으로 복귀 가능
```

---

## 📐 라우팅 아키텍처 패턴

### 1. 선언적 라우팅 (Declarative Routing)

```dart
// ✅ GoRouter는 선언적 라우팅 사용
final router = GoRouter(
  routes: [
    GoRoute(path: '/home', builder: ...),
    GoRoute(path: '/policy/:id', builder: ...),
  ],
);

// ❌ 명령형 라우팅 (Navigator 1.0)
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => HomeScreen()),
);
```

### 2. URL 기반 네비게이션

```dart
// ✅ URL 경로로 네비게이션 상태 관리
context.go('/policy/123');

// 브라우저처럼 작동:
// - 뒤로가기/앞으로가기 지원
// - 딥링크 지원
// - URL 공유 가능
```

### 3. 타입 안전 경로

```dart
// ✅ Routes 클래스로 타입 안전성 확보
context.go(Routes.home);
context.push(Routes.policyDetail('123'));

// ❌ 문자열 직접 사용 (오타 위험)
context.go('/home');
context.push('/policy/123');
```

---

## 🚀 다음 단계

1. **즉시 실행**:
   - [ ] 누락된 화면 파일 생성
   - [ ] 온보딩 플로우 연결
   - [ ] 네비게이션 테스트

2. **1주 내**:
   - [ ] 온보딩 상태 서비스 구현
   - [ ] 리다이렉트 로직 활성화
   - [ ] E2E 테스트 작성

3. **2주 내**:
   - [ ] 딥링크 지원
   - [ ] 애니메이션 추가
   - [ ] 성능 최적화

---

**참고 문서**:
- [라우팅 구조 분석 리포트](/docs/architecture/routing-structure-analysis.md)
- [구현 체크리스트](/docs/architecture/routing-implementation-checklist.md)
- [GoRouter 공식 문서](https://pub.dev/packages/go_router)
