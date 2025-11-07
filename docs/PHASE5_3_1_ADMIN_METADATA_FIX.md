# 👑 Phase 5.3.1 — Admin Metadata & Auth Verification

**PRD**: v9.6.2
**Status**: Ready to Execute
**Time Required**: 2-3 minutes

---

## 🎯 Objective

기존 관리자 계정(`admin@pickly.com`)에 **App Metadata를 설정**하고,
RLS 정책이 `user_role='admin'`을 정상적으로 인식하는지 검증

---

## 📋 Step-by-Step Execution

### Step 1️⃣: Supabase Studio SQL Editor 열기

1. **Supabase Studio** 접속: http://localhost:54323
2. 왼쪽 사이드바에서 **SQL Editor** 클릭
3. **New Query** 버튼 클릭

---

### Step 2️⃣: Admin Metadata 추가

아래 SQL을 복사해서 SQL Editor에 붙여넣고 **Run** 클릭:

```sql
-- ================================================================
-- Step 1: Add user_role='admin' to existing user
-- ================================================================

UPDATE auth.users
SET raw_app_meta_data =
  COALESCE(raw_app_meta_data, '{}'::jsonb) ||
  '{"user_role": "admin"}'::jsonb
WHERE email = 'admin@pickly.com';

-- ================================================================
-- Step 2: Verify metadata was set correctly
-- ================================================================

SELECT
  email,
  raw_app_meta_data->>'user_role' as role,
  email_confirmed_at IS NOT NULL as email_confirmed,
  created_at
FROM auth.users
WHERE email = 'admin@pickly.com';
```

**Expected Output:**
```
email              | role  | email_confirmed | created_at
-------------------+-------+-----------------+------------------------
admin@pickly.com   | admin | t               | 2025-11-06 XX:XX:XX
```

✅ `role = 'admin'` 이면 성공!

---

### Step 3️⃣: JWT Claims 확인

새 쿼리 창에서 실행:

```sql
-- ================================================================
-- Verify JWT will include user_role claim
-- ================================================================

SELECT
  email,
  raw_app_meta_data,
  raw_app_meta_data ? 'user_role' as has_user_role_key,
  raw_app_meta_data->>'user_role' as user_role_value
FROM auth.users
WHERE email = 'admin@pickly.com';
```

**Expected Output:**
```
email              | raw_app_meta_data                                    | has_user_role_key | user_role_value
-------------------+------------------------------------------------------+-------------------+-----------------
admin@pickly.com   | {"user_role": "admin", "provider": "email", ...}    | t                 | admin
```

✅ `has_user_role_key = t` 이고 `user_role_value = 'admin'` 이면 성공!

---

### Step 4️⃣: 로그인 테스트

1. **Admin 페이지** 열기: http://localhost:5173/login
2. 로그인:
   - 이메일: `admin@pickly.com`
   - 비밀번호: `pickly2025!`
3. 로그인 버튼 클릭

**Expected:**
- ✅ 로그인 성공
- ✅ 대시보드로 리디렉트
- ✅ 콘솔에 400 Bad Request 에러 없음

---

### Step 5️⃣: JWT Token 확인 (Optional)

**브라우저 개발자 도구 Console**에서 실행:

```javascript
// Supabase 세션의 JWT 토큰 디코드
const { data: { session } } = await supabase.auth.getSession();
if (session) {
  const payload = JSON.parse(atob(session.access_token.split('.')[1]));
  console.log('JWT user_role:', payload.user_role);
  console.log('Full JWT payload:', payload);
}
```

**Expected Output:**
```javascript
JWT user_role: admin
Full JWT payload: {
  aud: "authenticated",
  exp: 1730000000,
  iat: 1730000000,
  sub: "uuid-here",
  email: "admin@pickly.com",
  user_role: "admin",  // ← 이게 있어야 함!
  ...
}
```

---

## 🐛 Troubleshooting

### Issue: Metadata 업데이트 후에도 로그인 안 됨

**Solution 1: 세션 완전 클리어**

브라우저 콘솔에서:
```javascript
localStorage.clear();
sessionStorage.clear();
location.reload();
```

**Solution 2: Supabase Auth 재시작**

터미널에서:
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/backend
supabase db reset
supabase start
```

그 다음 다시 Step 2부터 실행

---

### Issue: JWT에 user_role이 없음

**Cause**: Metadata는 **로그인 시점**에 JWT에 포함됨.
기존 세션은 이전 JWT를 사용 중이므로 새로 로그인해야 함.

**Solution**:
1. 로그아웃
2. 다시 로그인
3. 새 JWT에는 `user_role='admin'` 포함됨

---

### Issue: 400 Bad Request 에러 계속 발생

**Cause**: Auth 서비스와 DB 간 동기화 문제

**Solution**:
```bash
docker restart supabase_auth_supabase
docker restart supabase_db_supabase
```

30초 대기 후 다시 로그인 시도

---

## ✅ Success Criteria

Phase 5.3.1 완료 조건:

- [x] `auth.users` 테이블에서 `raw_app_meta_data->>'user_role' = 'admin'` 확인
- [x] `admin@pickly.com` 로그인 성공
- [x] 대시보드 접근 가능
- [x] 브라우저 콘솔에 400 에러 없음
- [x] JWT 토큰에 `user_role: "admin"` 포함 확인

---

## 📌 Next Steps

Phase 5.3.1 완료 후:

1. **Phase 5.3.2**: RLS 정책 적용 (`20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql`)
2. **Phase 5.3.3**: Storage 정책 적용 (`20251106000002_fix_storage_bucket_policies_prd_v9_6_2.sql`)
3. **Phase 5.3.4**: 파일 업로드 테스트

---

**Last Updated**: 2025-11-06
**Author**: Claude Code
**PRD**: v9.6.2
