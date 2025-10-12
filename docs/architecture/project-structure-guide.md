# Pickly Mobile 프로젝트 구조 가이드

> **마지막 업데이트**: 2025.10.12 (v5.3)

---

## 📌 개요

본 문서는 Pickly Mobile 앱의 프로젝트 구조와 파일 배치 규칙을 설명합니다.
신규 개발자가 프로젝트를 이해하고 일관된 방식으로 개발할 수 있도록 가이드를 제공합니다.

---

## 🏗️ 아키텍처 원칙

### 1. Domain-Driven Design (DDD)

Pickly는 도메인 주도 설계를 기반으로 합니다:

**Contexts (도메인 경계)**:
- 비즈니스 로직과 규칙이 존재하는 영역
- UI와 독립적으로 동작
- 예: User Context, Policy Context, Filter Context

**Features (기능 모듈)**:
- 사용자 인터페이스 및 프레젠테이션 로직
- Contexts의 모델과 Repository를 사용
- 예: Onboarding Feature, Feed Feature

**Core (공통 인프라)**:
- 앱 전역에서 사용되는 설정 및 유틸리티
- 예: Router, Theme, Services

### 2. Clean Architecture

```
┌─────────────────────────────────────┐
│        Presentation Layer           │
│  (Features: Screens, Widgets)       │
└────────────┬────────────────────────┘
             │ depends on
             ↓
┌─────────────────────────────────────┐
│         Domain Layer                │
│  (Contexts: Models, Repositories)   │
└────────────┬────────────────────────┘
             │ depends on
             ↓
┌─────────────────────────────────────┐
│          Data Layer                 │
│  (Supabase, Local Storage)          │
└─────────────────────────────────────┘
```

### 3. MVVM + Riverpod

- **Model**: Contexts에서 정의 (비즈니스 모델)
- **View**: Features의 Screens 및 Widgets
- **ViewModel**: Features의 Providers (Riverpod)

---

## 📁 디렉토리 구조

### 전체 구조

```
pickly_service/
├─ apps/
│  └─ pickly_mobile/              # Flutter 모바일 앱
│     ├─ lib/
│     │  ├─ main.dart
│     │  ├─ contexts/             # 도메인 로직
│     │  │  └─ user/
│     │  │     ├─ models/
│     │  │     │  └─ age_category.dart
│     │  │     └─ repositories/
│     │  │        └─ age_category_repository.dart
│     │  │
│     │  ├─ features/             # UI 및 기능
│     │  │  └─ onboarding/
│     │  │     ├─ screens/
│     │  │     │  └─ age_category_screen.dart
│     │  │     ├─ providers/
│     │  │     │  └─ age_category_provider.dart
│     │  │     └─ widgets/
│     │  │        ├─ onboarding_header.dart
│     │  │        └─ selection_list_item.dart
│     │  │
│     │  └─ core/                 # 공통 설정
│     │     ├─ router.dart
│     │     ├─ theme.dart
│     │     └─ services/
│     │
│     ├─ test/                    # 테스트 파일
│     ├─ examples/                # 예제 코드
│     └─ pubspec.yaml
│
├─ packages/
│  └─ pickly_design_system/       # 공통 디자인 시스템
│     ├─ lib/
│     │  └─ widgets/
│     │     └─ buttons/
│     │        └─ next_button.dart
│     └─ assets/
│        └─ icons/
│
├─ backend/
│  └─ supabase/                   # Supabase 백엔드
│     ├─ migrations/
│     └─ seed.sql
│
└─ docs/                          # 프로젝트 문서
   ├─ PRD.md
   ├─ README.md
   ├─ development/
   ├─ architecture/
   └─ api/
```

### Contexts (도메인 계층)

**경로**: `lib/contexts/{domain}/`

**구조**:
```
contexts/
└─ user/
   ├─ models/                     # 도메인 모델
   │  ├─ user_profile.dart
   │  └─ age_category.dart
   │
   └─ repositories/               # 데이터 접근
      ├─ user_repository.dart
      └─ age_category_repository.dart
```

**역할**:
- 비즈니스 로직 캡슐화
- 데이터 모델 정의
- 외부 데이터 소스와의 인터페이스 (Repository)

**규칙**:
- ✅ UI 의존성 없음 (Flutter 위젯 사용 금지)
- ✅ 순수 Dart 코드만 사용
- ✅ 다른 Context 참조 가능
- ❌ Features 참조 금지

### Features (프레젠테이션 계층)

**경로**: `lib/features/{feature}/`

**구조**:
```
features/
└─ onboarding/
   ├─ screens/                    # 화면 파일
   │  ├─ splash_screen.dart
   │  └─ age_category_screen.dart
   │
   ├─ providers/                  # 상태 관리
   │  └─ age_category_provider.dart
   │
   └─ widgets/                    # 기능별 위젯
      ├─ onboarding_header.dart
      └─ selection_list_item.dart
```

**역할**:
- 사용자 인터페이스 구현
- 사용자 인터랙션 처리
- Contexts의 데이터를 화면에 표시

**규칙**:
- ✅ Contexts의 모델 및 Repository 사용
- ✅ Provider로 상태 관리
- ✅ 공통 위젯은 Design System 사용
- ❌ 다른 Feature 직접 참조 금지

### Core (공통 인프라)

**경로**: `lib/core/`

**구조**:
```
core/
├─ router.dart                    # GoRouter 설정
├─ theme.dart                     # 앱 테마
├─ constants.dart                 # 상수 정의
└─ services/                      # 공통 서비스
   ├─ supabase_service.dart
   └─ storage_service.dart
```

**역할**:
- 앱 전역 설정
- 공통 유틸리티
- 인프라 서비스

### Design System (공통 디자인)

**경로**: `packages/pickly_design_system/`

**구조**:
```
pickly_design_system/
├─ lib/
│  └─ widgets/
│     ├─ buttons/
│     │  └─ pickly_button.dart
│     ├─ cards/
│     │  └─ selection_list_item.dart
│     └─ inputs/
│
└─ assets/
   ├─ icons/
   │  └─ age_categories/
   └─ images/
```

**역할**:
- 재사용 가능한 UI 컴포넌트
- 일관된 디자인 적용
- Figma 디자인 자산 통합

---

## 🔗 의존성 규칙

### 허용되는 의존성

```
Features → Contexts ✅
Features → Core ✅
Features → Design System ✅

Contexts → Core ✅
Contexts → Other Contexts ✅

Core → (독립적) ✅
```

### 금지되는 의존성

```
Contexts → Features ❌
Features → Other Features (직접) ❌
Core → Features ❌
Core → Contexts ❌
```

### 예시

**✅ 올바른 의존성**:
```dart
// Feature에서 Context 사용
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';

// Feature에서 Design System 사용
import 'package:pickly_design_system/widgets/buttons/pickly_button.dart';
import 'package:pickly_design_system/widgets/cards/selection_list_item.dart';
```

**❌ 잘못된 의존성**:
```dart
// Context에서 Feature 사용 (금지!)
import 'package:pickly_mobile/features/onboarding/screens/age_category_screen.dart';

// Feature 간 직접 참조 (금지!)
import 'package:pickly_mobile/features/feed/widgets/policy_card.dart';
```

---

## 📝 파일 명명 규칙

### 일반 규칙

- **소문자 + 언더스코어**: `age_category_screen.dart`
- **명확한 접미사 사용**:
  - 화면: `*_screen.dart`
  - 위젯: `*_widget.dart` 또는 명사
  - Provider: `*_provider.dart`
  - Repository: `*_repository.dart`
  - Model: 명사 단수형 `age_category.dart`

### 예시

**모델**:
```
age_category.dart
user_profile.dart
policy.dart
```

**Repository**:
```
age_category_repository.dart
user_repository.dart
policy_repository.dart
```

**화면**:
```
age_category_screen.dart
splash_screen.dart
home_screen.dart
```

**Provider**:
```
age_category_provider.dart
onboarding_provider.dart
feed_provider.dart
```

**위젯**:
```
onboarding_header.dart
selection_list_item.dart
policy_card.dart
```

---

## 📦 Import 규칙

### 절대 경로 사용 (필수)

**✅ 올바른 방식**:
```dart
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/features/onboarding/providers/age_category_provider.dart';
import 'package:pickly_design_system/widgets/buttons/pickly_button.dart';
```

**❌ 잘못된 방식**:
```dart
import '../models/age_category.dart';           // 상대 경로 금지
import '../../contexts/user/models/user.dart';  // 상대 경로 금지
```

### Import 순서

```dart
// 1. Dart SDK
import 'dart:async';
import 'dart:convert';

// 2. Flutter SDK
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// 3. 외부 패키지
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:go_router/go_router.dart';

// 4. 프로젝트 내부 (Contexts)
import 'package:pickly_mobile/contexts/user/models/age_category.dart';
import 'package:pickly_mobile/contexts/user/repositories/age_category_repository.dart';

// 5. 프로젝트 내부 (Features/Core)
import 'package:pickly_mobile/features/onboarding/widgets/onboarding_header.dart';
import 'package:pickly_mobile/core/router.dart';

// 6. Design System
import 'package:pickly_design_system/widgets/buttons/pickly_button.dart';
import 'package:pickly_design_system/widgets/cards/selection_list_item.dart';
```

---

## ⚠️ 주의사항

### 1. 중복 파일 금지

**문제 상황 (v5.2 이전)**:
```
❌ lib/core/models/age_category.dart        (중복)
✅ lib/contexts/user/models/age_category.dart (정식)
```

**원칙**:
- 동일한 모델은 **하나의 위치**에만 존재
- 단일 진실 공급원 (Single Source of Truth) 유지

### 2. 위젯 소스 명확화

**공통 위젯** (Design System):
- PicklyButton (Primary/Secondary 변형)
- SelectionListItem (v5.3부터 Design System으로 이동)
- 기타 재사용 가능한 UI 컴포넌트

**기능별 위젯** (Features):
- OnboardingHeader (온보딩 전용)

### 3. 상대 경로 사용 금지

모든 import는 `package:` 형식의 절대 경로 사용

### 4. Context 간 순환 참조 방지

```
User Context → Policy Context ✅
Policy Context → User Context ❌ (순환 참조)
```

---

## 🛠️ 개발 워크플로우

### 새 기능 추가 시

1. **도메인 분석**:
   - 어떤 Context에 속하는가?
   - 새로운 Context가 필요한가?

2. **모델 정의**:
   ```
   lib/contexts/{domain}/models/{model}.dart
   ```

3. **Repository 생성**:
   ```
   lib/contexts/{domain}/repositories/{model}_repository.dart
   ```

4. **화면 구현**:
   ```
   lib/features/{feature}/screens/{screen}_screen.dart
   ```

5. **Provider 작성**:
   ```
   lib/features/{feature}/providers/{screen}_provider.dart
   ```

6. **위젯 분리** (필요시):
   ```
   lib/features/{feature}/widgets/{widget}.dart
   ```

7. **테스트 작성**:
   ```
   test/features/{feature}/screens/{screen}_screen_test.dart
   ```

### 예제 파일 관리

개발 중 생성된 예제나 참조 코드는 `examples/` 폴더로 이동:

```bash
mv lib/experimental/example_screen.dart examples/onboarding/
```

---

## 📚 참고 자료

### 관련 문서
- [PRD (Product Requirements Document)](../PRD.md)
- [온보딩 개발 가이드](../development/onboarding-development-guide.md)
- [공통 에이전트 아키텍처](../architecture/common-agent-architecture.md)

### 외부 자료
- [Flutter Style Guide](https://flutter.dev/docs/development/tools/formatting)
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)

---

## 🔄 변경 이력

### v5.3 (2025.10.12)
- Design System 컴포넌트 범위 확대
- SelectionListItem을 Design System으로 이동
- PicklyButton으로 버튼 컴포넌트 통일
- 온보딩 위젯 중복 제거

### v5.2 (2025.10.11)
- 프로젝트 구조 가이드 신규 작성
- 중복 파일 제거 원칙 명시
- Import 규칙 표준화
- 위젯 소스 구분 명확화

---

✍️ 이 문서는 Pickly Mobile 프로젝트의 구조와 규칙을 설명합니다.
새로운 개발자는 본 문서를 먼저 읽고 개발을 시작하시기 바랍니다.
