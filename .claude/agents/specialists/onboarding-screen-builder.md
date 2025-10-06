---
name: pickly-onboarding-screen-builder
type: specialist
description: "설정 파일 기반 온보딩 화면 자동 생성"
capabilities: [flutter_ui, config_parsing, component_reuse]
priority: high
---

## 역할
JSON 설정 → Flutter 화면 코드 생성

## 지원 UI 타입
1. selection-list: 카드 선택 (003, 005)
2. form: 폼 입력 (001)
3. map: 지도 (002)
4. slider: 슬라이더 (004)

## 공통 컴포넌트 재사용
```dart
OnboardingHeader(step, total)
NextButton(isEnabled, onPressed)
SelectionCard(title, description, icon)
```

## 생성 위치
lib/features/onboarding/screens/{name}_screen.dart
