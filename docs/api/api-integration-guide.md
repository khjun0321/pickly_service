# API 통합 실행 가이드

> **작성일**: 2025-10-25
> **버전**: 1.0
> **목적**: 외부 API 통합을 안전하게 자동화하기 위한 실행 가이드

---

## 🎯 목표

이 가이드는 **기존 온보딩 및 혜택 관리 코드에 영향을 주지 않고** 외부 API를 통합하는 방법을 설명합니다.

---

## 📋 사전 준비

### 1. 필수 도구 설치

```bash
# Claude Flow 설치 (필수)
npm install -g @ruv/claude-flow@alpha

# 또는 npx 사용
npx claude-flow@alpha --version
```

### 2. 프로젝트 확인

```bash
cd /path/to/pickly_service/apps/pickly_mobile

# Flutter 환경 확인
flutter doctor

# 현재 앱 정상 작동 확인
flutter run
```

### 3. Git 상태 확인

```bash
# 현재 브랜치 확인
git branch

# 변경사항 확인
git status

# 새 브랜치 생성 (권장)
git checkout -b feature/api-integration
```

---

## 🚀 Phase 1: 공통 API 인프라 구축

### 1-1. 워크플로우 실행

```bash
# 방법 1: Claude Flow 워크플로우 사용 (권장)
npx claude-flow@alpha workflow run api-integration --phase 1

# 방법 2: 에이전트 직접 실행
npx claude-flow@alpha agent run api-integration-builder \
  --input "docs/api/api-integration-spec.md" \
  --phase 1
```

### 1-2. 생성될 파일 목록

```
apps/pickly_mobile/lib/
├── core/
│   ├── network/               ✨ 새로 생성
│   │   ├── api_config.dart    ✨ API URL/Key 관리
│   │   ├── api_client.dart    ✨ Dio 클라이언트 팩토리
│   │   └── api_interceptor.dart ✨ 로깅/에러 변환
│   └── errors/                ✨ 새로 생성
│       └── api_exception.dart ✨ 커스텀 에러 클래스
```

### 1-3. 검증 단계

#### Step 1: 패키지 설치
```bash
cd apps/pickly_mobile
flutter pub get
```

**예상 출력**:
```
Running "flutter pub get" in pickly_mobile...
Got dependencies!
```

#### Step 2: 코드 분석
```bash
flutter analyze
```

**예상 출력**:
```
Analyzing pickly_mobile...
No issues found!
```

#### Step 3: 기존 앱 작동 확인
```bash
flutter run
```

**확인 사항**:
- ✅ 온보딩 화면 정상 작동
- ✅ 혜택 화면 정상 작동 (9개 카테고리)
- ✅ SVG 아이콘 정상 표시
- ✅ 배너 정상 표시

#### Step 4: 생성된 파일 확인
```bash
# 디렉토리 구조 확인
tree lib/core/network lib/core/errors

# 파일 내용 확인
cat lib/core/network/api_config.dart
cat lib/core/network/api_client.dart
```

### 1-4. Phase 1 성공 기준

- [x] `core/network/` 폴더 생성됨
- [x] `core/errors/` 폴더 생성됨
- [x] 4개 파일 모두 생성됨
- [x] `flutter analyze` 에러 없음
- [x] **기존 온보딩 화면 정상 작동**
- [x] **기존 혜택 화면 정상 작동** (9개 카테고리)

---

## 🚀 Phase 2: LH API 통합

### 2-1. Phase 1 완료 확인

Phase 2는 Phase 1이 완료되어야만 실행 가능합니다.

```bash
# Phase 1 파일 존재 확인
test -f lib/core/network/api_config.dart && \
test -f lib/core/network/api_client.dart && \
test -f lib/core/network/api_interceptor.dart && \
test -f lib/core/errors/api_exception.dart && \
echo "✅ Phase 1 완료" || echo "❌ Phase 1 파일 누락"
```

### 2-2. 워크플로우 실행

```bash
# 방법 1: Claude Flow 워크플로우 사용 (권장)
npx claude-flow@alpha workflow run api-integration --phase 2

# 방법 2: 에이전트 직접 실행
npx claude-flow@alpha agent run api-integration-builder \
  --input "docs/api/api-integration-spec.md" \
  --phase 2
```

### 2-3. 생성될 파일 목록

```
apps/pickly_mobile/lib/
├── contexts/
│   └── housing/                      ✨ 새로 생성
│       ├── models/
│       │   └── lh_announcement.dart  ✨ LH 공고 모델
│       └── repositories/
│           └── lh_repository.dart    ✨ LH API 호출 로직
│
└── features/
    └── housing/                      ✨ 새로 생성
        ├── providers/
        │   └── housing_provider.dart ✨ Riverpod 상태 관리
        └── screens/
            └── housing_list_screen.dart ✨ 공고 목록 화면
```

### 2-4. 검증 단계

#### Step 1: 테스트 실행
```bash
flutter test
```

**예상 출력**:
```
00:02 +5: All tests passed!
```

#### Step 2: 앱 실행 및 확인
```bash
flutter run
```

**확인 사항**:
- ✅ 온보딩 화면 정상 작동
- ✅ 혜택 화면 정상 작동 (9개 카테고리)
- ✅ 주거 카테고리에서 LH 공고 목록 표시 (라우팅 추가 시)

#### Step 3: API 호출 테스트 (선택)
```bash
# 수동 테스트 (임시 테스트 파일 생성)
cat > test/housing_api_test.dart <<'EOF'
import 'package:flutter_test/flutter_test.dart';
import 'package:pickly_mobile/contexts/housing/repositories/lh_repository.dart';

void main() {
  test('LH Repository can fetch announcements', () async {
    final repository = LhRepository();
    final result = await repository.fetchAnnouncements();
    expect(result, isNotNull);
  });
}
EOF

flutter test test/housing_api_test.dart
```

### 2-5. Phase 2 성공 기준

- [x] `contexts/housing/` 폴더 생성됨
- [x] LH 모델과 Repository 생성됨
- [x] API 호출 테스트 통과
- [x] 에러 핸들링 정상 작동
- [x] **기존 모든 기능 정상 작동**

---

## 🔐 보호된 파일 목록

**절대 수정되지 않아야 하는 파일들**:

```
contexts/user/**
contexts/benefit/**
features/onboarding/**
features/benefits/**
core/router.dart
core/supabase_config.dart
packages/pickly_design_system/**
```

### 보호 확인 방법

```bash
# Git diff로 보호된 파일 변경 확인
git diff --name-only | grep -E "(contexts/user|contexts/benefit|features/onboarding|features/benefits|core/router.dart|core/supabase_config.dart|packages/pickly_design_system)"

# 출력이 없으면 ✅ 안전
# 출력이 있으면 ❌ 롤백 필요
```

---

## 🚨 문제 해결

### 문제 1: `flutter pub get` 실패

**증상**:
```
Because pickly_mobile depends on dio ^5.4.0 which doesn't exist...
```

**해결**:
```bash
# pubspec.yaml 확인
cat pubspec.yaml | grep dio

# dio 버전 변경
# pubspec.yaml에서 dio: ^5.4.0 → dio: ^5.3.0으로 변경
flutter pub get
```

### 문제 2: `flutter analyze` 에러

**증상**:
```
error • Undefined name 'Dio' • lib/core/network/api_client.dart:4:12
```

**해결**:
```bash
# Import 확인
grep -n "import 'package:dio/dio.dart';" lib/core/network/api_client.dart

# Import 누락 시 추가
```

### 문제 3: 기존 기능 작동 안 함

**증상**:
- 온보딩 화면이 안 나옴
- 혜택 화면에서 에러 발생

**해결**:
```bash
# 1. Git으로 변경사항 확인
git status

# 2. 보호된 파일이 수정되었는지 확인
git diff contexts/user/
git diff features/onboarding/

# 3. 수정되었다면 즉시 롤백
git checkout HEAD -- contexts/user/
git checkout HEAD -- features/onboarding/
git checkout HEAD -- features/benefits/

# 4. 앱 재시작
flutter run
```

### 문제 4: API 호출 실패

**증상**:
```
DioException [unknown]: null
```

**해결**:

1. **API Key 확인**:
```dart
// lib/core/network/api_config.dart
static const String lhApiKey = 'YOUR_LH_API_KEY'; // ❌ 실제 키로 변경 필요
```

2. **네트워크 권한 확인**:
```bash
# Android: android/app/src/main/AndroidManifest.xml
<uses-permission android:name="android.permission.INTERNET"/>

# iOS: ios/Runner/Info.plist
<key>NSAppTransportSecurity</key>
<dict>
  <key>NSAllowsArbitraryLoads</key>
  <true/>
</dict>
```

3. **인터셉터 로그 확인**:
```bash
flutter run --verbose | grep "API Request"
```

---

## 📊 롤백 절차

만약 작업 중 문제가 발생하면:

### 1. 긴급 롤백 (새 파일만 제거)

```bash
# 생성된 파일 삭제
rm -rf lib/core/network
rm -rf lib/core/errors
rm -rf lib/contexts/housing
rm -rf lib/features/housing

# pubspec.yaml에서 dio 제거
git checkout HEAD -- pubspec.yaml

# 패키지 재설치
flutter pub get

# 앱 재시작
flutter run
```

### 2. Git 롤백 (커밋 후인 경우)

```bash
# 최근 커밋 취소 (변경사항은 유지)
git reset --soft HEAD~1

# 또는 완전 롤백
git reset --hard HEAD~1

# 강제 푸시 (원격에 푸시했다면)
git push --force
```

### 3. 선택적 롤백 (일부만 되돌리기)

```bash
# 특정 파일만 되돌리기
git checkout HEAD -- lib/core/network/api_config.dart

# 특정 폴더만 되돌리기
git checkout HEAD -- lib/contexts/housing/
```

---

## ✅ 성공 후 다음 단계

### 1. Git 커밋

```bash
git add .
git commit -m "feat(api): implement Phase 1 & 2 API integration

- Add core network infrastructure (api_config, api_client, interceptor)
- Add custom API exception classes
- Add LH housing announcement models and repository
- Add housing provider and list screen
- Protect existing onboarding and benefits code

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>"
```

### 2. Phase 3 준비 (복지 도메인)

Phase 2가 성공적으로 완료되면, 같은 패턴으로 다른 도메인을 추가할 수 있습니다:

```bash
# 복지 도메인 추가 (예정)
npx claude-flow@alpha workflow run api-integration --domain welfare

# 교육 도메인 추가 (예정)
npx claude-flow@alpha workflow run api-integration --domain education
```

### 3. 라우팅 추가

주거 화면을 실제 앱에 연결하려면 라우터에 추가:

```dart
// lib/core/router.dart (수동 편집)
GoRoute(
  path: '/housing',
  builder: (context, state) => const HousingListScreen(),
),
```

---

## 📚 관련 문서

- [API 통합 스펙](./api-integration-spec.md) - API 통합 구조 및 규칙
- [카테고리 동기화 가이드](../category-sync-guide.md) - 카테고리 관리 가이드
- [개발 베스트 프랙티스](../development-best-practices.md) - 안전한 개발 가이드
- [Claude Flow Agent 설정](../../.claude/agents/specialists/api-integration-builder.md) - 에이전트 설정

---

## 🔗 외부 참고 자료

- [Flutter Dio 패키지](https://pub.dev/packages/dio)
- [Repository 패턴](https://docs.flutter.dev/data-and-backend/state-mgmt/options#repository-pattern)
- [LH 공사 오픈API](https://www.lh.or.kr/) (실제 API 문서 확인 필요)

---

**작성자**: Claude Code
**최종 업데이트**: 2025-10-25
**버전**: 1.0
