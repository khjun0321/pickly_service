# Admin 로그인 문제 해결 가이드

## 현재 설정

```
URL: http://localhost:5180/
Local Supabase: http://127.0.0.1:54321
Admin 계정: admin@pickly.com / pickly2025!
```

## 해결된 사항

✅ 환경 변수 설정 완료
✅ Service Role Key 추가
✅ TypeScript 타입 재생성
✅ Auth 서비스 정상 동작 확인
✅ Admin 유저 DB에 존재 확인

## 로그인 시도 방법

### 1. 브라우저 하드 리프레시
```
Chrome/Edge: Cmd+Shift+R (Mac) / Ctrl+Shift+R (Windows)
Firefox: Cmd+Shift+R (Mac) / Ctrl+F5 (Windows)
Safari: Cmd+Option+R (Mac)
```

### 2. 브라우저 캐시 완전 삭제
1. 개발자 도구 열기 (F12)
2. Network 탭
3. "Disable cache" 체크
4. 페이지 새로고침

### 3. 로그인 정보
```
Email: admin@pickly.com
Password: pickly2025!
```

## 만약 여전히 스키마 에러가 나온다면

### A. 콘솔 에러 확인
1. F12로 개발자 도구 열기
2. Console 탭 확인
3. 에러 메시지 전체 복사

### B. Network 요청 확인
1. Network 탭 열기
2. 로그인 시도
3. 실패한 요청 확인
4. Response 탭에서 에러 내용 확인

### C. 일반적인 스키마 에러 원인

**1. TypeScript 타입 불일치**
- 해결: 타입 파일 재생성 (이미 완료됨)

**2. Supabase 클라이언트 초기화 실패**
- 확인: Console에서 "Missing Supabase environment variables" 에러
- 해결: .env.local에 SERVICE_ROLE_KEY 추가 (이미 완료됨)

**3. Auth 테이블 접근 권한**
- 확인: "permission denied for table auth.users"
- 해결: Service Role Key 사용 (이미 설정됨)

**4. CORS 문제**
- 확인: "CORS policy" 에러
- 해결: Local Supabase는 CORS 자동 허용

## 디버깅 명령어

### Local Supabase 상태 확인
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/backend
supabase status
```

### Admin 유저 확인
```bash
docker exec supabase_db_supabase psql -U postgres -d postgres -c "SELECT email FROM auth.users;"
```

### 테스트 로그인 시도 (CLI)
```bash
curl -X POST http://127.0.0.1:54321/auth/v1/token \
  -H "apikey: sb_publishable_ACJWlzQHlZjBrEguHvfOxg_3BJgxAaH" \
  -H "Content-Type: application/json" \
  -d '{
    "email": "admin@pickly.com",
    "password": "pickly2025!",
    "gotrue_meta_security": {}
  }'
```

## 긴급 복구

만약 모든 것이 실패한다면:

### 1. Dev server 재시작
```bash
# 현재 실행 중인 서버 종료 (Ctrl+C)
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_admin
rm -rf node_modules/.vite
npm run dev
```

### 2. Supabase 재시작
```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/backend
supabase stop
supabase start
```

### 3. Admin 유저 재생성
```bash
docker exec supabase_db_supabase psql -U postgres -d postgres -c "
DELETE FROM auth.users WHERE email = 'admin@pickly.com';
INSERT INTO auth.users (instance_id, id, aud, role, email, encrypted_password, email_confirmed_at, raw_user_meta_data, created_at, updated_at, confirmation_token, recovery_token, email_change_token_new, email_change)
VALUES (
  '00000000-0000-0000-0000-000000000000',
  'd8e310c5-2865-4f65-b11d-85d2e1b9dfb2',
  'authenticated',
  'authenticated',
  'admin@pickly.com',
  '\$2a\$10\$O7j3Y8Z1iV9v9hZ9h5Z5Z.OYZ7j3Y8Z1iV9v9hZ9h5Z5ZOYZejZZu',
  NOW(),
  '{\"role\": \"admin\", \"full_name\": \"Admin User\"}',
  NOW(),
  NOW(),
  '',
  '',
  '',
  ''
);
"
```

---

**상태**: ✅ 환경 설정 완료, 로그인 테스트 대기 중
**다음 단계**: 브라우저에서 로그인 시도 후 에러 메시지 확인
