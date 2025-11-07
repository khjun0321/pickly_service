# 🧩 Phase 5.3 Hotfix — Admin Insert RLS Policy for age_categories

**PRD**: v9.6.2
**Status**: Ready to Execute
**Issue**: Admin cannot INSERT into age_categories due to RLS policy violation

---

## 🎯 Objective

관리자(`admin@pickly.com`)로 로그인했을 때
`age_categories` 테이블에 INSERT 시 발생하는 RLS 에러 수정

---

## 🧩 Root Cause Analysis

### 가능한 원인:

1. **JWT에 `user_role` 클레임 없음**
   - Admin metadata가 설정되었어도, 로그인 **이전**에 설정된 경우 JWT에 반영 안 됨
   - 해결: 로그아웃 → 재로그인 (새 JWT 발급)

2. **RLS 정책 자체가 없음**
   - `age_categories` 테이블에 admin INSERT 정책이 없거나 잘못됨
   - 해결: 정책 생성/수정

3. **RLS 정책 조건 오류**
   - `auth.jwt() ->> 'user_role'` vs `auth.jwt() -> 'user_role'` (화살표 개수)
   - 해결: 올바른 syntax 사용

---

## ⚙️ Step-by-Step Fix

### Step 1️⃣: Admin Metadata 확인

**Supabase Studio SQL Editor**에서 실행:

```sql
-- Check if user_role is set
SELECT
  email,
  raw_app_meta_data->>'user_role' as role,
  raw_app_meta_data
FROM auth.users
WHERE email = 'admin@pickly.com';
```

**Expected Output:**
```
email              | role  | raw_app_meta_data
-------------------+-------+-------------------
admin@pickly.com   | admin | {"user_role": "admin", ...}
```

✅ `role = 'admin'` 이어야 함!

❌ `role`이 비어있으면:
```sql
UPDATE auth.users
SET raw_app_meta_data =
  COALESCE(raw_app_meta_data, '{}'::jsonb) ||
  '{"user_role": "admin"}'::jsonb
WHERE email = 'admin@pickly.com';
```

---

### Step 2️⃣: 현재 RLS 정책 확인

```sql
-- Check existing RLS policies for age_categories
SELECT
  policyname,
  cmd,
  qual,
  with_check
FROM pg_policies
WHERE tablename = 'age_categories'
ORDER BY policyname;
```

**Expected:**
- `admin_insert_age_categories` (INSERT, authenticated, user_role='admin')
- `admin_select_age_categories` (SELECT, authenticated, user_role='admin')
- `admin_update_age_categories` (UPDATE, authenticated, user_role='admin')
- `admin_delete_age_categories` (DELETE, authenticated, user_role='admin')
- `public_select_active_age_categories` (SELECT, anon/authenticated, is_active=true)

❌ **정책이 없거나 다르면** → Step 3으로 이동

---

### Step 3️⃣: RLS 정책 생성/수정

**Option A: 전체 재생성 (권장)**

```sql
-- ================================================================
-- Drop all existing age_categories RLS policies
-- ================================================================

DROP POLICY IF EXISTS "admin_select_age_categories" ON public.age_categories;
DROP POLICY IF EXISTS "admin_insert_age_categories" ON public.age_categories;
DROP POLICY IF EXISTS "admin_update_age_categories" ON public.age_categories;
DROP POLICY IF EXISTS "admin_delete_age_categories" ON public.age_categories;
DROP POLICY IF EXISTS "public_select_active_age_categories" ON public.age_categories;

-- Drop old naming patterns (if exist)
DROP POLICY IF EXISTS "Enable read access for all users" ON public.age_categories;
DROP POLICY IF EXISTS "Enable insert for authenticated users only" ON public.age_categories;
DROP POLICY IF EXISTS "Enable update for users based on user_id" ON public.age_categories;

-- ================================================================
-- Create new role-based RLS policies
-- ================================================================

-- Admin can SELECT all (including inactive)
CREATE POLICY "admin_select_age_categories"
ON public.age_categories
FOR SELECT
TO authenticated
USING (auth.jwt() ->> 'user_role' = 'admin');

-- Admin can INSERT
CREATE POLICY "admin_insert_age_categories"
ON public.age_categories
FOR INSERT
TO authenticated
WITH CHECK (auth.jwt() ->> 'user_role' = 'admin');

-- Admin can UPDATE
CREATE POLICY "admin_update_age_categories"
ON public.age_categories
FOR UPDATE
TO authenticated
USING (auth.jwt() ->> 'user_role' = 'admin')
WITH CHECK (auth.jwt() ->> 'user_role' = 'admin');

-- Admin can DELETE
CREATE POLICY "admin_delete_age_categories"
ON public.age_categories
FOR DELETE
TO authenticated
USING (auth.jwt() ->> 'user_role' = 'admin');

-- Public can SELECT only active
CREATE POLICY "public_select_active_age_categories"
ON public.age_categories
FOR SELECT
TO anon, authenticated
USING (is_active = true);
```

**Option B: INSERT 정책만 수정 (빠른 픽스)**

```sql
-- Drop existing INSERT policy
DROP POLICY IF EXISTS "admin_insert_age_categories" ON public.age_categories;

-- Create correct INSERT policy
CREATE POLICY "admin_insert_age_categories"
ON public.age_categories
FOR INSERT
TO authenticated
WITH CHECK (auth.jwt() ->> 'user_role' = 'admin');
```

---

### Step 4️⃣: 정책 적용 확인

```sql
-- Verify all 5 policies exist
SELECT policyname, cmd
FROM pg_policies
WHERE tablename = 'age_categories'
ORDER BY policyname;
```

**Expected Output:**
```
policyname                            | cmd
--------------------------------------+--------
admin_delete_age_categories           | DELETE
admin_insert_age_categories           | INSERT
admin_select_age_categories           | SELECT
admin_update_age_categories           | UPDATE
public_select_active_age_categories   | SELECT
```

✅ 5개 정책 모두 있어야 함!

---

### Step 5️⃣: JWT 토큰 새로고침 (중요!)

**Admin 페이지에서 로그아웃 → 재로그인**

1. Admin 우측 상단 **로그아웃 버튼** 클릭
2. 로그인 페이지로 이동
3. 다시 로그인:
   - 이메일: `admin@pickly.com`
   - 비밀번호: `pickly2025!`

**Why?**
- Metadata는 **로그인 시점**에만 JWT에 포함됨
- 기존 세션의 JWT는 `user_role` 없을 수 있음
- 재로그인으로 **새 JWT** 발급 → `user_role='admin'` 포함

---

### Step 6️⃣: JWT 확인 (Optional, Debugging용)

**브라우저 개발자 도구 Console**에서:

```javascript
const { data: { session } } = await supabase.auth.getSession();
if (session) {
  const payload = JSON.parse(atob(session.access_token.split('.')[1]));
  console.log('JWT user_role:', payload.user_role);
  console.log('Full JWT:', payload);
}
```

**Expected Output:**
```javascript
JWT user_role: admin
Full JWT: {
  aud: "authenticated",
  exp: ...,
  sub: "...",
  email: "admin@pickly.com",
  user_role: "admin",  // ← 이게 있어야 함!
  ...
}
```

❌ `user_role`이 없으면:
- Step 1 다시 확인 (metadata 설정)
- Step 5 다시 확인 (로그아웃 → 재로그인)

---

### Step 7️⃣: INSERT 테스트

**Admin UI에서 연령 카테고리 추가 시도:**

1. **연령 카테고리 관리** 페이지로 이동
2. **추가** 버튼 클릭
3. 정보 입력 후 **저장** 클릭

**Expected:**
- ✅ 정상적으로 저장됨
- ✅ "저장되었습니다" 메시지
- ✅ 목록에 새 항목 표시
- ✅ 콘솔에 RLS 에러 없음

---

## 🐛 Troubleshooting

### Issue 1: "new row violates row-level security policy for table age_categories"

**Cause**: JWT에 `user_role='admin'` 없음

**Solution**:
1. Step 5 재실행 (로그아웃 → 재로그인)
2. Step 6으로 JWT 확인
3. 여전히 없으면 Step 1로 돌아가서 metadata 재설정

---

### Issue 2: 정책은 있는데 여전히 INSERT 안 됨

**Cause**: 정책 syntax 오류 또는 조건 불일치

**Debugging**:

```sql
-- Test policy directly
SELECT
  auth.jwt() ->> 'user_role' as jwt_role,
  auth.uid() as user_id,
  auth.email() as email;
```

**Expected**: `jwt_role = 'admin'`

**If `jwt_role` is NULL**:
- 로그아웃 → 재로그인 필요
- Admin metadata 재확인 필요

---

### Issue 3: 로그인 후에도 여전히 안 됨

**Nuclear Option**: Supabase Auth 완전 재시작

```bash
docker restart supabase_auth_supabase
docker restart supabase_db_supabase

# Wait 30 seconds
sleep 30

# Check containers healthy
docker ps | grep supabase
```

그 후 다시 로그인 시도

---

## ✅ Success Criteria

Hotfix 완료 조건:

- [x] `auth.users`에서 `user_role='admin'` 확인
- [x] `age_categories` 테이블에 5개 RLS 정책 존재
- [x] 로그아웃 → 재로그인 완료
- [x] JWT 토큰에 `user_role: "admin"` 포함 확인
- [x] Admin UI에서 연령 카테고리 추가 성공
- [x] 콘솔에 RLS 에러 없음

---

## 📌 Related Files

- **RLS Migration**: `backend/supabase/migrations/20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql`
- **Quick Guide**: `docs/PHASE5_3_QUICK_START_GUIDE.md`
- **Complete Guide**: `docs/PHASE5_3_COMPLETE_PRD_v9_6_2_IMPLEMENTATION.md`

---

## 🔄 If This Doesn't Work

최종 해결 방법: **전체 Phase 5.3 마이그레이션 적용**

1. Supabase Studio SQL Editor 열기
2. `20251106000001_fix_rls_admin_role_guard_prd_v9_6_2.sql` 전체 실행
3. `20251106000002_fix_storage_bucket_policies_prd_v9_6_2.sql` 실행
4. `20251106000003_update_admin_user_metadata.sql` 실행
5. 로그아웃 → 재로그인
6. 다시 테스트

---

**Last Updated**: 2025-11-06
**Author**: Claude Code
**PRD**: v9.6.2
**Priority**: P0 (Blocker)
