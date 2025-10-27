# LH API 통합 배포 체크리스트 ✅

## 🎯 Phase 1: Backend (Supabase)

### 1.1 데이터베이스 마이그레이션

- [ ] 로컬 환경에서 마이그레이션 테스트
```bash
cd backend/supabase/supabase
supabase db reset
```

- [ ] '주거' 카테고리 존재 확인
```sql
SELECT id, name FROM benefit_categories WHERE name = '주거';
```

- [ ] 없으면 카테고리 생성
```sql
INSERT INTO benefit_categories (name, slug, description, is_active)
VALUES ('주거', 'housing', '주택, 임대, 분양 관련 혜택', true);
```

- [ ] 프로덕션 마이그레이션 적용
```bash
supabase db push
```

### 1.2 Edge Function 배포

- [ ] 환경 변수 설정 확인
```bash
cat backend/supabase/.env.local
```

- [ ] 로컬 테스트
```bash
supabase functions serve fetch-lh-announcements --env-file ../.env.local
```

- [ ] 로컬 호출 테스트
```bash
curl -X POST http://localhost:54321/functions/v1/fetch-lh-announcements \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

- [ ] 프로덕션 배포
```bash
supabase functions deploy fetch-lh-announcements
```

- [ ] 프로덕션 환경 변수 설정
```bash
supabase secrets set LH_API_KEY=2464c0e93735b87e2a66f4439535c9207396d3991ce9bdff236cebe7a76af28b
supabase secrets set LH_API_URL=https://apis.data.go.kr/B552555/lhLeaseNoticeInfo1
```

- [ ] 프로덕션 호출 테스트
```bash
curl -X POST https://YOUR_PROJECT.supabase.co/functions/v1/fetch-lh-announcements \
  -H "Authorization: Bearer YOUR_ANON_KEY"
```

---

## 🖥️ Phase 2: 백오피스 (React Admin)

### 2.1 환경 변수 설정

- [ ] `.env` 파일 확인
```env
VITE_SUPABASE_URL=https://YOUR_PROJECT.supabase.co
VITE_SUPABASE_ANON_KEY=YOUR_ANON_KEY
```

### 2.2 빌드 및 배포

- [ ] TypeScript 타입 체크
```bash
cd apps/pickly_admin
npm run typecheck
```

- [ ] 빌드 테스트
```bash
npm run build
```

- [ ] 로컬 실행 및 테스트
```bash
npm run dev
```

- [ ] "LH 공고 불러오기" 버튼 클릭 테스트
- [ ] 성공 메시지 확인
- [ ] 공고 목록 새로고침 확인

- [ ] 프로덕션 배포
```bash
npm run build
npm run deploy  # 또는 Vercel/Netlify 배포
```

---

## 📱 Phase 3: Flutter 모바일 앱

### 3.1 패키지 설치

- [ ] `pubspec.yaml`에 의존성 추가 확인
```yaml
dependencies:
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  freezed_annotation: ^2.4.4
  json_annotation: ^4.9.0
  intl: ^0.19.0
  url_launcher: ^6.3.0
  supabase_flutter: ^2.5.6

dev_dependencies:
  build_runner: ^2.4.11
  freezed: ^2.5.2
  json_serializable: ^6.8.0
  riverpod_generator: ^2.4.0
```

- [ ] 패키지 설치
```bash
cd apps/pickly_mobile
flutter pub get
```

### 3.2 코드 생성

- [ ] 코드 생성 실행
```bash
dart run build_runner build --delete-conflicting-outputs
```

- [ ] 생성 파일 확인
  - [ ] `announcement.freezed.dart`
  - [ ] `announcement.g.dart`
  - [ ] `announcement_repository.g.dart`
  - [ ] `announcement_provider.g.dart`

### 3.3 Supabase 설정

- [ ] `.env` 파일 생성
```env
SUPABASE_URL=http://127.0.0.1:54321
SUPABASE_ANON_KEY=YOUR_LOCAL_ANON_KEY
```

- [ ] `main.dart`에서 Supabase 초기화 확인
```dart
await Supabase.initialize(
  url: dotenv.env['SUPABASE_URL']!,
  anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
);
```

### 3.4 빌드 및 테스트

- [ ] Dart 분석 실행
```bash
flutter analyze
```

- [ ] 테스트 실행
```bash
flutter test
```

- [ ] 앱 실행 (Android)
```bash
flutter run -d android
```

- [ ] 앱 실행 (iOS)
```bash
flutter run -d ios
```

- [ ] 기능 테스트
  - [ ] 공고 목록 화면 표시
  - [ ] Pull-to-refresh 동작
  - [ ] 공고 카드 탭하여 상세 화면 이동
  - [ ] 조회수 증가 확인
  - [ ] 외부 링크 열기

### 3.5 프로덕션 빌드

- [ ] Android APK 빌드
```bash
flutter build apk --release
```

- [ ] iOS IPA 빌드
```bash
flutter build ios --release
```

---

## 🧪 통합 테스트

### 전체 플로우 테스트

1. [ ] **백오피스에서 LH 공고 수집**
   - 백오피스 로그인
   - "LH 공고 불러오기" 클릭
   - 성공 메시지 확인
   - 공고 목록에서 새 항목 확인

2. [ ] **데이터베이스 확인**
   - Supabase Studio 접속
   - `benefit_announcements` 테이블 확인
   - `external_id` 값 확인
   - `category_id`가 '주거' 카테고리인지 확인

3. [ ] **모바일 앱에서 확인**
   - Flutter 앱 실행
   - 주거 카테고리 선택
   - 공고 목록 표시 확인
   - 공고 상세 화면 확인
   - 조회수 증가 확인

---

## 📊 모니터링

### 배포 후 체크

- [ ] Edge Function 로그 확인
```bash
supabase functions logs fetch-lh-announcements
```

- [ ] 에러 모니터링
  - Supabase Dashboard > Edge Functions > Logs
  - 실패한 요청 확인
  - 응답 시간 확인

- [ ] 데이터 품질 확인
```sql
-- 최근 수집된 공고 확인
SELECT
  id,
  title,
  organization,
  external_id,
  status,
  created_at
FROM benefit_announcements
WHERE organization = 'LH 한국토지주택공사'
ORDER BY created_at DESC
LIMIT 10;

-- 중복 공고 확인 (external_id 기준)
SELECT external_id, COUNT(*)
FROM benefit_announcements
WHERE external_id IS NOT NULL
GROUP BY external_id
HAVING COUNT(*) > 1;
```

---

## 🚨 롤백 계획

### 문제 발생 시 롤백

1. **Edge Function 롤백**
```bash
# 이전 버전으로 되돌리기
supabase functions delete fetch-lh-announcements
```

2. **마이그레이션 롤백**
```sql
-- external_id 컬럼 제거
ALTER TABLE benefit_announcements DROP COLUMN IF EXISTS external_id;
```

3. **백오피스 롤백**
```bash
# Git에서 이전 커밋으로 되돌리기
git revert HEAD
npm run build
npm run deploy
```

---

## ✅ 최종 확인

- [ ] 모든 환경 변수 설정 완료
- [ ] 프로덕션 배포 완료
- [ ] 기능 테스트 통과
- [ ] 통합 테스트 통과
- [ ] 모니터링 설정 완료
- [ ] 롤백 계획 준비 완료
- [ ] 문서화 완료

---

## 📝 배포 후 작업

- [ ] 팀에 배포 완료 공지
- [ ] 사용자 가이드 작성
- [ ] 피드백 수집 계획 수립
- [ ] 다음 개선 사항 백로그 등록

---

**배포 책임자**: _________________
**배포 일시**: _________________
**검수자**: _________________

---

**체크리스트 버전**: 1.0.0
**마지막 업데이트**: 2024-10-24
