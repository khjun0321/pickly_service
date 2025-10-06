# 📄 Pickly PRD (Flutter Mobile + Web Admin - v4.1)

> **실제 프로젝트 구조 기반 + 백오피스 추가**  
> 마지막 업데이트: 2025.10.06

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

### 실제 구조 (Flutter + React Admin)

```
pickly_service/
├── apps/
│   ├── pickly_mobile/              # Flutter 모바일 앱 (사용자용)
│   │   ├── lib/
│   │   │   ├── main.dart
│   │   │   ├── contexts/           # 도메인 로직 (UI 금지)
│   │   │   │   ├── policy/         # 정책 관련 모델/리포지토리
│   │   │   │   ├── user/           # 사용자 관련 로직
│   │   │   │   └── ad/             # 광고 관련 로직
│   │   │   ├── features/           # 기능별 UI (contexts만 의존)
│   │   │   │   ├── onboarding/     # 온보딩 화면
│   │   │   │   ├── home/           # 홈 피드
│   │   │   │   ├── policy_detail/  # 정책 상세
│   │   │   │   ├── search/         # 검색/필터
│   │   │   │   └── profile/        # 프로필
│   │   │   └── shared/             # 공통 위젯/유틸
│   │   ├── assets/                 # 이미지, 폰트, 아이콘
│   │   │   ├── images/
│   │   │   │   ├── onboarding/
│   │   │   │   └── illustrations/
│   │   │   └── fonts/
│   │   │       └── Pretendard/
│   │   ├── test/                   # 테스트 파일
│   │   └── pubspec.yaml
│   │
│   └── admin/                      # React 백오피스 (관리자용)
│       ├── src/
│       │   ├── components/         # React 컴포넌트
│       │   │   ├── common/         # 공통 컴포넌트
│       │   │   ├── layout/         # 레이아웃 컴포넌트
│       │   │   └── forms/          # 폼 컴포넌트
│       │   ├── pages/              # 페이지
│       │   │   ├── Dashboard.tsx   # 대시보드
│       │   │   ├── PolicyList.tsx  # 정책 목록
│       │   │   ├── PolicyForm.tsx  # 정책 등록/수정
│       │   │   ├── AdList.tsx      # 광고 목록
│       │   │   ├── AdForm.tsx      # 광고 등록/수정
│       │   │   ├── UserList.tsx    # 사용자 목록
│       │   │   └── Analytics.tsx   # 분석 페이지
│       │   ├── hooks/              # 커스텀 훅
│       │   ├── stores/             # 상태 관리
│       │   ├── api/                # API 클라이언트
│       │   └── utils/              # 유틸리티
│       ├── public/
│       ├── package.json
│       └── vite.config.ts
│
├── packages/
│   └── pickly_design_system/       # 디자인 시스템 패키지 (모바일 전용)
│       ├── lib/
│       │   ├── tokens/             # 디자인 토큰
│       │   │   └── design_tokens.dart
│       │   ├── widgets/            # 공통 위젯
│       │   │   ├── buttons/
│       │   │   ├── cards/
│       │   │   └── inputs/
│       │   └── themes/             # Flutter 테마
│       └── pubspec.yaml
│
├── backend/                         # Supabase 설정
│   └── supabase/
│       ├── functions/               # Edge Functions
│       │   ├── policy-sync/        # 정책 데이터 동기화
│       │   ├── image-upload/       # 이미지 업로드 처리
│       │   └── analytics/          # 분석 데이터 집계
│       ├── migrations/              # DB 마이그레이션
│       │   ├── 001_policies.sql
│       │   ├── 002_users.sql
│       │   ├── 003_ads.sql
│       │   └── 004_analytics.sql
│       └── seed/                    # 초기 데이터
│
└── docs/                            # 문서
    ├── prd/
    ├── api/
    └── design-system/
```

### Contexts vs Features 규칙 (모바일 앱)

**Contexts (도메인 로직)**
- UI 코드 금지
- 비즈니스 로직, 모델, 리포지토리만
- 다른 contexts 의존 가능
- Features 의존 **절대 금지**

**Features (UI 레이어)**
- UI/상태/라우팅만
- Contexts만 의존 가능
- 다른 Features 의존 **금지** (shared를 통해야 함)

---

## 7. 기술 스택

### Mobile App (Flutter)
- **Flutter 3.x** - 모바일 앱 개발
- **Riverpod** - 상태관리
- **GoRouter** - 네비게이션
- **Dio** - HTTP 통신
- **Hive** - 로컬 저장소
- **Cached Network Image** - 이미지 캐싱

### Admin Web (React)
- **React 18** - UI 프레임워크
- **TypeScript** - 타입 안전성
- **Vite** - 빌드 도구
- **Zustand** - 상태관리 (가벼움)
- **TanStack Query** - 서버 상태 관리
- **React Hook Form** - 폼 관리
- **MUI (Material-UI)** - UI 컴포넌트
- **React Dropzone** - 파일 업로드
- **React Image Crop** - 이미지 크롭
- **Recharts** - 차트/그래프

### Backend (Supabase)
- **PostgreSQL** - 데이터베이스
- **Supabase Auth** - 인증 (관리자 로그인)
- **Supabase Storage** - 이미지 저장
- **Edge Functions** - 서버리스 함수
- **Row Level Security** - 데이터 보안

### DevOps
- **GitHub Actions** - CI/CD
- **Vercel** - 백오피스 배포
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
- **정적 분석**: Flutter Analyzer, ESLint
- **경계 강제**: Contexts/Features 의존성 검증

---

## 10. 로드맵

### Phase 1: MVP (2개월)

**Week 1-2: 디자인 시스템 & 프로젝트 설정**
- Figma 디자인 토큰 추출 → Dart 코드 변환
- Flutter 프로젝트 세팅
- React Admin 프로젝트 세팅
- Supabase 프로젝트 생성 및 스키마 설계

**Week 3-4: 모바일 - 온보딩 & 인증**
- 온보딩 화면 (조건 입력)
- 로그인/회원가입
- 프로필 설정

**Week 3-4: 백오피스 - 기본 틀**
- 관리자 로그인
- 레이아웃 (사이드바, 헤더)
- 대시보드 기본 화면

**Week 5-6: 모바일 - 정책 피드 & 상세**
- 정책 리스트 UI
- 정책 상세 화면
- 필터링 기능

**Week 5-6: 백오피스 - 콘텐츠 관리**
- 정책 CRUD
- 이미지 업로드 & 썸네일 관리
- 광고 등록 기능

**Week 7-8: 통합 & 배포**
- 모바일: 검색 기능
- 백오피스: 사용자 관리
- 전체 기능 통합 테스트
- 배포 (Vercel + Firebase)

### Phase 2: 핵심 기능 강화 (2개월)
- 모바일: 공고문 분석 AI, 푸시 알림, 북마크
- 백오피스: 분석 대시보드, 광고 성과 추적

### Phase 3: 고도화 (2개월)
- 모바일: AI 추천 개선, 커뮤니티
- 백오피스: 일괄 작업, 고급 분석

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

✍️ 이 문서는 **실제 프로젝트 구조 기반 Pickly PRD v4.1** (모바일 + 백오피스)입니다.