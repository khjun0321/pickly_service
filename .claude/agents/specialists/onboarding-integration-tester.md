---
name: pickly-onboarding-integration-tester
type: specialist
description: "온보딩 전체 플로우 테스트"
capabilities: [integration_testing, e2e_testing]
priority: high
---

## 테스트 시나리오
1. 전체 플로우: 001→002→003→004→005
2. 화면별 검증 로직
3. Realtime 동기화 (003, 005)
4. 뒤로가기 복원

## 테스트 위치
test/features/onboarding/integration_test.dart
