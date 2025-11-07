# 📖 PRD_v9.9.3_Pickly_Full_System_Integration_FINAL.md
> “모든 사람이 공공 혜택을 쉽게 이해하고, 스스로 선택할 수 있도록 돕는다.”

---

## 🧭 서비스 철학
Pickly는 복잡한 공공 혜택 정보를 누구나 직관적으로 이해하고  
자신에게 맞는 지원 정책을 쉽게 탐색할 수 있도록 돕는 **공공 정보 큐레이션 플랫폼**이다.  

- 기존 복잡한 행정문서 → 사용자 친화적 UI로 시각화  
- 데이터 기반 혜택 추천 및 개인화된 탐색 경험 제공  
- **모든 사람(청년, 신혼, 노년, 장애인, 1인가구 등)** 이 공평하게 혜택을 누릴 수 있는 구조 구축  

---

## 🧩 통합 구조 (Pipe & Wall Architecture)
Pickly는 세 시스템을 **“벽(Wall)”**으로 분리하되 **“파이프(Pipe)”**로 연결하는 구조다.

| Layer | 역할 | 주요 기술 |
|-------|------|------------|
| **Admin** | 정책·데이터 관리, SVG 업로드, 수동/자동 동기화 | React + Supabase + Vite |
| **Supabase (Backend)** | DB, Storage, Auth, API, Realtime, Edge Function | PostgreSQL + RLS + Storage Buckets |
| **Flutter App** | 사용자 인터페이스, 필터링, 검색, 실시간 반영 | Flutter + Supabase SDK + MediaResolver |

🧱 **Pipe** = Realtime Sync (DB ↔ App)  
🧱 **Wall** = Independent Deployment (각 시스템은 충돌 없이 개별 배포 가능)

---

## 🗄️ Database Structure
### 주요 테이블
| 테이블 | 설명 |
|--------|------|
| `age_categories` | 연령대 관리 (min/max, icon_url, sort_order 포함) |
| `benefit_categories` | 혜택 카테고리 (title, icon_url, sort_order, is_active) |
| `announcements` | 공고 데이터 (region, deadline, tags, content 등) |
| `regions` | 18개 시도 고정 |
| `user_regions` | 사용자 ↔ 지역 매핑 |
| `announcement_types` | 공고 유형 관리 |
| `announcement_tabs` | 앱 내 필터 탭 연결용 중간 테이블 |

🟢 **정책**
- 모든 테이블은 idempotent migration 방식 유지  
- naming 통일 (`snake_case`)  
- Foreign Key는 `ON DELETE CASCADE` 필수 적용  
- `benefit_categories` / `regions` / `announcements` 은 realtime publication 포함  

---

## 🔒 RLS & Storage Policy
| 버킷 | 설명 | 공개 여부 | 접근 방식 |
|------|------|------------|------------|
| `benefit-icons` | 혜택 카테고리 SVG | ✅ 공개 | public read / auth upload |
| `announcement-thumbnails` | 공고 썸네일 | ✅ 공개 | public read |
| `announcement-files` | 공고 첨부 파일 | ✅ 공개 | public read |
| `mapping-exports` | 매핑 결과 로그 | 🔒 비공개 | service_role 전용 |

✅ **Service Role Key 전환 (v9.9.0 이후)**  
- anon key 기반 접근 → ❌ Deprecated  
- dev 환경에서만 `service_role` 사용, prod에서는 복원 예정  

---

## 🖥️ Admin System
- **AutoLogin Gate**: Dev 환경에서 자동 로그인
- **Supabase Client**: anon → service_role key 교체
- **SVG Upload**: Storage `benefit-icons` 버킷에 자동 업로드  
- **미리보기 정책**
  - Design Fixed 자산 → 미리보기 비활성  
  - Dynamic 자산(업로드 SVG) → 미리보기 활성  

✅ 로그인 에러(504) 이슈는 `service_role` 전환으로 해결됨.  
> `anon`으로 schema 접근 불가했던 문제를 `VITE_SUPABASE_SERVICE_ROLE_KEY`로 해결.  

---

## 📱 Flutter App Structure
| 컴포넌트 | 기능 | 정책 |
|-----------|------|------|
| `CircleTab (혜택 써클탭)` | 혜택 카테고리 목록 표시 | UI 고정 / DB 데이터(title, icon_url)만 동적 |
| `MediaResolver` | 로컬 vs Storage 자동 분기 | asset 존재 시 로컬 우선 |
| `Stream Caching` | 중복 구독 방지 | `.asBroadcastStream()` + `keepAlive()` 적용 |
| `SearchBar` | 디자인 고정형 컴포넌트 | Design System에 고정 (DB 연결 없음) |

✅ **fire.svg → popular.svg 교체 완료**  
- Storage 및 DB icon_url 정규화 완료  
- 로컬 asset fallback 정상 작동  

---

## 🎨 Icon Asset Management Policy (v9.9.1 통합)
| 구분 | 예시 | 관리 위치 | DB 저장 | 변경 가능 |
|------|------|------------|-----------|------------|
| **Design Fixed** | SearchBar, TabBar, EmptyState | pickly_design_system | ❌ 없음 | ❌ |
| **Dynamic** | 혜택 카테고리, 필터칩 등 | Supabase Storage | ✅ 파일명.svg | ✅ 가능 |

🧩 **정책**
- DB에는 `파일명.svg`만 저장 (경로 미포함)
- Admin은 Storage 업로드 후 해당 파일명 저장
- Flutter는 로컬 asset 또는 Storage URL 자동 선택

🗑️ **Deprecated**
- `/icons/...` 상대 경로 저장 금지
- 예: `/icons/popular.svg` → ❌  
- 올바른 형식: `popular.svg` → ✅  

---

## 🌐 API & Mapping System
- 공공 API → Supabase → Admin → Flutter  
- 수집 데이터는 `raw_announcements`에 저장 후 워싱  
- Admin 편집 → 실시간 반영 (Realtime)  
- Edge Function 기반으로 확장 예정  

📡 **데이터 플로우**
1️⃣ 공공데이터 수집 → `raw_announcements`  
2️⃣ Admin 정제 및 매핑  
3️⃣ 실시간 반영 → `announcements`  
4️⃣ 앱 반영 → 필터 탭/상세 템플릿 기반 렌더링  

---

## ⚙️ Troubleshooting History & 변경 사유 로그

| 날짜 | 이슈 | 원인 | 해결/변경 내용 |
|------|------|------|----------------|
| 2025.10.27 | RLS 정책 충돌 | auth.users 접근 실패 | RLS helper function + 정책 분리 |
| 2025.10.29 | SVG 업로드 실패 | `uuid-ossp` 확장 누락 | Supabase extension 추가 |
| 2025.10.30 | 혜택 카테고리 미표시 | icon_url 상대 경로 | 파일명.svg 정규화 + MediaResolver 적용 |
| 2025.11.01 | Storage 접근 제한 | anon key 제한 | service_role key 전환 |
| 2025.11.03 | CircleTab 아이콘 누락 | 로컬 asset path 불일치 | Design System path 수정 |
| 2025.11.04 | Admin 로그인 불가 | schema 접근 거부 | service_role 기반 client 수정 |
| 2025.11.05 | SVG Preview 불일치 | Design Fixed 자산 미리보기 시도 | Preview 조건 분리 (Dynamic 전용) |

---

## 🧱 Phase 7+ 확장 계획
1️⃣ **Supabase Edge Function 자동화**  
2️⃣ **RLS 복원 (service_role 최소화)**  
3️⃣ **기관별 테넌트 정책 (Multi-Tenant)**  
4️⃣ **AI 기반 혜택 추천 (ML Filter)**  
5️⃣ **Claude Flow ↔ Git PRD 자동화 파이프라인**

---

## 🧩 운영 시나리오 (Example)
1️⃣ Admin에서 “주거” 카테고리 수정 → `home.svg` 업로드  
2️⃣ Supabase Storage에 자동 저장  
3️⃣ DB에 `icon_url = 'home.svg'` 업데이트  
4️⃣ Flutter 앱 CircleTab 실시간 반영  
5️⃣ 사용자 화면에서 즉시 “주거” 아이콘 및 이름 표시  
6️⃣ 다른 사용자 앱에도 자동 Sync (Realtime Subscription)

---

## ✅ 최종 상태 요약

| 항목 | 상태 |
|------|------|
| DB 구조 | ✅ 통합 완료 |
| Storage 정책 | ✅ 안정화 |
| Admin ↔ Flutter 파이프 | ✅ 정상 작동 |
| RLS / Service Role | ✅ 전환 완료 |
| CircleTab / Icon | ✅ 실시간 반영 |
| PRD 자동 동기화 | ✅ Claude Flow 호환 |
| 확장 (Phase 7+) | 🟡 준비 완료 |

---

## 📚 메타데이터
- **작성일:** 2025-11-06  
- **버전:** v9.9.3  
- **작성자:** Pickly System (Hyunjun + ChatGPT + Claude Code)  
- **파일 경로:** `/docs/prd/PRD_v9.9.3_Pickly_Full_System_Integration_FINAL.md`  
- **참조 문서:** v8.8.1~v9.9.2 전 버전  
