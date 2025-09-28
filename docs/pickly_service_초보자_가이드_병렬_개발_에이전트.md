# pickly\_service 초보자 가이드 (병렬 개발 + 에이전트)

> 대상: **완전 초보자** / 에디터: **Windsurf** / 프레임워크: **Flutter** / 오케스트레이션: **Claude-Flow**\
> 목적: **문서(PRD/DS/API)만 업로드하면 에이전트가 구조·앱·백엔드·테스트·PR까지 병렬로 진행**하도록 세팅

---

## 0. 한눈에 보기

- **내가 할 일**: 문서 업로드(PRD, 디자인 토큰, API 스펙), 피처 시작, PR 승인
- **에이전트가 할 일**: 구조 생성(모노레포/폴더), Flutter 화면 스캐폴드, 테스트 템플릿, PR/리뷰/CI 연계
- **브랜치 전략**: `feature/*` (개발), `docs/*` (문서), `release/*` (릴리즈)
- **TDD 게이트**: 테스트 통과 + 상태체크 통과한 PR만 `main` 머지

---

## 1. 준비물 설치 (왜/어디서/무엇을)

**왜**: 에이전트가 돌아가려면 Claude Code + Claude‑Flow 실행 환경이 필요

**어디서**: Windsurf의 터미널 (또는 맥 터미널)

**무엇을**: Node, Claude Code, Claude‑Flow 설치 + MCP 등록

```bash
# 버전 확인 (Node 18+, npm 9+ 권장)
node --version
npm --version

# Claude Code 설치
npm install -g @anthropic-ai/claude-code
claude --version

# Claude-Flow 설치(alpha 가능)
npm install -g claude-flow@alpha
claude-flow --version

# Claude Code에 Claude-Flow를 MCP 서버로 등록
claude mcp add claude-flow "npx claude-flow@alpha mcp start"
claude mcp list
```

> **문제 발생시**: `npm cache clean --force`, 재설치, `claude mcp list`로 등록 확인

---

## 2. 리포지토리 시드 (최소 작업)

**왜**: 에이전트가 스스로 움직이려면 “씨앗 파일”이 필요

**어디서**: `~/Desktop/pickly_service`

**무엇을**: 깃 초기화 + 에이전트/워크플로우 씨앗 3개 파일 생성

```bash
# 폴더 만들기
mkdir -p ~/Desktop/pickly_service && cd ~/Desktop/pickly_service

# 깃 초기화
git init

# 디렉토리 준비
mkdir -p .claude/agents/core .claude/workflows
```

### 2-1) 코디네이터(하이브 총괄)

**경로**: `./.claude/agents/core/mesh-coordinator.md`

```md
---
name: pickly_service-mesh-coordinator
type: coordinator
description: "pickly_service 병렬 개발 총괄(구조/앱/백엔드/문서/PR/TDD 게이트)"
capabilities: [parallel_orchestration, task_decomposition]
priority: high
memory: true
---
규칙:
- Flutter 우선.
- 문서/DS 없으면 '요청 이슈' 생성 + 임시 스켈레톤으로 진행.
```

### 2-2) 구조 담당 에이전트(자동 스캐폴드 핵심)

**경로**: `./.claude/agents/core/struct-architect.md`

```md
---
name: pickly_service-struct-architect
type: developer
description: "모노레포 뼈대/폴더/라우팅/멜로스, 앱·패키지 골격 자동 생성"
capabilities: [repo_scaffold, routing_convention, file_ops, shell_exec]
priority: high
---
목표:
1) 아래 트리를 자동 생성(없으면 만들고, 있으면 보정)
   - contexts/** (도메인 로직), features/** (UI/상태/라우팅)
   - docs/{prd,api,design-system}
   - apps/pickly_mobile (flutter create)
   - packages/pickly_design_system (flutter package)
   - melos.yaml + .gitignore + README.md
2) Flutter 라우팅/폴더 표준 스캐폴드
3) melos bootstrap 안내 및 스크립트 생성
4) 이후 TDD/PR 에이전트 파일 생성 PR 제안 남기기
```

### 2-3) 부트스트랩 워크플로우(한 줄 실행)

**경로**: `./.claude/workflows/pickly_service-bootstrap.yml`

```yaml
name: pickly_service-bootstrap
coordinator: pickly_service-mesh-coordinator
parallel: false
memory: true
tasks:
  - agent: pickly_service-struct-architect
    goal: |
      pickly_service 초기 구조를 자동 생성:
      - .gitignore(Dart/Flutter/Node) 작성
      - contexts/**, features/**, docs/{prd,api,design-system} 생성
      - apps/pickly_mobile 없으면 flutter create
      - packages/pickly_design_system 없으면 flutter package 생성
      - melos.yaml 생성 후 bootstrap 스크립트 파일 추가
      - README.md(작동방법) 작성
      - 다음 단계로 TDD 게이트/PR 매니저 에이전트 파일도 생성하는 PR 제안 남기기
```

**커밋**

```bash
git add .claude
git commit -m "chore: seed agents & bootstrap workflow for structure auto-generation"
```

---

## 3. 최소 문서 6종 만들기 (에이전트 트리거)

**왜**: 문서가 들어오면 관련 에이전트가 자동 동기화/스캐폴드 강화

**어디서**: `~/Desktop/pickly_service`

**무엇을**: PRD/DS/API/아키텍처/테스트 문서 뼈대 생성

```bash
mkdir -p docs/{prd,api,design-system,arch,dev}

# 1) 제품 개요(PRD)
cat > docs/prd/overview.md <<'MD'
# Pickly PRD Overview
- 문제/타깃/가치/KPI 요약을 적어주세요
MD

# 2) 기능별 PRD: 필터
cat > docs/prd/features_filter.md <<'MD'
# Feature: Filter
- 사용자 흐름 / 수용조건(AC) / 에러 케이스
MD

# 3) 디자인 토큰(JSON)
cat > docs/design-system/tokens.json <<'JSON'
{ "color":{"primary":"#60ACFF","bg":"#F5F7F9","text":"#313133"}, "typography":{"body":{"size":16,"lineHeight":24}} }
JSON

# 4) API 스펙: 필터
cat > docs/api/filter.md <<'MD'
# API: GET /benefits?region&age&household
- 요청/응답/에러/예시
MD

# 5) 아키텍처 개요
cat > docs/arch/architecture.md <<'MD'
# Architecture
- 앱/백엔드/에이전트/CI 흐름 다이어그램(텍스트로 초안)
MD

# 6) 테스트 전략(TDD 게이트)
cat > docs/dev/testing.md <<'MD'
# Testing Strategy
- 위젯/유닛/골든 테스트 구분
- 커버리지 하한: 60%부터 시작
MD
```

**커밋**

```bash
git add docs
git commit -m "docs: add minimal PRD/DS/API/ARCH/TESTING skeletons"
```

---

## 4. 구조 자동 생성 실행 (부트스트랩)

**왜**: 네가 폴더를 일일이 만들지 않아도 됨 (앱/패키지/contexts/features/docs 등)

**어디서**: 리포 루트 `~/Desktop/pickly_service`

**무엇을**: 부트스트랩 워크플로우 실행

```bash
claude-flow orchestrate --workflow .claude/workflows/pickly_service-bootstrap.yml
```

> 실행 후 기대 결과:
>
> - `apps/pickly_mobile` (Flutter 앱), `packages/pickly_design_system` (공유 패키지)
> - `contexts/**`, `features/**`, `docs/**`
> - `melos.yaml`, `.gitignore`, `README.md` 등 자동 생성/보정

---

## 5. 병렬 개발 워크플로우 준비(선택)

**왜**: 화면/백엔드/문서/TDD/PR을 한 번에 병렬 실행

**어디서**: `.claude/workflows`

**무엇을**: 병렬 워크플로우 파일 생성

```bash
cat > .claude/workflows/pickly_service-parallel.yml << 'YAML'
name: pickly_service-parallel
coordinator: pickly_service-mesh-coordinator
parallel: true
memory: true
tasks:
  - agent: pickly_service-struct-architect
    goal: "구조 일관성 검증 & 누락 폴더 자동 보정 (contexts/features/docs)"
  - agent: pickly_service-flutter-ui-coder
    goal: "features/filter 스캐폴드 + 라우팅/상태 템플릿 생성"
  - agent: pickly_service-design-system-bot
    goal: "docs/design-system/ 문서 있으면 토큰 매핑, 없으면 임시 토큰 생성"
  - agent: pickly_service-supabase-wire
    goal: "docs/api/filter.md 없으면 초안 작성, 있으면 Supabase 스키마/RPC 제안"
  - agent: pickly_service-prd-writer
    goal: "docs/prd/features_filter.md 보강(AC/흐름/데이터 계약)"
  - agent: pickly_service-tdd-guardian
    goal: "apps/pickly_mobile/test/ 템플릿 생성 + 테스트 실행 가이드"
  - agent: pickly_service-pr-manager
    goal: "feature/filter 브랜치 PR 오픈 + 상태체크 요구"
YAML

git add .claude/workflows/pickly_service-parallel.yml
git commit -m "chore: add pickly_service parallel workflow"
```

**실행**

```bash
claude-flow orchestrate --workflow .claude/workflows/pickly_service-parallel.yml
```

---

## 6. 기능 시작: Git worktree + feature 브랜치

**왜**: 병렬 개발 & main 보호

**어디서**: 리포 루트 `~/Desktop/pickly_service`

**무엇을**: worktree로 분리 디렉토리에서 개발

```bash
# 메인 기반 보장
git branch -M main

# 필터 기능용 워크트리
cd ~/Desktop
git worktree add ./pickly_service_feature_filter ~/Desktop/pickly_service feature/filter || \
  (cd ~/Desktop/pickly_service && git checkout -b feature/filter && \
   git worktree add ../pickly_service_feature_filter feature/filter)

cd ~/Desktop/pickly_service_feature_filter

# 병렬 워크플로우로 자동 작업 진행
claude-flow orchestrate --workflow .claude/workflows/pickly_service-parallel.yml
```

---

## 7. 로컬 테스트 실행 (TDD 게이트 사전 점검)

**어디서**: `~/Desktop/pickly_service_feature_filter/apps/pickly_mobile`

```bash
flutter pub get
flutter test
```

> 실패 시: 수정 → 재실행. 통과하면 PR

---

## 8. PR 생성 & 리뷰 & 머지

**어디서**: 워크트리 디렉토리

```bash
git add .
git commit -m "feat(filter): scaffold via agents"
git push -u origin feature/filter
```

- GitHub에서 PR 열림 → `reviewer`/`tdd-guardian` 에이전트가 리뷰/체크
- **브랜치 보호**(리포 Settings → Branches → `main` 보호):
  - Require PR reviews
  - Require status checks to pass before merging (Flutter CI)

---

## 9. CI/TDD 설정(요약)

**어디서**: `.github/workflows/flutter-ci.yml`

```yaml
name: Flutter CI (TDD Gate)
on: [pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - name: Enforce coverage ≥ 60%
        shell: bash
        run: |
          LH=$(grep -h "^LH:" coverage/lcov.info | awk -F: '{s+=$2} END {print s+0}')
          LF=$(grep -h "^LF:" coverage/lcov.info | awk -F: '{s+=$2} END {print s+0}')
          if [ -z "$LF" ] || [ "$LF" -eq 0 ]; then PCT=0; else PCT=$(( 100 * LH / LF )); fi
          echo "coverage=${PCT}%"
          test $PCT -ge 60
```

커밋 후, 브랜치 보호의 **필수 체크**로 등록하면 **테스트 통과 전 머지 불가**

### 9.1 브랜치 보호(메인 머지 게이트)

**UI 경로**: GitHub → Repository → **Settings** → **Branches** → **Branch protection rules**

1. **Add rule** → Branch name pattern: `main`
2. **Require a pull request before merging** 체크(승인 1명 이상)
3. **Require status checks to pass before merging** 체크 → 목록에서 `Flutter CI (TDD Gate)` 선택
4. (선택) **Require linear history**

> 선택: \*\*GitHub CLI(gh)\*\*로 보호 설정 (원하면 사용)

```bash
# gh auth login 후 사용
OWNER=<your_id>; REPO=pickly_service
# 예시: 최소 옵션만 적용
gh api \
  -X PUT \
  repos/$OWNER/$REPO/branches/main/protection \
  -f required_status_checks.strict=true \
  -f enforce_admins=true \
  -F required_status_checks.contexts[]='Flutter CI (TDD Gate)'
```

### 9.2 메인 머지 시 배포(예시)

**어디서**: `.github/workflows/release-on-main.yml`

```yaml
name: Release on main
on:
  push:
    branches: [ main ]
jobs:
  build-android:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
      - run: flutter build appbundle
      - uses: actions/upload-artifact@v4
        with: { name: appbundle, path: build/app/outputs/bundle/release/*.aab }
  # iOS 빌드/배포, Supabase 배포 스텝은 추후 추가 가능
```

---

## 10. 일일 루틴 치트시트

```bash
# 1) 문서 뼈대/수정 → 커밋
vim docs/prd/features_filter.md

# 2) 병렬 워크 실행
claude-flow orchestrate --workflow .claude/workflows/pickly_service-parallel.yml

# 3) Flutter 테스트
cd apps/pickly_mobile && flutter test && cd -

# 4) PR 올리기
git add . && git commit -m "feat(x): ..." && git push -u origin feature/x
```

---

## 11. Contexts & Features 분리 (매우 중요)

**왜**: UI(Features)와 도메인 로직(Contexts)을 분리하면 테스트/유지보수가 쉬워지고, 병렬 개발 시 충돌이 줄어듭니다.
**어디서**: `apps/pickly_mobile/lib/`
**무엇을**: Contexts=도메인 로직, Features=UI/상태/라우팅. 교차 import 금지.

### 11.1 폴더 구조 예시

```
apps/pickly_mobile/lib/
├─ app.dart
├─ router.dart
├─ contexts/                      # 도메인 로직 (UI 금지)
│  ├─ benefits/
│  │  ├─ models/benefit.dart
│  │  ├─ repository/benefit_repository.dart
│  │  └─ services/benefit_service.dart
│  └─ user/
│     └─ ...
└─ features/                      # UI/상태/라우팅
   ├─ onboarding/
   │  ├─ presentation/
   │  ├─ controller/
   │  └─ widgets/
   └─ filter/
      ├─ presentation/filter_page.dart
      ├─ controller/filter_controller.dart
      └─ widgets/
```

### 11.2 경계 강제 스크립트 (CI에서 자동 검사)

**경로**: `scripts/enforce-boundaries.sh`

```bash
#!/usr/bin/env bash
set -euo pipefail

# 금지1: features → 다른 features 직접 import(상대경로)
BAD=$(grep -R -nE "import\s+([\"'])\.\.\/\.\.\/features\/" apps/pickly_mobile/lib/features || true)
# 금지2: features → 다른 features 패키지 import
BAD3=$(grep -R -nE "import\s+([\"'])package:.*\/features\/" apps/pickly_mobile/lib/features || true)
# 금지3: contexts → features import 전면 금지
BAD2=$(grep -R -nE "import\s+([\"']).*\/features\/" apps/pickly_mobile/lib/contexts || true)

if [ -n "$BAD" ] || [ -n "$BAD2" ] || [ -n "$BAD3" ]; then
  echo "[BOUNDARY] 경계 위반이 발견되었습니다.";
  [ -n "$BAD" ]  && { echo "-- features 상대경로 위반:"; echo "$BAD";  };
  [ -n "$BAD3" ] && { echo "-- features 패키지 import 위반:"; echo "$BAD3"; };
  [ -n "$BAD2" ] && { echo "-- contexts→features 위반:"; echo "$BAD2"; };
  exit 1;
fi

echo "[BOUNDARY] OK — 경계 위반 없음"
```

**권한/커밋**

```bash
mkdir -p scripts
chmod +x scripts/enforce-boundaries.sh
git add scripts/enforce-boundaries.sh
git commit -m "chore(boundary): add contexts/features boundary enforcement script"
```

**CI에 추가(선택)** — `Flutter CI (TDD Gate)` 잡에 스텝 추가

```yaml
- name: Enforce Context/Feature boundaries
  run: scripts/enforce-boundaries.sh
```

---

## 12. TDD Guardian 에이전트 (PR 수문장)

**왜**: 테스트 기반으로 PR 품질을 강제하여, 메인(main) 안정성을 지킵니다.
**어디서**: `./.claude/agents/core/tdd-guardian.md`
**무엇을**: 테스트 템플릿 생성, 테스트 실행/커버리지 보고, 실패 시 코멘트.

**에이전트 파일**

```md
---
name: pickly_service-tdd-guardian
type: tester
description: "TDD 게이트: 테스트(위젯/유닛/골든) 통과해야만 PR 승인"
capabilities: [test_template, run_tests, coverage_report]
priority: high
---
정책:
- 실패 테스트 → 수정 요청 코멘트 남김
- 커버리지 하한: 60% (점진 상향)
출력:
- apps/pickly_mobile/test/**
```

**커밋**

```bash
git add .claude/agents/core/tdd-guardian.md
git commit -m "chore(tdd): add TDD guardian agent (coverage gate)"
```

### 12.1 Flutter CI에 커버리지 강제 예시

**경로**: `.github/workflows/flutter-ci.yml`

```yaml
name: Flutter CI (TDD Gate)
on: [pull_request]
jobs:
  test:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with: { channel: stable }
      - run: flutter pub get
      - run: flutter analyze
      - run: flutter test --coverage
      - name: Enforce coverage ≥ 60%
        shell: bash
        run: |
          LH=$(grep -h "^LH:" coverage/lcov.info | awk -F: '{s+=$2} END {print s+0}')
          LF=$(grep -h "^LF:" coverage/lcov.info | awk -F: '{s+=$2} END {print s+0}')
          if [ -z "$LF" ] || [ "$LF" -eq 0 ]; then PCT=0; else PCT=$(( 100 * LH / LF )); fi
          echo "coverage=${PCT}%"; test $PCT -ge 60
```

**브랜치 보호 설정**(요약): GitHub → Settings → Branches → `main` 규칙 추가 → "Require status checks"에 **Flutter CI (TDD Gate)** 지정

---

## 13. Git Worktree로 병렬 개발 (feature/\*)

**왜**: 기능마다 **독립 디렉토리**로 작업하여 충돌/컨텍스트 전환 비용을 줄이고, 에이전트가 브랜치 별로 작업하기 쉽게 합니다.
**어디서**: 리포 루트 `~/Desktop/pickly_service` 및 바깥 디렉토리
**무엇을**: feature 브랜치 생성/작업/정리 루틴.

### 13.1 생성 & 작업 시작

```bash
# 메인 보정
git branch -M main

# 필터 기능용 워크트리 생성(루트 바깥 경로 추천)
cd ~/Desktop
git worktree add ./pickly_service_feature_filter ~/Desktop/pickly_service feature/filter || \
  (cd ~/Desktop/pickly_service && git checkout -b feature/filter && \
   git worktree add ../pickly_service_feature_filter feature/filter)

# 작업 디렉토리로 이동
cd ~/Desktop/pickly_service_feature_filter

# 병렬 워크플로우 실행(필요 시)
claude-flow orchestrate --workflow .claude/workflows/pickly_service-parallel.yml
```

### 13.2 로컬 테스트 → PR 올리기

```bash
# 테스트(사전 점검)
cd apps/pickly_mobile
flutter pub get
flutter test
cd -

# 커밋/푸시/PR 생성
git add .
git commit -m "feat(filter): scaffold via agents"
git push -u origin feature/filter
```

### 13.3 머지 후 정리

```bash
# 워크트리 목록
git worktree list

# 머지 완료 후 제거
git worktree remove ../pickly_service_feature_filter
# 로컬 브랜치 정리
git branch -d feature/filter
```

> 팁: 동시에 여러 기능을 진행하면 워크트리 경로를 기능명으로 명확히 해주세요.

---

## 14. 트러블슈팅(Quick Fix)

* **MCP 인식 안 됨**: `claude mcp list` → 없으면 `claude mcp add "npx claude-flow@alpha mcp start"` 재등록
* **권한/버전 꼬임**: `npm cache clean --force` 후 `@anthropic-ai/claude-code`/`claude-flow` 재설치
* **Flutter 오류**: `flutter doctor` / `flutter clean` / `flutter pub get`
* **테스트 실패**: 실패 로그 확인 → 관련 파일 수정 → `flutter test` 재실행
* **경계 위반**: `scripts/enforce-boundaries.sh` 로컬 실행 또는 CI 로그 확인

---

### 부록 A. 일일 루틴 치트시트

```bash
# 1) 문서(PRD/DS/API) 수정 → 커밋
git add docs && git commit -m "docs: update prd/design-system/api"

# 2) 병렬 워크 실행
claude-flow orchestrate --workflow .claude/workflows/pickly_service-parallel.yml

# 3) Flutter 테스트
cd apps/pickly_mobile && flutter test && cd -

# 4) PR 올리기
git add . && git commit -m "feat(x): ..." && git push -u origin feature/x
```
