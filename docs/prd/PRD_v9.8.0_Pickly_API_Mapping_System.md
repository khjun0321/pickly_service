# 📄 PRD v9.8.0 — Pickly API 매핑 관리 시스템 (Phase 6)

**버전:** v9.8.0  
**작성일:** 2025-11-07  
**이전 버전:** v9.7.0 (RLS 제거 + Admin Role Guard Architecture)  
**상태:** ⏳ 개발 예정 (Phase 6 시작 전)  
**작성자:** 사용자 (PM), ChatGPT + Claude Code (시스템 아키텍처)  

---

## 🎯 서비스 목적
공공데이터 API에서 수집된 원본(raw) 데이터를 Pickly 내부 구조에 맞게 자동 매핑하고,  
관리자가 직접 시각적으로 매핑 규칙을 관리할 수 있도록 하는 **Admin 전용 매핑 시스템** 구축.

---

## 🧱 핵심 구조

[공공기관 API] → raw_announcements → mapping_config → announcements/subcategories → Flutter App

---

## 🧩 주요 기능

| 기능 | 설명 | 상태 |
|------|------|------|
| ✅ `api_sources` 관리 | API 소스 등록 및 상태 관리 | 완료 |
| ✅ `api_collection_logs` | 수집 이력 저장 | 완료 |
| 🆕 `mapping_config` | raw → Pickly 데이터 매핑 규칙 저장 | 예정 |
| 🆕 매핑 시뮬레이터 | 매핑 규칙 적용 테스트 기능 | 예정 |
| 🆕 자동 규칙 제안 (AI) | 키워드 기반 매핑 제안 기능 | 예정 |

---

## ⚙️ DB 테이블 정의

### 1️⃣ mapping_config

| 컬럼 | 타입 | 설명 |
|------|------|------|
| id | uuid (PK) | 기본 식별자 |
| source_id | uuid (FK → api_sources.id) | 연관 API 소스 |
| mapping_rules | jsonb | 매핑 규칙 정의(JSON 형식) |
| created_at | timestamptz | 생성 일시 |
| updated_at | timestamptz | 수정 일시 |

---

## 📦 Storage 정책

| 버킷 | 용도 | 접근권한 |
|------|------|----------|
| `benefit-icons` | 아이콘 | Public |
| `home-banners` | 홈 배너 | Public |
| `mapping-snapshots` | 매핑 테스트 결과 | Private (Admin Only) |

---

## 🔒 보안 모델 (v9.8.0 유지)
- ✅ Supabase RLS 완전 비활성화 유지  
- ✅ Next.js API 내부 Role Guard 적용  
- ✅ Supabase 접근은 service_role key로만 수행  
- ✅ Flutter 앱은 anon key (읽기 전용)

---

## 🧠 AI 연동 계획 (Phase 6.2 이후)
Claude Code Agent가 raw_announcements.raw_data를 분석해  
자동으로 `mapping_rules`를 생성/제안하는 기능 추가 예정.

예시:
```json
{
  "지원대상": "eligibility",
  "신청기간": "application_period",
  "신청방법": "application_method"
}
```

---

## 🧩 Phase 6.1 작업 리스트

| 단계 | 작업 내용 | 담당 |
|------|-----------|------|
| 1️⃣ | `mapping_config` 테이블 생성 (마이그레이션 실행) | Claude Code |
| 2️⃣ | Admin UI 탭 추가 (`/mapping`) | ChatGPT |
| 3️⃣ | 매핑 규칙 JSON 편집기 컴포넌트 구현 | ChatGPT |
| 4️⃣ | 매핑 시뮬레이터 연결 | Claude Code |
| 5️⃣ | Flutter 앱 반영 확인 | ChatGPT |

---

## ✅ Phase 6 완료 기준
- [ ] mapping_config 테이블 생성 및 정상 작동  
- [ ] Admin에서 매핑 규칙 CRUD 가능  
- [ ] 시뮬레이터 기능 정상 동작  
- [ ] Flutter 앱에서 반영 확인 완료  

---

## 📄 참조 파일
- `/backend/supabase/migrations/20251110_create_mapping_config.sql`
- `/apps/pickly_admin/src/pages/mapping/MappingConfig.tsx`
- `/docs/PHASE6_0_MAPPING_SYSTEM_OVERVIEW.md`

---

## 🔄 Phase 7 예고
- Next.js API Role Guard 완전 적용  
- Admin 사용자 Role 관리/SSO 통합  
- 로그 및 감사 트래킹 시스템 추가

---
