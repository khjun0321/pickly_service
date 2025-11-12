# Pickly v9.13.2 - 보안 감사 보고서 (Security Audit Report)

## 📅 감사 일시: 2025-11-12
## 🎯 목적: Production 환경 보안 상태 점검 및 "RLS 없는 안전한 런칭" 전략 검증
## ✅ 상태: 감사 완료

---

## 🔍 1. RLS (Row Level Security) 현황

### 1️⃣ 현재 상태: **비활성화 (DISABLED)**

**마이그레이션**: `20251107_disable_all_rls.sql`

```sql
-- ALL RLS DISABLED
ALTER TABLE age_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_categories DISABLE ROW LEVEL SECURITY;
ALTER TABLE benefit_subcategories DISABLE ROW LEVEL SECURITY;
ALTER TABLE category_banners DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcements DISABLE ROW LEVEL SECURITY;
ALTER TABLE announcement_tabs DISABLE ROW LEVEL SECURITY;
ALTER TABLE api_sources DISABLE ROW LEVEL SECURITY;
ALTER TABLE raw_announcements DISABLE ROW LEVEL SECURITY;
```

**Storage Buckets**: Public 모드
```sql
UPDATE storage.buckets SET public = true WHERE name IN ('benefit-icons', 'home-banners');
```

### 2️⃣ RLS 정책 이력

**비활성화된 이전 정책들** (`.disabled` 상태):
- `20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql.disabled`
- `20251106000002_fix_storage_bucket_policies_prd_v9_6_2.sql.disabled`

**활성 RLS 정책**: ❌ **없음**

---

## 🛡️ 2. Edge Functions (보안 래퍼) 현황

### 1️⃣ 배포된 Edge Functions

**총 1개 배포됨**:

#### `fetch-lh-announcements`
- **목적**: 한국토지주택공사(LH) 공고 데이터 수집
- **경로**: `backend/supabase/functions/fetch-lh-announcements/index.ts`
- **권한**: Service Role Key 사용 (admin 권한)
- **보안**:
  - ✅ CORS 헤더 설정됨
  - ✅ Service Role Key로 RLS 우회
  - ✅ 외부 API 인증 키 환경 변수로 관리
  - ⚠️ 인증 검증 없음 (누구나 호출 가능)

### 2️⃣ 계획되었으나 구현되지 않은 보안 래퍼

**❌ 구현되지 않음**:
- `safe_api_wrapper.ts` - 없음
- `verify_admin_access()` - 없음
- Admin API Guard Functions - 없음

**현재 상태**: **보안 래핑 함수 미구현**

---

## 🔌 3. Admin 앱 API 엔드포인트 사용 현황

### 1️⃣ Admin 앱 Supabase 클라이언트 설정

**파일**: `apps/pickly_admin/src/lib/supabase.ts`

```typescript
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseServiceRoleKey = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY

// ⚠️ SECURITY: Service Role Key 사용 (RLS 우회)
export const supabase = createClient<Database>(supabaseUrl, supabaseServiceRoleKey, {
  auth: {
    persistSession: true,
    autoRefreshToken: true,
    detectSessionInUrl: true,
  },
})
```

### 2️⃣ API 호출 방식

**직접 REST API 호출** (Supabase JS SDK):
- `supabase.from('benefit_categories').select()`
- `supabase.from('age_categories').select()`
- `supabase.from('announcements').insert()`
- `supabase.storage.from('benefit-icons').upload()`

**Edge Functions 호출**:
- ✅ `supabase.functions.invoke('fetch-lh-announcements')`
  - **파일**: `apps/pickly_admin/src/api/announcements.ts`

### 3️⃣ 보안 상태

| 항목 | 상태 | 비고 |
|------|------|------|
| Service Role Key 사용 | ✅ | RLS 우회 필요 |
| 브라우저 노출 | ⚠️ **위험** | 개발자 도구에서 Key 확인 가능 |
| Admin 인증 | ✅ | Supabase Auth 사용 |
| API 래핑 | ❌ | 직접 REST API 호출 |
| 요청 검증 | ❌ | Service Role Key만 의존 |

**⚠️ 주요 보안 위험**:
1. **Service Role Key가 브라우저(클라이언트)에 노출됨**
2. Admin 인증이 있더라도, Key가 탈취되면 전체 DB 접근 가능
3. RLS가 비활성화되어 있어 추가 보호 계층 없음

---

## 📱 4. Flutter 앱 API 엔드포인트 사용 현황

### 1️⃣ Flutter 앱 Supabase 클라이언트 설정

**파일**: `apps/pickly_mobile/lib/core/services/supabase_service.dart`

```dart
await Supabase.initialize(
  url: url,          // SUPABASE_URL
  anonKey: anonKey,  // SUPABASE_ANON_KEY (public key)
);
```

### 2️⃣ API 호출 방식

**직접 REST API 호출** (Supabase Dart SDK):
- `_supabase.from('age_categories').select()`
- `_supabase.from('announcements').select()`
- `_supabase.from('benefit_categories').select()`
- Realtime 구독: `_supabase.from('age_categories').stream()`

**Edge Functions 호출**: ❌ 없음

### 3️⃣ 보안 상태

| 항목 | 상태 | 비고 |
|------|------|------|
| Anon Key 사용 | ✅ | Public key (안전) |
| 브라우저 노출 | ✅ 안전 | Anon Key는 공개 가능 |
| 사용자 인증 | ❌ | 익명 접근 |
| RLS 보호 | ❌ | RLS 비활성화 상태 |
| 읽기 전용 | ✅ | SELECT만 수행 |

**보안 상태**: ✅ **상대적으로 안전**
- Anon Key 사용으로 노출 위험 낮음
- 읽기 전용이므로 데이터 변조 불가
- ⚠️ 단, RLS가 없어 모든 데이터 읽기 가능

---

## 🚨 5. 보안 위험 분석 및 우선순위

### 🔴 Critical (즉시 조치 필요)

#### 1. **Admin Service Role Key 클라이언트 노출**

**위험도**: ⚠️ **매우 높음 (CRITICAL)**

**문제점**:
```typescript
// ❌ BAD: Service Role Key가 브라우저에서 접근 가능
const supabaseServiceRoleKey = import.meta.env.VITE_SUPABASE_SERVICE_ROLE_KEY
```

**영향**:
- 브라우저 개발자 도구에서 Key 확인 가능
- Key 탈취 시 전체 데이터베이스 읽기/쓰기/삭제 가능
- RLS 없이 모든 테이블 무제한 접근

**해결 방법**:
1. **Option A: API 래핑 (권장)**
   ```
   Admin UI → Backend API (Express/NestJS) → Supabase (Service Role)
   ```
   - Backend에서 Service Role Key 관리
   - Admin 인증 검증 후 API 호출
   - Anon Key만 클라이언트에 노출

2. **Option B: Edge Functions로 완전 이관**
   ```
   Admin UI → Edge Functions (Admin Guard) → Supabase
   ```
   - 모든 write 작업을 Edge Function으로 이관
   - Function에서 Admin 권한 검증
   - Anon Key로 전환

---

### 🟡 Medium (단계적 개선)

#### 2. **RLS 비활성화 상태 장기 유지**

**위험도**: ⚠️ **중간**

**문제점**:
- 모든 테이블의 RLS가 비활성화됨
- Flutter 앱에서 Anon Key로 모든 데이터 읽기 가능
- 추가 보안 계층 없음

**영향**:
- 민감 데이터 노출 위험 (현재는 공개 데이터만 있음)
- 향후 개인정보 추가 시 보안 문제

**해결 방법**:
1. **Phase 1: 읽기 전용 RLS 추가**
   ```sql
   -- Allow anonymous read access
   CREATE POLICY "Public read access"
   ON public.announcements
   FOR SELECT
   USING (is_active = true);

   -- Admin write access
   CREATE POLICY "Admin write access"
   ON public.announcements
   FOR ALL
   USING (auth.jwt() ->> 'role' = 'admin');
   ```

2. **Phase 2: 세분화된 RLS**
   - 카테고리별 접근 제어
   - 지역별 필터링
   - 사용자별 맞춤 정책

---

### 🟢 Low (장기 개선)

#### 3. **Edge Functions 인증 검증 부재**

**위험도**: ⚠️ **낮음** (현재는 읽기 전용 공개 데이터)

**문제점**:
- `fetch-lh-announcements` 함수에 인증 검증 없음
- 누구나 호출 가능 (API 키 필요 없음)

**영향**:
- 외부에서 무단 호출 가능
- Rate limiting 없음
- DDoS 위험

**해결 방법**:
```typescript
// Add JWT verification
const authHeader = req.headers.get('Authorization');
const jwt = authHeader?.replace('Bearer ', '');

const { data: { user }, error } = await supabase.auth.getUser(jwt);
if (error || !user) {
  return new Response('Unauthorized', { status: 401 });
}

// Check admin role
const isAdmin = user.user_metadata?.role === 'admin';
if (!isAdmin) {
  return new Response('Forbidden', { status: 403 });
}
```

---

## 📊 6. 보안 스코어카드

| 평가 항목 | 점수 | 상태 | 비고 |
|----------|------|------|------|
| RLS 설정 | 0/10 | ❌ | 완전 비활성화 |
| Admin 키 관리 | 2/10 | 🔴 | 클라이언트 노출 |
| Flutter 앱 보안 | 7/10 | 🟡 | Anon Key 사용 (안전) |
| Edge Functions 보안 | 5/10 | 🟡 | 인증 없음 |
| API 래핑 | 0/10 | ❌ | 미구현 |
| 인증/인가 | 6/10 | 🟡 | Admin Auth 있음 |
| **전체 평균** | **3.3/10** | 🔴 **위험** | 즉시 개선 필요 |

---

## ✅ 7. 즉시 보완 권장 사항

### 🚀 Phase 1: 긴급 보안 조치 (1-2일)

#### 1. **Admin Service Role Key 제거**

**방법 A: Backend API 서버 구축** (권장)
```
pickly_service/
├── backend/
│   ├── api/              # ← NEW: Express/NestJS API
│   │   ├── src/
│   │   │   ├── auth/     # Admin 인증
│   │   │   ├── admin/    # Admin CRUD API
│   │   │   └── config/   # Service Role Key
│   └── supabase/
```

**구현**:
```typescript
// backend/api/src/admin/admin.controller.ts
@UseGuards(AdminAuthGuard)
@Controller('admin')
export class AdminController {
  @Post('benefit-categories')
  async createCategory(@Body() data, @Req() req) {
    // Verify admin session
    const isAdmin = await this.verifyAdminToken(req.headers.authorization);

    // Use Service Role Key (server-side)
    return this.supabaseAdmin.from('benefit_categories').insert(data);
  }
}
```

**Admin UI 변경**:
```typescript
// apps/pickly_admin/src/lib/supabase.ts
// ❌ REMOVE Service Role Key
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY

// ✅ Use Anon Key + Backend API
export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// Call backend API instead
await fetch('/api/admin/benefit-categories', {
  method: 'POST',
  headers: {
    'Authorization': `Bearer ${session.access_token}`
  },
  body: JSON.stringify(data)
});
```

---

**방법 B: Edge Functions 이관** (빠른 대안)

```typescript
// supabase/functions/admin-categories/index.ts
serve(async (req) => {
  // Verify admin JWT
  const jwt = req.headers.get('Authorization')?.replace('Bearer ', '');
  const { data: { user }, error } = await supabase.auth.getUser(jwt);

  if (error || user?.user_metadata?.role !== 'admin') {
    return new Response('Forbidden', { status: 403 });
  }

  // Use Service Role Key (server-side)
  const adminClient = createClient(
    Deno.env.get('SUPABASE_URL')!,
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY')!
  );

  const { data, error: dbError } = await adminClient
    .from('benefit_categories')
    .insert(await req.json());

  return new Response(JSON.stringify(data));
});
```

**배포**:
```bash
supabase functions deploy admin-categories
supabase functions deploy admin-announcements
supabase functions deploy admin-age-categories
# ... 모든 write 작업
```

---

### 🛡️ Phase 2: RLS 점진적 활성화 (1주)

#### 1. **읽기 전용 공개 정책**

```sql
-- announcements: 공개 읽기
ALTER TABLE announcements ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read active announcements"
ON announcements FOR SELECT
USING (is_active = true AND status = 'published');

-- benefit_categories: 공개 읽기
ALTER TABLE benefit_categories ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Public read active categories"
ON benefit_categories FOR SELECT
USING (is_active = true);
```

#### 2. **Admin 쓰기 정책**

```sql
-- Admin role만 write 가능
CREATE POLICY "Admin full access"
ON announcements FOR ALL
USING (
  auth.jwt() ->> 'email' = 'admin@pickly.com'
  OR
  (auth.jwt() -> 'user_metadata' ->> 'role') = 'admin'
);
```

---

### 🔐 Phase 3: 종합 보안 강화 (2주)

1. **Rate Limiting 추가**
   - Supabase Edge Functions에 Rate Limiter 구현
   - 또는 Cloudflare/AWS WAF 사용

2. **감사 로그 (Audit Log)**
   ```sql
   CREATE TABLE audit_logs (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     user_id UUID REFERENCES auth.users(id),
     action TEXT NOT NULL,
     table_name TEXT,
     record_id UUID,
     old_data JSONB,
     new_data JSONB,
     created_at TIMESTAMPTZ DEFAULT NOW()
   );
   ```

3. **IP 화이트리스트** (Admin 앱)
   - Backend API에 IP 제한
   - 또는 VPN 필수

---

## 📋 8. 최종 체크리스트

### 즉시 조치 (이번 주)

- [ ] **Admin Service Role Key를 환경 변수에서 제거**
- [ ] **Backend API 서버 구축** 또는 **Edge Functions 이관**
- [ ] **Admin UI를 Anon Key로 전환**
- [ ] **모든 write 작업을 Backend/Edge Functions로 이관**
- [ ] **Production 배포 후 Service Role Key 재생성**

### 단계적 개선 (1-2주)

- [ ] 주요 테이블에 **읽기 전용 RLS 활성화**
- [ ] **Admin 전용 쓰기 정책** 추가
- [ ] **Edge Functions에 인증 검증** 추가
- [ ] **Rate Limiting 구현**

### 장기 개선 (1개월)

- [ ] **감사 로그 시스템** 구축
- [ ] **세분화된 RLS 정책** (카테고리별, 지역별)
- [ ] **IP 화이트리스트** 또는 VPN
- [ ] **정기 보안 감사** 프로세스 확립

---

## 🎯 9. 현재 권장 조치 (RLS 없는 안전한 런칭)

### ✅ 즉시 실행 가능한 최소 보안 조치

**목표**: Service Role Key 노출 제거 + Anon Key로 전환

#### Step 1: Backend API 최소 구현 (Express.js)

```bash
cd backend
mkdir -p api/src/{routes,middleware,controllers}
npm init -y
npm install express @supabase/supabase-js cors dotenv jsonwebtoken
```

```javascript
// backend/api/src/app.js
const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors({ origin: 'http://localhost:5180' }));
app.use(express.json());

// Service Role Key는 서버에서만
const supabase = createClient(
  process.env.SUPABASE_URL,
  process.env.SUPABASE_SERVICE_ROLE_KEY
);

// Admin 인증 미들웨어
async function verifyAdmin(req, res, next) {
  const token = req.headers.authorization?.replace('Bearer ', '');
  const { data: { user }, error } = await supabase.auth.getUser(token);

  if (error || !user || user.email !== 'admin@pickly.com') {
    return res.status(403).json({ error: 'Unauthorized' });
  }

  req.user = user;
  next();
}

// Admin CRUD endpoints
app.post('/admin/benefit-categories', verifyAdmin, async (req, res) => {
  const { data, error } = await supabase
    .from('benefit_categories')
    .insert(req.body)
    .select();

  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.listen(3001, () => console.log('Admin API running on port 3001'));
```

#### Step 2: Admin UI 변경

```typescript
// apps/pickly_admin/src/lib/supabase.ts
const supabaseUrl = import.meta.env.VITE_SUPABASE_URL
const supabaseAnonKey = import.meta.env.VITE_SUPABASE_ANON_KEY // ✅ Anon Key

export const supabase = createClient(supabaseUrl, supabaseAnonKey);

// apps/pickly_admin/src/lib/api.ts
const API_URL = 'http://localhost:3001';

export async function createCategory(data) {
  const session = await supabase.auth.getSession();

  const response = await fetch(`${API_URL}/admin/benefit-categories`, {
    method: 'POST',
    headers: {
      'Authorization': `Bearer ${session.data.session.access_token}`,
      'Content-Type': 'application/json'
    },
    body: JSON.stringify(data)
  });

  return response.json();
}
```

#### Step 3: 환경 변수 업데이트

```bash
# backend/api/.env
SUPABASE_URL=https://vymxxpjxrorpywfmqpuk.supabase.co
SUPABASE_SERVICE_ROLE_KEY=<SECRET_KEY>

# apps/pickly_admin/.env.local
VITE_SUPABASE_URL=https://vymxxpjxrorpywfmqpuk.supabase.co
VITE_SUPABASE_ANON_KEY=<PUBLIC_KEY>
# ❌ REMOVE: VITE_SUPABASE_SERVICE_ROLE_KEY
```

---

## 📌 10. 최종 결론

### 🔴 현재 보안 상태: **위험 (Critical)**

**주요 문제**:
1. ⚠️ **Admin Service Role Key가 브라우저에 노출**
2. ⚠️ **RLS 완전 비활성화**
3. ⚠️ **보안 래퍼 미구현**

### ✅ 즉시 조치 필요

**최우선 과제**: Admin Service Role Key 제거
- Backend API 또는 Edge Functions로 이관
- Anon Key로 전환
- **예상 작업 시간**: 1-2일

**권장 순서**:
1. Backend API 최소 구현 (Express.js)
2. Admin write 작업 모두 Backend API로 이관
3. Admin UI를 Anon Key로 전환
4. Production Service Role Key 재생성
5. RLS 점진적 활성화 (읽기 전용부터)

### 📊 보안 개선 로드맵

| Phase | 작업 | 기간 | 우선순위 |
|-------|------|------|----------|
| **Phase 1** | Admin Key 제거 + Backend API | 1-2일 | 🔴 Critical |
| **Phase 2** | 읽기 전용 RLS 활성화 | 3-5일 | 🟡 High |
| **Phase 3** | Admin 쓰기 RLS 정책 | 1주 | 🟡 Medium |
| **Phase 4** | 감사 로그 + Rate Limiting | 2주 | 🟢 Low |

---

**Report Generated**: 2025-11-12
**Auditor**: Claude Code
**Environment**: Local Development & Production (vymxxpjxrorpywfmqpuk)
**Status**: ⚠️ **Immediate Action Required**
**Next Review**: After Phase 1 completion
