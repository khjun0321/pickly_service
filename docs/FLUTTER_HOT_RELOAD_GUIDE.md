# Flutter 핫 리로드 가이드 - 백엔드 변경사항 반영

**Date**: 2025-11-04
**Simulator**: iPhone 16 Pro (BBCCD2EB-A73C-4818-88BB-5E24FA3CFA53)
**Status**: ✅ Simulator Running

---

## 📋 최근 백엔드 변경사항

### 1. Admin 로그인 수정 ✅
- **Migration**: `20251101000010_create_dev_admin_user.sql`
- **Fix**: Token 필드 NULL → 빈 문자열('')
- **Result**: `admin@pickly.com` 로그인 정상 작동

### 2. Storage RLS 정책 추가 ✅
- **Migration**: `20251104000001_add_admin_rls_storage_objects.sql`
- **Bucket**: `icons` (public)
- **Policies**: Admin INSERT/UPDATE/DELETE 권한

### 3. Supabase 마이그레이션 완료 ✅
- 모든 마이그레이션 성공적으로 적용
- `supabase db reset` 완료
- Admin 계정 생성 완료

---

## 🔄 핫 리로드 방법

### 방법 1: Flutter 터미널에서 직접 리로드

Flutter 앱이 실행 중인 터미널에서:
```bash
# Hot Reload
r

# Hot Restart (완전 재시작)
R

# 종료
q
```

### 방법 2: VS Code/Android Studio에서

- **VS Code**: `Cmd + Shift + P` → "Flutter: Hot Reload"
- **Android Studio**: Lightning 아이콘 클릭 또는 `Cmd + \`

### 방법 3: 명령줄에서 수동 실행

```bash
cd /Users/kwonhyunjun/Desktop/pickly_service/apps/pickly_mobile

# 시뮬레이터에서 실행
flutter run --device-id=BBCCD2EB-A73C-4818-88BB-5E24FA3CFA53
```

---

## ⚠️ 발견된 이슈

### SVG 아이콘 URL 에러 (✅ 부분 해결)

**Phase 1: No Host Error** (✅ 해결됨)
```
Invalid argument(s): No host specified in URI baby.svg
```

**원인**: DB의 `age_categories` 테이블에서 `icon_url` 필드가 상대 경로만 저장되어 있음
**해결**: DB URL 업데이트 완료
```sql
UPDATE age_categories
SET icon_url = 'http://127.0.0.1:54321/storage/v1/object/public/icons/' || icon_url
WHERE icon_url NOT LIKE 'http%';
-- ✅ 6 rows updated
```

**Phase 2: Invalid SVG Data** (⚠️ 현재 이슈)
```
[ERROR] Unhandled Exception: Bad state: Invalid SVG data
```

**원인**: Storage bucket에 실제 SVG 파일이 없음
- `icons` 버킷은 존재함 (public)
- 하지만 `storage.objects` 테이블이 비어있음 (0 rows)
- Flutter가 URL로 접근하지만 404 Not Found 상태

**해결 방법**:

#### 옵션 1: SVG 파일 업로드 (권장)
```bash
# Admin 패널에서 SVG 파일 업로드:
# http://localhost:5174/
# 1. 로그인 (admin@pickly.com)
# 2. 아이콘 관리 페이지로 이동
# 3. 각 아이콘 업로드:
#    - baby.svg
#    - kinder.svg
#    - old_man.svg
#    - wheelchair.svg
#    - young_man.svg
#    - bride.svg
```

#### 옵션 2: Flutter 코드 수정 (임시)
`lib/contexts/benefit/models/age_category.dart` 수정:
```dart
// 네트워크 대신 로컬 asset 사용
String get iconAssetPath {
  return 'assets/icons/${iconUrl.split('/').last}';
}
```

---

## 🧪 백엔드 변경사항 검증

### 1. Admin 로그인 테스트
```bash
# Admin 패널 접속
open http://localhost:5174/

# 로그인
Email: admin@pickly.com
Password: admin1234
```

### 2. Supabase Auth API 테스트
```bash
curl -X POST 'http://127.0.0.1:54321/auth/v1/token?grant_type=password' \
  -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODM4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0" \
  -H "Content-Type: application/json" \
  -d '{"email": "admin@pickly.com", "password": "admin1234"}'
```

**Expected**: 200 OK with access_token

### 3. DB 확인
```bash
docker exec supabase_db_supabase psql -U postgres -d postgres -c \
  "SELECT email, confirmation_token = '' AS token_ok FROM auth.users WHERE email = 'admin@pickly.com';"
```

**Expected**:
```
      email       | token_ok
------------------+----------
 admin@pickly.com | t
```

---

## 📱 Flutter 앱에서 확인할 사항

### 1. 연령대 카테고리 로딩
- 홈 화면에서 연령대 아이콘이 표시되는지 확인
- SVG 에러가 있다면 아이콘이 표시되지 않을 수 있음

### 2. 데이터 동기화
- Supabase Realtime이 정상 작동하는지 확인
- Admin 패널에서 데이터 변경 시 앱에 실시간 반영되는지 확인

### 3. 인증 상태
- 앱에서 로그아웃/로그인이 정상 작동하는지 확인
- 백엔드 토큰 필드 수정으로 인증 흐름에 영향 없는지 확인

---

## 🚀 시뮬레이터 상태

### 현재 실행 중인 시뮬레이터
```
iPhone 16 Pro (BBCCD2EB-A73C-4518-88BB-5E24FA3CFA53) - Booted
```

### 시뮬레이터 제어 명령어

**부팅**:
```bash
xcrun simctl boot BBCCD2EB-A73C-4818-88BB-5E24FA3CFA53
open -a Simulator
```

**종료**:
```bash
xcrun simctl shutdown BBCCD2EB-A73C-4818-88BB-5E24FA3CFA53
```

**앱 삭제** (완전 재설치 필요 시):
```bash
xcrun simctl uninstall BBCCD2EB-A73C-4818-88BB-5E24FA3CFA53 com.example.pickly_mobile
```

**데이터 초기화**:
```bash
xcrun simctl erase BBCCD2EB-A73C-4818-88BB-5E24FA3CFA53
```

---

## 🔧 트러블슈팅

### 문제 1: 핫 리로드가 안 됨

**해결**:
```bash
# 앱 완전 재시작 (Hot Restart)
터미널에서 'R' 입력

# 또는 완전히 종료 후 재실행
터미널에서 'q' 입력
flutter run --device-id=BBCCD2EB-A73C-4818-88BB-5E24FA3CFA53
```

### 문제 2: SVG 아이콘이 안 보임

**원인**: `icon_url`이 상대 경로

**임시 해결**:
```bash
# DB에서 URL 수정
docker exec supabase_db_supabase psql -U postgres -d postgres -c "
UPDATE age_categories
SET icon_url = 'http://127.0.0.1:54321/storage/v1/object/public/icons/' || icon_url
WHERE icon_url NOT LIKE 'http%';
"
```

**영구 해결**: 새 마이그레이션 생성

### 문제 3: Supabase 연결 안 됨

**확인**:
```bash
# Supabase 서비스 상태 확인
docker ps | grep supabase

# Supabase 재시작
supabase stop
supabase start
```

---

## 📊 백엔드 변경사항 요약

| 항목 | 변경 전 | 변경 후 | 영향 |
|------|---------|---------|------|
| `auth.users.confirmation_token` | NULL | '' (empty string) | ✅ 로그인 정상화 |
| `auth.users.recovery_token` | NULL | '' (empty string) | ✅ 로그인 정상화 |
| Storage `icons` bucket | 미생성 | 생성 (public) | ✅ 아이콘 업로드 가능 |
| Storage RLS policies | 없음 | Admin CRUD 권한 | ✅ Admin 업로드 가능 |
| Admin 계정 | 로그인 실패 | 로그인 성공 | ✅ 인증 정상화 |

---

## ✅ 다음 단계

1. **Flutter 앱 실행 확인**
   - 시뮬레이터에서 앱이 정상 실행되는지 확인
   - SVG 아이콘 에러는 DB URL 수정으로 해결 가능

2. **Admin 패널 테스트**
   - `http://localhost:5174/`에서 로그인 테스트
   - SVG 아이콘 업로드 테스트

3. **데이터 동기화 테스트**
   - Admin에서 데이터 변경
   - Flutter 앱에서 실시간 반영 확인

4. **SVG 아이콘 URL 수정** (필요 시)
   - DB 업데이트 또는
   - Flutter 코드 수정으로 전체 URL 생성

---

**작성일**: 2025-11-04 04:45 UTC
**시뮬레이터**: iPhone 16 Pro (Booted)
**백엔드**: Supabase Local (http://127.0.0.1:54321)
**Admin 패널**: http://localhost:5174/
