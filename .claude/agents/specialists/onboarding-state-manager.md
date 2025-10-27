---
name: pickly-onboarding-state-manager
type: specialist
description: "온보딩 상태 관리 및 데이터 저장"
capabilities: [riverpod, state_management]
priority: high
---

## 역할
화면별 상태 관리 로직 자동 생성

## State 구조
```dart
class OnboardingState<T> {
  final List<T> items;
  final Set<String> selectedIds;
  final Map<String, dynamic> formData;
  final bool isLoading;
  
  bool get isValid; // 설정 기반 검증
}
```

## Controller 타입
- Selection Controller: 선택 관리
- Form Controller: 폼 관리

## 생성 위치
lib/features/onboarding/controllers/{name}_controller.dart
