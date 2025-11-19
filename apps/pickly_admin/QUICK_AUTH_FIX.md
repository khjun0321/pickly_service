# 🚨 QUICK AUTH FIX - Pickly Admin Login Issue

## 문제 상황
Admin UI 로그인 시 "Failed to fetch" 에러 발생

## 원인
`.env.production.local` 파일에 Production anon key가 입력되지 않음

## 즉시 해결 방법 (5분)

### 1️⃣ Production Anon Key 복사

**Supabase Dashboard 접속**:
```
https://supabase.com/dashboard/project/vymxxpjxrorpywfmqpuk/settings/api
```

**"Project API keys" 섹션에서**:
- "anon" → "public" 키 복사
- 형식: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` (긴 문자열)

### 2️⃣ .env.production.local 파일 수정

**파일 경로**:
```
/Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_admin/.env.production.local
```

**수정 전**:
```env
VITE_SUPABASE_ANON_KEY=[PLEASE_INSERT_PRODUCTION_ANON_KEY_HERE]
```

**수정 후** (복사한 키 붙여넣기):
```env
VITE_SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InZ5bXh4cGp4cm9yeXd3Zm1xdXVrIiwicm9sZSI6ImFub24iLCJpYXQiOjE2OTg3NzM2MjQsImV4cCI6MjAxNDM0OTYyNH0.xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

⚠️ **주의**: 절대로 이 파일을 git commit 하지 마세요!

### 3️⃣ Dev Server 재시작

**터미널에서**:
```bash
# 1. 현재 실행 중인 dev server 종료
lsof -ti:5180 | xargs kill -9

# 2. Admin 디렉토리로 이동
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_admin

# 3. Production 모드로 dev server 시작
npm run dev -- --mode production
```

**또는** (더 간단한 방법):
```bash
# .env.production.local을 .env.local로 임시 이름 변경 (모든 환경에서 우선 적용)
mv .env.production.local .env.local

# 일반 모드로 dev server 시작
npm run dev
```

### 4️⃣ 브라우저 확인

**접속**: http://localhost:5180

**브라우저 콘솔(F12) 확인**:
```
✅ 정상: "🟢 Supabase connection: READY"
✅ 정상: "Found 2 Storage buckets"
✅ 정상: "Found X announcements"

❌ 에러: "Failed to fetch"
❌ 에러: "Invalid API key"
```

### 5️⃣ 로그인 테스트

**테스트 계정으로 로그인**:
- Email: `admin@pickly.com` (또는 귀하의 테스트 계정)
- Password: (귀하의 비밀번호)

**성공 시**:
- ✅ 로그인 성공
- ✅ 대시보드로 리다이렉트
- ✅ 데이터 정상 로드

---

## 여전히 안 되는 경우

### 옵션 A: 로컬 Supabase 사용 (권장 - 개발 전용)

```bash
# 1. 백엔드 디렉토리로 이동
cd /Users/kwonhyunjun/Desktop/pickly_service/backend

# 2. 로컬 Supabase 시작
supabase start

# 3. 출력된 anon key 복사 (eyJ로 시작하는 긴 문자열)

# 4. Admin 디렉토리로 이동
cd ../apps/pickly_admin

# 5. .env 파일 확인 (이미 설정되어 있어야 함)
cat .env
# VITE_SUPABASE_URL=http://127.0.0.1:54321
# VITE_SUPABASE_ANON_KEY=<복사한_anon_key>

# 6. Dev server 시작 (일반 모드)
npm run dev
```

**접속**: http://localhost:5180

**테스트 계정 생성 필요**:
- Supabase Studio: http://127.0.0.1:54323
- Authentication → Users → "Add user"
- Email: `admin@pickly.com`, Password: 원하는 비밀번호

### 옵션 B: Dashboard 설정 확인

**Site URL 확인**:
```
Dashboard → Auth → URL Configuration → Site URL
값: http://localhost:5180
```

**Redirect URLs 확인**:
```
Dashboard → Auth → URL Configuration → Redirect URLs
추가: http://localhost:5180/**
추가: http://localhost:5173/**
```

---

## 상세 문서

전체 분석 및 해결 방법:
```
docs/prd/Pickly_v9.12.0_Auth_Recovery_Report.md
```

---

## 자주 묻는 질문

**Q: anon key를 어디서 찾나요?**
A: Supabase Dashboard → Project Settings → API → "anon public" 키

**Q: 키를 붙여넣었는데도 안 됩니다**
A: Dev server를 재시작했나요? 환경 변수 변경 시 재시작 필수

**Q: "Invalid API key" 에러가 나옵니다**
A: 복사한 키가 올바른지 확인 (공백 없이, 전체 문자열)

**Q: 로그인은 되는데 바로 로그아웃됩니다**
A: 이메일 확인(email_confirmed_at) 필요. Dashboard에서 user "Confirm email"

**Q: 개발 중에는 어떤 방법이 좋나요?**
A: 로컬 Supabase 사용 (supabase start) 권장

---

**마지막 업데이트**: 2025-11-12
**문제 해결 안 되면**: 상세 리포트 참고 또는 이슈 등록
