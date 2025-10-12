# 📄 Pickly PRD (Flutter Mobile + Claude Flow - v5.0)

> **AI 자동화 기반 개발 시스템**
> 마지막 업데이트: 2025.10.07

---

## 1. 프로젝트 개요

### 제품 정의
Pickly는 복잡한 정부 정책/혜택 공고문을 **개인 맞춤형으로 큐레이션**하여, 누구나 쉽게 혜택을 확인하고 신청할 수 있도록 돕는 **모바일 정책 정보 서비스**입니다.

### 문제 정의
- 정책 정보가 여러 기관 사이트에 흩어져 있음
- 공고문이 길고 전문 용어가 많아 이해하기 어려움
- 내 상황에 맞는 정책을 찾기 어려움
- 신청 방법과 마감일을 놓치기 쉬움

### 핵심 가치 제안
1. **개인화**: 사용자 정보 기반 맞춤형 정책 추천
2. **단순화**: 복잡한 정책을 이해하기 쉽게 요약
3. **접근성**: 모바일에서 언제 어디서나 확인
4. **실용성**: 신청까지 원스톱 지원

---

## 2. 대상 사용자

### 주요 타겟
- **연령**: 20-40대
- **상황**: 주거, 복지, 교육, 취업 관련 정책 필요자
- **특징**: 정책 정보 접근에 어려움을 겪는 일반인

### 페르소나
1. **김정책 (28세, 신혼부부)** - 주거 지원 정책 필요
2. **박복지 (35세, 두 자녀 부모)** - 육아/복지 지원 필요
3. **이취업 (25세, 청년)** - 취업/교육 지원 필요

---

## 3. 목표 & KPI

### 비즈니스 목표
- 초기 6개월 내 **MAU 5,000명** 확보
- 정책 정보 큐레이션 시장에서 신뢰받는 서비스

### 사용자 목표
- 본인에게 맞는 정책을 **5분 이내**에 찾기
- 공고문 분석 **정확도 70% 이상**

### 성공 지표 (KPI)
- 월간 활성 사용자 (MAU)
- 정책 상세 페이지 클릭률
- 30일 재방문율 (Retention)
- 앱스토어 평점 4.0 이상

---

## 4. 핵심 기능

### 모바일 앱 (사용자용)

**MVP (Phase 1 - 2개월)**

**온보딩 & 개인화**
- 거주 지역, 연령, 가구 형태, 소득 구간 입력
- 관심 정책 카테고리 선택

**정책 피드**
- 조건 기반 맞춤 정책 리스트
- 카테고리별 필터링 (주거, 복지, 교육 등)
- 광고/스폰서 콘텐츠 표시

**정책 상세**
- 정책 요약
- 자격 요건
- 신청 방법 및 링크
- 마감일 안내

**검색 & 필터**
- 키워드 검색
- 조건별 필터 (지역, 연령, 카테고리)

**Phase 2 (2-3개월 후)**
- 공고문 업로드 → AI 자동 분석
- 북마크 & 공유 기능
- 푸시 알림 (마감 임박, 신규 정책)

**Phase 3 (4-6개월 후)**
- 정책 신청 현황 트래킹
- 커뮤니티 기능 (댓글, Q&A)
- AI 추천 고도화

### 백오피스 (관리자용)

**MVP (Phase 1 - 2개월)**

**콘텐츠 관리**
- 정책 정보 CRUD (수동 등록/수정/삭제)
- 정책 카테고리 관리
- 정책 우선순위 설정

**광고/스폰서 콘텐츠 관리**
- 광고 배너 등록 (이미지, 링크, 노출 위치)
- 스폰서 콘텐츠 등록 (썸네일, 제목, 설명, 링크)
- 노출 기간 설정 (시작일, 종료일)
- 타겟팅 설정 (지역, 연령, 카테고리)

**썸네일 관리**
- 이미지 업로드 (다중 업로드 지원)
- 이미지 크롭 및 리사이징
- 썸네일 미리보기

**사용자 관리**
- 사용자 목록 조회
- 사용자 상세 정보 확인
- 신고된 사용자 관리

**Phase 2 (3-4개월 후)**

**분석 대시보드**
- 사용자 통계 (MAU, DAU, Retention)
- 정책 조회수/클릭률 분석
- 광고 성과 분석 (노출수, 클릭수, CTR)
- 인기 검색어 분석

**일괄 작업**
- 정책 데이터 CSV 일괄 업로드
- 만료된 정책 자동 아카이빙
- 정책 데이터 엑셀 내보내기

**알림 관리**
- 푸시 알림 일괄 발송
- 알림 템플릿 관리
- 발송 내역 조회

---

## 5. 사용자 시나리오

### 모바일 앱 (일반 사용자)
1. 앱 설치 → 온보딩 (조건 입력)
2. 홈 화면에서 맞춤 정책 확인
3. 관심 정책 클릭 → 상세 정보 확인
4. 신청 링크로 이동하여 신청
5. 북마크하여 나중에 다시 보기

### 백오피스 (관리자)
1. 관리자 로그인
2. 신규 정책 정보 등록
3. 썸네일 이미지 업로드 및 크롭
4. 광고 배너 등록 (노출 기간, 타겟팅 설정)
5. 대시보드에서 정책 조회수 확인
6. 만료된 정책 아카이빙

---

## 6. 프로젝트 구조

### 📁 실제 프로젝트 구조 (2025.10.07 기준)

```
pickly_service/
├── apps/
│   └── pickly_mobile/              # 📱 Flutter 모바일 앱 (단일 플랫폼)
│       ├── lib/
│       │   ├── main.dart
│       │   ├── contexts/           # 도메인 로직 (비즈니스 규칙, 모델, 리포지토리)
│       │   │   └── user/
│       │   │       ├── models/
│       │   │       │   ├── user_profile.dart
│       │   │       │   └── age_category.dart
│       │   │       └── repositories/
│       │   │           ├── user_repository.dart
│       │   │           └── age_category_repository.dart
│       │   │
│       │   ├── features/           # UI 레이어 (화면, 위젯, 상태관리)
│       │   │   └── onboarding/
│       │   │       ├── screens/
│       │   │       │   ├── personal_info_screen.dart      # 001
│       │   │       │   └── age_category_screen.dart       # 003
│       │   │       ├── widgets/
│       │   │       │   ├── selection_card.dart
│       │   │       │   └── onboarding_header.dart
│       │   │       └── providers/
│       │   │           └── onboarding_provider.dart
│       │   │
│       │   └── core/               # 핵심 설정
│       │       ├── router.dart     # GoRouter 설정
│       │       ├── theme.dart      # 디자인 토큰
│       │       └── supabase_config.dart
│       │
│       ├── test/                   # 테스트 파일
│       │   └── features/
│       │       └── onboarding/
│       └── pubspec.yaml
│
├── backend/
│   └── supabase/                   # 🗄️ Supabase 백엔드
│       ├── migrations/             # 데이터베이스 마이그레이션
│       │   └── 20251007035747_onboarding_schema.sql
│       ├── seed.sql               # 초기 데이터 (6개 카테고리)
│       └── config.toml            # Supabase 설정
│
├── .claude/                        # 🤖 Claude Flow AI 에이전트 시스템
│   ├── agents/
│   │   ├── core/
│   │   │   └── onboarding-coordinator.md          # 총괄 코디네이터
│   │   └── specialists/
│   │       ├── onboarding-screen-builder.md       # Flutter UI 생성
│   │       ├── onboarding-state-manager.md        # 상태 관리 로직
│   │       ├── onboarding-database-manager.md     # Supabase 연동
│   │       ├── onboarding-admin-builder.md        # 백오피스 (미래)
│   │       └── onboarding-integration-tester.md   # 테스트 자동화
│   │
│   ├── workflows/
│   │   └── onboarding-universal.yml               # 통합 워크플로우
│   │
│   ├── screens/                    # 화면별 설정 JSON
│   │   ├── 001-personal-info.json
│   │   └── 003-age-category.json
│   │
│   └── helpers/
│       ├── setup-common.sh         # 공통 설정 스크립트
│       └── setup-docs.sh           # 문서 생성 스크립트
│
├── docs/
│   ├── pickly_prd.md              # 제품 요구사항 문서
│   ├── README.md                  # 프로젝트 개요
│   ├── development/
│   │   └── onboarding-development-guide.md
│   ├── architecture/
│   │   └── common-agent-architecture.md
│   └── api/
│       └── screen-config-schema.md
│
├── scripts/
│   ├── setup-common.sh             # 프로젝트 초기 설정
│   └── setup-docs.sh               # 문서 자동 생성
│
└── package.json                    # 루트 의존성 (melos 등)
```

### 🎯 아키텍처 핵심 원칙

#### 1. Contexts/Features 분리
- **Contexts**: 도메인 로직만 (UI 의존성 없음)
  - 모델 (Model)
  - 리포지토리 (Repository)
  - 서비스 로직 (Service)

- **Features**: UI와 상태 관리
  - 화면 (Screen)
  - 위젯 (Widget)
  - Provider (Riverpod)

#### 2. Claude Flow 에이전트 기반 개발
- **자동화**: JSON 설정 → 전체 화면 자동 생성
- **병렬 처리**: 6개 에이전트가 동시 작업
- **일관성**: 모든 화면이 동일한 패턴으로 생성

#### 3. Supabase 중심 백엔드
- **Database**: PostgreSQL + RLS
- **Auth**: 이메일/소셜 로그인
- **Storage**: 이미지 업로드 (미래)
- **Edge Functions**: 서버리스 함수 (미래)

---

## 7. 기술 스택

### Frontend

- **Flutter (모바일)**:
  - 상태관리: Riverpod
  - 라우팅: GoRouter
  - HTTP: Dio + Supabase Client
  - 로컬 저장소: Hive (캐싱용)
  - 디자인: Material 3 기반 커스텀 테마

### Backend

- **Supabase**:
  - PostgreSQL (데이터베이스)
  - Auth (인증/인가)
  - Storage (파일 저장소, 미래)
  - Edge Functions (서버리스, 미래)
  - Real-time (실시간 구독, 미래)

### 개발 도구 & 자동화

- **Claude Flow**: AI 기반 개발 워크플로우 자동화
  - 에이전트 오케스트레이션
  - 화면 자동 생성
  - 테스트 자동화

- **Supabase CLI**: 로컬 개발 환경
  - 로컬 PostgreSQL
  - 마이그레이션 관리
  - 데이터 시딩

### DevOps
- **GitHub Actions** - CI/CD
- **Firebase** - 모바일 앱 배포 및 모니터링
- **Sentry** - 에러 트래킹

---

## 8. 데이터베이스 스키마 (주요 테이블)

### policies (정책)
```sql
- id: uuid (PK)
- title: text
- summary: text
- description: text
- category: text
- thumbnail_url: text
- target_age_min: int
- target_age_max: int
- target_region: text[]
- application_url: text
- deadline: timestamp
- priority: int (노출 우선순위)
- is_active: boolean
- created_at: timestamp
- updated_at: timestamp
```

### ads (광고/스폰서 콘텐츠)
```sql
- id: uuid (PK)
- type: enum (banner, sponsor_content)
- title: text
- image_url: text
- link_url: text
- target_age_min: int
- target_age_max: int
- target_region: text[]
- target_category: text[]
- start_date: timestamp
- end_date: timestamp
- priority: int
- impressions: int (노출수)
- clicks: int (클릭수)
- is_active: boolean
- created_at: timestamp
```

### users (사용자)
```sql
- id: uuid (PK)
- email: text
- age: int
- region: text
- household_type: text
- income_level: text
- interests: text[]
- created_at: timestamp
- last_login_at: timestamp
```

### analytics (분석)
```sql
- id: uuid (PK)
- event_type: text (policy_view, policy_click, ad_impression, ad_click)
- target_id: uuid (정책 또는 광고 ID)
- user_id: uuid
- metadata: jsonb
- created_at: timestamp
```

---

## 9. 개발 방법론

### Claude Flow 기반 자동화 개발

#### 화면 개발 프로세스
1. **설정 파일 작성**: `.claude/screens/{화면ID}.json`
2. **워크플로우 실행**: `claude-flow orchestrate --workflow .claude/workflows/onboarding-universal.yml --screen {화면ID}`
3. **에이전트 자동 작업**:
   - 코디네이터: 작업 계획 수립
   - Screen Builder: Flutter UI 생성
   - State Manager: Provider 생성
   - Database Manager: Repository 생성
   - Integration Tester: 테스트 코드 생성
4. **검증 및 수정**: 생성된 코드 리뷰 및 커스터마이징

#### 에이전트 역할 분담
- **Coordinator**: 전체 작업 조율 및 우선순위 결정
- **Screen Builder**: 화면 파일 및 위젯 생성
- **State Manager**: Riverpod Provider 및 상태 로직
- **Database Manager**: Supabase 연동 및 Repository
- **Admin Builder**: 백오피스 CRUD 화면 (미래)
- **Integration Tester**: 위젯/통합 테스트

#### 장점
- ⚡ **빠른 개발**: 수동 대비 70% 시간 단축
- 🎯 **일관성**: 모든 화면이 동일한 패턴
- 🧪 **품질**: 테스트 자동 생성으로 커버리지 확보
- 📚 **문서화**: 자동 생성된 주석 및 README

### SPARC 방법론
1. **Specification**: PRD 기반 요구사항 명세
2. **Pseudocode**: 핵심 로직 의사코드 작성
3. **Architecture**: Contexts/Features 분리 설계
4. **Refinement**: TDD 기반 반복 개발
5. **Completion**: 통합 테스트 및 배포

### TDD 적용
- **Red**: 실패하는 테스트 먼저 작성
- **Green**: 테스트 통과하는 최소 코드
- **Refactor**: 코드 품질 개선

### 품질 관리
- **코드 리뷰**: 모든 PR 필수 리뷰
- **자동 테스트**: 커버리지 60% 이상
- **정적 분석**: Flutter Analyzer
- **경계 강제**: Contexts/Features 의존성 검증

---

## 10. 로드맵

### Phase 1: MVP 개발 (3개월)

#### ✅ 완료 (Week 1-2)
- [x] Supabase 프로젝트 설정
- [x] 로컬 개발 환경 구축
- [x] 온보딩 DB 스키마 설계 및 마이그레이션
- [x] 초기 데이터 시딩 (6개 카테고리)
- [x] Claude Flow 에이전트 시스템 구축
- [x] 화면 설정 JSON 구조 확립

#### ✅ 완료 (Week 2-3)
- [x] 003 온보딩 화면 개발 (연령/세대 선택)
  - SelectionListItem 공통 위젯 구현
  - Figma 아이콘 연동 완료
  - Realtime 구독 기능 구현
  - 다중 선택 상태 관리

#### 🔄 진행 중 (Week 3-4)
- [ ] 001 온보딩 화면 개발 (개인정보 입력)
- [ ] 002 온보딩 화면 개발 (지역 선택)
- [ ] 온보딩 플로우 통합 및 네비게이션

#### 📅 예정 (Week 4-6)
- [ ] 정책 피드 화면
- [ ] 정책 상세 화면
- [ ] 검색 및 필터 기능

### Phase 2: 핵심 기능 강화 (2개월)
- 모바일: 공고문 분석 AI, 푸시 알림, 북마크
- 백오피스 (미래): 분석 대시보드, 광고 성과 추적

### Phase 3: 고도화 (2개월)
- 모바일: AI 추천 개선, 커뮤니티
- 백오피스 (미래): 일괄 작업, 고급 분석

---

## 11. 성능 & 보안

### 성능 목표
- **모바일 첫 화면**: 1초 이내
- **백오피스 로딩**: 2초 이내
- **API 응답**: 평균 200ms 이하
- **이미지 로딩**: Progressive loading

### 성능 최적화
- 이미지 최적화 (WebP, 다중 해상도)
- 리스트 가상화 (Lazy Loading)
- CDN 활용 (Supabase Storage)
- 캐싱 전략 (모바일: Hive, 웹: TanStack Query)

### 보안
- **인증**: Supabase Auth + JWT
- **권한**: RLS (Row Level Security)
  - 일반 사용자: 정책 읽기만 가능
  - 관리자: 모든 테이블 CRUD 가능
- **데이터 전송**: HTTPS 필수
- **이미지 업로드**: 파일 타입/크기 검증
- **XSS/CSRF 방어**: React 기본 보호 + CSP 헤더

---

## 12. 리스크 & 대응

### 주요 리스크

1. **데이터 품질**
   - 리스크: 공고문 포맷 다양성
   - 대응: 다양한 포맷 학습 데이터 확보

2. **사용자 유입**
   - 리스크: 초기 사용자 확보 어려움
   - 대응: 베타 테스트, SNS 마케팅

3. **관리 부담**
   - 리스크: 수동 콘텐츠 관리 부담 증가
   - 대응: 일괄 업로드, 자동화 기능 개발

4. **기술 의존성**
   - 리스크: Supabase 플랫폼 의존도
   - 대응: 백엔드 코드 추상화 (Repository 패턴)

---

## 13. 범위 제외

### 초기 버전에서 제외
- 정책 신청 대행 서비스
- 실시간 채팅
- 결제 시스템
- 외부 API 자동 수집 (수동 등록 먼저)

---

## 14. 참고 자료

### 프로젝트 리소스
- **Repository**: https://github.com/kwonhyunjun/pickly-service
- **Figma**: https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly

### 기술 문서
- **Flutter**: https://flutter.dev
- **React**: https://react.dev
- **Supabase**: https://supabase.com/docs
- **MUI**: https://mui.com

### 경쟁사
- 청약홈, 복지로, 온통정부
- 네이버 정책뉴스, 카카오 정부24

---

## 15. 변경 이력

### v5.4 (2025.10.12) - 📚 아키텍처 문서화 및 구조 표준화

#### 주요 변경사항

**아키텍처 문서 신규 작성**:
- `docs/architecture/project-structure.md`: 프로젝트 구조 상세 가이드
  - 모노레포 구조 설명 (apps/, packages/, docs/)
  - Feature-First 조직화 원칙
  - 모듈 경계 및 의존성 다이어그램
  - 파일 명명 규칙
  - 내비게이션 전략 (GoRouter)
  - 상태 관리 (Riverpod)
  - 테스트 전략 (Unit, Widget, Integration)

- `docs/architecture/import-conventions.md`: Import 규칙 가이드
  - 절대 경로 vs 상대 경로 비교
  - 표준 Import 순서 (6단계)
  - Asset Import 패턴
  - 절대 경로의 이점 설명
  - 자동화 도구 설정 (VS Code, 린트)

**기술 스택 명확화**:
- Flutter: Riverpod (상태관리), GoRouter (라우팅), Supabase Client (백엔드)
- Design System: 공통 컴포넌트 및 디자인 토큰 관리
- Testing: Unit Tests (80%), Widget Tests (60%), Integration Tests (주요 플로우)

**개발 워크플로우 표준화**:
- Claude Flow를 통한 화면 자동 생성 프로세스
- 6개 전문 에이전트 역할 분담 명확화
- TDD 기반 개발 사이클

**Asset 관리 개선**:
- Design System: `packages/pickly_design_system/assets/`
- 앱 전용: `apps/pickly_mobile/assets/`
- Figma 아이콘 통합 워크플로우

#### 문서화 개선

- ✅ 신규 개발자 온보딩 가이드 완성
- ✅ 의존성 규칙 다이어그램 추가
- ✅ Import 규칙 자동화 도구 설정 가이드
- ✅ 테스트 전략 및 커버리지 목표 명시
- ✅ FAQ 및 실전 팁 추가

#### 성공 기준

- 신규 개발자가 30분 내에 프로젝트 구조 이해 가능
- 모든 파일이 명확한 위치에 배치
- Import 규칙 100% 준수 (린트 강제)
- 아키텍처 의사결정 문서화 완료

### v5.3 (2025.10.12) - 🎨 컴포넌트 정리 및 Design System 통합

#### 주요 변경사항
- **버튼 컴포넌트 통합**:
  - 온보딩 내 여러 버튼 위젯(NextButton, OnboardingBottomButton 등) 제거
  - Design System의 `PicklyButton` 사용으로 통일
  - Primary/Secondary 변형으로 모든 버튼 스타일 커버

- **SelectionListItem Design System 이동**:
  - `features/onboarding/widgets/selection_list_item.dart` → `packages/pickly_design_system/lib/widgets/cards/selection_list_item.dart`
  - 다른 Feature에서도 재사용 가능하도록 공통 컴포넌트화
  - Import 경로 변경: `package:pickly_design_system/widgets/cards/selection_list_item.dart`

- **온보딩 위젯 최적화**:
  - 중복 버튼 컴포넌트 제거 (next_button.dart, onboarding_bottom_button.dart)
  - Selection 관련 카드 위젯 통합 (age_selection_card.dart, selection_card.dart)
  - OnboardingHeader만 로컬 위젯으로 유지

#### 기술 부채 해결
- ✅ 버튼 컴포넌트 중복 제거로 일관성 확보
- ✅ SelectionListItem의 재사용성 향상
- ✅ Design System 범위 명확화
- ✅ Import 경로 단순화

#### 마이그레이션 가이드
```dart
// Before (v5.2)
import 'package:pickly_mobile/features/onboarding/widgets/next_button.dart';
import 'package:pickly_mobile/features/onboarding/widgets/selection_list_item.dart';

NextButton(
  label: '다음',
  enabled: true,
  onPressed: () {},
)

// After (v5.3)
import 'package:pickly_design_system/widgets/buttons/pickly_button.dart';
import 'package:pickly_design_system/widgets/cards/selection_list_item.dart';

PicklyButton.primary(
  text: '다음',
  onPressed: () {},
)
```

### v5.2 (2025.10.11) - 🧹 프로젝트 구조 정리 및 표준화

#### 주요 변경사항
- **중복 파일 제거**:
  - `lib/core/models/age_category.dart` 삭제
  - 모든 모델을 `contexts/user/models`로 통합
  - 단일 진실 공급원(Single Source of Truth) 확립

- **온보딩 위젯 소스 통일**:
  - Design System 패키지 위젯 우선 사용 (NextButton 등)
  - 온보딩 전용 위젯만 로컬 유지 (OnboardingHeader, SelectionListItem)
  - 위젯 소스 출처 명확화

- **파일 구조 정리**:
  - 예제 파일을 `examples/` 폴더로 이동
  - 미사용 컨트롤러 파일 제거 (age_category_controller.dart)
  - 테스트 파일 정리 및 표준화

- **Import 경로 표준화**:
  - 모든 import를 절대 경로로 통일
  - `package:pickly_mobile/...` 형식 강제
  - 상대 경로 사용 금지

#### 기술 부채 해결
- ✅ 중복 모델 파일 제거로 혼란 방지
- ✅ 온보딩 위젯 소스 명확화로 유지보수성 향상
- ✅ Import 경로 일관성 확보로 코드 가독성 개선
- ✅ 미사용 파일 정리로 프로젝트 정돈

#### 개발 경험 개선
- 새로운 개발자 온보딩 용이성 향상
- 파일 위치 예측 가능성 증대
- 의존성 관계 명확화

### v5.1 (2025.10.11) - 🎨 Figma 연동 및 공통 컴포넌트 구축
- **003 온보딩 화면 완성**:
  - SelectionListItem 공통 위젯 구현 (재사용 가능)
  - Figma 아이콘 자동 연동 시스템
  - SVG 아이콘 지원 (flutter_svg)
  - Realtime 구독으로 관리자 수정사항 즉시 반영
- **공통 컴포넌트 체계 확립**:
  - SelectionCard (카드형 선택)
  - SelectionListItem (리스트형 선택)
  - OnboardingHeader (단계 표시)
  - NextButton (다음 버튼)
- **Figma 워크플로우**:
  - iconMapping을 통한 자동 경로 변환
  - Design System 패키지에 아이콘 통합
  - 일관된 아이콘 표시 방식
- **개발 가이드 강화**:
  - SelectionListItem 사용 예시 추가
  - Figma assets 연동 가이드
  - 화면 상태 추적 테이블 업데이트

### v5.0 (2025.10.07) - 🤖 AI 자동화 시스템 도입
- **구조 단순화**: React 웹 제거, Flutter 모바일 단일 플랫폼
- **Claude Flow 도입**: AI 에이전트 기반 자동 개발 시스템
  - 6개 전문 에이전트 구축
  - 화면별 JSON 설정 기반 자동 생성
  - 통합 워크플로우 구현
- **Supabase 설정 완료**:
  - 로컬 개발 환경 구축
  - 온보딩 테이블 스키마 (user_profiles, age_categories)
  - 초기 데이터 6개 시딩
- **문서화 강화**:
  - 온보딩 개발 가이드
  - 에이전트 아키텍처 문서
  - 화면 설정 스키마 문서
- **개발 자동화 스크립트**:
  - setup-common.sh (공통 설정)
  - setup-docs.sh (문서 생성)

### v4.1 (2025.10.06)
- ➕ **백오피스 추가**: React 기반 관리자 웹 앱
- 📦 **DB 스키마**: ads, analytics 테이블 추가
- 🎯 **기능 확장**: 광고/썸네일 관리, 대시보드

### v4 (2025.10.06)
- 🔧 **실제 구조 반영**: Flutter 단일 앱으로 간소화
- 🎯 **현실적 목표**: MVP 2개월
- 📦 **구조 명확화**: Contexts/Features 분리

### v3 (2025.09.22)
- 하이브리드 구조 (실제와 불일치)

---

✍️ 이 문서는 **실제 프로젝트 구조 기반 Pickly PRD v5.0** (Flutter Mobile + Claude Flow)입니다.