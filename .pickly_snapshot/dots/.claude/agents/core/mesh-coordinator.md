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