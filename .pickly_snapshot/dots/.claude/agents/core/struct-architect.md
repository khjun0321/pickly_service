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