# Pickly Admin v9.12.0 Auth Recovery Report
## 로그인 실패 (Failed to fetch) 원인 분석 및 복구 가이드

**Date**: 2025-11-12
**Issue**: Admin UI 로그인 실패 - "Failed to fetch"
**Environment**: Production (vymxxpjxrorpywfmqpuk)
**Status**: 🔴 **ROOT CAUSE IDENTIFIED**

---

## 🎯 Executive Summary

### Issue Description

Admin UI에서 로그인 시도 시 "Failed to fetch" 에러 발생

### Root Cause Identified ✅

**Primary Issue**: `.env.production.local` 파일에 Production anon key가 삽입되지 않음
**Secondary Issue**: Dev server가 기본 `.env` 파일 사용 (로컬 Supabase 대신 Production 사용 필요)

### Impact

- ❌ Production Supabase Auth 연결 불가
- ❌ 로그인 요청이 잘못된 endpoint로 전송
- ❌ Admin UI 접근 불가

### Resolution Required

1. Production anon key 삽입
2. Dev server 환경 변수 설정
3. Supabase Dashboard에서 Site URL/Redirect URLs 확인

---

## 🔍 Detailed Analysis

### 1️⃣ Environment Configuration Analysis

#### Current .env Files Status

**File 1: `.env` (Default - Local Supabase)**
```env
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH
VITE_BYPASS_AUTH=false
```

**Status**: ✅ Valid for local development (local Supabase)
**Problem**: Dev server defaults to this file, points to non-existent local Supabase instance

**File 2: `.env.development.local` (Development with Auto-login)**
```env
VITE_DEV_AUTO_LOGIN=true
VITE_DEV_ADMIN_EMAIL=admin@pickly.com
VITE_DEV_ADMIN_PASSWORD=pickly2025!

VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
VITE_SUPABASE_SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Status**: ✅ Valid for local development with auto-login
**Problem**: Still points to local Supabase, not Production

**File 3: `.env.production.local` (Production - INCOMPLETE)**
```env
VITE_SUPABASE_URL=https://vymxxpjxrorpywfmqpuk.supabase.co
VITE_SUPABASE_ANON_KEY=[PLEASE_INSERT_PRODUCTION_ANON_KEY_HERE]  ← ❌ PLACEHOLDER
VITE_BYPASS_AUTH=false
```

**Status**: ❌ **INVALID - Placeholder not replaced**
**Problem**: Anon key is a placeholder string, not a valid JWT token

#### Environment Variable Priority

Vite loads environment files in this order (highest priority first):
1. `.env.[mode].local` (e.g., `.env.production.local`)
2. `.env.[mode]` (e.g., `.env.production`)
3. `.env.local`
4. `.env`

**Current Behavior**:
- `npm run dev` uses **development mode** by default
- Loads `.env` → points to `http://127.0.0.1:54321` (local Supabase)
- Local Supabase not running → Auth requests fail → "Failed to fetch"

**Expected Behavior** (for Production testing):
- Need to explicitly use Production mode: `npm run dev -- --mode production`
- OR rename `.env.production.local` to `.env.local` (overrides all)
- OR start local Supabase: `supabase start`

---

### 2️⃣ Supabase API Health Check

#### Test 1: Production Auth Health Endpoint

**Command**:
```bash
curl -X GET "https://vymxxpjxrorpywfmqpuk.supabase.co/auth/v1/health" \
  -H "apikey: [test-key]"
```

**Result**:
```json
{
  "message": "Invalid API key",
  "hint": "Double check your Supabase `anon` or `service_role` API key."
}
```

**Analysis**:
- ❌ Test used demo anon key (not Production key)
- ✅ Endpoint is accessible (not a network/CORS issue)
- ✅ Auth service is running (returned error message, not timeout)
- ❌ Need valid Production anon key for actual test

#### Test 2: Local Supabase Check

**Command**:
```bash
curl -X GET "http://127.0.0.1:54321/auth/v1/health"
```

**Expected Result** (if local Supabase running):
```json
{"status": "ok"}
```

**Actual Result**: Connection refused (local Supabase not running)

**Conclusion**: Dev server trying to connect to non-existent local Supabase

---

### 3️⃣ Auth Configuration Requirements

#### Supabase Dashboard Settings (Manual Verification Required)

**Navigate to**: https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/auth/url-configuration

**Required Settings**:

1. **Site URL**:
   ```
   http://localhost:5180
   ```
   **Purpose**: Base URL for local development
   **Status**: ⚠️  Needs manual verification

2. **Redirect URLs** (Allowlist):
   ```
   http://localhost:5180/**
   http://localhost:5180/auth/callback
   http://localhost:5173/**  (if using default Vite port)
   ```
   **Purpose**: Allowed redirect destinations after OAuth
   **Status**: ⚠️  Needs manual verification

3. **Additional Redirect URLs** (Optional):
   ```
   http://127.0.0.1:5180/**
   http://127.0.0.1:5173/**
   ```
   **Purpose**: Support for 127.0.0.1 vs localhost
   **Status**: ⚠️  Recommended

#### CORS Configuration

Supabase automatically handles CORS for Auth endpoints based on:
- Site URL
- Redirect URLs

**No additional CORS configuration needed** if Site URL is set correctly.

---

### 4️⃣ Admin UI Auth Implementation Analysis

#### Current Auth Flow

**File**: `apps/pickly_admin/src/lib/auth.ts` (assumed location)

**Expected Flow**:
1. User submits login form (email, password)
2. Client calls `supabase.auth.signInWithPassword({ email, password })`
3. Request sent to: `${VITE_SUPABASE_URL}/auth/v1/token?grant_type=password`
4. Supabase validates credentials
5. Returns session token + user data

**Current Failure Point**:
- Request attempts to reach: `http://127.0.0.1:54321/auth/v1/token`
- Local Supabase not running
- Connection refused → "Failed to fetch"

#### Auth Connection Test Utility

**File Created Earlier**: `src/lib/test-connection.ts`

**Purpose**: Auto-test Supabase connection on dev server start

**Current Status**: Will fail because:
1. Using `.env` (local Supabase URL)
2. Local Supabase not running
3. No valid anon key

---

## 🛠️ Resolution Steps

### Option 1: Use Production Supabase (Recommended for v9.12.0 Testing)

#### Step 1: Get Production Anon Key

**Method A: Via Supabase Dashboard**
1. Navigate to: https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/settings/api
2. Copy "Project API keys" → "anon" → "public" key
3. Example format: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3...`

**Method B: Via Supabase CLI**
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/backend
supabase status --json | jq -r '.anon_key'
```

#### Step 2: Update .env.production.local

**File**: `apps/pickly_admin/.env.production.local`

**Replace**:
```env
VITE_SUPABASE_ANON_KEY=[PLEASE_INSERT_PRODUCTION_ANON_KEY_HERE]
```

**With** (example):
```env
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5bXh4cGp4cm9yeXd3Zm1xdXVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTg3NzM2MjQsImV4cCI6MjAxNDM0OTYyNH0.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

⚠️ **DO NOT COMMIT THIS FILE TO GIT**

#### Step 3: Restart Dev Server with Production Mode

**Stop current server**:
```bash
# Find PID
lsof -ti:5180

# Kill process
kill -9 <PID>
```

**Start with Production environment**:
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_admin
npm run dev -- --mode production
```

**OR** (alternative):
```bash
# Temporarily rename file to override all
mv .env.production.local .env.local
npm run dev
```

#### Step 4: Verify Connection

**Open browser**: http://localhost:5180

**Check browser console** for:
```
🔍 Testing Supabase connection...
URL: https://vymxxpjxrorpywfmqpuk.supabase.co

📦 Test 1: Listing Storage buckets...
✅ Found 2 Storage buckets
   - announcement-pdfs (public: true)
   - announcement-images (public: true)

📋 Test 2: Querying announcements table...
✅ Found 3 announcements

🔍 Test 3: Checking for v9.12.0 columns...
   Found 0/6 v9.12.0 columns
   ⚠️  v9.12.0 not yet deployed (expected)

✅ All connection tests passed!
🟢 Supabase connection: READY
```

#### Step 5: Test Login

**Navigate to**: http://localhost:5180/login (or root)

**Attempt login with test credentials**:
- Email: `admin@pickly.com` (or your test admin)
- Password: (your test password)

**Expected Result**:
- ✅ Login successful
- ✅ Redirected to dashboard
- ✅ User session created

**If fails**, check:
1. User exists in Production database
2. Password is correct
3. RLS policies allow auth.users access
4. Browser console for specific error messages

---

### Option 2: Start Local Supabase (Alternative for Full Local Development)

#### Step 1: Start Local Supabase

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/backend
supabase start
```

**Expected Output**:
```
Started supabase local development setup.

         API URL: http://127.0.0.1:54321
     GraphQL URL: http://127.0.0.1:54321/graphql/v1
          DB URL: postgresql://postgres:postgres@127.0.0.1:54322/postgres
      Studio URL: http://127.0.0.1:54323
    Inbucket URL: http://127.0.0.1:54324
      JWT secret: super-secret-jwt-token-with-at-least-32-characters-long
        anon key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
service_role key: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

#### Step 2: Verify .env is Configured

**File**: `apps/pickly_admin/.env`

```env
VITE_SUPABASE_URL=http://127.0.0.1:54321
VITE_SUPABASE_ANON_KEY=<anon_key_from_supabase_start_output>
VITE_BYPASS_AUTH=false
```

#### Step 3: Restart Dev Server (Normal Mode)

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_admin
npm run dev
```

**Access**: http://localhost:5180

#### Step 4: Create Test Admin User

**Via Supabase Studio**: http://127.0.0.1:54323
1. Navigate to Authentication → Users
2. Click "Add user"
3. Email: `admin@pickly.com`
4. Password: `pickly2025!` (or your choice)
5. Save

**OR via SQL**:
```sql
-- Via Studio SQL Editor
INSERT INTO auth.users (email, encrypted_password, email_confirmed_at)
VALUES (
  'admin@pickly.com',
  crypt('pickly2025!', gen_salt('bf')),
  now()
);
```

#### Step 5: Test Login

Same as Option 1 Step 5, but with local user credentials.

---

### Option 3: Quick Fix (Temporary for Testing Only)

#### Use Auto-Login (Development Mode)

**File**: `.env.development.local`

Already configured:
```env
VITE_DEV_AUTO_LOGIN=true
VITE_DEV_ADMIN_EMAIL=admin@pickly.com
VITE_DEV_ADMIN_PASSWORD=pickly2025!
```

**Requirements**:
1. Start local Supabase (see Option 2 Step 1)
2. Create admin user with matching credentials
3. Run dev server normally: `npm run dev`

**Result**: Auto-login bypasses login form, immediately authenticates

⚠️ **WARNING**: Only for development, never use in production!

---

## 📋 Verification Checklist

### Pre-Login Checklist

- [ ] **Production anon key** inserted in `.env.production.local`
- [ ] **Dev server restarted** with correct mode
- [ ] **Browser console** shows successful connection test
- [ ] **No network errors** in browser DevTools Network tab
- [ ] **Supabase Dashboard** Site URL = `http://localhost:5180`
- [ ] **Supabase Dashboard** Redirect URLs include `http://localhost:5180/**`

### Post-Login Checklist

- [ ] Login form submits without errors
- [ ] Network tab shows successful POST to `/auth/v1/token`
- [ ] Response includes `access_token` and `refresh_token`
- [ ] User redirected to dashboard
- [ ] Session persisted (refresh page still authenticated)

---

## 🚨 Common Errors and Solutions

### Error 1: "Failed to fetch"

**Symptoms**:
- Login button click → immediate error
- No network request visible in DevTools
- Console shows CORS or network error

**Causes**:
1. Local Supabase not running (using `.env` with localhost URL)
2. Wrong Supabase URL in environment file
3. Network/firewall blocking requests

**Solutions**:
1. Start local Supabase: `supabase start`
2. OR switch to Production mode (Option 1)
3. OR check firewall/proxy settings

---

### Error 2: "Invalid API key"

**Symptoms**:
- Network request completes
- Response: `{"message": "Invalid API key"}`
- Status code: 401

**Causes**:
1. Wrong anon key in `.env` file
2. Anon key is placeholder text
3. Using expired or revoked key

**Solutions**:
1. Copy correct anon key from Supabase Dashboard
2. Verify key format (starts with `eyJ...`)
3. Restart dev server after updating `.env`

---

### Error 3: "Invalid login credentials"

**Symptoms**:
- Network request completes
- Response: `{"error": "Invalid login credentials"}`
- Status code: 400

**Causes**:
1. User doesn't exist in database
2. Wrong password
3. User email not confirmed
4. RLS policies blocking auth.users

**Solutions**:
1. Create user via Supabase Studio or SQL
2. Verify correct email/password
3. Confirm email in auth.users table
4. Check RLS policies on auth.users

---

### Error 4: "Email not confirmed"

**Symptoms**:
- Login succeeds but immediately logs out
- Response includes `email_confirmed_at: null`

**Causes**:
1. Email confirmation required by Auth settings
2. User email_confirmed_at is NULL

**Solutions**:
1. **Via Dashboard**: Auth → Users → Click user → "Confirm email"
2. **Via SQL**:
   ```sql
   UPDATE auth.users
   SET email_confirmed_at = now()
   WHERE email = 'admin@pickly.com';
   ```

---

### Error 5: Redirect URL Not Allowed

**Symptoms**:
- OAuth login fails
- Response: `{"error": "redirect_url not allowed"}`

**Causes**:
1. `http://localhost:5180` not in Redirect URLs list
2. Typo in redirect URL (e.g., missing port)

**Solutions**:
1. Dashboard → Auth → URL Configuration
2. Add to "Redirect URLs":
   ```
   http://localhost:5180/**
   http://localhost:5173/**
   ```
3. Save changes, wait 1-2 minutes for propagation

---

## 🔐 Security Best Practices

### DO ✅

1. **Use anon key only** in frontend (never service_role)
2. **Store Production keys** in `.env.*.local` files (gitignored)
3. **Rotate keys periodically** (every 3-6 months)
4. **Use RLS policies** to protect all tables
5. **Enable email confirmation** for production
6. **Use HTTPS** for production domains (not localhost)

### DON'T ❌

1. **Don't commit** `.env.*.local` files to git
2. **Don't use service_role key** in frontend code
3. **Don't expose anon key** in public GitHub repos
4. **Don't disable RLS** on sensitive tables
5. **Don't share credentials** in plaintext (use secrets managers)
6. **Don't skip email confirmation** in production

---

## 📊 Current Status Summary

| Component | Status | Notes |
|-----------|--------|-------|
| **Production Supabase** | 🟢 Online | Auth service responding |
| **Anon Key** | 🔴 Missing | Placeholder not replaced |
| **Dev Server** | 🟡 Running | Using wrong environment (local) |
| **Environment Files** | 🟡 Incomplete | `.env.production.local` needs key |
| **Connection Test** | 🔴 Failed | No valid Production connection |
| **Login Functionality** | 🔴 Broken | "Failed to fetch" error |
| **Site URL** | ⚠️  Unknown | Manual verification required |
| **Redirect URLs** | ⚠️  Unknown | Manual verification required |

---

## 🎯 Recommended Action Plan

### Immediate (Required for Login to Work)

1. **Get Production Anon Key** (5 minutes)
   - Dashboard → Settings → API → Copy "anon public" key

2. **Update .env.production.local** (1 minute)
   - Replace placeholder with actual key
   - Save file

3. **Restart Dev Server** (1 minute)
   ```bash
   # Kill current
   lsof -ti:5180 | xargs kill -9

   # Start with Production mode
   cd apps/pickly_admin
   npm run dev -- --mode production
   ```

4. **Verify Connection** (2 minutes)
   - Open http://localhost:5180
   - Check console for successful connection test
   - Verify buckets/announcements loaded

5. **Test Login** (2 minutes)
   - Try login with test credentials
   - Check for errors in console
   - Verify successful authentication

**Total Time**: ~10 minutes

---

### Short-Term (Recommended Setup)

6. **Verify Dashboard Settings** (5 minutes)
   - Check Site URL = `http://localhost:5180`
   - Check Redirect URLs include `http://localhost:5180/**`

7. **Create Test Admin User** (if needed, 3 minutes)
   - Via Dashboard or SQL
   - Confirm email address

8. **Test Full Auth Flow** (5 minutes)
   - Login
   - Logout
   - Refresh page (session persistence)
   - Test RLS-protected queries

**Total Time**: ~15 minutes

---

### Long-Term (Production Readiness)

9. **Setup Environment Files Properly**
   - `.env` → Local Supabase (default)
   - `.env.development.local` → Local with auto-login
   - `.env.production.local` → Production (testing)
   - `.env.production` → Production (deployment)

10. **Document Auth Setup**
   - Required credentials
   - Dashboard settings
   - Troubleshooting steps

11. **Setup CI/CD Environment Variables**
   - Store Production keys in GitHub Secrets
   - Auto-inject during build

12. **Monitor Auth Metrics**
   - Dashboard → Auth → Logs
   - Track failed login attempts
   - Set up alerts for auth errors

---

## 📝 Files Requiring Manual Update

### Critical (Must Do Now)

**File**: `apps/pickly_admin/.env.production.local`

**Current**:
```env
VITE_SUPABASE_ANON_KEY=[PLEASE_INSERT_PRODUCTION_ANON_KEY_HERE]
```

**Required**:
```env
VITE_SUPABASE_ANON_KEY=<paste-actual-key-from-dashboard>
```

**Location**: `/Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_admin/.env.production.local`

---

### Optional (Recommended for Full Setup)

**File**: `.gitignore` (verify these are included)

```gitignore
# Environment files with secrets
.env.local
.env.*.local
.env.production
.env.production.local

# But allow .env and .env.example
!.env
!.env.example
```

---

## 🔗 Related Resources

### Supabase Dashboard Links

- **Project Dashboard**: https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk
- **API Settings**: https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/settings/api
- **Auth Settings**: https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/auth/url-configuration
- **Auth Users**: https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/auth/users

### Documentation

- [Supabase Auth Docs](https://supabase.com/docs/guides/auth)
- [Vite Environment Variables](https://vitejs.dev/guide/env-and-mode.html)
- [Supabase CLI Auth](https://supabase.com/docs/reference/cli/supabase-auth)

### Related Reports

- [v9.12.0 Implementation Report](./Pickly_v9.12.0_Implementation_Report.md)
- [v9.12.0 Verification Summary](./Pickly_v9.12.0_Verification_Summary.md)
- [v9.12.0 Local Environment Setup](./Pickly_v9.12.0_Local_Environment_Setup_Report.md)

---

## ✅ Success Criteria

Login is considered **FIXED** when:

1. ✅ Dev server starts without errors
2. ✅ Browser console shows successful Supabase connection
3. ✅ Login form submission triggers network request
4. ✅ Network request reaches Production Supabase Auth endpoint
5. ✅ Response includes valid session tokens
6. ✅ User redirected to dashboard after login
7. ✅ Session persists on page refresh
8. ✅ No "Failed to fetch" errors in console

---

## 🎓 Root Cause Summary

### Primary Issue
**Missing Production Anon Key**
- `.env.production.local` contains placeholder text
- No valid JWT token for Auth requests
- Connection to Production Supabase impossible

### Secondary Issue
**Wrong Environment Mode**
- Dev server defaults to development mode
- Loads `.env` (local Supabase URL)
- Local Supabase not running → connection fails

### Tertiary Issue
**Potentially Missing Dashboard Configuration**
- Site URL may not include `http://localhost:5180`
- Redirect URLs may not allowlist localhost
- Manual verification required via Dashboard

---

## 🛡️ Prevention for Future

1. **Document credentials clearly** in README
2. **Provide .env.example** with placeholders and instructions
3. **Add startup checks** to detect missing credentials
4. **Improve error messages** to hint at missing keys
5. **Add setup script** to validate environment before start

---

**Report Version**: 1.0
**Generated**: 2025-11-12
**Status**: ✅ Analysis Complete - Resolution Steps Provided

---

**END OF AUTH RECOVERY REPORT**
