# 공통 에이전트 아키텍처

> **재사용 가능한 에이전트 구조**

---

## 개요

Pickly는 **공통 에이전트 + 설정 기반** 개발 방식을 사용합니다.

### 기존 방식 (화면별 개별)
```
화면 1개 = 에이전트 6개 × 워크플로우 1개
→ 화면 5개 = 30개 파일 관리 ❌
```

### 현재 방식 (공통 + 설정)
```
에이전트 6개 (공통) + 설정 파일 N개
→ 화면 5개 = 11개 파일 관리 ✅
```

---

## 에이전트 목록

### 1. onboarding-coordinator (코디네이터)
- **역할**: 전체 온보딩 개발 총괄
- **위치**: `.claude/agents/core/`
- **작업**: 설정 읽고 → 에이전트 조율

### 2. onboarding-screen-builder (화면 생성)
- **역할**: UI 코드 자동 생성
- **위치**: `.claude/agents/specialists/`
- **입력**: JSON 설정
- **출력**: Flutter 화면 코드

### 3. onboarding-state-manager (상태 관리)
- **역할**: Controller + Repository 생성
- **출력**: Riverpod Provider

### 4. onboarding-database-manager (DB)
- **역할**: Supabase 스키마 관리
- **출력**: 마이그레이션 SQL

### 5. onboarding-admin-builder (백오피스)
- **역할**: React CRUD 페이지 생성
- **조건**: manageable: true인 경우만

### 6. onboarding-integration-tester (테스트)
- **역할**: E2E 테스트 자동 생성

---

## 워크플로우 구조

```yaml
name: onboarding-universal
coordinator: onboarding-coordinator

# 화면 목록 (여기만 수정!)
screens:
  - id: "003"
    config: ".claude/screens/003-age-category.json"

# Phase 1: DB
phase_database:
  - agent: database-manager

# Phase 2: 공통 컴포넌트
phase_common:
  - agent: screen-builder
  - agent: state-manager

# Phase 3: 화면별 (병렬!)
phase_screens:
  parallel: true
  for_each: screens
  tasks:
    - agent: screen-builder
    - agent: state-manager
    - agent: admin-builder (조건부)

# Phase 4: 테스트
phase_testing:
  - agent: integration-tester
```

---

## 데이터 흐름

```
1. JSON 설정 파일 작성
   ↓
2. Coordinator가 읽기
   ↓
3. 에이전트들에게 분배 (병렬)
   ├─ Screen Builder → Flutter 화면
   ├─ State Manager → Controller
   ├─ DB Manager → 스키마 (필요 시)
   └─ Admin Builder → 백오피스 (조건부)
   ↓
4. Tester가 검증
   ↓
5. 완료!
```

---

## 장점

### 1. 코드 중복 제거
- 공통 컴포넌트 한 번만 작성
- 화면별 차이점만 설정

### 2. 빠른 개발
- JSON 10분 vs 코드 2시간
- 70% 시간 절감

### 3. 일관성
- 모든 화면이 같은 패턴
- 유지보수 쉬움

### 4. 확장성
- 새 UI 타입 추가 용이
- 새 화면 추가 간단

---

## 확장 방법

### 새 UI 타입 추가

**예**: "carousel" 타입 추가

1. Screen Builder에 템플릿 추가
2. 설정에서 사용:
```json
{
  "ui": {
    "type": "carousel",
    "autoPlay": true
  }
}
```

### 새 데이터 소스 타입

**예**: "graphql" 타입

1. State Manager에 로직 추가
2. 설정에서 사용:
```json
{
  "dataSource": {
    "type": "graphql",
    "endpoint": "...",
    "query": "..."
  }
}
```

---

## 참고 문서

- [온보딩 개발 가이드](../development/onboarding-development-guide.md)
- [설정 파일 스키마](../api/screen-config-schema.md)
