# Pickly Admin 패널 구현 문서

**작성일**: 2025-10-23
**버전**: 1.0.0

## 📋 목차

1. [개요](#개요)
2. [프로젝트 구조](#프로젝트-구조)
3. [기술 스택](#기술-스택)
4. [설치 및 실행](#설치-및-실행)
5. [주요 기능](#주요-기능)
6. [구현된 페이지](#구현된-페이지)
7. [해결된 이슈](#해결된-이슈)
8. [데이터베이스 연동](#데이터베이스-연동)
9. [인증 정보](#인증-정보)

---

## 개요

Pickly Admin 패널은 관리자가 모바일 앱의 사용자, 연령 카테고리 등을 관리할 수 있는 웹 기반 관리 도구입니다.

### 주요 목표
- ✅ Flutter 모바일 앱과 **완전 분리**된 독립적인 React 애플리케이션
- ✅ Supabase 백엔드만 공유
- ✅ 실시간 데이터 동기화 (Admin 수정 → 모바일 앱 반영)
- ✅ Material UI 기반 직관적인 관리 인터페이스

---

## 프로젝트 구조

```
pickly_service/
├── apps/
│   ├── pickly_admin/          # ← 새로 생성된 React Admin 패널
│   │   ├── src/
│   │   │   ├── api/           # Supabase API 호출 함수
│   │   │   │   ├── users.ts
│   │   │   │   └── categories.ts
│   │   │   ├── components/    # React 컴포넌트
│   │   │   │   ├── common/    # 공통 컴포넌트 (Header, Sidebar, PrivateRoute)
│   │   │   │   └── layout/    # 레이아웃 컴포넌트
│   │   │   ├── pages/         # 페이지 컴포넌트
│   │   │   │   ├── auth/      # 인증 (Login)
│   │   │   │   ├── dashboard/ # 대시보드
│   │   │   │   ├── users/     # 사용자 관리
│   │   │   │   └── categories/ # 카테고리 CRUD
│   │   │   ├── lib/           # 라이브러리 설정
│   │   │   │   ├── supabase.ts
│   │   │   │   └── queryClient.ts
│   │   │   ├── types/         # TypeScript 타입 정의
│   │   │   │   └── database.ts
│   │   │   ├── styles/        # MUI 테마 설정
│   │   │   │   └── theme.ts
│   │   │   └── hooks/         # Custom React Hooks
│   │   │       └── useAuth.ts
│   │   ├── .env.local         # 환경 변수
│   │   ├── package.json
│   │   ├── vite.config.ts
│   │   └── tsconfig.json
│   └── pickly_mobile/         # 기존 Flutter 모바일 앱
└── docs/
    └── admin-panel-implementation.md  # 이 문서
```

---

## 기술 스택

### Frontend
- **React 18.2.0** - UI 라이브러리
- **TypeScript 5.9.3** - 타입 안정성
- **Vite 7.1.7** - 빌드 도구 및 개발 서버
- **Material-UI (MUI) 5.15.0** - UI 컴포넌트 프레임워크
- **@mui/x-data-grid 6.18.0** - 데이터 테이블
- **React Router v6** - 클라이언트 사이드 라우팅

### State Management
- **TanStack Query v5** - 서버 상태 관리
- **React Hook Form 7.49.0** - 폼 상태 관리
- **Zod 3.22.0** - 스키마 검증

### Backend Integration
- **Supabase Client 2.39.0** - 인증 및 데이터베이스 연동
- **로컬 Supabase**: `http://127.0.0.1:54321`

### Styling
- **Emotion** - CSS-in-JS
- **React Hot Toast 2.4.0** - 알림 시스템

---

## 설치 및 실행

### 1. 프로젝트 초기화 (이미 완료됨)

```bash
cd apps/pickly_admin
npm install
```

### 2. 환경 변수 설정

`.env.local` 파일에 다음 설정:

```env
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
VITE_APP_NAME=Pickly Admin
```

### 3. 개발 서버 실행

```bash
npm run dev
```

브라우저에서 자동으로 `http://localhost:5173` 열림

### 4. 프로덕션 빌드

```bash
npm run build
npm run preview  # 빌드 결과 미리보기
```

---

## 주요 기능

### 1. 인증 시스템
- **로그인/로그아웃** 기능
- Supabase Auth 통합
- Protected Routes (인증되지 않은 사용자 자동 리다이렉트)
- 세션 자동 복원

### 2. 대시보드
- 전체 사용자 수 표시
- 연령 카테고리 수 통계
- 실시간 데이터 업데이트

### 3. 사용자 관리
- 사용자 목록 조회 (DataGrid)
- 필터링, 정렬, 페이지네이션
- 표시 정보:
  - 이름, 나이, 성별
  - 지역 (시/도, 시/군/구)
  - 온보딩 완료 여부

### 4. 연령 카테고리 관리 (CRUD)
- **생성**: 새 카테고리 추가
- **조회**: 전체 카테고리 목록
- **수정**: 기존 카테고리 편집
- **삭제**: 카테고리 삭제 (확인 다이얼로그)
- 실시간 동기화 (수정 시 Flutter 앱에도 반영)

---

## 구현된 페이지

### 1. Login (`/login`)
- **파일**: `src/pages/auth/Login.tsx`
- **기능**: 이메일/비밀번호 로그인
- **리다이렉트**: 로그인 성공 시 `/` (대시보드)로 이동

### 2. Dashboard (`/`)
- **파일**: `src/pages/dashboard/Dashboard.tsx`
- **기능**: 통계 카드 (사용자 수, 카테고리 수)
- **보호**: PrivateRoute로 인증 필요

### 3. User List (`/users`)
- **파일**: `src/pages/users/UserList.tsx`
- **기능**: MUI DataGrid로 사용자 목록 표시
- **데이터 소스**: `user_profiles` 테이블

### 4. Category List (`/categories`)
- **파일**: `src/pages/categories/CategoryList.tsx`
- **기능**: 카테고리 목록, 편집/삭제 버튼

### 5. Category Form (`/categories/new`, `/categories/:id/edit`)
- **파일**: `src/pages/categories/CategoryForm.tsx`
- **기능**: 카테고리 생성/수정 폼
- **검증**: React Hook Form + Zod

---

## 해결된 이슈

### 이슈 1: TypeScript `User` 타입 임포트 오류

**문제**:
```
Uncaught SyntaxError: The requested module does not provide an export named 'User'
```

**원인**: `@supabase/supabase-js`에서 `User`를 값으로 임포트

**해결**:
```typescript
// ❌ 잘못된 방법
import { User } from '@supabase/supabase-js'

// ✅ 올바른 방법
import type { User } from '@supabase/supabase-js'
```

**파일**: `src/hooks/useAuth.ts:2`

---

### 이슈 2: `GridColDef` 타입 임포트 오류

**문제**:
```
'GridColDef' is a type and must be imported using a type-only import when 'verbatimModuleSyntax' is enabled
```

**해결**:
```typescript
// ❌ 잘못된 방법
import { DataGrid, GridColDef } from '@mui/x-data-grid'

// ✅ 올바른 방법
import { DataGrid } from '@mui/x-data-grid'
import type { GridColDef } from '@mui/x-data-grid'
```

**파일**:
- `src/pages/users/UserList.tsx:3-4`
- `src/pages/categories/CategoryList.tsx:4-5`

---

### 이슈 3: Supabase 타입 추론 문제

**문제**: `insert()`와 `update()` 함수의 타입 불일치

**해결**:
```typescript
// src/api/categories.ts
export async function createCategory(category: Omit<AgeCategory, 'id' | 'created_at' | 'updated_at'>) {
  const { data, error } = await supabase
    .from('age_categories')
    // @ts-expect-error - Supabase type inference issue
    .insert(category)
    .select()
    .single()

  if (error) throw error
  return data as AgeCategory
}

export async function updateCategory(id: string, category: Partial<AgeCategory>) {
  const { data, error } = await supabase
    .from('age_categories')
    // @ts-expect-error - Supabase type inference issue
    .update(category)
    .eq('id', id)
    .select()
    .single()

  if (error) throw error
  return data as AgeCategory
}
```

---

### 이슈 4: React 19 vs MUI DataGrid 호환성

**문제**: `@mui/x-data-grid`가 React 19 미지원

**해결**: React 버전을 18.2.0으로 다운그레이드

```json
{
  "dependencies": {
    "react": "^18.2.0",
    "react-dom": "^18.2.0"
  }
}
```

설치 시 `--legacy-peer-deps` 플래그 사용

---

### 이슈 5: Vite 캐시 문제로 인한 흰 화면

**문제**: 브라우저에서 흰 화면만 표시

**해결**:
```bash
# Vite 캐시 완전히 삭제
rm -rf node_modules/.vite

# 개발 서버 재시작
npm run dev
```

**브라우저 하드 리프레시**: `Cmd + Shift + R` (Mac) / `Ctrl + F5` (Windows)

---

## 데이터베이스 연동

### Supabase 테이블

#### 1. `user_profiles`
```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  user_id UUID,
  name TEXT,
  age INTEGER,
  gender TEXT,
  region_sido TEXT,
  region_sigungu TEXT,
  selected_categories UUID[],
  income_level TEXT,
  interest_policies UUID[],
  onboarding_completed BOOLEAN DEFAULT false,
  onboarding_step INTEGER DEFAULT 1,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

#### 2. `age_categories`
```sql
CREATE TABLE age_categories (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  icon_component TEXT NOT NULL,
  icon_url TEXT,
  min_age INTEGER,
  max_age INTEGER,
  sort_order INTEGER DEFAULT 0,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now(),
  updated_at TIMESTAMPTZ DEFAULT now()
);
```

### 데이터 동기화

**Admin 패널 → Flutter 앱**:

1. Admin에서 카테고리 추가/수정/삭제
2. Supabase 데이터베이스 즉시 업데이트
3. Flutter 앱에서 화면 새로고침 시 변경사항 반영

**실시간 동기화 (선택사항)**:

Flutter 앱에서 Supabase Realtime 구독:
```dart
supabase
  .from('age_categories')
  .stream(primaryKey: ['id'])
  .listen((categories) {
    // Admin 수정 시 자동 업데이트
  });
```

---

## 인증 정보

### 테스트 관리자 계정

**이메일**: `admin@pickly.com`
**비밀번호**: `admin123!@#`

### 계정 생성 방법

```bash
curl -X POST 'http://127.0.0.1:54321/auth/v1/signup' \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@pickly.com",
    "password": "admin123!@#"
  }'
```

---

## 개발 가이드

### 1. 새 페이지 추가

```typescript
// src/pages/example/ExamplePage.tsx
import { Box, Typography } from '@mui/material'

export default function ExamplePage() {
  return (
    <Box>
      <Typography variant="h4">새 페이지</Typography>
      {/* 콘텐츠 */}
    </Box>
  )
}
```

라우팅에 추가:
```typescript
// src/App.tsx
<Route path="example" element={<ExamplePage />} />
```

### 2. 새 API 함수 추가

```typescript
// src/api/example.ts
import { supabase } from '@/lib/supabase'

export async function fetchData() {
  const { data, error } = await supabase
    .from('table_name')
    .select('*')

  if (error) throw error
  return data
}
```

### 3. React Query 사용

```typescript
import { useQuery } from '@tanstack/react-query'
import { fetchData } from '@/api/example'

function Component() {
  const { data, isLoading } = useQuery({
    queryKey: ['example'],
    queryFn: fetchData,
  })

  // ...
}
```

---

## 빌드 및 배포

### 빌드 최적화

현재 번들 크기: **1,057.25 kB**

개선 방법:
1. **Dynamic Import** 사용
2. **Code Splitting** 적용
3. **Lazy Loading** 페이지별 분리

```typescript
// Lazy Loading 예시
const UserList = lazy(() => import('@/pages/users/UserList'))
```

---

## 다음 단계

### 기능 개선
- [ ] 사용자 상세 정보 조회 페이지
- [ ] 사용자 필터링 기능 강화
- [ ] 카테고리 아이콘 업로드 기능
- [ ] Realtime 구독 (즉시 데이터 동기화)
- [ ] 관리자 권한 관리 (Role-Based Access Control)

### 성능 최적화
- [ ] Code Splitting
- [ ] Image Optimization
- [ ] Bundle Size 최적화 (500kb 이하)

### DevOps
- [ ] CI/CD 파이프라인 구축
- [ ] Vercel/Netlify 배포
- [ ] 환경별 설정 분리 (dev/staging/prod)

---

## 참고 문서

- [React 공식 문서](https://react.dev)
- [Vite 공식 문서](https://vitejs.dev)
- [Material-UI](https://mui.com)
- [TanStack Query](https://tanstack.com/query)
- [Supabase 공식 문서](https://supabase.com/docs)

---

**문서 끝**
