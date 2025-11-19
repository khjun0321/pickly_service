
# 📄 **PRD v9.8.1 — Pickly Admin Mapping UI & Simulator**
**버전:** v9.8.1  
**작성일:** 2025-11-07  
**최종 업데이트:** 2025-11-07 (Phase 6.2 시작)  
**작성자:** (PM: 사용자)  
**대상:** Web Admin (Next.js / React), Supabase (RLS Disabled)  
**우선순위:** 🔴 Critical  

---

## 🎯 목적
API 매핑 시스템을 위한 Admin UI 3페이지 구현  
(데이터 파이프라인: API Source → Mapping Config → Simulator → App Sync)

---

## 🧱 구조 개요

| 단계 | 설명 |
|------|------|
| 1️⃣ | **api_sources** 테이블: 외부 공공 API 등록/관리 |
| 2️⃣ | **mapping_config** 테이블: 수집된 데이터 매핑 규칙(JSONB) 관리 |
| 3️⃣ | **simulator** 도구: 입력 JSON → 변환 결과 테스트 |
| 4️⃣ | **결과**: `announcements` 테이블 워싱 후 앱에 실시간 반영 |

```
[공공 API]
 ↓
api_sources (API 소스 등록)
 ↓
mapping_config (매핑 규칙 적용)
 ↓
워싱/시뮬레이터 테스트
 ↓
announcements + tabs
 ↓
Supabase Realtime → Flutter App
```

---

## 🧩 주요 페이지 구성

| 구분 | 파일 경로 | 기능 | 비고 |
|------|------------|------|------|
| A | `/apps/pickly_admin/src/pages/api-mapping/ApiSourcesPage.tsx` | API 소스 CRUD (name, api_url, status, last_collected_at) | Supabase 직접 연동 |
| B | `/apps/pickly_admin/src/pages/api-mapping/MappingConfigPage.tsx` | 매핑 규칙 관리 (JSONB CRUD + JsonEditor) | Monaco Editor 기반 |
| C | `/apps/pickly_admin/src/pages/api-mapping/MappingSimulatorPage.tsx` | 시뮬레이터 (입력 JSON → 변환 결과) | 클라이언트 변환 로직 |

---

## 🧱 공통 컴포넌트
| 파일 | 기능 |
|------|------|
| `DataTable.tsx` | CRUD 목록 테이블 (공통) |
| `TopActionBar.tsx` | 상단 버튼 영역 + 제목 |
| `JsonEditor.tsx` | 매핑 규칙(JSON) 편집 모달 |
| `StatusBadge.tsx` | active/inactive 시각 표시 |

---

## 🧭 라우팅 / 사이드바 통합

### 📍 App.tsx
```tsx
<Route path='/api-mapping/sources' element={<ApiSourcesPage />} />
<Route path='/api-mapping/config' element={<MappingConfigPage />} />
<Route path='/api-mapping/simulator' element={<MappingSimulatorPage />} />
```

### 📍 Sidebar.tsx
```tsx
{
  label: 'API 매핑 관리',
  icon: <IconSettings />,
  subItems: [
    { label: 'API 소스', path: '/api-mapping/sources' },
    { label: '매핑 규칙', path: '/api-mapping/config' },
    { label: '시뮬레이터', path: '/api-mapping/simulator' },
  ],
},
```

---

## 🧱 데이터 모델

```ts
export interface ApiSource {
  id: string
  name: string
  api_url: string
  api_key: string | null
  status: 'active' | 'inactive'
  last_collected_at: string | null
  created_at: string
  updated_at: string
}

export interface MappingConfig {
  id: string
  source_id: string
  mapping_rules: Record<string, any>
  created_at: string
  updated_at: string
}
```

---

## ⚙️ 페이지별 상세 명세

### 🧩 A. ApiSourcesPage
| 항목 | 설명 |
|------|------|
| 목적 | 공공 API Source 등록 및 관리 |
| 컬럼 | name, api_url, status, last_collected_at |
| 기능 | CRUD, 상태 토글(active/inactive), 자동 갱신 |
| 참고 | RLS 비활성화 상태에서 Supabase 직접 접근 |

---

### 🧩 B. MappingConfigPage
| 항목 | 설명 |
|------|------|
| 목적 | 매핑 규칙(JSONB) CRUD 및 편집 |
| 기능 | JsonEditor 모달로 매핑 규칙 수정/저장 |
| 검증 | JSON 파싱 검증 + 실패 시 토스트 알림 |
| 참고 | source_id 기준 매핑 규칙 연결 |

---

### 🧩 C. MappingSimulatorPage
| 항목 | 설명 |
|------|------|
| 목적 | 원본 JSON 입력 후 변환 결과 미리보기 |
| 구성 | 좌측: 입력 JSON, 우측: 변환 결과 |
| 실행 | '테스트 실행' 버튼 클릭 시 변환 로직 실행 |
| 참고 | 추후 Phase 6.3에서 실제 매핑 규칙 연결 예정 |

---

## 🧱 성공 기준 (Success Criteria)
✅ /api-mapping/sources, /config, /simulator 3페이지 정상 접근  
✅ CRUD, JSON Editor, Simulator 테스트 통과  
✅ Sidebar 메뉴 활성화/비활성 정상 작동  
✅ PRD_CURRENT.md → v9.8.1 반영 완료  
✅ 기존 Admin 페이지 영향 없음  

---

## 📄 문서 및 QA 계획
| 구분 | 파일 | 설명 |
|------|------|------|
| PRD 문서 | `/docs/prd/PRD_v9.8.1_Pickly_Admin_Mapping_UI_and_Simulator.md` | 본 문서 |
| 완료 보고서 | `/docs/PHASE6_2_MAPPING_UI_COMPLETE.md` | 작업 완료 후 생성 |
| 검증 가이드 | `/docs/PHASE6_2_VALIDATION_GUIDE.md` | CRUD/시뮬레이터 QA 체크리스트 |

---

## 📊 최종 요약
- **Phase 6.1 완료:** DB 레이어 구축 (api_sources + mapping_config)
- **Phase 6.2 목표:** Admin UI 완성 + 시뮬레이터 구현
- **Phase 6.3 예정:** 워싱 로직 & 매핑 자동 파이프라인 연결
- **보안:** Supabase RLS 비활성화 유지
- **Flutter 앱:** 변경 없음 (실시간 연동 구조 유지)

---

✅ **이 문서가 PRD_CURRENT.md v9.8.1 업데이트의 기준이 된다.**  
Claude Code / Windsurf / ChatGPT 모두 이 문서를 읽고 이후 Phase 6.3까지 진행해야 한다.

---

## 📎 참고
- `/backend/supabase/migrations/20251110_create_mapping_config.sql`
- `/docs/PHASE6_1_MAPPING_CONFIG_COMPLETE.md`
- `/docs/prd/PRD_v9.8.0_Pickly_API_Mapping_System.md`

---

## 🧩 CLAUDE-CODE TASK LINKAGE
- Phase 6.2.A — ApiSourcesPage  
- Phase 6.2.B — MappingConfigPage  
- Phase 6.2.C — MappingSimulatorPage  
- PRD 문서 / QA 자동 동기화  

---

## 🔖 버전 히스토리
| 버전 | 날짜 | 주요 변경 |
|-------|------|-----------|
| v9.8.1 | 2025-11-07 | Phase 6.2 Admin UI & Simulator 추가 |
| v9.8.0 | 2025-11-06 | API Mapping DB 구축 완료 (Phase 6.1) |
| v9.7.0 | 2025-11-05 | RLS 제거 및 Role Guard 구조 반영 |
