# 📄 Pickly Service — PRD v8.5 Master Final (2025-10-31)

> **목표:**  
> Flutter 앱은 절대 변경하지 않는다.  
> Admin과 Supabase만 기능 중심으로 확장하며,  
> 향후 카카오/네이버 SSO 로그인까지 통합 가능한 구조를 갖춘다.  
>  
> 👉 지금은 “기능 개발 1순위”, 디자인은 그대로 유지한다.

---

## 🧱 1. 전체 아키텍처 개요

| 계층 | 역할 | 주요 폴더 | 수정 가능 여부 |
|------|------|------------|----------------|
| **Flutter App (Mobile)** | 사용자 UI / 앱 화면 | `/apps/pickly_mobile` | ❌ 절대 변경 금지 |
| **Repository Layer (Wall)** | Flutter 데이터 매핑 계층 | `/apps/pickly_mobile/lib/contexts/**` | ✅ 변경 가능 |
| **Supabase (Backend)** | DB + 실시간 이벤트 + API 허브 | `/backend/supabase/**` | ✅ 변경 가능 |
| **Admin (React + Material)** | 데이터 관리, 커스터마이징 | `/apps/pickly_admin/**` | ✅ Material 기준 변경 가능 |
| **Design System (DS)** | 공통 컴포넌트 / 스타일 | `/packages/pickly_design_system` | ❌ 변경 금지 |

---

## 🎨 2. 디자인 & UI Lock 정책 (절대 변경 금지)

> “Flutter 화면은 손대지 않는다.  
> 디자인, 구조, 색상, 레이아웃, 컴포넌트 모두 Figma 기준으로 고정된다.”

### 2.1 Flutter 앱 고정

- **절대 변경 금지 범위**
  - `/apps/pickly_mobile/lib/features/**`
  - 온보딩, 홈, 필터, 상세, 프로필 등 모든 화면 구조
  - 라우트 및 네비게이션 흐름
  - 버튼, 카드, 칩, 간격, 폰트 등 시각적 요소

- **허용되는 수정**
  - `/contexts/**` 내부의 Repository, Provider, Service 로직만 수정 가능  
  - UI 파일(.dart)은 생성·삭제·수정 절대 금지

- **디자인 수정 시점**
  - 추후 “디자인 리뉴얼 스프린트” 단계에서 별도 버전(v9.0)으로 진행 예정

---

### 2.2 Design System 고정

- **경로:** `/packages/pickly_design_system`
- **규칙:**
  - 기존 DS 컴포넌트 수정 금지  
  - 새로운 컴포넌트는 `extends` 기반으로 추가만 가능  
  - `primary`, `neutral`, `surface` 색상 토큰 및 spacing 단위 고정  
  - Figma 기준 1:1 매칭 유지

### 2.3 Figma 기준 유지
- [🎨 Pickly Figma 링크](https://www.figma.com/design/xOpx8v3FiYmCxSLkj9sgcu/pickly)
- 디자인 변경은 PRD 승인 이후 다음 버전에서만 반영

---

### 🧠 Claude / 개발 에이전트 지시문

```text
🚫 절대 지시: Flutter 앱 UI를 변경하지 마라.

- /apps/pickly_mobile/lib/features/**  → 수정 금지
- /packages/pickly_design_system/**     → 수정 금지
- /apps/pickly_mobile/lib/contexts/**   → 데이터만 변경 가능
- Admin(React), Supabase(DB), Repository(Data Layer)만 작업 허용
```

---

## 🧩 3. Admin (React + Material Design)

> Flutter는 고정, Admin은 Material Design 기준으로 자유롭게 기능 확장 가능.

### 3.1 디자인 원칙

| 항목 | 내용 |
|------|------|
| **기준** | Google Material Design v3 |
| **UI 라이브러리** | MUI (Material UI) |
| **색상** | Pickly DS의 `primary`, `surface`, `neutral` |
| **레이아웃 변경** | ✅ 가능 (탭/모달/테이블 구조 조정 가능) |
| **기능 확장** | ✅ 가능 (CRUD, 필터, 정렬 등 자유) |
| **외부 UI 프레임워크** | ❌ 금지 (Tailwind, Antd, Shadcn 등 불허) |

---

### 3.2 화면별 구성

#### 🏠 혜택 관리
- 탭: 주거 / 취업 / 건강 / 교육 / 금융  
- CRUD (공고 등록/수정/삭제)  
- 상태 필터: 모집중 / 마감 / 예정  
- D-Day 자동 계산  
- 홈 노출 토글 (`is_home_visible`)  
- 조회수 순 정렬 (`views_count`)  
- 썸네일 업로드 (`thumbnail_url`)  
- 추가 및 수정 → 하나의 모달 통합

#### 🖼 배너 관리
- 카테고리별 배너 리스트  
- 이미지 업로드 (S3 연결)  
- 정렬(`sort_order`), 노출여부(`is_active`), 링크(`link_type`)  
- MUI Modal 기반 편집  

#### 👤 연령대 관리
- 연령대명 / 최소~최대 나이  
- SVG 아이콘 업로드 (미리보기 포함)  
- 순서(`sort_order`) 및 활성화(`is_active`) 관리  

#### 🧾 공고유형 관리
- 상위 카테고리 연결 (`benefit_category_id`)  
- 유형명, 설명, 정렬, 활성화  
- CRUD 기능 완비  

---

## ⚙️ 4. Supabase & 파이프라인 구조

### 4.1 데이터 흐름 요약

```
[공공기관 API]
   ↓
[Supabase Edge Function (fetch)]
   ↓
[announcements_raw] (원본 데이터)
   ↓
[transform_announcements()] (정제)
   ↓
[announcements] (표준화된 공고)
   ↓
[Admin] (수정 및 노출 관리)
   ↓
[Flutter Repository]
   ↓
[App 표시]
```

---

### 4.2 핵심 테이블

| 테이블 | 역할 |
|--------|------|
| `announcements_raw` | 원본 API 데이터 |
| `announcements` | 표준화된 공고 데이터 |
| `announcement_types` | 공고 세부 유형 |
| `benefit_categories` | 주거·취업·건강 등 대분류 |
| `category_banners` | 카테고리별 배너 |
| `age_categories` | 연령대 필터 |

---

## 🧱 5. “벽 + 파이프라인” 구조

| 계층 | 설명 |
|------|------|
| **Flutter UI** | 고정 (Figma 기준 유지) |
| **Repository (벽)** | DB 구조 변경 흡수, 데이터 매핑 담당 |
| **Supabase (파이프)** | 실시간 데이터 전송 및 저장 |
| **Admin (밸브)** | 데이터 CRUD 및 노출 제어 |

### 예시 흐름

```
Admin 수정 → Supabase DB → Realtime Event → Repository → 앱 자동 반영
```

---

## 🔄 6. 실시간 동기화 (Realtime Sync)

| 테이블 | 실시간 반영 대상 |
|---------|----------------|
| `announcements` | 앱 홈 / 리스트 |
| `category_banners` | 앱 홈 배너 |
| `benefit_categories` | 앱 필터 탭 |
| `age_categories` | 재시작 후 반영 |

---

## 🌐 7. 공공 API 통합 및 데이터 커스터마이징

### 7.1 API 파이프라인
- Supabase Edge Function 기반 (`fetch-lh-announcements`, `fetch-sh-announcements`, `fetch-bokjiro-announcements`)  
- `announcements_raw`에 원본 저장  
- `transform_announcements()` SQL Function으로 변환  
- `announcements` 테이블에 표준화 삽입  

### 7.2 Admin 커스터마이징 필드

| 필드 | 설명 |
|------|------|
| `custom_subtitle` | 요약문 수동 입력 |
| `custom_image_url` | 이미지 보정 |
| `display_priority` | 우선순위 설정 |
| `is_home_visible` | 홈 노출 여부 |
| `tags` | 검색 키워드 |
| `region` | 지역 보정 |

### 7.3 API 매핑 예시

```json
{
  "source": "LH",
  "mapping": {
    "title": "PBLANC_TITLE",
    "deadline_date": "SUBSCRPT_RCEPT_ENDDE",
    "posted_date": "SUBSCRPT_RCEPT_BGNDE",
    "external_url": "HOUSE_DTL_URL",
    "region": "CNSTRCT_AREA_CODE_NM",
    "organization": "BSNS_MBY_NM"
  }
}
```

---

## 🔐 8. SSO 로그인 (향후 확장 계획)

> 현재 개발 단계에서는 미사용.  
> 향후 “사용자 인증” 기능이 안정화된 후 SSO를 추가한다.

| 구분 | 서비스 | 예상 방식 | 우선순위 |
|------|----------|-------------|-------------|
| 1️⃣ | **카카오 로그인** | OAuth 2.0 + Supabase Auth | 중 |
| 2️⃣ | **네이버 로그인** | OAuth 2.0 + Supabase Auth | 중 |
| 3️⃣ | **이메일 로그인** | Supabase 기본 인증 | 현재 사용 중 |
| 4️⃣ | **SSO 통합 시점** | 기능 개발 이후 (v9.0) | 추후 논의 |

📘 참고  
- SSO는 Supabase Auth Function과 연계해 확장  
- App/Flutter UI는 동일, 로그인 버튼만 추가  

---

## 🧩 9. Claude Flow 작업 단계

| 단계 | 이름 | 설명 |
|------|------|------|
| 1️⃣ | “이 땅이 우리 땅이다” | Claude가 레포/PRD 전체 구조 인식 |
| 2️⃣ | “벽 세우기” | Repository 분리 (`contexts/`) |
| 3️⃣ | “파이프 연결” | Supabase 연결 및 실시간 이벤트 |
| 4️⃣ | “Admin 밸브 확장” | Material UI CRUD UX 개선 |
| 5️⃣ | “API 세척기 설치” | Edge Function 기반 공공 API 정제 |
| 6️⃣ | “실시간 급수” | Flutter와 Admin 동기화 검증 |
| 7️⃣ | “SSO 예비 배관” | 카카오/네이버 OAuth 준비 |

---

## ✅ 10. 결론 요약

| 항목 | 상태 | 비고 |
|------|------|------|
| Flutter UI | 🔒 고정 | 절대 변경 금지 |
| Design System | 🔒 고정 | Figma 기반 |
| Repository | 🧱 안정화 | Flutter 데이터 매핑 |
| Admin | 🟢 자유롭게 확장 | Material Design |
| Supabase | 🟢 확장 가능 | 공공 API, SSO 준비 |
| Edge Function | 🚧 진행 중 | LH → SH → 복지로 순 |
| SSO 로그인 | 📅 예정 | v9.0 이후 도입 |

---

📘 **한 줄 요약**

> **“Pickly는 Flutter 디자인을 절대 건드리지 않고,  
> Admin과 Supabase를 통해 데이터와 기능만 확장한다.”**  
>  
> 현재는 기능 개발이 우선이며, SSO(카카오·네이버)는 추후 v9.0에 통합될 예정이다.
