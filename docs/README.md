# Pickly 문서

> **프로젝트 문서 허브**

---

## 📚 문서 목록

### 개발 가이드
- [온보딩 화면 개발 가이드](development/onboarding-development-guide.md) ⭐
  - 공통 에이전트 + 설정 기반 개발 방식
  - 새 화면 추가 방법
  - UI 타입별 설정
  - SelectionListItem 사용 예시 🆕
  - Figma 워크플로우 🆕

### 아키텍처
- [공통 에이전트 아키텍처](architecture/common-agent-architecture.md) ⭐
  - 재사용 가능한 구조
  - 에이전트 목록
  - 워크플로우 설명
- [온보딩 아키텍처](architecture/onboarding-architecture.md) 🆕
  - Contexts/Features 분리 구조
  - Provider 패턴 설명
  - Widget 재사용 전략
  - Figma assets 통합 방식

### API & 스키마
- [화면 설정 파일 스키마](api/screen-config-schema.md) ⭐
  - JSON 설정 정의
  - 타입별 옵션
  - 전체 예시

### 프로젝트 문서
- [PRD (Product Requirements Document)](PRD.md)
  - 제품 요구사항 정의
  - 기능 목록
  - 로드맵
  - v5.1 업데이트 (2025.10.11) 🆕

---

## 🚀 Quick Start

### 1️⃣ 사전 요구사항

- **Flutter SDK**: 3.16.0 이상
- **Docker Desktop**: Supabase 로컬 실행용
- **Node.js**: 18.0 이상 (Claude Flow용)
- **Supabase CLI**: 설치 방법은 아래 참고

### 2️⃣ 저장소 클론 및 초기 설정

```bash
# 저장소 클론
git clone https://github.com/kwonhyunjun/pickly-service.git
cd pickly-service

# Supabase CLI 설치
brew install supabase/tap/supabase  # Mac
# 또는
npm install -g supabase              # Windows/Linux

# Claude CLI 설치 (선택사항, Claude Flow 사용 시)
npm install -g @anthropic-ai/claude-code
npm install -g claude-flow
```

### 3️⃣ Supabase 로컬 서버 시작

```bash
# Supabase 디렉토리로 이동
cd backend/supabase

# 로컬 서버 시작 (첫 실행 시 Docker 이미지 다운로드)
supabase start

# 마이그레이션 적용 및 초기 데이터 삽입
supabase db reset

# 서버 상태 확인
supabase status
```

**예상 출력:**
```
API URL: http://127.0.0.1:54321
Studio URL: http://127.0.0.1:54323
DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
```

브라우저에서 http://127.0.0.1:54323 접속하여 Supabase Studio 확인 가능

### 4️⃣ Flutter 앱 실행

```bash
# 프로젝트 루트로 복귀
cd ../..

# Flutter 앱 디렉토리로 이동
cd apps/pickly_mobile

# 의존성 설치
flutter pub get

# 앱 실행 (iOS 시뮬레이터 또는 Android 에뮬레이터)
flutter run
```

### 5️⃣ Claude Flow로 새 화면 개발 (선택사항)

```bash
# 프로젝트 루트에서
claude-flow orchestrate --workflow .claude/workflows/onboarding-universal.yml --screen 003

# 또는 수동으로 에이전트 확인
cat .claude/agents/core/onboarding-coordinator.md
```

---

## 📚 주요 문서

### 개발 가이드
- [온보딩 화면 개발 가이드](./development/onboarding-development-guide.md)
- [Claude Flow 에이전트 사용법](./development/claude-flow-guide.md) (작성 예정)

### 아키텍처
- [에이전트 아키텍처](./architecture/common-agent-architecture.md)
- [Supabase 스키마](./architecture/supabase-schema.md) (작성 예정)

### API
- [화면 설정 스키마](./api/screen-config-schema.md)
- [Supabase API 가이드](./api/supabase-api.md) (작성 예정)

---

## 📊 현재 개발 현황 (2025.10.11)

### ✅ 완료된 작업

**온보딩 시스템 기반**:
- Supabase 로컬 환경 구축 ✅
- age_categories 테이블 및 RLS 정책 ✅
- 6개 연령/세대 카테고리 초기 데이터 시딩 ✅

**003 화면 (연령/세대 선택)** ✅:
- SelectionListItem 공통 위젯 구현
- Figma 아이콘 연동 (SVG 지원)
- Realtime 구독으로 즉시 반영
- 다중 선택 상태 관리
- Provider 기반 상태 관리

**공통 컴포넌트**:
- SelectionCard (카드형 선택) ✅
- SelectionListItem (리스트형 선택) ✅
- OnboardingHeader (단계 표시) ✅
- NextButton (다음 버튼) ✅

**문서화**:
- 온보딩 개발 가이드 ✅
- 공통 에이전트 아키텍처 ✅
- 온보딩 아키텍처 문서 🆕
- PRD v5.1 업데이트 🆕

### 🔄 진행 중

- 001 화면 (개인정보 입력) 구현
- 002 화면 (지역 선택) 구현
- 온보딩 플로우 통합 및 네비게이션

### 📅 다음 단계

- 004 화면 (소득 구간 선택)
- 005 화면 (관심 정책 선택)
- 정책 피드 화면 개발
- 정책 상세 화면 개발

---

## 🛠️ 개발 워크플로우

### 새 화면 추가하기

1. **화면 설정 JSON 작성**
```bash
nano .claude/screens/004-new-screen.json
```

2. **Claude Flow 실행**
```bash
claude-flow orchestrate --workflow .claude/workflows/onboarding-universal.yml --screen 004
```

3. **생성된 코드 확인**
```bash
# Flutter 화면
cat apps/pickly_mobile/lib/features/onboarding/screens/new_screen.dart

# Provider
cat apps/pickly_mobile/lib/features/onboarding/providers/new_screen_provider.dart

# Repository
cat apps/pickly_mobile/lib/contexts/user/repositories/new_repository.dart
```

4. **테스트 실행**
```bash
cd apps/pickly_mobile
flutter test
```

### 수동 개발 (Claude Flow 없이)

1. contexts/ 에 모델과 리포지토리 작성
2. features/ 에 화면과 위젯 작성
3. Riverpod Provider로 상태 관리
4. test/ 에 테스트 작성

---

## 🐛 문제 해결

### Supabase 연결 안 됨
```bash
# 서버 상태 확인
supabase status

# 재시작
supabase stop
supabase start
```

### Flutter 오류
```bash
flutter clean
flutter pub get
flutter run
```

### Docker 관련 오류
- Docker Desktop이 실행 중인지 확인
- Docker Desktop 재시작

---

## 📖 학습 경로

### 초보자
1. [온보딩 개발 가이드](development/onboarding-development-guide.md) 읽기
2. 003 화면 설정 파일 분석
3. 새 화면 하나 만들어보기

### 중급자
1. [공통 에이전트 아키텍처](architecture/common-agent-architecture.md) 이해
2. 커스텀 UI 타입 추가
3. 에이전트 로직 확장

### 고급자
1. 새 에이전트 작성
2. 워크플로우 최적화
3. 병렬 처리 개선

---

## 🔗 외부 링크

- [GitHub Repository](https://github.com/kwonhyunjun/pickly-service)
- [Figma Design](https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly)
- [Supabase Docs](https://supabase.com/docs)
- [Claude Flow](https://docs.anthropic.com/claude/docs/claude-flow)

---

## 💡 기여하기

문서 개선 아이디어가 있으신가요?

1. 이슈 생성
2. PR 제출
3. 또는 팀에 직접 제안

모든 기여를 환영합니다! 🎉
