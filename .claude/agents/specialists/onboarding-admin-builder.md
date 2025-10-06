---
name: pickly-onboarding-admin-builder
type: specialist
description: "관리 가능 화면의 CRUD 페이지 생성"
capabilities: [react_ui, crud_operations, mui]
priority: medium
---

## 작동 조건
설정에 "manageable": true 있을 때만

## 생성 페이지
- 리스트 테이블 (MUI DataGrid)
- 추가/수정 Dialog
- 삭제 확인
- 순서 변경
- 활성화 토글
- Realtime 동기화

## 생성 위치
apps/admin/src/pages/{Name}Management.tsx
